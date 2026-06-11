function FX_VehsHonkboost(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and IsHornActive(veh) then
                ApplyForceToEntity(veh, 0, 0.0, 50.0, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end
        Citizen.Wait(0)
    end
end
