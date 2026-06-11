function FX_PedsDriveby(alive)
    local playerPed = PlayerPedId()
    local weaponHash = GetHashKey("WEAPON_MACHINEPISTOL")
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if not IsPedAPlayer(ped) and IsPedInAnyVehicle(ped, false) then
                SetBlockingOfNonTemporaryEvents(ped, true)
                GiveWeaponToPed(ped, weaponHash, 9999, true, true)
                TaskDriveBy(ped, playerPed, 0, 0.0, 0.0, 0.0, -1.0, 5, false, 0xC6EE6B4C)
            end
        end
        Citizen.Wait(0)
    end
end
