function FX_PlayerTired(alive)
    while alive() do
        Citizen.Wait(1000)
        SetPedToRagdoll(PlayerPedId(), 1500, 1500, 0, true, true, false)
    end
end
