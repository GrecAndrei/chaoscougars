-- sync_mode: GLOBAL_OWNED
function FX_VehsGreen(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            ToggleVehicleMod(veh, 20, true)
            SetVehicleTyreSmokeColor(veh, 0, 255, 0)
            SetVehicleCustomPrimaryColour(veh, 0, 255, 0)
            SetVehicleCustomSecondaryColour(veh, 0, 255, 0)
            SetVehicleEnveffScale(veh, 0.0)
            SetVehicleDirtLevel(veh, 0.0)
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsChrome(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            ToggleVehicleMod(veh, 20, true)
            SetVehicleTyreSmokeColor(veh, 219, 226, 233)
            ClearVehicleCustomPrimaryColour(veh)
            ClearVehicleCustomSecondaryColour(veh)
            SetVehicleColours(veh, 120, 120)
            SetVehicleEnveffScale(veh, 0.0)
            SetVehicleDirtLevel(veh, 0.0)
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsPink(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) then
            SetVehicleCustomPrimaryColour(veh, 255, 105, 180)
            SetVehicleCustomSecondaryColour(veh, 255, 105, 180)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsRainbow(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                SetVehicleCustomPrimaryColour(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
                SetVehicleCustomSecondaryColour(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
            end
        end)
        Citizen.Wait(500)
    end
end

-- sync_mode: LOCAL
function FX_VehsCruiseControl(alive)
    local currentVel = -1.0
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            if IsVehicleOnAllWheels(veh) then
                local speed = GetEntitySpeed(veh)
                if speed > currentVel or speed < currentVel / 2 or speed < 1 then
                    currentVel = speed
                elseif speed < currentVel then
                    SetVehicleForwardSpeed(veh, currentVel)
                end
            else
                currentVel = -1.0
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsCrumble(alive)
    while alive() do
        local vehs = {}
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            table.insert(vehs, veh)
        end)
        if #vehs > 0 then
            local veh = vehs[math.random(#vehs)]
            SetVehicleDamage(veh,
                (-1.0 + math.random() * 2.0),
                (-1.0 + math.random() * 2.0),
                (-1.0 + math.random() * 2.0),
                (1000.0 + math.random() * 9000.0),
                (100.0 + math.random() * 900.0),
                true)
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_VehsDetachWheel(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    local wheelBones = {
        "wheel_lf", "wheel_rf", "wheel_lm", "wheel_rm",
        "wheel_lr", "wheel_rr", "wheel_lm1", "wheel_rm1",
    }
    local wheels = {}
    for _, boneName in ipairs(wheelBones) do
        local idx = GetEntityBoneIndexByName(veh, boneName)
        if idx ~= -1 then
            table.insert(wheels, idx)
        end
    end
    if #wheels > 0 then
        local pick = wheels[math.random(#wheels)]
        for i = 0, 7 do
            SetVehicleTyreBurst(veh, i, true, 1000.0)
        end
    end
end

-- sync_mode: LOCAL
function FX_VehsDisassemble(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    for i = 0, 49 do
        SetVehicleDoorBroken(veh, i, true)
    end
    for i = 0, 7 do
        SetVehicleTyreBurst(veh, i, true, 1000.0)
    end
    SetVehicleEngineHealth(veh, -4000.0)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsX2engine(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            ModifyVehicleTopSpeed(veh, 2.0)
            SetVehicleCheatPowerIncrease(veh, 2.0)
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        ModifyVehicleTopSpeed(veh, 1.0)
        SetVehicleCheatPowerIncrease(veh, 1.0)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsX10engine(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            ModifyVehicleTopSpeed(veh, 10.0)
            SetVehicleCheatPowerIncrease(veh, 10.0)
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        ModifyVehicleTopSpeed(veh, 1.0)
        SetVehicleCheatPowerIncrease(veh, 1.0)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsX05engine(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            ModifyVehicleTopSpeed(veh, 0.5)
            SetVehicleCheatPowerIncrease(veh, 0.5)
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        ModifyVehicleTopSpeed(veh, 1.0)
        SetVehicleCheatPowerIncrease(veh, 1.0)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsExplode(alive)
    local playerVeh = GetVehiclePedIsIn(PlayerPedId(), false)
    local count = 3
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if veh ~= playerVeh then
            ExplodeVehicle(veh, true, false)
            count = count - 1
            if count == 0 then
                count = 3
                Citizen.Wait(0)
            end
        end
    end)
end

-- sync_mode: LOCAL
function FX_VehsFlyingcars(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            local vehClass = GetVehicleClass(veh)
            if vehClass ~= 15 and vehClass ~= 16 then
                local speed = GetEntitySpeed(veh)
                if speed > 5.0 then
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
                end
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_TrafficFullaccel(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                local driver = GetPedInVehicleSeat(veh, -1, false)
                if driver ~= 0 and not IsPedAPlayer(driver) then
                    SetVehicleForwardSpeed(veh, GetVehicleModelEstimatedMaxSpeed(GetEntityModel(veh)) * 2.0)
                end
            end
        end)
        Citizen.Wait(250)
    end
end

-- MANUAL OVERRIDE from VehsGTAOTraffic.cpp
-- sync_mode: GLOBAL_OWNED
function FX_TrafficGtao(alive)
    local goneThrough = {}
    while alive() do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed, false)
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if IsPedInAnyVehicle(ped, false)
            and GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1, 0) == ped
            and (function() for _,_v in ipairs(goneThrough) do if _v == ped then return false end end return true end)() then
                local veh = GetVehiclePedIsIn(ped, false)
                SetBlockingOfNonTemporaryEvents(ped, true)
                TaskVehicleMissionPedTarget(ped, veh, playerPed, 13, 9999.0, 4176732, 0.0, 0.0, false)
                table.insert(goneThrough, ped)
            end
        end)
        for i = #goneThrough, 1, -1 do
            if not DoesEntityExist(goneThrough[i]) then
                table.remove(goneThrough, i)
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsHonkboost(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and IsHornActive(veh) then
                ApplyForceToEntity(veh, 0, 0.0, 50.0, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsInvincible(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                SetEntityInvincible(veh, true)
            end
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetEntityInvincible(veh, false)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsGhost(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                SetEntityAlpha(veh, 80, false)
            end
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        ResetEntityAlpha(veh)
    end)
end

-- sync_mode: SPAWN_SINGLE
function FX_VehJesustakethewheel(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, true)
    local heading = GetEntityHeading(playerPed)
    local vehHash = GetHashKey("PANTO")
    RequestModel(vehHash)
    while not HasModelLoaded(vehHash) do Citizen.Wait(0) end
    local veh = CreateVehicle(vehHash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(vehHash)
    SetVehicleColours(veh, 135, 135)
    SetPedIntoVehicle(playerPed, veh, -1)
    local jesusHash = -835930287
    local group = AddRelationshipGroup("_WHEEL_JESUS")
    SetRelationshipBetweenGroups(0, group, GetHashKey("PLAYER"))
    RequestModel(jesusHash)
    while not HasModelLoaded(jesusHash) do Citizen.Wait(0) end
    local jesus = CreatePedInsideVehicle(veh, 4, jesusHash, -1, true, false)
    SetModelAsNoLongerNeeded(jesusHash)
    SetPedRelationshipGroupHash(jesus, group)
    SetEntityProofs(jesus, true, false, false, false, false, false, false, false)
    SetPedIntoVehicle(playerPed, veh, -2)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsJumpy(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and math.random() < 0.1 and not IsEntityInAir(veh) then
                ApplyForceToEntity(veh, 1, 0.0, 0.0, 10.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end)
        Citizen.Wait(100)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayervehKillengine(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) then
            SetVehicleEngineHealth(veh, 0.0)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsLockdoors(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) then
            SetVehicleDoorsLocked(veh, 2)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsNogravity(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                SetVehicleGravity(veh, false)
            end
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetVehicleGravity(veh, true)
    end)
end

-- sync_mode: VISUAL
function FX_Notraffic(alive)
    while alive() do
        SetAmbientVehicleRangeMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetVehicleDensityMultiplierThisFrame(0.0)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsOhko(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and HasEntityCollidedWithAnything(veh) and GetEntitySpeed(veh) > 5.0 then
                ExplodeVehicle(veh, true, false)
            end
        end)
        Citizen.Wait(500)
    end
end

-- sync_mode: LOCAL
function FX_PlayervehDespawn(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    Citizen.Wait(0)
    SetEntityAsMissionEntity(veh, true, true)
    DeleteVehicle(veh)
end

-- sync_mode: LOCAL
function FX_PlayervehExplode(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    local lastTimestamp = GetGameTimer()
    local detonateTimer = 5000
    local beepTimer = 5000
    while DoesEntityExist(veh) and alive() do
        Citizen.Wait(0)
        local curTimestamp = GetGameTimer()
        detonateTimer = detonateTimer - (curTimestamp - lastTimestamp)
        lastTimestamp = curTimestamp
        if detonateTimer < beepTimer then
            beepTimer = beepTimer * 0.8
            PlaySoundFromEntity(-1, "Beep_Red", veh, "DLC_HEIST_HACKING_SNAKE_SOUNDS", true, false)
        end
        if detonateTimer <= 0 then
            ExplodeVehicle(veh, true, false)
            break
        end
        if not IsPedInVehicle(playerPed, veh, false) then break end
    end
end

-- sync_mode: LOCAL
function FX_PlayervehLock(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            SetVehicleDoorsLocked(veh, 4)
        end
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetVehicleDoorsLocked(veh, 1)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayervehPoptires(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        for i = 0, 47 do
            SetVehicleTyresCanBurst(veh, true)
            SetVehicleTyreBurst(veh, i, true, 1000.0)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehPoptire(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            for i = 0, 47 do
                if math.random(0, 1) == 1 then
                    SetVehicleTyresCanBurst(veh, true)
                    SetVehicleTyreBurst(veh, i, true, 1000.0)
                else
                    SetVehicleTyreFixed(veh, i)
                end
            end
        end)
        Citizen.Wait(1750)
    end
end

-- sync_mode: SPAWN_SINGLE
function FX_VehsPropModels(alive)
    while alive() do
        local models = {}
        OwnershipGuard.ForEachOwnedObject(function(prop)
            if DoesEntityExist(prop) then
                local model = GetEntityModel(prop)
                local min, max = GetModelDimensions(model)
                local size = #(max - min)
                if size > 0.75 and size < 6.0 then
                    models[#models + 1] = model
                end
            end
        end)
        if #models > 0 then
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed, false)
            local pick = models[math.random(#models)]
            RequestModel(pick)
            while not HasModelLoaded(pick) do Citizen.Wait(0) end
            local obj = CreateObject(pick, playerPos.x + math.random(-10, 10), playerPos.y + math.random(-10, 10), playerPos.z + 10.0, true, true, false)
            SetModelAsNoLongerNeeded(pick)
            SetObjectAsNoLongerNeeded(obj)
        end
        Citizen.Wait(1000)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehRandtraffic(alive)
    while alive() do
        local toRespawn = {}
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and GetVehicleWindowTint(veh) ~= 3 then
                table.insert(toRespawn, veh)
            end
        end)
        for _, veh in ipairs(toRespawn) do
            local model = GetEntityModel(veh)
            local coords = GetEntityCoords(veh, false)
            local heading = GetEntityHeading(veh)
            SetEntityAsMissionEntity(veh, true, true)
            DeleteVehicle(veh)
            Citizen.Wait(0)
            RequestModel(model)
            while not HasModelLoaded(model) do Citizen.Wait(0) end
            local newVeh = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
            SetModelAsNoLongerNeeded(model)
            SetVehicleWindowTint(newVeh, 3)
            local driver = GetPedInVehicleSeat(newVeh, -1, false)
            if driver ~= 0 and DoesEntityExist(driver) and not IsPedAPlayer(driver) then
                TaskVehicleDriveWander(driver, newVeh, 40.0, 786603)
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayervehRepair(alive)
    local count = 5
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetVehicleFixed(veh)
        SetVehicleDirtLevel(veh, 0.0)
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehiclePetrolTankHealth(veh, 1000.0)
        SetVehicleBodyHealth(veh, 1000.0)
        SetVehicleUndriveable(veh, false)
        SetVehicleOnGroundProperly(veh, 5.0)
        count = count - 1
        if count == 0 then
            count = 5
            Citizen.Wait(0)
        end
    end)
end

-- sync_mode: LOCAL
function FX_MiscReplacevehicle(alive)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local veh = GetVehiclePedIsIn(playerPed, false)
        local model = GetEntityModel(veh)
        local coords = GetEntityCoords(veh, false)
        local heading = GetEntityHeading(veh)
        SetEntityAsMissionEntity(veh, true, true)
        DeleteVehicle(veh)
        Citizen.Wait(0)
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(0) end
        local newVeh = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
        SetModelAsNoLongerNeeded(model)
        SetPedIntoVehicle(playerPed, newVeh, -1)
    else
        local coords = GetEntityCoords(playerPed, false)
        local heading = GetEntityHeading(playerPed)
        RequestModel(GetHashKey("buffalo"))
        while not HasModelLoaded(GetHashKey("buffalo")) do Citizen.Wait(0) end
        local veh = CreateVehicle(GetHashKey("buffalo"), coords.x, coords.y + 5.0, coords.z, heading, true, false)
        SetModelAsNoLongerNeeded(GetHashKey("buffalo"))
        SetPedIntoVehicle(playerPed, veh, -1)
    end
end

-- sync_mode: SPAWN_SINGLE
function FX_VehRepossession(alive)
    local playerPed = PlayerPedId()

    if IsPedInAnyVehicle(playerPed, false) then
        local modelHash = GetHashKey("franklin")
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Citizen.Wait(0) end

        local relationshipGroup
        AddRelationshipGroup("_WHEEL_FRANKLIN", relationshipGroup)
        SetRelationshipBetweenGroups(0, relationshipGroup, GetHashKey("PLAYER"))

        local veh = GetVehiclePedIsIn(playerPed, false)
        SetPedIntoVehicle(playerPed, veh, -2)

        local franklinDrive = CreatePedInsideVehicle(veh, 4, modelHash, -1, true, false)
        SetModelAsNoLongerNeeded(modelHash)
        SetPedRelationshipGroupHash(franklinDrive, relationshipGroup)
        SetEntityProofs(franklinDrive, true, false, false, false, false, false, false, false)

        TaskVehicleDriveToCoordLongrange(franklinDrive, veh, -52, -1106.88, 26, 9999.0, 262668, 0.0)
        SetPedKeepTask(franklinDrive, true)
        SetBlockingOfNonTemporaryEvents(franklinDrive, true)
    else
        local playerPos = GetEntityCoords(playerPed, false)
        local heading = GetEntityHeading(playerPed)

        local carModel = GetHashKey("BJXL")
        RequestModel(carModel)
        while not HasModelLoaded(carModel) do Citizen.Wait(0) end
        local veh = CreateVehicle(carModel, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
        SetModelAsNoLongerNeeded(carModel)
        SetVehicleColours(veh, 88, 0)
        SetVehicleEngineOn(veh, true, true, false)

        local modelHash = GetHashKey("franklin")
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Citizen.Wait(0) end

        local relationshipGroup
        AddRelationshipGroup("_WHEEL_FRANKLIN", relationshipGroup)
        SetRelationshipBetweenGroups(0, relationshipGroup, GetHashKey("PLAYER"))
        SetPedIntoVehicle(playerPed, veh, -2)

        local franklinDrive = CreatePedInsideVehicle(veh, 4, modelHash, -1, true, false)
        SetModelAsNoLongerNeeded(modelHash)
        SetPedRelationshipGroupHash(franklinDrive, relationshipGroup)
        SetEntityProofs(franklinDrive, true, false, false, false, false, false, false, false)

        TaskVehicleDriveToCoordLongrange(franklinDrive, veh, -52, -1106.88, 26, 9999.0, 262668, 0.0)
        SetPedKeepTask(franklinDrive, true)
        SetBlockingOfNonTemporaryEvents(franklinDrive, true)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsRotall(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) then
            local vel = GetEntityVelocity(veh)
            local rot = GetEntityRotation(veh, 2)
            if math.random(0, 1) == 0 then
                SetEntityRotation(veh, rot.x + 180.0, rot.y, rot.z, 2, true)
            else
                SetEntityRotation(veh, rot.x, rot.y + 180.0, rot.z, 2, true)
            end
            SetEntityVelocity(veh, vel.x, vel.y, vel.z)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsSlippery(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                SetVehicleReduceGrip(veh, true)
            end
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetVehicleReduceGrip(veh, false)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsSpamdoors(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            for i = 0, 5 do
                SetVehicleDoorOpen(veh, i, false, false)
                SetVehicleDoorCanBreak(veh, i, false)
            end
        end)
        Citizen.Wait(500)
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            SetVehicleDoorsShut(veh, false)
        end)
        Citizen.Wait(500)
    end
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnRhino(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("rhino")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnAdder(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("adder")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnDump(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("dump")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnMonster(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("monster")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnBmx(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("bmx")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnTug(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("tug")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnCargo(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("cargoplane")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnBus(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("bus")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnBlimp(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("blimp")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnBuzzard(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("buzzard")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnFaggio(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("faggio")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnRuiner3(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("ruiner3")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end
