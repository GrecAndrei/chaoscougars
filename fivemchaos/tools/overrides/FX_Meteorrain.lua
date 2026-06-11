function FX_Meteorrain(alive)
    while alive() do
        local playerPos = GetEntityCoords(PlayerPedId(), false)
        local pos = vector3(
            playerPos.x + math.random(-100, 100),
            playerPos.y + math.random(-100, 100),
            playerPos.z + math.random(50, 100)
        )
        local weaponHash = GetHashKey("WEAPON_AIRSTRIKE_ROCKET")
        if not HasWeaponAssetLoaded(weaponHash) then
            RequestWeaponAsset(weaponHash, 31, 0)
        end
        while not HasWeaponAssetLoaded(weaponHash) do Citizen.Wait(0) end
        ShootSingleBulletBetweenCoords(pos.x, pos.y, pos.z, pos.x, pos.y, 0.0, 200, true, weaponHash, PlayerPedId(), true, false, 1.0)
        Citizen.Wait(150)
    end
end
