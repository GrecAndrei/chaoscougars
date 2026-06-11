function FX_VehsRed(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            ToggleVehicleMod(veh, 20, true)
            SetVehicleTyreSmokeColor(veh, 255, 0, 0)
            SetVehicleCustomPrimaryColour(veh, 255, 0, 0)
            SetVehicleCustomSecondaryColour(veh, 255, 0, 0)
            SetVehicleEnveffScale(veh, 0.0)
            SetVehicleDirtLevel(veh, 0.0)
        end
        Citizen.Wait(0)
    end
end
