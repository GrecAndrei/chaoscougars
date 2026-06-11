function FX_VehsSlippery(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) then
                SetVehicleReduceGrip(veh, true)
            end
        end
        Citizen.Wait(0)
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        SetVehicleReduceGrip(veh, false)
    end
end
