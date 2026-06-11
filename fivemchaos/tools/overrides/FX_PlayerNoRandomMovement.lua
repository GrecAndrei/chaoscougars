function FX_PlayerNoRandomMovement(alive)
    while alive() do
        SetPedRandomComponentVariation(PlayerPedId(), false)
        SetPedRandomProps(PlayerPedId(), false)
        Citizen.Wait(0)
    end
end
