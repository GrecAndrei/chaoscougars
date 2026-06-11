function FX_SpawnComprnd(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local ped = _ChaosCreateRandomPed(playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed))
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedSuffersCriticalHits(ped, false)
    SetPedHearingRange(ped, 9999.0)
    SetPedAsGroupMember(ped, GetPlayerGroup(PlayerId()))
    GiveWeaponToPed(ped, GetSelectedPedWeapon(playerPed), 9999, true, true)
    SetPedAccuracy(ped, 100)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
end
