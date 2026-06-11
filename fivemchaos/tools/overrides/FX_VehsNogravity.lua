function FX_VehsNogravity(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) then
                SetVehicleGravity(veh, false)
            end
        end
        Citizen.Wait(0)
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        SetVehicleGravity(veh, true)
    end
end
