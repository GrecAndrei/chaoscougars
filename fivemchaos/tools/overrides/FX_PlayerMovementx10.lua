function FX_PlayerMovementx10(alive)
    while alive() do
        SetPedMoveRateOverride(PlayerPedId(), 10.0)
        Citizen.Wait(0)
    end
end
