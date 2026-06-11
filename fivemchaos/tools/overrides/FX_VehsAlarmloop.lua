function FX_VehsAlarmloop(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) then
                SetVehicleAlarm(veh, true)
                StartVehicleAlarm(veh)
            end
        end
        Citizen.Wait(2000)
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        SetVehicleAlarm(veh, false)
    end
end
