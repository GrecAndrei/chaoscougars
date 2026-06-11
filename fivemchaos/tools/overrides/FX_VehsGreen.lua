function FX_VehsGreen(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            ToggleVehicleMod(veh, 20, true)
            SetVehicleTyreSmokeColor(veh, 0, 255, 0)
            SetVehicleCustomPrimaryColour(veh, 0, 255, 0)
            SetVehicleCustomSecondaryColour(veh, 0, 255, 0)
            SetVehicleEnveffScale(veh, 0.0)
            SetVehicleDirtLevel(veh, 0.0)
        end
        Citizen.Wait(0)
    end
end
