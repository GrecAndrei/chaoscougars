function FX_MiscSpawnOrangeBall(alive)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed, false)
    local ballHash = GetHashKey("prop_beach_ball_01")
    RequestModel(ballHash)
    while not HasModelLoaded(ballHash) do Citizen.Wait(0) end
    local ball = CreateObject(ballHash, pos.x, pos.y + 10.0, pos.z + 1.0, true, true, false)
    SetModelAsNoLongerNeeded(ballHash)
    ActivatePhysics(ball)
    ApplyForceToEntityCenterOfMass(ball, 1, 0.0, 500.0, 200.0, true, false, true, true)
    SetObjectAsNoLongerNeeded(ball)
end
