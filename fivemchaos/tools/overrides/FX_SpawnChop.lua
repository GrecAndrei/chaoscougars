function FX_SpawnChop(alive)
    local modelHash = GetHashKey("a_c_chop")
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePed(28, modelHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(modelHash)
    SetPedCombatAttributes(ped, 0, false)
    SetPedHearingRange(ped, 9999.0)
    SetPedRelationshipGroupHash(ped, GetHashKey("_COMPANION_CHOP"))
    SetPedAsGroupMember(ped, GetPlayerGroup(PlayerId()))
end
