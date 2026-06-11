function FX_VehsPoptiresconstant(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            for i = 0, 7 do
                SetVehicleTyresCanBurst(veh, true)
                SetVehicleTyreBurst(veh, i, true, 1000.0)
            end
        end
        Citizen.Wait(400)
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        for i = 0, 7 do
            SetVehicleTyreFixed(veh, i)
        end
    end
end
