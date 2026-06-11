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
