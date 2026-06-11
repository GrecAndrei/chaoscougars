function FX_PedsSpawnSpaceRanger(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local modelHash = GetHashKey("u_m_y_rsranger_01")
    local weaponHash = GetHashKey("WEAPON_RAYCARBINE")
    local relationshipGroup = AddRelationshipGroup("_HOSTILE_SPACE_RANGER")
    SetRelationshipBetweenGroups(5, relationshipGroup, GetHashKey("PLAYER"))
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePed(4, modelHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(modelHash)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedRelationshipGroupHash(ped, relationshipGroup)
    SetPedHearingRange(ped, 9999.0)
    SetPedConfigFlag(ped, 281, true)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedSuffersCriticalHits(ped, false)
    GiveWeaponToPed(ped, weaponHash, 9999, true, true)
    TaskCombatPed(ped, playerPed, 0, 16)
end
