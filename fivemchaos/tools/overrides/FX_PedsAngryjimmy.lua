function FX_PedsAngryjimmy(alive)
    local modelHash = 1459905209
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local group = AddRelationshipGroup("_HOSTILE_JIMMY")
    SetRelationshipBetweenGroups(5, group, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVMALE"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVFEMALE"))
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePed(4, modelHash, playerPos.x, playerPos.y, playerPos.z, 0.0, true, false)
    SetModelAsNoLongerNeeded(modelHash)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedRelationshipGroupHash(ped, group)
    SetPedHearingRange(ped, 9999.0)
    SetPedConfigFlag(ped, 281, true)
    SetEntityProofs(ped, false, true, true, false, false, false, false, false)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetRagdollBlockingFlags(ped, 5)
    SetPedSuffersCriticalHits(ped, false)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_COMBATMG"), 9999, true, true)
    TaskCombatPed(ped, playerPed, 0, 16)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
end
