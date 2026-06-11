function FX_PlayerBreak(alive)
    while alive() do
        SetVehicleCheatPowerIncrease(PlayerPedId(), 2.0)
        Citizen.Wait(0)
    end
end
