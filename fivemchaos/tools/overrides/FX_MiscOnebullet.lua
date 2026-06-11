function FX_MiscOnebullet(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if IsPedArmed(ped, 7) then
                local weaponHash = GetCurrentPedWeapon(ped, true)
                local ammo = GetAmmoInClip(ped, weaponHash)
                if ammo > 1 then
                    local diff = ammo - 1
                    AddAmmoToPed(ped, weaponHash, diff)
                    SetAmmoInClip(ped, weaponHash, 1)
                end
            end
        end
        Citizen.Wait(0)
    end
end
