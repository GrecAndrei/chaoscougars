function FX_PlayervehPoptires(alive)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        for i = 0, 47 do
            SetVehicleTyresCanBurst(veh, true)
            SetVehicleTyreBurst(veh, i, true, 1000.0)
        end
    end
end
