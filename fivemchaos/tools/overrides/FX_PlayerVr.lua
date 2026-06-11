function FX_PlayerVr(alive)
    local playerPed = PlayerPedId()
    local heading = GetEntityHeading(playerPed)
    local coords = GetEntityCoords(playerPed, true)
    local rot = GetEntityRotation(playerPed, 0)
    local pedType = GetPedType(playerPed)
    local model = GetEntityModel(playerPed)
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end
    local clone = CreatePed(pedType, model, coords.x, coords.y, coords.z, heading, true, false)
    ClonePedToTarget(playerPed, clone)
    local _, groundZ = GetGroundZFor3dCoord(coords.x, coords.y, coords.z, 0.0, false, false)
    local cloneVeh = nil
    if IsPedInAnyVehicle(playerPed, false) then
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        local vehModel = GetEntityModel(playerVeh)
        RequestModel(vehModel)
        while not HasModelLoaded(vehModel) do Citizen.Wait(0) end
        local vehCoords = GetEntityCoords(playerVeh, false)
        cloneVeh = CreateVehicle(vehModel, vehCoords.x, vehCoords.y, vehCoords.z + 1.0, GetEntityHeading(playerVeh), true, false)
        SetPedIntoVehicle(clone, cloneVeh, -1)
        SetVehicleEngineOn(cloneVeh, GetIsVehicleEngineRunning(playerVeh), true, false)
        SetVehicleForwardSpeed(cloneVeh, GetEntitySpeed(playerVeh))
        local vel = GetEntityVelocity(playerVeh)
        SetEntityVelocity(cloneVeh, vel.x, vel.y, vel.z)
        SetModelAsNoLongerNeeded(vehModel)
    end
    SetModelAsNoLongerNeeded(model)
    while alive() do
        local targetHeading = GetEntityHeading(playerPed)
        heading = heading + (targetHeading - heading) * 0.15
        SetEntityHeading(clone, heading)
        local targCoords = GetEntityCoords(playerPed, true)
        local _, gz = GetGroundZFor3dCoord(targCoords.x, targCoords.y, targCoords.z, 0.0, false, false)
        coords = vector3(
            coords.x + (targCoords.x - coords.x) * 0.15,
            coords.y + (targCoords.y - coords.y) * 0.15,
            coords.z + (groundZ - coords.z) * 0.15
        )
        SetEntityCoords(clone, coords.x, coords.y, coords.z, true, false, false, true)
        Citizen.Wait(0)
    end
    if DoesEntityExist(clone) then DeleteEntity(clone) end
    if cloneVeh and DoesEntityExist(cloneVeh) then DeleteVehicle(cloneVeh) end
end
