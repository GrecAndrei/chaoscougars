function FX_PedsSpawnfancats(alive)
    local modelHash = GetHashKey("a_c_cat_01")
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local relationshipGroup = AddRelationshipGroup("_FAN_CATS")
    SetRelationshipBetweenGroups(0, relationshipGroup, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), relationshipGroup)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    for i = 1, 3 do
        local ped = CreatePed(28, modelHash, playerPos.x, playerPos.y, playerPos.z, 0.0, true, false)
        SetPedRelationshipGroupHash(ped, relationshipGroup)
        SetPedAsGroupMember(ped, GetPlayerGroup(PlayerId()))
    end
    SetModelAsNoLongerNeeded(modelHash)
end
