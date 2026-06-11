function FX_PlayervehKillengine(alive)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) then
            SetVehicleEngineHealth(veh, 0.0)
        end
    end
end
