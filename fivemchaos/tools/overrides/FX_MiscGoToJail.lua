function FX_MiscGoToJail(alive)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)

    local carModel = GetHashKey("POLICE2")
    RequestModel(carModel)
    while not HasModelLoaded(carModel) do
        Citizen.Wait(0)
    end

    local car = CreateVehicle(carModel, pos.x, pos.y, pos.z, heading, true, true)
    SetModelAsNoLongerNeeded(carModel)

    local copModel = GetHashKey("S_M_Y_Cop_01")
    RequestModel(copModel)
    while not HasModelLoaded(copModel) do
        Citizen.Wait(0)
    end

    local cop = CreatePedInsideVehicle(car, 4, copModel, -1, true, false)
    SetModelAsNoLongerNeeded(copModel)

    SetPedIntoVehicle(playerPed, car, 1)
    SetVehicleSiren(car, true)

    TaskVehicleDriveToCoordLongrange(cop, car, 473.1, -1023.5, 28.1, 9999.0, 537395716, 10.0)
    SetBlockingOfNonTemporaryEvents(cop, true)

    SetEntityAsNoLongerNeeded(cop)
    SetEntityAsNoLongerNeeded(car)
end
