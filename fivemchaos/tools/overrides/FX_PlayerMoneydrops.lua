function FX_PlayerMoneydrops(alive)
    local model = GetHashKey("prop_money_bag_01")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end

    while alive() do
        local playerPos = GetEntityCoords(PlayerPedId(), false)
        CreateAmbientPickup(GetHashKey("PICKUP_MONEY_SECURITY_CASE"),
            playerPos.x + math.random(-20, 20),
            playerPos.y + math.random(-20, 20),
            playerPos.z + math.random(5, 10),
            0, 1000, model, false, true)
        Citizen.Wait(0)
    end

    SetModelAsNoLongerNeeded(model)
end
