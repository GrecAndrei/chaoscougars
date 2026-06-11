function FX_PedsMinigun(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        GiveWeaponToPed(ped, GetHashKey("WEAPON_MINIGUN"), 9999, true, true)
        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_MINIGUN"), true)
    end
end
