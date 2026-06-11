function FX_PlayerBees(alive)
    while alive() do
        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed, false)
        UseParticleFxAsset("core")
        StartParticleFxLoopedOnEntity("ent_sht_pest_cont", playerPed, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
        if math.random() < 0.1 then
            SetEntityHealth(playerPed, GetEntityHealth(playerPed) - 1)
        end
        Citizen.Wait(100)
    end
end
