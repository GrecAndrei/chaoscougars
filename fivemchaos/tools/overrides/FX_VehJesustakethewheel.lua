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
