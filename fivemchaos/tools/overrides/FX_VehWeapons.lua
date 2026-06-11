function FX_VehWeapons(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) and IsControlPressed(0, 69) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            local pos = GetEntityCoords(veh, false)
            local weaponHash = GetHashKey("WEAPON_AIRSTRIKE_ROCKET")
            if not HasWeaponAssetLoaded(weaponHash) then
                RequestWeaponAsset(weaponHash, 31, 0)
                while not HasWeaponAssetLoaded(weaponHash) do Citizen.Wait(0) end
            end
            local fwd = GetEntityForwardVector(veh)
            local targ = vector3(pos.x + fwd.x * 100.0, pos.y + fwd.y * 100.0, pos.z - 1.0)
            ShootSingleBulletBetweenCoords(pos.x, pos.y, pos.z + 0.35, targ.x, targ.y, targ.z, 500, true, weaponHash, playerPed, true, false, 1.0)
        end
        Citizen.Wait(1000)
    end
end
