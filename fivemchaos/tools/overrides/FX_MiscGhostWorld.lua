function FX_MiscGhostWorld(alive)
    while alive() do
        SetAiWeaponDamageModifier(0.0)
        SetAiMeleeWeaponDamageModifier(0.0)
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                SetEntityAlpha(ped, 128, false)
            end
        end
        Citizen.Wait(0)
    end
    ResetAiWeaponDamageModifier()
    ResetAiMeleeWeaponDamageModifier()
end
