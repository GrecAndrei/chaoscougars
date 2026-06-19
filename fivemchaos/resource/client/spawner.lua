-- __COUGAR_OWNER_LOCK_PATCH__
-- All cougar entities are claimed by the TARGET client for the lifetime of
-- the spawn. AI/effect threads gate on AIIsMine(ent) which uses
-- NetworkHasControlOfEntity + (when needed) NetworkRequestControlOfEntity +
-- a 1s wait, so even mid-game migration is recovered from.
--
-- AIIsMine is defined as a global in client/ownership.lua so it can be
-- shared with client/effects_spawn.lua (RetargetSpawnedPed) and any other
-- script that drives cougar / spawned-ped AI.
local activeCougars = {}
local COUGAR_MODEL = `a_c_mtlion`

-- =====================================================================
-- OWNERSHIP HELPERS
-- =====================================================================

-- Run by whichever client the server says is the AI driver. Locks the
-- network id to that client and stops migration.
local function ClaimOwner(ent)
    if not DoesEntityExist(ent) then return end
    local netId = ObjToNet(ent)
    if netId and netId ~= 0 then
        SetNetworkIdCanMigrate(netId, false)
    end
    SetEntityAsMissionEntity(ent, true, true)
end

-- =====================================================================
-- UTILITIES
-- =====================================================================

local function LoadModel(hash)
    RequestModel(hash)
    local t = 50
    while not HasModelLoaded(hash) and t > 0 do
        Citizen.Wait(100)
        t = t - 1
    end
    return HasModelLoaded(hash)
end

local function FindGround(x, y, z)
    -- Try descending offsets; use the first one that returns a real hit
    -- (the `found` boolean, not the z value, is the ground-truth signal —
    --  z=0 is a valid sea-level result and must NOT be filtered out).
    for _, offset in ipairs({100.0, 50.0, 20.0, 0.0}) do
        local found, groundZ = GetGroundZFor_3dCoord(x, y, z + offset, false)
        if found then return groundZ + 1.0 end
    end
    return z
end

local function RetargetLoop(ped, intervalMs)
    intervalMs = intervalMs or 3000
    Citizen.CreateThread(function()
        while DoesEntityExist(ped) and not IsEntityDead(ped) do
            if AIIsMine(ped) then
                local nearest = GetNearestPlayerPed(GetEntityCoords(ped))
                if nearest and nearest ~= 0 then
                    ClearPedTasks(ped)
                    Citizen.Wait(0)
                    TaskCombatPed(ped, nearest, 0, 16)
                    SetPedKeepTask(ped, true)
                end
            end
            Citizen.Wait(intervalMs)
        end
    end)
end

local function SpawnHostileCougar(pos)
    if not LoadModel(COUGAR_MODEL) then return nil end
    local z = FindGround(pos.x, pos.y, pos.z)
    local cougar = CreatePed(28, COUGAR_MODEL, pos.x, pos.y, z, math.random(0, 360) + 0.0, true, true)
    if not DoesEntityExist(cougar) then return nil end

    ClaimOwner(cougar)

    -- Disable ALL flee behavior
    SetPedFleeAttributes(cougar, 0, false)
    SetPedConfigFlag(cougar, 292, true)   -- disable flee from armed ped
    SetPedConfigFlag(cougar, 2, false)    -- not a wimp
    SetPedConfigFlag(cougar, 281, true)   -- disable writhe
    SetBlockingOfNonTemporaryEvents(cougar, true)
    SetPedAsEnemy(cougar, true)

    -- Max aggression
    SetPedCombatAttributes(cougar, 46, true)  -- always fight
    SetPedCombatAttributes(cougar, 5, true)   -- can fight armed peds
    SetPedCombatAttributes(cougar, 0, false)  -- don't use cover
    SetPedCombatAttributes(cougar, 2, true)   -- can investigate
    SetPedCombatAttributes(cougar, 3, true)   -- can flank
    SetPedCombatAttributes(cougar, 20, true)  -- can taunt
    SetPedCombatAttributes(cougar, 52, true)  -- aggressive
    SetPedCombatAttributes(cougar, 58, true)  -- disable flee
    SetPedCombatAbility(cougar, 2)
    SetPedCombatRange(cougar, 2)
    SetPedCombatMovement(cougar, 3)

    -- Ignore vehicles — attack the player inside
    SetPedSeeingRange(cougar, 200.0)
    SetPedHearingRange(cougar, 200.0)
    SetPedAlertness(cougar, 3)

    local nearest = GetNearestPlayerPed(GetEntityCoords(cougar))
    TaskCombatPed(cougar, nearest or PlayerPedId(), 0, 16)
    SetModelAsNoLongerNeeded(COUGAR_MODEL)

    RetargetLoop(cougar, 3000)
    return cougar
end

local function RegisterCougar(netId, entities, cougarType, pos)
    activeCougars[netId] = {entities = entities, type = cougarType}
    TriggerServerEvent('cc:cougar_spawned', netId, cougarType, pos)
    TriggerServerEvent('cc:spawn_load_inc')
end

-- Unified cleanup path. Called by:
--   - the per-type spawner thread when it detects the cougar is dead
--   - the cc:despawn_cougar handler (server-initiated despawn)
--   - the cc:despawn_all_cougars handler (mission end)
-- Claims `activeCougars[netId]` first so only one path fires the events
-- even if both race. The 3-second corpse delay has been removed: the engine
-- plays the death animation independently of entity existence.
local function Cleanup(netId)
    local data = activeCougars[netId]
    if not data then return end
    activeCougars[netId] = nil
    for _, ent in ipairs(data.entities) do
        if DoesEntityExist(ent) then DeleteEntity(ent) end
    end
    TriggerServerEvent('cc:cougar_dead', netId)
    TriggerServerEvent('cc:spawn_load_dec')
end

-- =====================================================================
-- Per-type spawners. Every variant takes `pos` and (optionally) returns
-- the primary entity for ownership claiming. AI/effect threads gate on
-- AIIsMine(ent) so they only fire from the canonical owner.
-- =====================================================================

-- FENCE: reverses velocity on hit, scales with speed
local function SpawnFence(pos)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'fence', pos)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(50)
            if not AIIsMine(cougar) then goto next end
            for _, ped in ipairs(GetAllPlayerPeds()) do
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 and #(GetEntityCoords(cougar) - GetEntityCoords(veh)) < 3.5 then
                    if OwnershipGuard.IsOwner(veh) then
                        local vel = GetEntityVelocity(veh)
                        local speed = #vel
                        local mult = math.min(1.2, speed / 25.0)
                        SetEntityVelocity(veh, -vel.x * 0.8 * mult, -vel.y * 0.8 * mult, vel.z + 5.0)
                        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.2)
                    end
                    SetEntityHealth(cougar, 0)
                    SendNUIMessage({type = 'hit', variant = 'REVERSED!'})
                    break
                end
            end
            ::next::
        end
        Cleanup(netId)
    end)
end

-- CAR: AI driver rams player, honks aggressively
local function SpawnCar(pos)
    local vehHash = `buffalo`
    local driverHash = `s_m_y_cop_01`
    if not LoadModel(vehHash) or not LoadModel(driverHash) or not LoadModel(COUGAR_MODEL) then return end

    local z = FindGround(pos.x, pos.y, pos.z)
    local vehicle = CreateVehicle(vehHash, pos.x, pos.y, z, math.random(0, 360) + 0.0, true, true)
    SetVehicleOnGroundProperly(vehicle)
    ModifyVehicleTopSpeed(vehicle, 30.0)
    SetVehicleColours(vehicle, 0, 0) -- black
    ClaimOwner(vehicle)

    local driver = CreatePedInsideVehicle(vehicle, 26, driverHash, -1, true, true)
    ClaimOwner(driver)
    SetEntityVisible(driver, false, false)

    local cougar = CreatePed(28, COUGAR_MODEL, pos.x, pos.y, z, 0.0, true, true)
    TaskWarpPedIntoVehicle(cougar, vehicle, 0)

    local nearest = GetNearestPlayerPed(pos)
    TaskVehicleChase(driver, nearest or PlayerPedId())
    SetTaskVehicleChaseBehaviorFlag(driver, 32, true)
    SetTaskVehicleChaseIdealPursuitDistance(driver, 0.0)

    SetModelAsNoLongerNeeded(vehHash)
    SetModelAsNoLongerNeeded(driverHash)
    SetModelAsNoLongerNeeded(COUGAR_MODEL)

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    RegisterCougar(netId, {vehicle, driver, cougar}, 'car', pos)

    Citizen.CreateThread(function()
        local hornTimer = 0
        while DoesEntityExist(vehicle) and IsVehicleDriveable(vehicle, false) do
            if AIIsMine(driver) then
                local target = GetNearestPlayerPed(GetEntityCoords(vehicle))
                if target then
                    TaskVehicleChase(driver, target)
                    SetTaskVehicleChaseBehaviorFlag(driver, 32, true)
                    SetTaskVehicleChaseIdealPursuitDistance(driver, 0.0)
                end
                hornTimer = hornTimer + 1
                if hornTimer % 3 == 0 then
                    StartVehicleHorn(vehicle, 800, GetHashKey('NORMAL'), false)
                end
            end
            Citizen.Wait(3000)
        end
        Cleanup(netId)
    end)
end

-- SHOOTER: ranged cougar - periodically damages nearby players
local function SpawnShooter(pos)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end

    SetEntityHealth(cougar, 400)
    SetPedArmour(cougar, 100)
    SetEntityMaxSpeed(cougar, 7.0)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'shooter', pos)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(2000)
            if not AIIsMine(cougar) then goto next end

            local cpos = GetEntityCoords(cougar)
            for _, ped in ipairs(GetAllPlayerPeds()) do
                local ppos = GetEntityCoords(ped)
                local dist = #(cpos - ppos)
                if dist > 8.0 and dist < 45.0 then
                    RequestNamedPtfxAsset('core')
                    if HasNamedPtfxAssetLoaded('core') then
                        UseParticleFxAsset('core')
                        StartParticleFxNonLoopedAtCoord('ent_sht_flame', cpos.x, cpos.y, cpos.z + 0.5, 0.0, 0.0, 0.0, 0.6, false, false, false)
                    end
                    Citizen.Wait(300)
                    local veh = GetVehiclePedIsIn(ped, false)
                    if veh ~= 0 and OwnershipGuard.IsOwner(veh) then
                        ApplyForceToEntity(veh, 1, 0.0, 0.0, 8.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                    end
                end
            end
            ::next::
        end
        Cleanup(netId)
    end)
end

-- JESUS: invincible jesus ped mounted on a tanky cougar with knockback aura
local function SpawnJesus(pos)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    SetEntityHealth(cougar, 1000)
    SetPedArmour(cougar, 500)

    local jesusHash = `u_m_y_jesus01`
    local entities = {cougar}

    if LoadModel(jesusHash) then
        local z = FindGround(pos.x, pos.y, pos.z)
        local jesus = CreatePed(26, jesusHash, pos.x, pos.y, z, 0.0, true, true)
        ClaimOwner(jesus)
        AttachEntityToEntity(jesus, cougar, 0, 0.0, -0.1, 0.7, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        SetEntityInvincible(jesus, true)
        SetModelAsNoLongerNeeded(jesusHash)
        entities[#entities + 1] = jesus
    end

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, entities, 'jesus', pos)

    Citizen.CreateThread(function()
        local lastFireDrop = 0
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(100)
            if not AIIsMine(cougar) then goto next end
            local cpos = GetEntityCoords(cougar)

            local now = GetGameTimer()
            if now - lastFireDrop > 2000 then
                StartScriptFire(cpos.x, cpos.y, cpos.z, 3, false)
                lastFireDrop = now
            end

            for _, ped in ipairs(GetAllPlayerPeds()) do
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 and OwnershipGuard.IsOwner(veh) then
                    local vpos = GetEntityCoords(veh)
                    local dist = #(vpos - cpos)
                    if dist < 12.0 and dist > 1.0 then
                        local dir = vpos - cpos
                        dir = dir / #dir
                        local push = (12.0 - dist) / 12.0 * 1.5
                        ApplyForceToEntity(veh, 1, dir.x * push, dir.y * push, push * 0.3, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                    end
                end
            end
            ::next::
        end
        Cleanup(netId)
    end)
end

-- BALL: physics launcher (blue=straight up, purple=directional yeet)
local function SpawnBall(pos, color)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end

    local ballHash = color == 'blue' and `prop_beach_ball_01` or `prop_beach_ball_02`
    LoadModel(ballHash)
    local ball = CreateObject(ballHash, pos.x, pos.y, pos.z + 1.0, true, true, false)
    ClaimOwner(ball)
    AttachEntityToEntity(ball, cougar, 0, 0.0, 0.0, 0.4, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    SetModelAsNoLongerNeeded(ballHash)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar, ball}, 'ball_' .. color, pos)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(50)
            -- Gate on BOTH cougar and ball ownership. ClaimOwner calls
            -- SetNetworkIdCanMigrate(false) for both, so this is normally
            -- instant, but if a migration ever slips through we want both
            -- entities to be ours before issuing physics effects.
            if not (AIIsMine(cougar) and AIIsMine(ball)) then goto next end
            for _, ped in ipairs(GetAllPlayerPeds()) do
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 and #(GetEntityCoords(cougar) - GetEntityCoords(veh)) < 4.0 then
                    if OwnershipGuard.IsOwner(veh) then
                        if color == 'blue' then
                            ApplyForceToEntity(veh, 1, 0.0, 0.0, 55.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                        else
                            local dir = GetEntityCoords(veh) - GetEntityCoords(cougar)
                            dir = dir / #dir
                            ApplyForceToEntity(veh, 1, dir.x * 40.0, dir.y * 40.0, 18.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                        end
                        ShakeGameplayCam('MEDIUM_EXPLOSION_SHAKE', 1.5)
                    end
                    SetEntityHealth(cougar, 0)
                    SendNUIMessage({type = 'hit', variant = color == 'blue' and 'LAUNCHED!' or 'YEETED!'})
                    break
                end
            end
            ::next::
        end
        Cleanup(netId)
    end)
end

-- SWARM: coordinated pack of 5
local function SpawnSwarm(pos)
    local entities = {}
    local count = 5
    for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local offset = vector3(math.cos(angle) * 12.0, math.sin(angle) * 12.0, 0)
        local cougar = SpawnHostileCougar(pos + offset)
        if cougar then
            SetEntityMaxSpeed(cougar, 14.0)
            SetEntityHealth(cougar, 120)
            entities[#entities + 1] = cougar
        end
    end

    if #entities == 0 then return end

    local netId = NetworkGetNetworkIdFromEntity(entities[1])
    RegisterCougar(netId, entities, 'swarm', pos)

    Citizen.CreateThread(function()
        while true do
            local alive = {}
            for _, c in ipairs(entities) do
                if DoesEntityExist(c) and not IsEntityDead(c) then
                    alive[#alive + 1] = c
                end
            end
            if #alive == 0 then break end

            -- Per-cougar ownership gate. If a single cougar's ownership
            -- has migrated, only skip task assignment for THAT cougar; the
            -- rest still get their flanking/combat tasks. This avoids the
            -- single-point-of-failure where one migration froze the whole
            -- swarm.
            local target = GetNearestPlayerPed(GetEntityCoords(alive[1]))
            if target and target ~= 0 then
                local tpos = GetEntityCoords(target)
                for i, c in ipairs(alive) do
                    if AIIsMine(c) then
                        local angle = (i / #alive) * math.pi * 2
                        local flankPos = tpos + vector3(math.cos(angle) * 8.0, math.sin(angle) * 8.0, 0)
                        TaskGoToCoordAnyMeans(c, flankPos.x, flankPos.y, flankPos.z, 3.0, 0, false, 786603, 0.0)
                        Citizen.Wait(200)
                        TaskCombatPed(c, target, 0, 16)
                    end
                end
            end
            Citizen.Wait(6000)
        end
        Cleanup(netId)
    end)
end

-- BOMBER: suicide runner, explodes when in range
local function SpawnBomber(pos)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end

    SetEntityHealth(cougar, 150)
    SetEntityMaxSpeed(cougar, 13.0)

    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do Citizen.Wait(10) end
    UseParticleFxAsset('core')
    local ptfx = StartParticleFxLoopedOnEntity('ent_amb_smoke_foundry', cougar, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, false, false, false)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'bomber', pos)

    Citizen.CreateThread(function()
        local beepRate = 1000
        local lastBeep = 0
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(50)
            if not AIIsMine(cougar) then goto next end
            local cpos = GetEntityCoords(cougar)
            local closestDist = 999.0

            for _, ped in ipairs(GetAllPlayerPeds()) do
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 then
                    local dist = #(cpos - GetEntityCoords(veh))
                    if dist < closestDist then closestDist = dist end
                end
            end

            if closestDist < 30.0 then
                beepRate = math.max(100, math.floor(closestDist / 30.0 * 800))
                local now = GetGameTimer()
                if now - lastBeep > beepRate then
                    PlaySoundFromEntity(-1, 'Beep_Red', cougar, 'DLC_HEIST_HACKING_SNAKE_SOUNDS', false, 0)
                    lastBeep = now
                end
            end

            if closestDist < 5.0 then
                AddExplosion(cpos.x, cpos.y, cpos.z, 2, 10.0, true, false, 1.2)
                SetEntityHealth(cougar, 0)
                ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 2.0)
                SendNUIMessage({type = 'hit', variant = 'BOOM!'})
                break
            end
            ::next::
        end
        StopParticleFxLooped(ptfx, false)
        Cleanup(netId)
    end)
end

-- PHANTOM: invisible stalker
local function SpawnPhantom(pos)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    SetEntityMaxSpeed(cougar, 11.0)
    SetEntityAlpha(cougar, 0, false)
    SetEntityHealth(cougar, 200)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'phantom', pos)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(80)
            if not AIIsMine(cougar) then goto next end
            local cpos = GetEntityCoords(cougar)
            local closestDist = 999.0
            local closestVeh = 0
            local closestPed = 0

            for _, ped in ipairs(GetAllPlayerPeds()) do
                local dist = #(cpos - GetEntityCoords(ped))
                if dist < closestDist then
                    closestDist = dist
                    closestPed = ped
                    closestVeh = GetVehiclePedIsIn(ped, false)
                end
            end

            if closestDist < 8.0 then
                SetEntityAlpha(cougar, 220, false)
            elseif closestDist < 20.0 then
                local flicker = math.random() > 0.7 and 120 or 0
                SetEntityAlpha(cougar, flicker, false)
            else
                SetEntityAlpha(cougar, 0, false)
            end

            if closestDist < 3.0 and closestVeh ~= 0 then
                if OwnershipGuard.IsOwner(closestVeh) then
                    local spin = math.random() > 0.5 and 15.0 or -15.0
                    ApplyForceToEntity(closestVeh, 1, 0.0, 0.0, 18.0, spin, spin * 0.5, 0.0, 0, true, true, true, false, true)
                    ShakeGameplayCam('DEATH_FAIL_IN_EFFECT_SHAKE', 2.5)
                end
                SendNUIMessage({type = 'hit', variant = 'BOO!'})
                PlaySoundFrontend(-1, 'CHARACTERS_ACTIVE', 'HUD_AWARDS', false)
                SetEntityHealth(cougar, 0)
            end
            ::next::
        end
        Cleanup(netId)
    end)
end

-- STUN: EMP cougar
local function SpawnStun(pos)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    SetEntityMaxSpeed(cougar, 11.0)
    SetEntityHealth(cougar, 250)

    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do Citizen.Wait(10) end
    UseParticleFxAsset('core')
    local ptfx = StartParticleFxLoopedOnEntity('ent_amb_elec_crackle', cougar, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, false, false, false)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'stun', pos)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(50)
            if not AIIsMine(cougar) then goto next end
            for _, ped in ipairs(GetAllPlayerPeds()) do
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 and #(GetEntityCoords(cougar) - GetEntityCoords(veh)) < 4.0 then
                    if OwnershipGuard.IsOwner(veh) then
                        FreezeEntityPosition(veh, true)
                        SetVehicleEngineOn(veh, false, true, true)
                        SetVehicleUndriveable(veh, true)
                        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.5)

                        local vpos = GetEntityCoords(veh)
                        if HasNamedPtfxAssetLoaded('core') then
                            UseParticleFxAsset('core')
                            StartParticleFxNonLoopedAtCoord('ent_amb_elec_crackle', vpos.x, vpos.y, vpos.z, 0.0, 0.0, 0.0, 2.0, false, false, false)
                        end

                        SetTimeout(4000, function()
                            if DoesEntityExist(veh) then
                                FreezeEntityPosition(veh, false)
                                SetVehicleUndriveable(veh, false)
                                SetVehicleEngineOn(veh, true, false, true)
                            end
                        end)
                    end
                    SendNUIMessage({type = 'hit', variant = 'EMP!'})
                    SetEntityHealth(cougar, 0)
                    break
                end
            end
            ::next::
        end
        StopParticleFxLooped(ptfx, false)
        Cleanup(netId)
    end)
end

-- MAGNETIC: gravity well
local function SpawnMagnetic(pos)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    SetEntityHealth(cougar, 600)
    SetPedArmour(cougar, 200)
    SetEntityMaxSpeed(cougar, 5.0)

    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do Citizen.Wait(10) end
    UseParticleFxAsset('core')
    local ptfx = StartParticleFxLoopedOnEntity('ent_amb_elec_crackle', cougar, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'magnetic', pos)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(100)
            if not AIIsMine(cougar) then goto next end
            local cpos = GetEntityCoords(cougar)
            for _, ped in ipairs(GetAllPlayerPeds()) do
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 and OwnershipGuard.IsOwner(veh) then
                    local vpos = GetEntityCoords(veh)
                    local dist = #(vpos - cpos)
                    if dist < 40.0 and dist > 3.0 then
                        local t = 1.0 - (dist / 40.0)
                        local strength = t * t * 2.0
                        local dir = cpos - vpos
                        dir = dir / #dir
                        ApplyForceToEntity(veh, 1, dir.x * strength, dir.y * strength, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                    end
                end
            end
            ::next::
        end
        StopParticleFxLooped(ptfx, false)
        Cleanup(netId)
    end)
end

-- SPLITTER
-- Each gen cougar is registered in activeCougars individually, so:
--   - each gets its own balanced inc (RegisterCougar) and dec (Cleanup)
--   - Director.cougars tracks all 7 cougars, so CountCougars() is accurate
--   - the gen-1 cougar's death triggers gen-2 spawns in the per-type thread
local function SpawnSplitter(pos)
    local function SpawnGen(genPos, generation)
        local cougar = SpawnHostileCougar(genPos)
        if not cougar then return end

        local hp = generation == 1 and 350 or (generation == 2 and 180 or 100)
        SetEntityHealth(cougar, hp)
        SetEntityMaxSpeed(cougar, 7.0 + generation * 3.0)

        -- Register this cougar individually so the server can count it
        -- toward the spawn cap and so the inc/dec pair is balanced.
        local netId = NetworkGetNetworkIdFromEntity(cougar)
        RegisterCougar(netId, {cougar}, 'splitter', genPos)

        Citizen.CreateThread(function()
            while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
                Citizen.Wait(500)
            end

            -- Death path: spawn children, then clean up. Cleanup fires
            -- cc:cougar_dead and cc:spawn_load_dec.
            if generation < 3 and DoesEntityExist(cougar) and AIIsMine(cougar) then
                local deathPos = GetEntityCoords(cougar)
                AddExplosion(deathPos.x, deathPos.y, deathPos.z, 41, 0.5, true, false, 0.3)
                Citizen.Wait(400)
                for i = 1, 2 do
                    local angle = math.random() * math.pi * 2
                    local offset = vector3(math.cos(angle) * 3.0, math.sin(angle) * 3.0, 0)
                    SpawnGen(deathPos + offset, generation + 1)
                end
            end
            Cleanup(netId)
        end)
    end

    SpawnGen(pos, 1)
end

-- =====================================================================
-- DISPATCH
-- =====================================================================

local Spawners = {
    fence       = SpawnFence,
    car         = SpawnCar,
    shooter     = SpawnShooter,
    jesus       = SpawnJesus,
    ball_blue   = function(pos) SpawnBall(pos, 'blue') end,
    ball_purple = function(pos) SpawnBall(pos, 'purple') end,
    swarm       = SpawnSwarm,
    bomber      = SpawnBomber,
    phantom     = SpawnPhantom,
    stun        = SpawnStun,
    magnetic    = SpawnMagnetic,
    splitter    = SpawnSplitter,
}

RegisterNetEvent('cc:spawn_cougar', function(cougarType, pos, targetPlayerId)
    local spawner = Spawners[cougarType] or SpawnFence
    local myServerId = GetPlayerServerId(PlayerId())
    -- Server tells us which client is the AI driver. The entity itself was
    -- created networked and syncs to every client; the AI thread is what we
    -- want to keep singular.
    if targetPlayerId and targetPlayerId ~= -1 and targetPlayerId ~= myServerId then
        return -- observer; entity is already networked from the owner client
    end
    spawner(pos)
end)

RegisterNetEvent('cc:despawn_cougar', function(netId)
    Cleanup(netId)
end)

RegisterNetEvent('cc:despawn_all_cougars', function()
    -- Snapshot keys because Cleanup mutates activeCougars
    local keys = {}
    for netId in pairs(activeCougars) do keys[#keys + 1] = netId end
    for _, netId in ipairs(keys) do
        Cleanup(netId)
    end
end)
