function FX_VehsX10engine(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            ModifyVehicleTopSpeed(veh, 10.0)
            SetVehicleCheatPowerIncrease(veh, 10.0)
        end
        Citizen.Wait(0)
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        ModifyVehicleTopSpeed(veh, 1.0)
        SetVehicleCheatPowerIncrease(veh, 1.0)
    end
end
