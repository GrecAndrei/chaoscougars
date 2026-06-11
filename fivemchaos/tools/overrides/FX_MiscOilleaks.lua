function FX_MiscOilleaks(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and GetEntitySpeed(veh) > 2.0 then
                SetVehicleEngineHealth(veh, -4000.0)
            end
        end
        Citizen.Wait(2500)
    end
end
