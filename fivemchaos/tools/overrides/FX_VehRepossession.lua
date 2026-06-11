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
