function FX_PedsRoasting(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local group = AddRelationshipGroup("_ROASTING_LAMAR")
    SetRelationshipBetweenGroups(0, group, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), group)
    local lamarModel = GetHashKey("ig_lamardavis")
    RequestModel(lamarModel)
    while not HasModelLoaded(lamarModel) do Citizen.Wait(0) end
    local lamarPed = CreatePed(4, lamarModel, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(lamarModel)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(lamarPed, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedRelationshipGroupHash(lamarPed, group)
    SetPedAsGroupMember(lamarPed, GetPlayerGroup(PlayerId()))
    SetEntityInvincible(lamarPed, true)
    -- Speech is approximated
    Citizen.Wait(1500)
    Citizen.Wait(2500)
end
