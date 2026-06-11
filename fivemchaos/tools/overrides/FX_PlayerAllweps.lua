function FX_PlayerAllweps(alive)
    local ped = PlayerPedId()
    local weapons = {
        GetHashKey("WEAPON_PISTOL"), GetHashKey("WEAPON_SMG"), GetHashKey("WEAPON_ASSAULTRIFLE"),
        GetHashKey("WEAPON_PUMPSHOTGUN"), GetHashKey("WEAPON_SNIPERRIFLE"), GetHashKey("WEAPON_RPG"),
        GetHashKey("WEAPON_GRENADE"), GetHashKey("WEAPON_MOLOTOV"), GetHashKey("WEAPON_MINIGUN"),
        GetHashKey("WEAPON_COMBATMG"), GetHashKey("WEAPON_STICKYBOMB"), GetHashKey("WEAPON_RAILGUN"),
    }
    for _, weapon in ipairs(weapons) do
        GiveWeaponToPed(ped, weapon, 999, false, false)
    end
end
