function FX_PedsSpawnBiker(alive)
    local vehHash = GetHashKey("DAEMON")
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(
        IsPedInAnyVehicle(playerPed, false) and GetVehiclePedIsIn(playerPed, false) or playerPed
    )
    local xPos = math.sin((360 - heading) * math.pi / 180) * 10
    local yPos = math.cos((360 - heading) * math.pi / 180) * 10
    RequestModel(vehHash)
    while not HasModelLoaded(vehHash) do Citizen.Wait(0) end
    local veh = CreateVehicle(vehHash, playerPos.x - xPos, playerPos.y - yPos, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(vehHash)
    SetVehicleEngineOn(veh, true, true, false)
    local vel = GetEntityVelocity(playerPed)
    SetEntityVelocity(veh, vel.x, vel.y, vel.z)
    local ped = _ChaosCreateHostilePed(GetHashKey("G_M_Y_Lost_03"), GetHashKey("weapon_dbshotgun"))
    SetPedIntoVehicle(ped, veh, -1)
end
