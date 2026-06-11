function FX_PedsRainbowweps(alive)
    while alive() do
        local weapons = {
            GetHashKey("WEAPON_PISTOL"), GetHashKey("WEAPON_SMG"), GetHashKey("WEAPON_ASSAULTRIFLE"),
            GetHashKey("WEAPON_PUMPSHOTGUN"), GetHashKey("WEAPON_GRENADE"),
            GetHashKey("WEAPON_RPG"), GetHashKey("WEAPON_MINIGUN"),
        }
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                RemoveAllPedWeapons(ped, true)
                GiveWeaponToPed(ped, weapons[math.random(#weapons)], 9999, true, true)
            end
        end
        Citizen.Wait(5000)
    end
end
