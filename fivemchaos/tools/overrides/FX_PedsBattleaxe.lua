function FX_PedsBattleaxe(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        GiveWeaponToPed(ped, GetHashKey("WEAPON_BATTLEAXE"), 9999, true, true)
        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_BATTLEAXE"), true)
    end
end
