function FX_SpawnAngryChimp(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local chimpHash = 2825402133
    local weaponHash = GetHashKey("WEAPON_STONE_HATCHET")
    local relationshipGroup = AddRelationshipGroup("_HOSTILE_CHIMP")
    SetRelationshipBetweenGroups(5, relationshipGroup, GetHashKey("PLAYER"))
    RequestModel(chimpHash)
    while not HasModelLoaded(chimpHash) do Citizen.Wait(0) end
    local ped = CreatePed(4, chimpHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(chimpHash)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedRelationshipGroupHash(ped, relationshipGroup)
    SetPedHearingRange(ped, 9999.0)
    SetPedConfigFlag(ped, 281, true)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedAccuracy(ped, 100)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
    SetPedSuffersCriticalHits(ped, false)
    GiveWeaponToPed(ped, weaponHash, 9999, true, true)
    TaskCombatPed(ped, playerPed, 0, 16)
end
