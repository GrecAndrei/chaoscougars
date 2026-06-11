function FX_PlayerClone(alive)
    local playerPed = PlayerPedId()
    local model = GetEntityModel(playerPed)
    local coords = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end
    local clone = CreatePed(GetPedType(playerPed), model, coords.x + 1.0, coords.y, coords.z, heading, true, false)
    ClonePedToTarget(playerPed, clone)
    SetModelAsNoLongerNeeded(model)
end
