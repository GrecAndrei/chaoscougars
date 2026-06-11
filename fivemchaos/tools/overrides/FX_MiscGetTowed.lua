function FX_MiscGetTowed(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    local vehCoords = GetEntityCoords(veh, false)
    local towHash = GetHashKey("towtruck")
    RequestModel(towHash)
    while not HasModelLoaded(towHash) do Citizen.Wait(0) end
    local towTruck = CreateVehicle(towHash, vehCoords.x + 10.0, vehCoords.y + 10.0, vehCoords.z, 0.0, true, false)
    SetModelAsNoLongerNeeded(towHash)
    SetVehicleOnGroundProperly(towTruck)
    AttachEntityToEntity(veh, towTruck, 0, 0.0, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    local driverHash = GetHashKey("s_m_m_trucker_01")
    RequestModel(driverHash)
    while not HasModelLoaded(driverHash) do Citizen.Wait(0) end
    local driver = CreatePedInsideVehicle(towTruck, 26, driverHash, -1, true, false)
    SetModelAsNoLongerNeeded(driverHash)
    TaskVehicleDriveWander(driver, towTruck, 40.0, 786603)
end
