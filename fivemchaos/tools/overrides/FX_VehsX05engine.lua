function FX_VehsX05engine(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            ModifyVehicleTopSpeed(veh, 0.5)
            SetVehicleCheatPowerIncrease(veh, 0.5)
        end
        Citizen.Wait(0)
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        ModifyVehicleTopSpeed(veh, 1.0)
        SetVehicleCheatPowerIncrease(veh, 1.0)
    end
end
