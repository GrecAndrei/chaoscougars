function FX_PedsMindmg(alive)
    while alive() do
        SetAiMeleeWeaponDamageModifier(0.1)
        SetAiWeaponDamageModifier(0.1)
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), 0.1, true)
        SetPlayerWeaponDamageModifier(PlayerId(), 0.1)
        for _, ped in ipairs(GetGamePool('CPed')) do
            if not IsPedAPlayer(ped) then
                SetPedSuffersCriticalHits(ped, false)
                SetPedConfigFlag(ped, 281, true)
            end
        end
        Citizen.Wait(0)
    end
    ResetAiMeleeWeaponDamageModifier()
    ResetAiWeaponDamageModifier()
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0, true)
    SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) then
            SetPedSuffersCriticalHits(ped, true)
            SetPedConfigFlag(ped, 281, false)
        end
    end
end
