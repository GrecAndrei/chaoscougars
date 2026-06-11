function FX_WorldWhalerain(alive)
    while alive() do
        local playerPos = GetEntityCoords(PlayerPedId(), false)
        local wh = GetHashKey("a_c_humpback")
        RequestModel(wh)
        while not HasModelLoaded(wh) do Citizen.Wait(0) end
        local pos = vector3(
            playerPos.x + math.random(-100, 100),
            playerPos.y + math.random(-100, 100),
            playerPos.z + math.random(50, 100)
        )
        local whale = CreatePed(28, wh, pos.x, pos.y, pos.z, 0.0, true, false)
        SetPedToRagdoll(whale, 5000, 5000, 0, true, true, false)
        SetPedAsNoLongerNeeded(whale)
        SetModelAsNoLongerNeeded(wh)
        Citizen.Wait(750)
    end
end
