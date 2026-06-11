function FX_VehBrakeboost(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) then
                local vehClass = GetVehicleClass(veh)
                if vehClass ~= 15 and vehClass ~= 16 then
                    ApplyForceToEntity(veh, 0, 0.0, 50.0, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                end
            end
        end
        Citizen.Wait(0)
    end
end
