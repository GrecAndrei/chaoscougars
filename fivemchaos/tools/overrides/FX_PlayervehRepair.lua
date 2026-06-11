function FX_PlayervehRepair(alive)
    local count = 5
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        SetVehicleFixed(veh)
        SetVehicleDirtLevel(veh, 0.0)
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehiclePetrolTankHealth(veh, 1000.0)
        SetVehicleBodyHealth(veh, 1000.0)
        SetVehicleUndriveable(veh, false)
        SetVehicleOnGroundProperly(veh, 5.0)
        count = count - 1
        if count == 0 then
            count = 5
            Citizen.Wait(0)
        end
    end
end
