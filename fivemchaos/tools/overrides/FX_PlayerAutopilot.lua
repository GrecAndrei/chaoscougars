function FX_PlayerAutopilot(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    ClearPedTasksImmediately(playerPed)
    TaskVehicleDriveWander(playerPed, veh, 40.0, 786603)
    while alive() do
        Citizen.Wait(0)
    end
end
