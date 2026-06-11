function FX_VehsBlue(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            ToggleVehicleMod(veh, 20, true)
            SetVehicleTyreSmokeColor(veh, 0, 0, 255)
            SetVehicleCustomPrimaryColour(veh, 0, 0, 255)
            SetVehicleCustomSecondaryColour(veh, 0, 0, 255)
            SetVehicleEnveffScale(veh, 0.0)
            SetVehicleDirtLevel(veh, 0.0)
        end
        Citizen.Wait(0)
    end
end
