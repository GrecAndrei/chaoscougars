function FX_VehsChrome(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            ToggleVehicleMod(veh, 20, true)
            SetVehicleTyreSmokeColor(veh, 219, 226, 233)
            ClearVehicleCustomPrimaryColour(veh)
            ClearVehicleCustomSecondaryColour(veh)
            SetVehicleColours(veh, 120, 120)
            SetVehicleEnveffScale(veh, 0.0)
            SetVehicleDirtLevel(veh, 0.0)
        end
        Citizen.Wait(0)
    end
end
