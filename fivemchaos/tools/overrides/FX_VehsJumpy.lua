function FX_VehsJumpy(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and math.random() < 0.1 and not IsEntityInAir(veh) then
                ApplyForceToEntity(veh, 1, 0.0, 0.0, 10.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end
        Citizen.Wait(100)
    end
end
