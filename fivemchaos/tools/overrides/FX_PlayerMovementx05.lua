function FX_PlayerMovementx05(alive)
    while alive() do
        SetPedMoveRateOverride(PlayerPedId(), 0.5)
        Citizen.Wait(0)
    end
end
