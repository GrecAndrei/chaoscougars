function FX_PedsGiverpg(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        GiveWeaponToPed(ped, GetHashKey("WEAPON_RPG"), 9999, true, true)
        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_RPG"), true)
    end
end
