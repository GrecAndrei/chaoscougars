function FX_VehsSpamdoors(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            for i = 0, 5 do
                SetVehicleDoorOpen(veh, i, false, false)
                SetVehicleDoorCanBreak(veh, i, false)
            end
        end
        Citizen.Wait(500)
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            SetVehicleDoorsShut(veh, false)
        end
        Citizen.Wait(500)
    end
end
