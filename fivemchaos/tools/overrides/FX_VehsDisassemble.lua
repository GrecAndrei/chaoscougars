function FX_VehsDisassemble(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    for i = 0, 49 do
        SetVehicleDoorBroken(veh, i, true)
    end
    for i = 0, 7 do
        SetVehicleTyreBurst(veh, i, true, 1000.0)
    end
    SetVehicleEngineHealth(veh, -4000.0)
end
