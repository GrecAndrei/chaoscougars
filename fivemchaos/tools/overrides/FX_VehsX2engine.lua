function FX_VehsX2engine(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            ModifyVehicleTopSpeed(veh, 2.0)
            SetVehicleCheatPowerIncrease(veh, 2.0)
        end
        Citizen.Wait(0)
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        ModifyVehicleTopSpeed(veh, 1.0)
        SetVehicleCheatPowerIncrease(veh, 1.0)
    end
end
