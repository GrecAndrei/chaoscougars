function FX_SpawnBluesultan(alive)
    local playerPed = PlayerPedId()
    local playerHeading = GetEntityHeading(playerPed)

    local heading
    if IsPedInAnyVehicle(playerPed, false) then
        heading = GetEntityHeading(GetVehiclePedIsIn(playerPed, false))
    else
        heading = playerHeading
    end

    local playerPos = GetEntityCoords(playerPed, false)

    local sultanHash = GetHashKey("sultanrs")
    RequestModel(sultanHash)
    while not HasModelLoaded(sultanHash) do Citizen.Wait(0) end

    local veh = CreateVehicle(sultanHash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(sultanHash)
    SetVehicleColours(veh, 64, 64)
    SetVehicleEngineOn(veh, true, true, false)

    local playerGroup = GetHashKey("PLAYER")

    local relationshipGroup
    AddRelationshipGroup("_HOSTILE_IESULTAN", relationshipGroup)
    SetRelationshipBetweenGroups(5, relationshipGroup, playerGroup)
    SetRelationshipBetweenGroups(5, playerGroup, relationshipGroup)
    SetRelationshipBetweenGroups(0, relationshipGroup, relationshipGroup)

    local pedModel = GetHashKey("g_m_m_armboss_01")
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do Citizen.Wait(0) end

    local weaponHash = GetHashKey("WEAPON_MICROSMG")

    local ped = CreatePedInsideVehicle(veh, 4, pedModel, -1, true, false)
    SetPedCombatAttributes(ped, 3, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedRelationshipGroupHash(ped, relationshipGroup)
    SetPedHearingRange(ped, 9999.0)
    GiveWeaponToPed(ped, weaponHash, 9999, true, true)
    SetPedAccuracy(ped, 50)
    TaskCombatPed(ped, playerPed, 0, 16)

    Citizen.Wait(0)

    ped = CreatePedInsideVehicle(veh, 4, pedModel, 0, true, false)
    SetModelAsNoLongerNeeded(pedModel)
    SetPedCombatAttributes(ped, 3, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedRelationshipGroupHash(ped, relationshipGroup)
    SetPedHearingRange(ped, 9999.0)
    GiveWeaponToPed(ped, weaponHash, 9999, true, true)
    SetPedAccuracy(ped, 50)
    TaskCombatPed(ped, playerPed, 0, 16)
end
