--[[
    Effect implementations. Each function is called by string name from server.
    Timed effects receive alive() — return false to signal cleanup.
    Instant effects receive nothing, fire once.
]]

local activeTimers = {}

RegisterNetEvent('cc:trigger_effect', function(id, name, fnName, instant, duration)
    SendNUIMessage({type = 'effect', id = id, name = name, duration = instant and 0 or duration})

    local fn = _G[fnName]
    if not fn then return end

    if instant then
        fn()
    else
        -- Cancel existing instance of same effect
        if activeTimers[id] then activeTimers[id]() end

        local running = true
        activeTimers[id] = function() running = false end

        Citizen.CreateThread(function()
            fn(function() return running end)
            activeTimers[id] = nil
        end)

        SetTimeout(duration * 1000, function()
            running = false
        end)
    end
end)

RegisterNetEvent('cc:clear_effects', function()
    for _, cancel in pairs(activeTimers) do cancel() end
    activeTimers = {}
    -- Hard reset common state
    ClearTimecycleModifier()
    SetTimeScale(1.0)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    SetNightvision(false)
    SetSeethrough(false)
    SetGravityLevel(0)
    RenderScriptCams(false, false, 0, true, true)
    StopGameplayCamShaking(true)
    ClearWeatherTypePersist()
    local ped = PlayerPedId()
    SetEntityInvincible(ped, false)
    ResetPedMovementClipset(ped, 0.0)
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        SetVehicleEnginePowerMultiplier(veh, 1.0)
        SetVehicleReduceGrip(veh, false)
    end
    SendNUIMessage({type = 'effects_cleared'})
end)

-- =====================================================================
-- GRAVITY
-- =====================================================================
function FX_LowGravity(alive)
    while alive() do SetGravityLevel(1); Citizen.Wait(0) end
    SetGravityLevel(0)
end

function FX_VeryLowGravity(alive)
    while alive() do SetGravityLevel(2); Citizen.Wait(0) end
    SetGravityLevel(0)
end

function FX_HighGravity(alive)
    while alive() do SetGravityLevel(3); Citizen.Wait(0) end
    SetGravityLevel(0)
end

function FX_MoonGravity(alive)
    while alive() do
        SetGravityLevel(2)
        -- Also give vehicles a gentle upward push
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 and not IsEntityInAir(veh) then
            ApplyForceToEntity(veh, 1, 0.0, 0.0, 1.5, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
        Citizen.Wait(200)
    end
    SetGravityLevel(0)
end

-- =====================================================================
-- VEHICLE
-- =====================================================================
function FX_SlipperyCars(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then SetVehicleReduceGrip(veh, true) end
        Citizen.Wait(100)
    end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then SetVehicleReduceGrip(veh, false) end
end

function FX_BouncyCars(alive)
    while alive() do
        local vehicles = GetGamePool('CVehicle')
        for _, veh in ipairs(vehicles) do
            if DoesEntityExist(veh) and not IsEntityInAir(veh) and math.random() < 0.03 then
                ApplyForceToEntity(veh, 1, 0.0, 0.0, math.random(8, 15) + 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end
        Citizen.Wait(50)
    end
end

function FX_TurboCars(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then SetVehicleEnginePowerMultiplier(veh, 200.0) end
        Citizen.Wait(0)
    end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then SetVehicleEnginePowerMultiplier(veh, 1.0) end
end

function FX_SlowCars(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then SetVehicleEnginePowerMultiplier(veh, -50.0) end
        Citizen.Wait(0)
    end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then SetVehicleEnginePowerMultiplier(veh, 1.0) end
end

function FX_Turbo10x(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then SetVehicleEnginePowerMultiplier(veh, 1000.0) end
        Citizen.Wait(0)
    end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then SetVehicleEnginePowerMultiplier(veh, 1.0) end
end

function FX_HonkBoost(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 and IsHornActive(veh) then
            local fwd = GetEntityForwardVector(veh)
            ApplyForceToEntity(veh, 1, fwd.x * 50.0, fwd.y * 50.0, 2.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
        Citizen.Wait(0)
    end
end

function FX_BrakeBoost(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 and IsControlPressed(0, 72) then -- Brake
            local fwd = GetEntityForwardVector(veh)
            ApplyForceToEntity(veh, 1, fwd.x * 40.0, fwd.y * 40.0, 1.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
        Citizen.Wait(0)
    end
end

function FX_FlyingCars(alive)
    while alive() do
        Citizen.Wait(0)
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh == 0 then goto cont end

        local class = GetVehicleClass(veh)
        if class == 15 or class == 16 then goto cont end

        local speed = GetEntitySpeed(veh)
        if speed < 5.0 then goto cont end

        local fwd = GetEntityForwardVector(veh)
        local deltaSpeed = 10.0 * GetFrameTime()
        local vel = GetEntityVelocity(veh)

        DisableControlAction(0, 68, true)
        DisableControlAction(0, 69, true)

        if IsControlPressed(0, 71) then -- Accel
            vel = vector3(fwd.x * (speed + deltaSpeed), fwd.y * (speed + deltaSpeed), vel.z)
        end

        SetEntityVelocity(veh, vel.x, vel.y, vel.z)

        local rot = GetEntityRotation(veh, 2)
        local deltaAngle = 80.0 * GetFrameTime()

        if IsControlPressed(0, 63) then rot = vector3(rot.x, rot.y, rot.z + deltaAngle) end  -- Left
        if IsControlPressed(0, 64) then rot = vector3(rot.x, rot.y, rot.z - deltaAngle) end  -- Right
        if IsControlPressed(0, 108) then rot = vector3(rot.x, rot.y - deltaAngle, rot.z) end -- Roll L
        if IsControlPressed(0, 109) then rot = vector3(rot.x, rot.y + deltaAngle, rot.z) end -- Roll R
        if IsControlPressed(0, 111) then rot = vector3(rot.x - deltaAngle, rot.y, rot.z) end -- Pitch D
        if IsControlPressed(0, 112) then rot = vector3(rot.x + deltaAngle, rot.y, rot.z) end -- Pitch U

        SetEntityRotation(veh, rot.x, rot.y, rot.z, 2, true)
        ::cont::
    end
end

function FX_FlipCars()
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) then
            local rot = GetEntityRotation(veh, 2)
            SetEntityRotation(veh, rot.x + 180.0, rot.y, rot.z, 2, true)
        end
    end
end

function FX_LaunchCars()
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) then
            ApplyForceToEntity(veh, 1, 0.0, 0.0, 40.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
    end
end

function FX_PopTires()
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        for i = 0, 7 do SetVehicleTyreBurst(veh, i, true, 1000.0) end
    end
end

function FX_ExplodeOnImpact(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 and HasEntityCollidedWithAnything(veh) and GetEntitySpeed(veh) > 12.0 then
            ExplodeVehicle(veh, true, false)
        end
        Citizen.Wait(50)
    end
end

function FX_Beyblade(alive)
    while alive() do
        local count = 0
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and GetEntitySpeed(veh) > 3.0 then
                local isPlayerVeh = GetVehiclePedIsIn(PlayerPedId(), false) == veh
                if not isPlayerVeh then
                    SetEntityInvincible(veh, true)
                    SetVehicleReduceGrip(veh, true)
                    ApplyForceToEntity(veh, 3, 100.0, 0.0, 0.0, 0.0, 4.0, 0.0, 0, true, true, true, true, true)
                    ApplyForceToEntity(veh, 3, -100.0, 0.0, 0.0, 0.0, -4.0, 0.0, 0, true, true, true, true, true)
                end
            end
            count = count + 1
            if count % 5 == 0 then Citizen.Wait(0) end
        end
        Citizen.Wait(0)
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        SetEntityInvincible(veh, false)
        SetVehicleReduceGrip(veh, false)
    end
end

function FX_CruiseControl(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then
            local speed = GetEntitySpeed(veh)
            if speed > 5.0 then
                local fwd = GetEntityForwardVector(veh)
                SetEntityVelocity(veh, fwd.x * speed, fwd.y * speed, GetEntityVelocity(veh).z)
            end
        end
        Citizen.Wait(0)
    end
end

function FX_NoSteering(alive)
    while alive() do
        DisableControlAction(0, 59, true)  -- Steer left/right
        Citizen.Wait(0)
    end
end

function FX_InvincibleCars(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then
            SetEntityInvincible(veh, true)
            SetVehicleFixed(veh)
        end
        Citizen.Wait(500)
    end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then SetEntityInvincible(veh, false) end
end

function FX_LockDoors()
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        SetVehicleDoorsLocked(veh, 2)
    end
    SetTimeout(15000, function()
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            SetVehicleDoorsLocked(veh, 0)
        end
    end)
end

function FX_FullAccel(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then
            SetControlNormal(0, 71, 1.0) -- Full throttle
        end
        Citizen.Wait(0)
    end
end

function FX_SpeedLimit(alive)
    local limit = 13.4  -- ~30 mph
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 and GetEntitySpeed(veh) > limit then
            local fwd = GetEntityForwardVector(veh)
            SetEntityVelocity(veh, fwd.x * limit, fwd.y * limit, GetEntityVelocity(veh).z)
        end
        Citizen.Wait(0)
    end
end

-- =====================================================================
-- PLAYER
-- =====================================================================
function FX_SuperJump(alive)
    while alive() do SetSuperJumpThisFrame(PlayerId()); Citizen.Wait(0) end
end

function FX_SuperSpeed(alive)
    SetRunSprintMultiplierForPlayer(PlayerId(), 3.0)
    while alive() do Citizen.Wait(500) end
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end

function FX_Drunk(alive)
    local ped = PlayerPedId()
    SetPedIsDrunk(ped, true)
    RequestAnimSet('move_m@drunk@verydrunk')
    while not HasAnimSetLoaded('move_m@drunk@verydrunk') do Citizen.Wait(10) end
    SetPedMovementClipset(ped, 'move_m@drunk@verydrunk', 1.0)
    while alive() do
        SetPedConfigFlag(ped, 100, true)
        ShakeGameplayCam('DRUNK_SHAKE', 0.5)
        Citizen.Wait(100)
    end
    ResetPedMovementClipset(ped, 0.0)
    SetPedIsDrunk(ped, false)
    StopGameplayCamShaking(true)
end

function FX_Ragdoll()
    SetPedToRagdoll(PlayerPedId(), 4000, 4000, 0, false, false, false)
end

function FX_IgnitePlayer()
    StartEntityFire(PlayerPedId())
end

function FX_LaunchPlayer()
    local ped = PlayerPedId()
    SetPedToRagdoll(ped, 3000, 3000, 0, false, false, false)
    Citizen.Wait(100)
    ApplyForceToEntity(ped, 1, 0.0, 0.0, 75.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
end

function FX_GiveWeapon()
    local weapons = {
        `WEAPON_PISTOL`, `WEAPON_SMG`, `WEAPON_ASSAULTRIFLE`,
        `WEAPON_SNIPERRIFLE`, `WEAPON_RPG`, `WEAPON_GRENADELAUNCHER`,
        `WEAPON_MINIGUN`, `WEAPON_COMBATMG`, `WEAPON_RAILGUN`,
        `WEAPON_MUSKET`, `WEAPON_DBSHOTGUN`,
    }
    GiveWeaponToPed(PlayerPedId(), weapons[math.random(#weapons)], 200, false, true)
end

function FX_NoSprint(alive)
    while alive() do DisableControlAction(0, 21, true); Citizen.Wait(0) end
end

function FX_Forcefield(alive)
    while alive() do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for _, entity in ipairs(GetGamePool('CPed')) do
            if entity ~= ped and DoesEntityExist(entity) then
                local epos = GetEntityCoords(entity)
                local dist = #(pos - epos)
                if dist < 15.0 and dist > 0.1 then
                    local force = (15.0 - dist) / 15.0 * 100.0
                    local dir = epos - pos
                    dir = dir / #dir
                    if not IsPedRagdoll(entity) then
                        SetPedToRagdoll(entity, 3000, 3000, 0, true, true, false)
                    end
                    ApplyForceToEntity(entity, 3, dir.x * force, dir.y * force, dir.z * force + 5.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
                end
            end
        end

        for _, entity in ipairs(GetGamePool('CVehicle')) do
            if not IsPedInVehicle(ped, entity, false) and DoesEntityExist(entity) then
                local epos = GetEntityCoords(entity)
                local dist = #(pos - epos)
                if dist < 15.0 and dist > 0.1 then
                    local force = (15.0 - dist) / 15.0 * 80.0
                    local dir = epos - pos
                    dir = dir / #dir
                    ApplyForceToEntity(entity, 3, dir.x * force, dir.y * force, dir.z * force, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
                end
            end
        end

        Citizen.Wait(0)
    end
end

function FX_Invincible(alive)
    SetEntityInvincible(PlayerPedId(), true)
    while alive() do Citizen.Wait(500) end
    SetEntityInvincible(PlayerPedId(), false)
end

function FX_Bees(alive)
    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do Citizen.Wait(10) end
    UseParticleFxAsset('core')
    local ptfx = StartParticleFxLoopedOnEntity('ent_amb_fly_swarm', PlayerPedId(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, false, false, false)

    while alive() do
        if math.random(1, 80) == 1 then
            ApplyDamageToPed(PlayerPedId(), 2, false)
            SetTimecycleModifier('damage')
            SetTimeout(200, ClearTimecycleModifier)
        end
        Citizen.Wait(0)
    end

    StopParticleFxLooped(ptfx, false)
    RemoveNamedPtfxAsset('core')
end

function FX_KeepRunning(alive)
    while alive() do
        local ped = PlayerPedId()
        if not IsPedInAnyVehicle(ped, false) then
            SetControlNormal(0, 32, 1.0) -- Forward
            SetControlNormal(0, 21, 1.0) -- Sprint
        end
        Citizen.Wait(0)
    end
end

function FX_HeavyRecoil(alive)
    while alive() do
        if IsPedShooting(PlayerPedId()) then
            local ped = PlayerPedId()
            ApplyForceToEntity(ped, 1, 0.0, -8.0, 3.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
        Citizen.Wait(0)
    end
end

function FX_RapidFire(alive)
    while alive() do
        if IsControlPressed(0, 24) then -- Attack
            DisablePlayerFiring(PlayerId(), false)
            local ped = PlayerPedId()
            local _, weapon = GetCurrentPedWeapon(ped, true)
            if weapon ~= `WEAPON_UNARMED` then
                local camCoord = GetGameplayCamCoord()
                local camRot = GetGameplayCamRot(2)
                local dir = RotToDir(camRot)
                local dest = camCoord + dir * 200.0
                ShootSingleBulletBetweenCoords(camCoord.x, camCoord.y, camCoord.z, dest.x, dest.y, dest.z, 5, true, weapon, ped, true, false, 2000.0)
            end
        end
        Citizen.Wait(50)
    end
end

function FX_OneHitKO(alive)
    while alive() do
        SetEntityMaxHealth(PlayerPedId(), 1)
        SetEntityHealth(PlayerPedId(), 1)
        Citizen.Wait(0)
    end
    SetEntityMaxHealth(PlayerPedId(), 200)
    SetEntityHealth(PlayerPedId(), 200)
end

function FX_ClonePlayer()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    ClonePed(ped, true, false, false)
end

function FX_JesusTakeTheWheel()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then return end

    local jesusHash = `u_m_y_jesus01`
    RequestModel(jesusHash)
    while not HasModelLoaded(jesusHash) do Citizen.Wait(10) end

    SetPedIntoVehicle(ped, veh, 0) -- Move player to passenger

    local jesus = CreatePedInsideVehicle(veh, 4, jesusHash, -1, true, false)
    SetEntityProofs(jesus, true, false, false, false, false, false, false, false)
    SetBlockingOfNonTemporaryEvents(jesus, true)
    SetPedKeepTask(jesus, true)

    if IsWaypointActive() then
        local wp = GetBlipCoords(GetFirstBlipInfoId(8))
        TaskVehicleDriveToCoordLongrange(jesus, veh, wp.x, wp.y, wp.z, 80.0, 262668, 0.0)
    else
        TaskVehicleDriveWander(jesus, veh, 80.0, 4176732)
    end

    SetModelAsNoLongerNeeded(jesusHash)
end

function FX_CantMoveForward(alive)
    while alive() do DisableControlAction(0, 32, true); Citizen.Wait(0) end
end

-- =====================================================================
-- PEDS
-- =====================================================================
function FX_PedRiot(alive)
    while alive() do
        for _, p in ipairs(GetGamePool('CPed')) do
            if p ~= PlayerPedId() and not IsPedInCombat(p, 0) then
                TaskCombatHatedTargetsAroundPed(p, 100.0, 0)
            end
        end
        Citizen.Wait(3000)
    end
end

function FX_PedAttack(alive)
    while alive() do
        local ped = PlayerPedId()
        for _, p in ipairs(GetGamePool('CPed')) do
            if p ~= ped then TaskCombatPed(p, ped, 0, 16) end
        end
        Citizen.Wait(5000)
    end
end

function FX_PedFlee()
    for _, p in ipairs(GetGamePool('CPed')) do
        if p ~= PlayerPedId() then
            TaskSmartFleePed(p, PlayerPedId(), 200.0, -1, false, false)
        end
    end
end

function FX_PedExplode(alive)
    while alive() do
        for _, p in ipairs(GetGamePool('CPed')) do
            if p ~= PlayerPedId() and IsEntityDead(p) then
                local pos = GetEntityCoords(p)
                AddExplosion(pos.x, pos.y, pos.z, 2, 4.0, true, false, 0.5)
                DeleteEntity(p)
            end
        end
        Citizen.Wait(300)
    end
end

function FX_PedWeapons()
    local weps = {`WEAPON_PISTOL`, `WEAPON_MICROSMG`, `WEAPON_BAT`, `WEAPON_KNIFE`, `WEAPON_SHOTGUN`}
    for _, p in ipairs(GetGamePool('CPed')) do
        if p ~= PlayerPedId() then
            GiveWeaponToPed(p, weps[math.random(#weps)], 200, false, true)
        end
    end
end

function FX_PedRockets()
    for _, p in ipairs(GetGamePool('CPed')) do
        if p ~= PlayerPedId() then
            GiveWeaponToPed(p, `WEAPON_RPG`, 10, false, true)
        end
    end
end

function FX_PedRagdoll()
    for _, p in ipairs(GetGamePool('CPed')) do
        if p ~= PlayerPedId() then
            SetPedToRagdoll(p, 5000, 5000, 0, false, false, false)
        end
    end
end

function FX_SpawnKillerClowns()
    local pos = GetEntityCoords(PlayerPedId())
    local hash = `s_m_y_clown_01`
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(10) end
    for i = 1, 4 do
        local x = pos.x + math.random(-15, 15)
        local y = pos.y + math.random(-15, 15)
        local p = CreatePed(4, hash, x, y, pos.z, math.random(0, 360) + 0.0, true, true)
        GiveWeaponToPed(p, `WEAPON_MACHETE`, 1, false, true)
        TaskCombatPed(p, PlayerPedId(), 0, 16)
        SetPedFleeAttributes(p, 0, false)
        SetBlockingOfNonTemporaryEvents(p, true)
    end
    SetModelAsNoLongerNeeded(hash)
end

function FX_SpawnJuggernaut()
    local pos = GetEntityCoords(PlayerPedId())
    local hash = `u_m_y_juggernaut_01`
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(10) end
    local p = CreatePed(4, hash, pos.x + 10, pos.y + 10, pos.z, 0.0, true, true)
    SetEntityHealth(p, 2000)
    SetPedArmour(p, 500)
    GiveWeaponToPed(p, `WEAPON_MINIGUN`, 9999, false, true)
    TaskCombatPed(p, PlayerPedId(), 0, 16)
    SetPedFleeAttributes(p, 0, false)
    SetBlockingOfNonTemporaryEvents(p, true)
    SetModelAsNoLongerNeeded(hash)
end

function FX_SpawnAngryJesus()
    local pos = GetEntityCoords(PlayerPedId())
    local hash = `u_m_y_jesus01`
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(10) end
    local p = CreatePed(4, hash, pos.x + 8, pos.y, pos.z, 0.0, true, true)
    SetEntityHealth(p, 500)
    GiveWeaponToPed(p, `WEAPON_RAILGUN`, 50, false, true)
    TaskCombatPed(p, PlayerPedId(), 0, 16)
    SetPedFleeAttributes(p, 0, false)
    SetBlockingOfNonTemporaryEvents(p, true)
    SetPedAccuracy(p, 70)
    SetModelAsNoLongerNeeded(hash)
end

-- =====================================================================
-- SCREEN / VISUAL
-- =====================================================================
function FX_FlipScreen(alive)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    RenderScriptCams(true, true, 500, true, true)
    while alive() do
        local pos = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        SetCamCoord(cam, pos.x, pos.y, pos.z)
        SetCamRot(cam, rot.x, rot.y, rot.z + 180.0, 2)
        SetCamFov(cam, GetGameplayCamFov())
        Citizen.Wait(0)
    end
    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(cam, false)
end

function FX_QuakeFOV(alive)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    RenderScriptCams(true, true, 300, true, true)
    while alive() do
        local pos = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        SetCamCoord(cam, pos.x, pos.y, pos.z)
        SetCamRot(cam, rot.x, rot.y, rot.z, 2)
        SetCamFov(cam, 120.0)
        Citizen.Wait(0)
    end
    RenderScriptCams(false, true, 300, true, true)
    DestroyCam(cam, false)
end

function FX_NightVision(alive)
    SetNightvision(true)
    while alive() do Citizen.Wait(500) end
    SetNightvision(false)
end

function FX_HeatVision(alive)
    SetSeethrough(true)
    while alive() do Citizen.Wait(500) end
    SetSeethrough(false)
end

function FX_LSD(alive)
    SetTimecycleModifier('drugslean')
    SetTimecycleModifierStrength(1.5)
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_Noir(alive)
    SetTimecycleModifier('NG_filmic01')
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_DeepFried(alive)
    SetTimecycleModifier('spectator5')
    SetTimecycleModifierStrength(2.0)
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_NoHUD(alive)
    while alive() do HideHudAndRadarThisFrame(); Citizen.Wait(0) end
end

function FX_FogScreen(alive)
    SetTimecycleModifier('FogGreenLight')
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_ExtremeBright(alive)
    SetTimecycleModifier('WhiteOut')
    SetTimecycleModifierStrength(1.0)
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_ExtremeDark(alive)
    SetArtificialLightsState(true)
    while alive() do Citizen.Wait(500) end
    SetArtificialLightsState(false)
end

-- =====================================================================
-- WEATHER
-- =====================================================================
function FX_Storm(alive)
    SetWeatherTypeNowPersist('THUNDER')
    while alive() do Citizen.Wait(1000) end
    ClearWeatherTypePersist()
end

function FX_Fog(alive)
    SetWeatherTypeNowPersist('FOGGY')
    while alive() do Citizen.Wait(1000) end
    ClearWeatherTypePersist()
end

function FX_Snow(alive)
    SetWeatherTypeNowPersist('XMAS')
    while alive() do Citizen.Wait(1000) end
    ClearWeatherTypePersist()
end

function FX_DiscoWeather(alive)
    local weathers = {'EXTRASUNNY', 'THUNDER', 'FOGGY', 'XMAS', 'OVERCAST', 'RAIN', 'CLEARING'}
    while alive() do
        SetWeatherTypeNow(weathers[math.random(#weathers)])
        Citizen.Wait(500)
    end
    ClearWeatherTypePersist()
end

-- =====================================================================
-- TIME
-- =====================================================================
function FX_SlowMo(alive)
    SetTimeScale(0.3)
    while alive() do Citizen.Wait(500) end
    SetTimeScale(1.0)
end

function FX_FastMo(alive)
    SetTimeScale(2.0)
    while alive() do Citizen.Wait(500) end
    SetTimeScale(1.0)
end

function FX_VeryFast(alive)
    SetTimeScale(5.0)
    while alive() do Citizen.Wait(500) end
    SetTimeScale(1.0)
end

-- =====================================================================
-- MISC
-- =====================================================================
function FX_Earthquake(alive)
    while alive() do
        ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 0.08)
        local shook = math.random() * 14.0 - 7.0
        for _, entity in ipairs(GetGamePool('CVehicle')) do
            ApplyForceToEntity(entity, 1, 0.0, 0.0, shook, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
        for _, entity in ipairs(GetGamePool('CObject')) do
            ApplyForceToEntity(entity, 1, 0.0, 0.0, shook * 0.5, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
        Citizen.Wait(0)
    end
    StopGameplayCamShaking(true)
end

function FX_MeteorRain(alive)
    while alive() do
        local pos = GetEntityCoords(PlayerPedId())
        local x = pos.x + math.random(-80, 80)
        local y = pos.y + math.random(-80, 80)
        AddExplosion(x, y, pos.z + math.random(30, 60), 28, 8.0, true, false, 1.0)
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.3)
        Citizen.Wait(math.random(150, 500))
    end
    StopGameplayCamShaking(true)
end

function FX_BlackHole(alive)
    local playerPos = GetEntityCoords(PlayerPedId())
    local holePos = vector3(
        playerPos.x + math.random(-200, 200),
        playerPos.y + math.random(-200, 200),
        playerPos.z + math.random(100, 300)
    )
    local radius = 0.0

    while alive() do
        if radius < 150.0 then radius = radius + 0.3 end
        ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 0.05 * (radius / 150.0))
        DrawMarker(28, holePos.x, holePos.y, holePos.z, 0, 0, 0, 0, 0, 0, radius, radius, radius, 0, 0, 0, 200, false, false, 2, false, nil, nil, false)

        for _, entity in ipairs(GetGamePool('CVehicle')) do
            if not IsPedInVehicle(PlayerPedId(), entity, false) then
                local epos = GetEntityCoords(entity)
                local dist = #(epos - holePos)
                if dist < radius * 2 then
                    local dir = holePos - epos
                    local vel = GetEntityVelocity(entity)
                    local force = vector3(
                        (dir.x) - vel.x * 2.0,
                        (dir.y) - vel.y * 2.0,
                        (dir.z) - vel.z * 2.0
                    )
                    ApplyForceToEntity(entity, 1, force.x, force.y, force.z, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                    if dist < radius * 0.5 then
                        ExplodeVehicle(entity, true, false)
                    end
                end
            end
        end

        Citizen.Wait(0)
    end
    StopGameplayCamShaking(true)
end

function FX_Airstrike()
    local pos = GetEntityCoords(PlayerPedId())
    for i = 1, 8 do
        SetTimeout(i * 400, function()
            local x = pos.x + math.random(-25, 25)
            local y = pos.y + math.random(-25, 25)
            AddExplosion(x, y, pos.z + 1.0, 4, 12.0, true, false, 1.0)
        end)
    end
end

function FX_InvertVelocity()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then
        local vel = GetEntityVelocity(veh)
        SetEntityVelocity(veh, -vel.x, -vel.y, vel.z + 2.0)
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.8)
    end
end

function FX_BoostVelocity()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then
        local fwd = GetEntityForwardVector(veh)
        local vel = GetEntityVelocity(veh)
        SetEntityVelocity(veh, vel.x + fwd.x * 40.0, vel.y + fwd.y * 40.0, vel.z + 3.0)
    end
end

function FX_UTurn()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then
        local rot = GetEntityRotation(veh, 2)
        SetEntityRotation(veh, rot.x, rot.y, rot.z + 180.0, 2, true)
    end
end

function FX_MoneyRain()
    local pos = GetEntityCoords(PlayerPedId())
    for i = 1, 30 do
        local x = pos.x + math.random(-15, 15)
        local y = pos.y + math.random(-15, 15)
        CreateAmbientPickup(`PICKUP_MONEY_CASE`, x, y, pos.z + 25.0, 0, 1000, 0, false, true)
    end
end

function FX_OilLeaks(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 and GetEntitySpeed(veh) > 5.0 and math.random() < 0.15 then
            SetVehicleReduceGrip(veh, true)
            Citizen.Wait(300)
            SetVehicleReduceGrip(veh, false)
        end
        Citizen.Wait(100)
    end
end

function FX_JumpyProps(alive)
    while alive() do
        for _, obj in ipairs(GetGamePool('CObject')) do
            if DoesEntityExist(obj) and math.random() < 0.02 then
                ApplyForceToEntity(obj, 1, 0.0, 0.0, math.random(5, 20) + 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end
        Citizen.Wait(100)
    end
end

function FX_GhostWorld(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if not IsPedInVehicle(PlayerPedId(), veh, false) then
                SetEntityAlpha(veh, 50, false)
                SetEntityCollision(veh, false, false)
            end
        end
        Citizen.Wait(500)
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        ResetEntityAlpha(veh)
        SetEntityCollision(veh, true, true)
    end
end

-- =====================================================================
-- WANTED
-- =====================================================================
function FX_Wanted3()
    SetPlayerWantedLevel(PlayerId(), 3, false)
    SetPlayerWantedLevelNow(PlayerId(), false)
end

function FX_Wanted5()
    SetPlayerWantedLevel(PlayerId(), 5, false)
    SetPlayerWantedLevelNow(PlayerId(), false)
end

function FX_ClearWanted()
    ClearPlayerWantedLevel(PlayerId())
end

function FX_NeverWanted(alive)
    while alive() do
        SetPlayerWantedLevel(PlayerId(), 0, false)
        SetMaxWantedLevel(0)
        Citizen.Wait(0)
    end
    SetMaxWantedLevel(5)
end

-- =====================================================================
-- UTILITY
-- =====================================================================
function RotToDir(rot)
    local rz = math.rad(rot.z)
    local rx = math.rad(rot.x)
    local num = math.abs(math.cos(rx))
    return vector3(-math.sin(rz) * num, math.cos(rz) * num, math.sin(rx))
end
