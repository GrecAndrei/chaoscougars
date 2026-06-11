function FX_SpawnCompbrad(alive)
    local modelHash = GetHashKey("ig_brad")
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePed(4, modelHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(modelHash)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedSuffersCriticalHits(ped, false)
    SetPedHearingRange(ped, 9999.0)
    SetPedAsGroupMember(ped, GetPlayerGroup(PlayerId()))
    GiveWeaponToPed(ped, GetHashKey("WEAPON_MICROSMG"), 9999, true, true)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_RPG"), 9999, true, true)
    SetPedAccuracy(ped, 100)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
end
