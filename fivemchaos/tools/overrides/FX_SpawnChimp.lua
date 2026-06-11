function FX_SpawnChimp(alive)
    local modelHash = GetHashKey("a_c_chimp")
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePed(28, modelHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(modelHash)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedSuffersCriticalHits(ped, false)
    SetPedHearingRange(ped, 9999.0)
    SetPedAsGroupMember(ped, GetPlayerGroup(PlayerId()))
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedAccuracy(ped, 100)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 9999, false, true)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_CARBINERIFLE"), 9999, false, true)
end
