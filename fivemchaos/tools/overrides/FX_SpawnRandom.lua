function FX_SpawnRandom(alive)
    local spawns = {
        {model = "adder", name = "Adder"},
        {model = "zentorno", name = "Zentorno"},
        {model = "t20", name = "T20"},
        {model = "akuma", name = "Akuma"},
        {model = "buzzard", name = "Buzzard"},
        {model = "hydra", name = "Hydra"},
        {model = "insurgent", name = "Insurgent"},
        {model = "kuruma", name = "Kuruma"},
    }
    local pick = spawns[math.random(#spawns)]
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey(pick.model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x + 5.0, playerPos.y, playerPos.z, heading, true, false)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end
