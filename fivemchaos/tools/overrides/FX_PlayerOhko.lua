function FX_PlayerOhko(alive)
    while alive() do
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), 100.0)
        SetPlayerWeaponDamageModifier(PlayerId(), 100.0)
        Citizen.Wait(0)
    end
    SetPlayerMeleeWeaponDefenseModifier(PlayerId(), 1.0)
    SetPlayerWeaponDefenseModifier(PlayerId(), 1.0)
end
