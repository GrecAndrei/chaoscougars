function FX_PedsSpawnballasquad(alive)
    local ballaNames = {-198252413, 588969535, 361513884, -1492432238, -1410400252, 599294057}
    local group = AddRelationshipGroup("_ENEMY_BALLAS")
    SetRelationshipBetweenGroups(5, group, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), group)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(
        IsPedInAnyVehicle(playerPed, false) and GetVehiclePedIsIn(playerPed, false) or playerPed
    )
    local vehHash = GetHashKey("Virgo2")
    RequestModel(vehHash)
    while not HasModelLoaded(vehHash) do Citizen.Wait(0) end
    local veh = CreateVehicle(vehHash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(vehHash)
    SetVehicleColours(veh, 148, 148)
    SetVehicleEngineOn(veh, true, true, false)
    for i = 0, 1 do
        local modelHash = ballaNames[math.random(#ballaNames)]
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
        local ped = CreatePed(4, modelHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
        SetModelAsNoLongerNeeded(modelHash)
        if i == 0 then
            SetPedIntoVehicle(ped, veh, -1)
        else
            SetPedIntoVehicle(ped, veh, 0)
        end
        SetPedCombatAttributes(ped, 3, false)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedRelationshipGroupHash(ped, group)
        SetPedHearingRange(ped, 9999.0)
        GiveWeaponToPed(ped, GetHashKey("WEAPON_MICROSMG"), 9999, true, true)
        SetPedAccuracy(ped, 50)
        TaskCombatPed(ped, playerPed, 0, 16)
    end
end
