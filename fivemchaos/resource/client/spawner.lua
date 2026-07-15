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
local COUGAR_RELATIONSHIP = GetHashKey('CHAOS_COUGARS')
local PLAYER_RELATIONSHIP = GetHashKey('PLAYER')

-- Animals do not reliably inherit hostility toward network players.  Give
-- every director cougar an explicit enemy relationship once, rather than
-- hoping TaskCombatPed decides to pursue a player who is in a vehicle.
AddRelationshipGroup('CHAOS_COUGARS')
SetRelationshipBetweenGroups(5, COUGAR_RELATIONSHIP, PLAYER_RELATIONSHIP)
SetRelationshipBetweenGroups(5, PLAYER_RELATIONSHIP, COUGAR_RELATIONSHIP)

local function ThreatEntity(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    return vehicle ~= 0 and vehicle or ped, vehicle
end

local function IsMissionRunning()
    return MyState and MyState.phase == Phase.RUNNING
end

-- Client-owned player peds are authoritative for health changes.  Do not
-- try to damage another player's ped from the cougar owner's client: FiveM
-- will either drop that mutation or create a desync. Each player's targeted
-- cougars are spawned by that same player, so this covers the actual victim.
local function HurtLocalPlayer(ped, amount)
    if ped == PlayerPedId() and not IsEntityDead(ped) then
        ApplyDamageToPed(ped, amount, false)
    end
end

local function ClosestThreat(origin)
    local closestPed, closestTarget, closestVehicle
    local closestDist = math.huge
    for _, ped in ipairs(GetAllPlayerPeds()) do
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            local target, vehicle = ThreatEntity(ped)
            local distance = #(GetEntityCoords(target) - origin)
            if distance < closestDist then
                closestPed, closestTarget, closestVehicle, closestDist = ped, target, vehicle, distance
            end
        end
    end
    return closestPed, closestTarget, closestVehicle, closestDist
end

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

local function PursuePlayerLoop(ped)
    Citizen.CreateThread(function()
        local lastBiteAt = 0
        while DoesEntityExist(ped) and not IsEntityDead(ped) do
            if AIIsMine(ped) then
                local nearest = GetNearestPlayerPed(GetEntityCoords(ped))
                if nearest and nearest ~= 0 then
                    local targetEntity, targetVehicle = ThreatEntity(nearest)
                    local distance = #(GetEntityCoords(ped) - GetEntityCoords(targetEntity))

                    -- Do not ask an animal to enter the target vehicle. In
                    -- FiveM, combat task selection against a seated player
                    -- can also choose a flee/pathing branch. A short direct
                    -- sprint is refreshed every pass, so the cougar chases
                    -- the car's *current* position rather than picking an
                    -- unrelated ambient behaviour. On-foot targets still use
                    -- the normal animal combat animation.
                    if targetVehicle ~= 0 then
                        local targetPos = GetEntityCoords(targetVehicle)
                        local delta = targetPos - GetEntityCoords(ped)
                        local heading = GetHeadingFromVector_2d(delta.x, delta.y)
                        TaskGoStraightToCoord(ped, targetPos.x, targetPos.y, targetPos.z, 13.5, 750, heading, 1.0)
                    else
                        TaskCombatPed(ped, nearest, 0, 16)
                    end

                    if distance <= 3.0 then
                        -- A cougar that reaches a moving car cannot always
                        -- land GTA's normal melee animation. Apply a paced
                        -- bite so close contact remains a real threat rather
                        -- than harmless crowding around the vehicle.
                        local now = GetGameTimer()
                        if now - lastBiteAt >= 900 then
                            lastBiteAt = now
                            ApplyDamageToPed(nearest, targetVehicle ~= 0 and 18 or 28, false)
                            if targetVehicle ~= 0 and OwnershipGuard.IsOwner(targetVehicle) then
                                SetVehicleEngineHealth(targetVehicle, GetVehicleEngineHealth(targetVehicle) - 35.0)
                                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.35)
                            end
                        end
                    end
                    SetPedKeepTask(ped, true)
                end
            end
            Citizen.Wait(350)
        end
    end)
end

local function SpawnHostileCougar(pos)
    if not IsMissionRunning() then return nil end
    if not LoadModel(COUGAR_MODEL) then return nil end
    -- Model loading yields. A mission can end while this client is waiting,
    -- and a late entity would otherwise increment spawn load after the server
    -- has already reset the run.
    if not IsMissionRunning() then
        SetModelAsNoLongerNeeded(COUGAR_MODEL)
        return nil
    end
    local z = FindGround(pos.x, pos.y, pos.z)
    local cougar = CreatePed(28, COUGAR_MODEL, pos.x, pos.y, z, math.random(0, 360) + 0.0, true, true)
    if not DoesEntityExist(cougar) then return nil end

    ClaimOwner(cougar)

    -- Disable ALL flee behavior
    -- These are the attributes used by the original PedsHotCougars effect.
    -- Several speculative flags in the previous implementation prevented
    -- mountain lions from selecting their sprint-combat locomotion at all.
    SetPedFleeAttributes(cougar, 2, true)
    SetBlockingOfNonTemporaryEvents(cougar, true)
    SetPedAsEnemy(cougar, true)
    SetPedRelationshipGroupHash(cougar, COUGAR_RELATIONSHIP)

    SetPedCombatAttributes(cougar, 1, true)
    SetPedCombatAttributes(cougar, 3, true)

    -- Ignore vehicles — attack the player inside
    SetPedSeeingRange(cougar, 200.0)
    SetPedHearingRange(cougar, 200.0)
    SetPedAlertness(cougar, 3)

    local nearest = GetNearestPlayerPed(GetEntityCoords(cougar))
    TaskCombatPed(cougar, nearest or PlayerPedId(), 0, 16)
    SetModelAsNoLongerNeeded(COUGAR_MODEL)

    PursuePlayerLoop(cougar)
    return cougar
end

local function RegisterCougar(netId, entities, cougarType, pos, requestId)
    if type(netId) ~= 'number' or netId == 0 then return false end
    -- Final race guard for every variant. This covers entities whose custom
    -- setup yielded after mission end (particles/models, for example).
    if not IsMissionRunning() then
        for _, entity in ipairs(entities) do
            if DoesEntityExist(entity) then DeleteEntity(entity) end
        end
        return false
    end
    activeCougars[netId] = {entities = entities, type = cougarType}
    TriggerServerEvent('cc:cougar_spawned', netId, cougarType, pos, requestId)
    TriggerServerEvent('cc:spawn_load_inc')
    return true
end

-- Unified cleanup path. Called by:
--   - the per-type spawner thread when it detects the cougar is dead
--   - the cc:despawn_cougar handler (server-initiated despawn)
--   - the cc:despawn_all_cougars handler (mission end)
-- Claims `activeCougars[netId]` first so only one path fires the events
-- even if both race. The 3-second corpse delay has been removed: the engine
-- plays the death animation independently of entity existence.
local function Cleanup(netId)
    if type(netId) ~= 'number' then return end
    local data = activeCougars[netId]
    if not data then return end
    activeCougars[netId] = nil
    for _, ent in ipairs(data.entities) do
        if DoesEntityExist(ent) then DeleteEntity(ent) end
    end
    TriggerServerEvent('cc:cougar_dead', netId)
    TriggerServerEvent('cc:spawn_load_dec')
end

-- The server previously retained the original spawn coordinate forever.
-- A cougar that was actively chasing a fast vehicle was therefore cleaned
-- up as soon as the player was 250m from where it appeared. Report the
-- live position of each owner-driven threat at a modest cadence so the
-- director can despawn only enemies that are genuinely left behind.
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        for netId, data in pairs(activeCougars) do
            local entity = data.entities[1]
            if entity and DoesEntityExist(entity) and AIIsMine(entity) then
                local pos = GetEntityCoords(entity)
                TriggerServerEvent('cc:cougar_pos', netId, pos)
            end
        end
    end
end)

-- =====================================================================
-- Per-type spawners. Every variant takes `pos` and (optionally) returns
-- the primary entity for ownership claiming. AI/effect threads gate on
-- AIIsMine(ent) so they only fire from the canonical owner.
-- =====================================================================

-- FENCE: reverses velocity on hit, scales with speed
local function SpawnFence(pos, requestId)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'fence', pos, requestId)

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
local function SpawnCar(pos, requestId)
    local vehHash = `buffalo`
    local driverHash = `s_m_y_cop_01`
    if not LoadModel(vehHash) or not LoadModel(driverHash) or not LoadModel(COUGAR_MODEL) then return end
    if not IsMissionRunning() then
        SetModelAsNoLongerNeeded(vehHash)
        SetModelAsNoLongerNeeded(driverHash)
        SetModelAsNoLongerNeeded(COUGAR_MODEL)
        return
    end

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
    RegisterCougar(netId, {vehicle, driver, cougar}, 'car', pos, requestId)

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
local function SpawnShooter(pos, requestId)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end

    SetEntityHealth(cougar, 400)
    SetPedArmour(cougar, 100)
    SetEntityMaxSpeed(cougar, 7.0)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'shooter', pos, requestId)

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
                    local _, veh = ThreatEntity(ped)
                    if veh ~= 0 and OwnershipGuard.IsOwner(veh) then
                        ApplyForceToEntity(veh, 1, 0.0, 0.0, 8.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                        SetVehicleEngineHealth(veh, GetVehicleEngineHealth(veh) - 30.0)
                    end
                    HurtLocalPlayer(ped, 12)
                end
            end
            ::next::
        end
        Cleanup(netId)
    end)
end

-- JESUS: invincible jesus ped mounted on a tanky cougar with knockback aura
local function SpawnJesus(pos, requestId)
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
    RegisterCougar(netId, entities, 'jesus', pos, requestId)

    Citizen.CreateThread(function()
        local lastFireDrop = 0
        local lastBurnAt = {}
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
                local _, veh = ThreatEntity(ped)
                local target = veh ~= 0 and veh or ped
                local dist = #(GetEntityCoords(target) - cpos)
                if veh ~= 0 and OwnershipGuard.IsOwner(veh) then
                    local vpos = GetEntityCoords(veh)
                    if dist < 12.0 and dist > 1.0 then
                        local dir = vpos - cpos
                        dir = dir / #dir
                        local push = (12.0 - dist) / 12.0 * 1.5
                        ApplyForceToEntity(veh, 1, dir.x * push, dir.y * push, push * 0.3, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                        SetVehicleEngineHealth(veh, GetVehicleEngineHealth(veh) - 8.0)
                    end
                end
                if dist < 10.0 and now - (lastBurnAt[ped] or 0) >= 1000 then
                    lastBurnAt[ped] = now
                    HurtLocalPlayer(ped, 15)
                end
            end
            ::next::
        end
        Cleanup(netId)
    end)
end

-- BALL: physics launcher (blue=straight up, purple=directional yeet)
local function SpawnBall(pos, color, requestId)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end

    local ballHash = color == 'blue' and `prop_beach_ball_01` or `prop_beach_ball_02`
    LoadModel(ballHash)
    local ball = CreateObject(ballHash, pos.x, pos.y, pos.z + 1.0, true, true, false)
    ClaimOwner(ball)
    AttachEntityToEntity(ball, cougar, 0, 0.0, 0.0, 0.4, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    SetModelAsNoLongerNeeded(ballHash)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar, ball}, 'ball_' .. color, pos, requestId)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(50)
            -- Gate on BOTH cougar and ball ownership. ClaimOwner calls
            -- SetNetworkIdCanMigrate(false) for both, so this is normally
            -- instant, but if a migration ever slips through we want both
            -- entities to be ours before issuing physics effects.
            if not (AIIsMine(cougar) and AIIsMine(ball)) then goto next end
            for _, ped in ipairs(GetAllPlayerPeds()) do
                local target, veh = ThreatEntity(ped)
                if #(GetEntityCoords(cougar) - GetEntityCoords(target)) < 4.0 then
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
                    if veh == 0 then
                        if color == 'blue' then
                            ApplyForceToEntity(ped, 1, 0.0, 0.0, 30.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                        else
                            local dir = GetEntityCoords(ped) - GetEntityCoords(cougar)
                            dir = dir / #dir
                            ApplyForceToEntity(ped, 1, dir.x * 25.0, dir.y * 25.0, 10.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                        end
                        HurtLocalPlayer(ped, 20)
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
local function SpawnSwarm(pos, requestId)
    local entities = {}
    local count = 5
    for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local offset = vector3(math.cos(angle) * 12.0, math.sin(angle) * 12.0, 0)
        local spawnPos = pos + offset
        local cougar = SpawnHostileCougar(spawnPos)
        if cougar then
            SetEntityMaxSpeed(cougar, 14.0)
            SetEntityHealth(cougar, 120)
            local netId = NetworkGetNetworkIdFromEntity(cougar)
            if RegisterCougar(netId, {cougar}, 'swarm', spawnPos, requestId) then
                entities[#entities + 1] = {ped = cougar, netId = netId}
            else
                DeleteEntity(cougar)
            end
        end
    end

    if #entities == 0 then return end

    Citizen.CreateThread(function()
        while true do
            local alive = {}
            for _, entry in ipairs(entities) do
                if DoesEntityExist(entry.ped) and not IsEntityDead(entry.ped) then
                    alive[#alive + 1] = entry.ped
                end
            end
            if #alive == 0 then break end

            Citizen.Wait(6000)
        end
        for _, entry in ipairs(entities) do Cleanup(entry.netId) end
    end)
end

-- BOMBER: suicide runner, explodes when in range
local function SpawnBomber(pos, requestId)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end

    SetEntityHealth(cougar, 150)
    SetEntityMaxSpeed(cougar, 13.0)

    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do Citizen.Wait(10) end
    UseParticleFxAsset('core')
    local ptfx = StartParticleFxLoopedOnEntity('ent_amb_smoke_foundry', cougar, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, false, false, false)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'bomber', pos, requestId)

    Citizen.CreateThread(function()
        local beepRate = 1000
        local lastBeep = 0
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(50)
            if not AIIsMine(cougar) then goto next end
            local cpos = GetEntityCoords(cougar)
            local closestDist = 999.0

            for _, ped in ipairs(GetAllPlayerPeds()) do
                local target = ThreatEntity(ped)
                local dist = #(cpos - GetEntityCoords(target))
                if dist < closestDist then closestDist = dist end
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
                for _, ped in ipairs(GetAllPlayerPeds()) do
                    local target = ThreatEntity(ped)
                    if #(cpos - GetEntityCoords(target)) < 7.0 then HurtLocalPlayer(ped, 80) end
                end
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
local function SpawnPhantom(pos, requestId)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    SetEntityMaxSpeed(cougar, 11.0)
    SetEntityAlpha(cougar, 0, false)
    SetEntityHealth(cougar, 200)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'phantom', pos, requestId)

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

            if closestDist < 3.0 then
                if closestVeh ~= 0 and OwnershipGuard.IsOwner(closestVeh) then
                    local spin = math.random() > 0.5 and 15.0 or -15.0
                    ApplyForceToEntity(closestVeh, 1, 0.0, 0.0, 18.0, spin, spin * 0.5, 0.0, 0, true, true, true, false, true)
                    ShakeGameplayCam('DEATH_FAIL_IN_EFFECT_SHAKE', 2.5)
                end
                HurtLocalPlayer(closestPed, 35)
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
local function SpawnStun(pos, requestId)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    SetEntityMaxSpeed(cougar, 11.0)
    SetEntityHealth(cougar, 250)

    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do Citizen.Wait(10) end
    UseParticleFxAsset('core')
    local ptfx = StartParticleFxLoopedOnEntity('ent_amb_elec_crackle', cougar, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, false, false, false)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'stun', pos, requestId)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(50)
            if not AIIsMine(cougar) then goto next end
            for _, ped in ipairs(GetAllPlayerPeds()) do
                local target, veh = ThreatEntity(ped)
                if #(GetEntityCoords(cougar) - GetEntityCoords(target)) < 4.0 then
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
                    if veh == 0 then
                        SetPedToRagdoll(ped, 1500, 1500, 0, true, true, false)
                        HurtLocalPlayer(ped, 20)
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
local function SpawnMagnetic(pos, requestId)
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
    RegisterCougar(netId, {cougar}, 'magnetic', pos, requestId)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(100)
            if not AIIsMine(cougar) then goto next end
            local cpos = GetEntityCoords(cougar)
            for _, ped in ipairs(GetAllPlayerPeds()) do
                local target, veh = ThreatEntity(ped)
                local tpos = GetEntityCoords(target)
                local dist = #(tpos - cpos)
                if dist < 40.0 and dist > 3.0 then
                    local t = 1.0 - (dist / 40.0)
                    local strength = t * t * 35.0
                    local dir = cpos - tpos
                    dir = dir / #dir
                    if veh ~= 0 and OwnershipGuard.IsOwner(veh) then
                        ApplyForceToEntity(veh, 1, dir.x * strength, dir.y * strength, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                    end
                    if veh == 0 then ApplyForceToEntity(ped, 1, dir.x * strength, dir.y * strength, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true) end
                end
            end
            ::next::
        end
        StopParticleFxLooped(ptfx, false)
        Cleanup(netId)
    end)
end

-- POUNCER: a fast, telegraphed leap.  Staying close to it is dangerous, but
-- the attack has a recovery window so a driver can dodge it instead of simply
-- being deleted by an unavoidable contact hit.
local function SpawnPouncer(pos, requestId)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    SetEntityHealth(cougar, 500)
    SetPedArmour(cougar, 100)
    SetEntityMaxSpeed(cougar, 15.0)
    SetPedMoveRateOverride(cougar, 1.35)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'pouncer', pos, requestId)

    Citizen.CreateThread(function()
        local nextPounce = GetGameTimer() + 1200
        local pouncingUntil = 0
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(80)
            if not AIIsMine(cougar) then goto next end

            local cpos = GetEntityCoords(cougar)
            local ped, target, vehicle, distance = ClosestThreat(cpos)
            if not ped then goto next end
            local now = GetGameTimer()

            if pouncingUntil > now then
                if distance < 3.5 then
                    if vehicle ~= 0 and OwnershipGuard.IsOwner(vehicle) then
                        local dir = GetEntityCoords(vehicle) - cpos
                        if #dir > 0.1 then
                            dir = dir / #dir
                            ApplyForceToEntity(vehicle, 1, dir.x * 45.0, dir.y * 45.0, 24.0, 0.0, 0.0, 0.0, 0, false, true, false, false, true)
                        end
                        SetVehicleEngineHealth(vehicle, GetVehicleEngineHealth(vehicle) - 80.0)
                    else
                        SetPedToRagdoll(ped, 1300, 1300, 0, true, true, false)
                    end
                    HurtLocalPlayer(ped, 48)
                    ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 1.1)
                    SendNUIMessage({type = 'hit', variant = 'POUNCED!'})
                    pouncingUntil = 0
                    nextPounce = now + 3500
                end
            elseif now >= nextPounce and distance > 7.0 and distance < 28.0 then
                -- Face first, then leap: this is intentionally visible and
                -- gives alert drivers a fraction of a second to juke.
                TaskTurnPedToFaceEntity(cougar, target, 220)
                Citizen.Wait(240)
                if DoesEntityExist(cougar) and AIIsMine(cougar) then
                    cpos = GetEntityCoords(cougar)
                    local dir = GetEntityCoords(target) - cpos
                    if #dir > 0.1 then
                        dir = dir / #dir
                        -- ApplyForceToEntity defaults to local-space vectors
                        -- in this call shape.  A leap needs a world-space
                        -- direction, otherwise a turning cat can launch away
                        -- from its target. Direct velocity is deterministic
                        -- and is immediately followed by the normal combat AI.
                        SetEntityVelocity(cougar, dir.x * 18.0, dir.y * 18.0, 7.5)
                        pouncingUntil = GetGameTimer() + 1300
                        PlaySoundFrontend(-1, '5_SEC_WARNING', 'HUD_MINI_GAME_SOUNDSET', false)
                    end
                end
                nextPounce = GetGameTimer() + 3800
            end
            ::next::
        end
        Cleanup(netId)
    end)
end

-- LEECH: clings to a car and drains the engine and driver.  The counterplay
-- is to sustain motorway speed for a moment, which shakes it back onto the
-- road; abandoning the vehicle does not grant a free escape.
local function SpawnLeech(pos, requestId)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    SetEntityHealth(cougar, 450)
    SetPedArmour(cougar, 120)
    SetEntityMaxSpeed(cougar, 12.5)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'leech', pos, requestId)

    Citizen.CreateThread(function()
        local latched, latchVehicle, latchPed = false, 0, 0
        local latchedAt, shakeOffFor, lastDrain = 0, 0, 0
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(100)
            if not AIIsMine(cougar) then goto next end

            local now = GetGameTimer()
            if not latched then
                local ped, target, vehicle, distance = ClosestThreat(GetEntityCoords(cougar))
                if ped and distance < 3.0 then
                    latched, latchVehicle, latchPed = true, vehicle, ped
                    latchedAt, shakeOffFor, lastDrain = now, 0, now
                    ClearPedTasksImmediately(cougar)
                    if vehicle ~= 0 then
                        AttachEntityToEntity(cougar, vehicle, 0, 0.0, -1.55, 0.45, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                    end
                    SetEntityCollision(cougar, false, false)
                    SendNUIMessage({type = 'hit', variant = 'LEECH ATTACHED!'})
                end
            else
                local detach = now - latchedAt > 10000
                if latchVehicle ~= 0 and DoesEntityExist(latchVehicle) then
                    if GetEntitySpeed(latchVehicle) > 28.0 then
                        shakeOffFor = shakeOffFor + 100
                    else
                        shakeOffFor = 0
                    end
                    detach = detach or shakeOffFor >= 1500
                    if not detach and now - lastDrain >= 700 then
                        lastDrain = now
                        if OwnershipGuard.IsOwner(latchVehicle) then
                            SetVehicleEngineHealth(latchVehicle, GetVehicleEngineHealth(latchVehicle) - 24.0)
                        end
                        HurtLocalPlayer(latchPed, 7)
                    end
                elseif now - lastDrain >= 700 then
                    lastDrain = now
                    HurtLocalPlayer(latchPed, 12)
                end

                if detach then
                    if IsEntityAttached(cougar) then DetachEntity(cougar, true, true) end
                    SetEntityCollision(cougar, true, true)
                    latched, latchVehicle, latchPed = false, 0, 0
                    TaskCombatPed(cougar, GetNearestPlayerPed(GetEntityCoords(cougar)) or PlayerPedId(), 0, 16)
                    SendNUIMessage({type = 'hit', variant = shakeOffFor >= 1500 and 'LEECH SHAKEN!' or 'LEECH RELEASED!'})
                end
            end
            ::next::
        end
        if DoesEntityExist(cougar) and IsEntityAttached(cougar) then DetachEntity(cougar, true, true) end
        Cleanup(netId)
    end)
end

-- HOWLER: periodically sends a radial shockwave.  The brief warning tone is
-- the tell; getting clear of its radius is safer than trying to tank it.
local function SpawnHowler(pos, requestId)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    SetEntityHealth(cougar, 750)
    SetPedArmour(cougar, 250)
    SetEntityMaxSpeed(cougar, 8.0)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'howler', pos, requestId)

    Citizen.CreateThread(function()
        local nextHowl = GetGameTimer() + 2500
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(100)
            if not AIIsMine(cougar) then goto next end
            local cpos = GetEntityCoords(cougar)
            local _, _, _, nearest = ClosestThreat(cpos)
            local now = GetGameTimer()
            if nearest and nearest < 38.0 and now >= nextHowl then
                PlaySoundFrontend(-1, '5_SEC_WARNING', 'HUD_MINI_GAME_SOUNDSET', false)
                SendNUIMessage({type = 'hit', variant = 'INCOMING HOWL!'})
                Citizen.Wait(700)
                if DoesEntityExist(cougar) and AIIsMine(cougar) then
                    cpos = GetEntityCoords(cougar)
                    AddExplosion(cpos.x, cpos.y, cpos.z, 41, 0.0, false, false, 0.0)
                    for _, ped in ipairs(GetAllPlayerPeds()) do
                        local target, vehicle = ThreatEntity(ped)
                        local tpos = GetEntityCoords(target)
                        local distance = #(tpos - cpos)
                        if distance < 36.0 and distance > 0.5 then
                            local dir = (tpos - cpos) / distance
                            local force = 10.0 + (1.0 - distance / 36.0) * 32.0
                            if vehicle ~= 0 and OwnershipGuard.IsOwner(vehicle) then
                                ApplyForceToEntity(vehicle, 1, dir.x * force, dir.y * force, 10.0 + force * 0.25, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                                SetVehicleEngineHealth(vehicle, GetVehicleEngineHealth(vehicle) - 20.0)
                            elseif vehicle == 0 then
                                SetPedToRagdoll(ped, 1000, 1000, 0, true, true, false)
                            end
                            HurtLocalPlayer(ped, 18)
                        end
                    end
                    ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 1.5)
                end
                nextHowl = GetGameTimer() + 5200
            end
            ::next::
        end
        Cleanup(netId)
    end)
end

-- ALPHA: a rare final-stretch boss.  It does not use invincibility: damage
-- still matters. At half health it enrages, becomes faster, and its close
-- pulse turns into a serious car-control problem.
local function SpawnAlpha(pos, requestId)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    SetEntityHealth(cougar, 1400)
    SetPedArmour(cougar, 500)
    SetEntityMaxSpeed(cougar, 12.0)
    SetPedMoveRateOverride(cougar, 1.2)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'alpha', pos, requestId)

    Citizen.CreateThread(function()
        local enraged = false
        local nextPulse = GetGameTimer() + 2200
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(120)
            if not AIIsMine(cougar) then goto next end
            local now = GetGameTimer()
            if not enraged and GetEntityHealth(cougar) <= 700 then
                enraged = true
                SetEntityMaxSpeed(cougar, 17.0)
                SetPedMoveRateOverride(cougar, 1.49)
                PlaySoundFrontend(-1, 'RACE_PLACED', 'HUD_AWARDS', false)
                SendNUIMessage({type = 'hit', variant = 'ALPHA ENRAGED!'})
            end

            local cpos = GetEntityCoords(cougar)
            local ped, target, vehicle, distance = ClosestThreat(cpos)
            if ped and distance < (enraged and 22.0 or 16.0) and now >= nextPulse then
                local power = enraged and 55.0 or 34.0
                if vehicle ~= 0 and OwnershipGuard.IsOwner(vehicle) then
                    local dir = GetEntityCoords(vehicle) - cpos
                    if #dir > 0.1 then
                        dir = dir / #dir
                        ApplyForceToEntity(vehicle, 1, dir.x * power, dir.y * power, power * 0.45, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                    end
                    SetVehicleEngineHealth(vehicle, GetVehicleEngineHealth(vehicle) - (enraged and 55.0 or 32.0))
                else
                    SetPedToRagdoll(ped, 1300, 1300, 0, true, true, false)
                end
                HurtLocalPlayer(ped, enraged and 32 or 20)
                AddExplosion(cpos.x, cpos.y, cpos.z, 41, 0.0, false, false, 0.0)
                ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', enraged and 2.0 or 1.2)
                SendNUIMessage({type = 'hit', variant = enraged and 'ALPHA RAGE!' or 'ALPHA STRIKE!'})
                nextPulse = now + (enraged and 1900 or 3000)
            end
            ::next::
        end
        Cleanup(netId)
    end)
end

-- SPLITTER
-- Each gen cougar is registered in activeCougars individually, so:
--   - each gets its own balanced inc (RegisterCougar) and dec (Cleanup)
--   - Director.cougars tracks all 7 cougars, so CountCougars() is accurate
--   - the gen-1 cougar's death triggers gen-2 spawns in the per-type thread
local function SpawnSplitter(pos, requestId)
    local function SpawnGen(genPos, generation, spawnRequestId)
        local cougar = SpawnHostileCougar(genPos)
        if not cougar then return end

        local hp = generation == 1 and 350 or (generation == 2 and 180 or 100)
        SetEntityHealth(cougar, hp)
        SetEntityMaxSpeed(cougar, 7.0 + generation * 3.0)

        -- Register this cougar individually so the server can count it
        -- toward the spawn cap and so the inc/dec pair is balanced.
        local netId = NetworkGetNetworkIdFromEntity(cougar)
        RegisterCougar(netId, {cougar}, 'splitter', genPos, spawnRequestId)

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
                    SpawnGen(deathPos + offset, generation + 1, spawnRequestId)
                end
            end
            Cleanup(netId)
        end)
    end

    SpawnGen(pos, 1, requestId)
end

-- =====================================================================
-- DISPATCH
-- =====================================================================

local Spawners = {
    fence       = SpawnFence,
    car         = SpawnCar,
    shooter     = SpawnShooter,
    jesus       = SpawnJesus,
    ball_blue   = function(pos, requestId) SpawnBall(pos, 'blue', requestId) end,
    ball_purple = function(pos, requestId) SpawnBall(pos, 'purple', requestId) end,
    swarm       = SpawnSwarm,
    bomber      = SpawnBomber,
    phantom     = SpawnPhantom,
    stun        = SpawnStun,
    magnetic    = SpawnMagnetic,
    pouncer     = SpawnPouncer,
    leech       = SpawnLeech,
    howler      = SpawnHowler,
    alpha       = SpawnAlpha,
    splitter    = SpawnSplitter,
}

RegisterNetEvent('cc:spawn_cougar', function(cougarType, pos, targetPlayerId, requestId)
    if type(cougarType) ~= 'string' or type(requestId) ~= 'string' or requestId == '' then return end
    local spawner = Spawners[cougarType]
    if not spawner then return end
    local myServerId = GetPlayerServerId(PlayerId())
    -- Server tells us which client is the AI driver. The entity itself was
    -- created networked and syncs to every client; the AI thread is what we
    -- want to keep singular.
    if targetPlayerId and targetPlayerId ~= -1 and targetPlayerId ~= myServerId then
        return -- observer; entity is already networked from the owner client
    end
    spawner(pos, requestId)
end)

RegisterNetEvent('cc:despawn_cougar', function(netId)
    if type(netId) ~= 'number' then return end
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
