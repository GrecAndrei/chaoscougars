function FX_PedsStungun(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        GiveWeaponToPed(ped, GetHashKey("WEAPON_STUNGUN"), 9999, true, true)
        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_STUNGUN"), true)
    end
end
