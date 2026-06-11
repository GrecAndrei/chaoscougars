function FX_PlayerMovementx5(alive)
    while alive() do
        SetPedMoveRateOverride(PlayerPedId(), 5.0)
        Citizen.Wait(0)
    end
end
