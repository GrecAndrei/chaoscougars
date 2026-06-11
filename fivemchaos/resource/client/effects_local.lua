-- sync_mode: LOCAL — only affects the triggering player's ped/vehicle

-- === GRAVITY ===

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
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 and not IsEntityInAir(veh) then
            ApplyForceToEntity(veh, 1, 0.0, 0.0, 1.5, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
        Citizen.Wait(200)
    end
    SetGravityLevel(0)
end

-- === VEHICLE (player's own vehicle only) ===

function FX_SlipperyCars(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then SetVehicleReduceGrip(veh, true) end
        Citizen.Wait(100)
    end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then SetVehicleReduceGrip(veh, false) end
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
        if veh ~= 0 and IsControlPressed(0, 72) then
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

        if IsControlPressed(0, 71) then
            vel = vector3(fwd.x * (speed + deltaSpeed), fwd.y * (speed + deltaSpeed), vel.z)
        end

        SetEntityVelocity(veh, vel.x, vel.y, vel.z)

        local rot = GetEntityRotation(veh, 2)
        local deltaAngle = 80.0 * GetFrameTime()

        if IsControlPressed(0, 63) then rot = vector3(rot.x, rot.y, rot.z + deltaAngle) end
        if IsControlPressed(0, 64) then rot = vector3(rot.x, rot.y, rot.z - deltaAngle) end
        if IsControlPressed(0, 108) then rot = vector3(rot.x, rot.y - deltaAngle, rot.z) end
        if IsControlPressed(0, 109) then rot = vector3(rot.x, rot.y + deltaAngle, rot.z) end
        if IsControlPressed(0, 111) then rot = vector3(rot.x - deltaAngle, rot.y, rot.z) end
        if IsControlPressed(0, 112) then rot = vector3(rot.x + deltaAngle, rot.y, rot.z) end

        SetEntityRotation(veh, rot.x, rot.y, rot.z, 2, true)
        ::cont::
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
        DisableControlAction(0, 59, true)
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

function FX_FullAccel(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then
            SetControlNormal(0, 71, 1.0)
        end
        Citizen.Wait(0)
    end
end

function FX_SpeedLimit(alive)
    local limit = 13.4
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 and GetEntitySpeed(veh) > limit then
            local fwd = GetEntityForwardVector(veh)
            SetEntityVelocity(veh, fwd.x * limit, fwd.y * limit, GetEntityVelocity(veh).z)
        end
        Citizen.Wait(0)
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

-- === PLAYER ===

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
            SetControlNormal(0, 32, 1.0)
            SetControlNormal(0, 21, 1.0)
        end
        Citizen.Wait(0)
    end
end

function FX_HeavyRecoil(alive)
    while alive() do
        if IsPedShooting(PlayerPedId()) then
            ApplyForceToEntity(PlayerPedId(), 1, 0.0, -8.0, 3.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
        Citizen.Wait(0)
    end
end

function FX_RapidFire(alive)
    while alive() do
        if IsControlPressed(0, 24) then
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
    ClonePed(PlayerPedId(), true, false, false)
end

function FX_JesusTakeTheWheel()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then return end

    local jesusHash = `u_m_y_jesus01`
    RequestModel(jesusHash)
    while not HasModelLoaded(jesusHash) do Citizen.Wait(10) end

    SetPedIntoVehicle(ped, veh, 0)
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

-- === WANTED ===

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

-- === INSTANT: vehicle (player's only) ===

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

-- === TIME (local to each client) ===

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

-- === UTILITY ===

function RotToDir(rot)
    local rz = math.rad(rot.z)
    local rx = math.rad(rot.x)
    local num = math.abs(math.cos(rx))
    return vector3(-math.sin(rz) * num, math.cos(rz) * num, math.sin(rx))
end

-- === NEW: VEHICLE LOCAL ===

function FX_AutoDrive(alive)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then return end
    local target
    if IsWaypointActive() then
        target = GetBlipCoords(GetFirstBlipInfoId(8))
    else
        local fwd = GetEntityForwardVector(veh)
        local pos = GetEntityCoords(veh)
        target = vector3(pos.x + fwd.x * 800.0, pos.y + fwd.y * 800.0, pos.z)
    end
    TaskVehicleDriveToCoordLongrange(ped, veh, target.x, target.y, target.z, 60.0, 262668, 0.0)
    while alive() do
        DisableControlAction(0, 71, true)
        DisableControlAction(0, 72, true)
        Citizen.Wait(0)
    end
    ClearPedTasks(ped)
end

function FX_ReverseOnly(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then
            DisableControlAction(0, 71, true)
            SetControlNormal(0, 72, 1.0)
        end
        Citizen.Wait(0)
    end
end

function FX_HoverMode(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then
            ApplyForceToEntity(veh, 1, 0.0, 0.0, 5.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            if GetEntityHeightAboveGround(veh) < 1.5 then
                ApplyForceToEntity(veh, 1, 0.0, 0.0, 8.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end
        Citizen.Wait(0)
    end
end

function FX_StickyTires(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then
            SetVehicleReduceGrip(veh, false)
        end
        Citizen.Wait(100)
    end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then SetVehicleReduceGrip(veh, false) end
end

function FX_PopcornEngine(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 and GetIsVehicleEngineRunning(veh) and math.random() < 0.04 then
            SetVehicleEngineOn(veh, false, true, true)
            SetTimeout(250 + math.random(0, 400), function()
                if DoesEntityExist(veh) then SetVehicleEngineOn(veh, true, false, true) end
            end)
        end
        Citizen.Wait(60)
    end
end

function FX_ReverseCamera(alive)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    RenderScriptCams(true, true, 300, true, true)
    while alive() do
        local pos = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        SetCamCoord(cam, pos.x, pos.y, pos.z)
        SetCamRot(cam, rot.x, rot.y, rot.z + 180.0, 2)
        SetCamFov(cam, GetGameplayCamFov())
        Citizen.Wait(0)
    end
    RenderScriptCams(false, true, 300, true, true)
    DestroyCam(cam, false)
end

function FX_UnderwaterCar(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then
            SetEntityProofs(veh, true, true, false, false, false, false, false, false)
        end
        Citizen.Wait(0)
    end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 then SetEntityProofs(veh, false, false, false, false, false, false, false, false) end
end

function FX_IceCam(alive)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    RenderScriptCams(true, true, 300, true, true)
    local t = 0
    while alive() do
        t = t + 0.1
        local pos = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        local wobble = math.sin(t * 2.0) * 4.0
        SetCamCoord(cam, pos.x, pos.y, pos.z)
        SetCamRot(cam, rot.x + wobble, rot.y + math.cos(t * 1.5) * 3.0, rot.z, 2)
        SetCamFov(cam, 90.0 + math.sin(t * 3.0) * 15.0)
        Citizen.Wait(0)
    end
    RenderScriptCams(false, true, 300, true, true)
    DestroyCam(cam, false)
end

function FX_RocketSeat(alive)
    while alive() do
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 and not IsEntityInAir(veh) then
            local fwd = GetEntityForwardVector(veh)
            ApplyForceToEntity(veh, 1, fwd.x * 30.0, fwd.y * 30.0, 25.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
        Citizen.Wait(300)
    end
end

function FX_TowAlong(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 and GetEntitySpeed(veh) < 1.0 and math.random() < 0.05 then
            local fwd = GetEntityForwardVector(veh)
            ApplyForceToEntity(veh, 1, fwd.x * 50.0, fwd.y * 50.0, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.3)
        end
        Citizen.Wait(500)
    end
end

-- === NEW: PLAYER LOCAL ===

function FX_HugePlayer(alive)
    SetPedScale(PlayerPedId(), 2.5)
    while alive() do Citizen.Wait(500) end
    SetPedScale(PlayerPedId(), 1.0)
end

function FX_TinyPlayer(alive)
    SetPedScale(PlayerPedId(), 0.4)
    while alive() do Citizen.Wait(500) end
    SetPedScale(PlayerPedId(), 1.0)
end

function FX_MarioVoice(alive)
    SetAmbientVoiceName(PlayerPedId(), 'A_F_M_BEVHILLS_02_WHITE_FULL_01')
    while alive() do Citizen.Wait(500) end
    SetAmbientVoiceName(PlayerPedId(), 'A_M_Y_ACULT_01_WHITE_FULL_01')
end

function FX_WhisperVoice(alive)
    SetAmbientVoiceName(PlayerPedId(), 'A_M_M_SKIDROW_01_WHITE_FULL_02')
    while alive() do Citizen.Wait(500) end
    SetAmbientVoiceName(PlayerPedId(), 'A_M_Y_ACULT_01_WHITE_FULL_01')
end

function FX_InvisiblePlayer(alive)
    SetEntityAlpha(PlayerPedId(), 0, false)
    while alive() do Citizen.Wait(500) end
    ResetEntityAlpha(PlayerPedId())
end

function FX_Pacifist(alive)
    DisablePlayerFiring(PlayerId(), true)
    while alive() do
        DisablePlayerFiring(PlayerId(), true)
        Citizen.Wait(0)
    end
end

function FX_ConfusedControls(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 then
            if IsControlPressed(0, 34) then SetControlNormal(0, 35, 1.0) end
            if IsControlPressed(0, 35) then SetControlNormal(0, 34, 1.0) end
            if IsControlPressed(0, 71) then SetControlNormal(0, 72, 1.0) end
            if IsControlPressed(0, 72) then SetControlNormal(0, 71, 1.0) end
        end
        Citizen.Wait(0)
    end
end

function FX_HeavyPlayer(alive)
    while alive() do
        ApplyForceToEntity(PlayerPedId(), 1, 0.0, 0.0, -4.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
        Citizen.Wait(0)
    end
end

function FX_ExplosiveMelee(alive)
    while alive() do
        if IsPedInMeleeCombat(PlayerPedId()) and IsPedPerformingMeleeAction(PlayerPedId()) then
            local pos = GetEntityCoords(PlayerPedId())
            local fwd = GetEntityForwardVector(PlayerPedId())
            AddExplosion(pos.x + fwd.x * 1.5, pos.y + fwd.y * 1.5, pos.z, 4, 4.0, true, false, 0.5)
            Citizen.Wait(400)
        end
        Citizen.Wait(0)
    end
end

function FX_IceSkates(alive)
    while alive() do
        local ped = PlayerPedId()
        if not IsPedInAnyVehicle(ped, false) and IsPedOnFoot(ped) then
            local vel = GetEntityVelocity(ped)
            if math.abs(vel.x) > 0.05 or math.abs(vel.y) > 0.05 then
                SetEntityVelocity(ped, vel.x * 1.04, vel.y * 1.04, vel.z)
            end
            if math.random() < 0.04 then
                ApplyForceToEntity(ped, 1, math.random(-15.0, 15.0), math.random(-15.0, 15.0), 0.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
            end
        end
        Citizen.Wait(0)
    end
end

function FX_ReverseTime(alive)
    while alive() do
        local h = GetClockHours() - 1
        if h < 0 then h = 23 end
        SetClockTime(h, GetClockMinutes(), GetClockSeconds())
        Citizen.Wait(1000)
    end
end
