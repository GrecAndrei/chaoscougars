function FX_PedsRandomwep(alive)
    local weapons = {
        GetHashKey("WEAPON_PISTOL"), GetHashKey("WEAPON_SMG"), GetHashKey("WEAPON_ASSAULTRIFLE"),
        GetHashKey("WEAPON_PUMPSHOTGUN"), GetHashKey("WEAPON_GRENADE"), GetHashKey("WEAPON_MOLOTOV"),
        GetHashKey("WEAPON_RPG"), GetHashKey("WEAPON_MINIGUN"),
    }
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            GiveWeaponToPed(ped, weapons[math.random(#weapons)], 9999, true, true)
        end
    end
end
