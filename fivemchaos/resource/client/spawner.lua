local activeCougars = {}
local COUGAR_MODEL = `a_c_panther`

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
    for _, offset in ipairs({100.0, 50.0, 20.0, 0.0}) do
        local found, groundZ = GetGroundZFor_3dCoord(x, y, z + offset, false)
        if found and groundZ > 0.0 then return groundZ + 1.0 end
    end
    return z
end

local function RetargetLoop(ped, intervalMs)
    intervalMs = intervalMs or 3000
    Citizen.CreateThread(function()
        while DoesEntityExist(ped) and not IsEntityDead(ped) do
            if OwnershipGuard.IsOwner(ped) then
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

    -- Disable ALL flee behavior
    SetPedFleeAttributes(cougar, 0, false)
    SetPedConfigFlag(cougar, 292, true)   -- disable flee from armed ped
    SetPedConfigFlag(cougar, 2, false)    -- not a wimp
    SetPedConfigFlag(cougar, 281, true)   -- disable writhe
    SetBlockingOfNonTemporaryEvents(cougar, true)

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

local function Cleanup(netId)
    local data = activeCougars[netId]
    if not data then return end
    Citizen.Wait(3000)
    for _, ent in ipairs(data.entities) do
        if DoesEntityExist(ent) then DeleteEntity(ent) end
    end
    activeCougars[netId] = nil
    TriggerServerEvent('cc:cougar_dead', netId)
    TriggerServerEvent('cc:spawn_load_dec')
end

-- =====================================================================
-- FENCE: reverses velocity on hit, scales with speed
-- =====================================================================
local function SpawnFence(pos)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'fence', pos)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(50)
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
        end
        Cleanup(netId)
    end)
end

-- =====================================================================
-- CAR: AI driver rams player, honks aggressively
-- =====================================================================
local function SpawnCar(pos)
    local vehHash = `buffalo`
    local driverHash = `s_m_y_cop_01`
    if not LoadModel(vehHash) or not LoadModel(driverHash) or not LoadModel(COUGAR_MODEL) then return end

    local z = FindGround(pos.x, pos.y, pos.z)
    local vehicle = CreateVehicle(vehHash, pos.x, pos.y, z, math.random(0, 360) + 0.0, true, true)
    SetVehicleOnGroundProperly(vehicle)
    ModifyVehicleTopSpeed(vehicle, 30.0)
    SetVehicleColours(vehicle, 0, 0) -- black

    local driver = CreatePedInsideVehicle(vehicle, 26, driverHash, -1, true, true)
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
            if OwnershipGuard.IsOwner(driver) then
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

-- =====================================================================
-- SHOOTER: ranged cougar - periodically damages nearby players
-- (animals can't hold weapons, so we simulate ranged spit attacks)
-- =====================================================================
local function SpawnShooter(pos)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end

    SetEntityHealth(cougar, 400)
    SetPedArmour(cougar, 100)
    SetEntityMaxSpeed(cougar, 7.0) -- slower, keeps distance

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'shooter', pos)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(2000)
            if not OwnershipGuard.IsOwner(cougar) then goto next end

            local cpos = GetEntityCoords(cougar)
            for _, ped in ipairs(GetAllPlayerPeds()) do
                local ppos = GetEntityCoords(ped)
                local dist = #(cpos - ppos)
                if dist > 8.0 and dist < 45.0 then
                    -- Projectile visual
                    RequestNamedPtfxAsset('core')
                    if HasNamedPtfxAssetLoaded('core') then
                        UseParticleFxAsset('core')
                        StartParticleFxNonLoopedAtCoord('ent_sht_flame', cpos.x, cpos.y, cpos.z + 0.5, 0.0, 0.0, 0.0, 0.6, false, false, false)
                    end
                    Citizen.Wait(300)
                    -- Damage the player
                    local veh = GetVehiclePedIsIn(ped, false)
                    if veh ~= 0 and OwnershipGuard.IsOwner(veh) then
                        ApplyForceToEntity(veh, 1, 0.0, 0.0, 2.5, math.random(-2,2)+0.0, 0.0, 0.0, 0, true, true, true, false, true)
                    end
                    break
                end
            end
            ::next::
        end
        Cleanup(netId)
    end)
end

-- =====================================================================
-- JESUS: holy cougar - AOE fire trail + knockback aura
-- =====================================================================
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
            local cpos = GetEntityCoords(cougar)

            -- Fire trail every 2s
            local now = GetGameTimer()
            if now - lastFireDrop > 2000 and OwnershipGuard.IsOwner(cougar) then
                StartScriptFire(cpos.x, cpos.y, cpos.z, 3, false)
                lastFireDrop = now
            end

            -- Knockback aura: push vehicles away within 12m
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
        end
        Cleanup(netId)
    end)
end

-- =====================================================================
-- BALL: physics launcher (blue=straight up, purple=directional yeet)
-- =====================================================================
local function SpawnBall(pos, color)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end

    local ballHash = color == 'blue' and `prop_beach_ball_01` or `prop_beach_ball_02`
    LoadModel(ballHash)
    local ball = CreateObject(ballHash, pos.x, pos.y, pos.z + 1.0, true, true, false)
    AttachEntityToEntity(ball, cougar, 0, 0.0, 0.0, 0.4, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    SetModelAsNoLongerNeeded(ballHash)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar, ball}, 'ball_' .. color, pos)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(50)
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
        end
        Cleanup(netId)
    end)
end

-- =====================================================================
-- SWARM: coordinated pack of 5 - they surround and converge
-- =====================================================================
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

    -- Coordinated flanking: every few seconds they reposition to surround target
    Citizen.CreateThread(function()
        while true do
            local alive = {}
            for _, c in ipairs(entities) do
                if DoesEntityExist(c) and not IsEntityDead(c) then
                    alive[#alive + 1] = c
                end
            end
            if #alive == 0 then break end

            if OwnershipGuard.IsOwner(alive[1]) then
                local target = GetNearestPlayerPed(GetEntityCoords(alive[1]))
                if target and target ~= 0 then
                    local tpos = GetEntityCoords(target)
                    for i, c in ipairs(alive) do
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

-- =====================================================================
-- BOMBER: suicide runner, explodes when in range. Beeps as warning.
-- =====================================================================
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
            local cpos = GetEntityCoords(cougar)
            local closestDist = 999.0

            for _, ped in ipairs(GetAllPlayerPeds()) do
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 then
                    local dist = #(cpos - GetEntityCoords(veh))
                    if dist < closestDist then closestDist = dist end
                end
            end

            -- Beep faster as it gets closer
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
        end
        StopParticleFxLooped(ptfx, false)
        Cleanup(netId)
    end)
end

-- =====================================================================
-- PHANTOM: invisible stalker, flickers when close, instant-kills on touch
-- =====================================================================
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

            -- Visibility: flickers in 20m, solid in 8m
            if closestDist < 8.0 then
                SetEntityAlpha(cougar, 220, false)
            elseif closestDist < 20.0 then
                -- Flicker
                local flicker = math.random() > 0.7 and 120 or 0
                SetEntityAlpha(cougar, flicker, false)
            else
                SetEntityAlpha(cougar, 0, false)
            end

            -- Strike: vehicle gets launched + spun
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
        end
        Cleanup(netId)
    end)
end

-- =====================================================================
-- STUN: EMP cougar - freezes vehicle + disables engine temporarily
-- =====================================================================
local function SpawnStun(pos)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    SetEntityMaxSpeed(cougar, 11.0)
    SetEntityHealth(cougar, 250)

    -- Blue tint to signal electric type
    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do Citizen.Wait(10) end
    UseParticleFxAsset('core')
    local ptfx = StartParticleFxLoopedOnEntity('ent_amb_elec_crackle', cougar, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, false, false, false)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'stun', pos)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(50)
            for _, ped in ipairs(GetAllPlayerPeds()) do
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 and #(GetEntityCoords(cougar) - GetEntityCoords(veh)) < 4.0 then
                    if OwnershipGuard.IsOwner(veh) then
                        FreezeEntityPosition(veh, true)
                        SetVehicleEngineOn(veh, false, true, true)
                        SetVehicleUndriveable(veh, true)
                        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 1.5)

                        -- EMP burst visual
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
        end
        StopParticleFxLooped(ptfx, false)
        Cleanup(netId)
    end)
end

-- =====================================================================
-- MAGNETIC: gravity well - pulls vehicles in with increasing force
-- =====================================================================
local function SpawnMagnetic(pos)
    local cougar = SpawnHostileCougar(pos)
    if not cougar then return end
    SetEntityHealth(cougar, 600)
    SetPedArmour(cougar, 200)
    SetEntityMaxSpeed(cougar, 5.0) -- slow, acts like a turret

    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do Citizen.Wait(10) end
    UseParticleFxAsset('core')
    local ptfx = StartParticleFxLoopedOnEntity('ent_amb_elec_crackle', cougar, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)

    local netId = NetworkGetNetworkIdFromEntity(cougar)
    RegisterCougar(netId, {cougar}, 'magnetic', pos)

    Citizen.CreateThread(function()
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            Citizen.Wait(100) -- 100ms not 50ms, halved force application rate
            local cpos = GetEntityCoords(cougar)
            for _, ped in ipairs(GetAllPlayerPeds()) do
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 and OwnershipGuard.IsOwner(veh) then
                    local vpos = GetEntityCoords(veh)
                    local dist = #(vpos - cpos)
                    if dist < 40.0 and dist > 3.0 then
                        -- Quadratic falloff so it's gentle at range, strong up close
                        local t = 1.0 - (dist / 40.0)
                        local strength = t * t * 2.0
                        local dir = cpos - vpos
                        dir = dir / #dir
                        ApplyForceToEntity(veh, 1, dir.x * strength, dir.y * strength, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                    end
                end
            end
        end
        StopParticleFxLooped(ptfx, false)
        Cleanup(netId)
    end)
end

-- =====================================================================
-- SPLITTER: splits into 2 on death, up to generation 3 (max 7 total)
-- =====================================================================
local function SpawnSplitter(pos)
    local allEntities = {}

    local function SpawnGen(genPos, generation)
        local cougar = SpawnHostileCougar(genPos)
        if not cougar then return end

        local hp = generation == 1 and 350 or (generation == 2 and 180 or 100)
        SetEntityHealth(cougar, hp)
        SetEntityMaxSpeed(cougar, 7.0 + generation * 3.0)

        allEntities[#allEntities + 1] = cougar

        if generation == 1 then
            local netId = NetworkGetNetworkIdFromEntity(cougar)
            RegisterCougar(netId, allEntities, 'splitter', genPos)
        end

        Citizen.CreateThread(function()
            while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
                Citizen.Wait(500)
            end

            if generation < 3 and DoesEntityExist(cougar) then
                local deathPos = GetEntityCoords(cougar)
                -- Visual: small explosion on split
                AddExplosion(deathPos.x, deathPos.y, deathPos.z, 41, 0.5, true, false, 0.3)
                Citizen.Wait(400)
                for i = 1, 2 do
                    local angle = math.random() * math.pi * 2
                    local offset = vector3(math.cos(angle) * 3.0, math.sin(angle) * 3.0, 0)
                    SpawnGen(deathPos + offset, generation + 1)
                end
            end
        end)
    end

    SpawnGen(pos, 1)
end

-- =====================================================================
-- DISPATCH
-- =====================================================================
local Spawners = {
    fence = SpawnFence,
    car = SpawnCar,
    shooter = SpawnShooter,
    jesus = SpawnJesus,
    ball_blue = function(pos) SpawnBall(pos, 'blue') end,
    ball_purple = function(pos) SpawnBall(pos, 'purple') end,
    swarm = SpawnSwarm,
    bomber = SpawnBomber,
    phantom = SpawnPhantom,
    stun = SpawnStun,
    magnetic = SpawnMagnetic,
    splitter = SpawnSplitter,
}

RegisterNetEvent('cc:spawn_cougar', function(cougarType, pos)
    local spawner = Spawners[cougarType] or SpawnFence
    spawner(pos)
end)

RegisterNetEvent('cc:despawn_cougar', function(netId)
    local data = activeCougars[netId]
    if data then
        for _, ent in ipairs(data.entities) do
            if DoesEntityExist(ent) then DeleteEntity(ent) end
        end
        activeCougars[netId] = nil
    end
end)

RegisterNetEvent('cc:despawn_all_cougars', function()
    for _, data in pairs(activeCougars) do
        for _, ent in ipairs(data.entities) do
            if DoesEntityExist(ent) then DeleteEntity(ent) end
        end
    end
    activeCougars = {}
end)
