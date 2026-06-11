function FX_MiscAirstrike(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local pos = GetEntityCoords(playerPed, false)
    local weaponHash = GetHashKey("WEAPON_AIRSTRIKE_ROCKET")
    if not HasWeaponAssetLoaded(weaponHash) then
        RequestWeaponAsset(weaponHash, 31, 0)
    end
    while not HasWeaponAssetLoaded(weaponHash) do
        Citizen.Wait(0)
    end
    local offset = vector3(math.random(-20, 20), math.random(-20, 20), 30.0)
    ShootSingleBulletBetweenCoords(pos.x + offset.x, pos.y + offset.y, pos.z + offset.z,
        pos.x + offset.x, pos.y + offset.y, 0.0, 250, true, weaponHash, PlayerPedId(), true, false, 1.0)
end
