function FX_PedsUpnatomizer(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        GiveWeaponToPed(ped, GetHashKey("WEAPON_RAYPISTOL"), 9999, true, true)
        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_RAYPISTOL"), true)
    end
end
