function FX_PedsRailgun(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        GiveWeaponToPed(ped, GetHashKey("WEAPON_RAILGUN"), 9999, true, true)
        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_RAILGUN"), true)
    end
end
