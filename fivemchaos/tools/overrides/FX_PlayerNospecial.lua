function FX_PlayerNospecial(alive)
    while alive() do
        SpecialAbilityDepleteMeter(PlayerId(), true, 0)
        Citizen.Wait(0)
    end
end
