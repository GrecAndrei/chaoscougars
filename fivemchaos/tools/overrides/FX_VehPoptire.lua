function FX_VehPoptire(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            for i = 0, 47 do
                if math.random(0, 1) == 1 then
                    SetVehicleTyresCanBurst(veh, true)
                    SetVehicleTyreBurst(veh, i, true, 1000.0)
                else
                    SetVehicleTyreFixed(veh, i)
                end
            end
        end
        Citizen.Wait(1750)
    end
end
