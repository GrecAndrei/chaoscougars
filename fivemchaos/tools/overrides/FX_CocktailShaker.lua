function FX_CocktailShaker(alive)
    while alive() do
        for _, obj in ipairs(GetGamePool('CObject')) do
            if DoesEntityExist(obj) and math.random() < 0.05 then
                ApplyForceToEntityCenterOfMass(obj, 1, math.random(-20, 20), math.random(-20, 20), 10.0, false, false, true, false)
            end
        end
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and math.random() < 0.02 then
                ApplyForceToEntityCenterOfMass(veh, 1, math.random(-10, 10), math.random(-10, 10), 5.0, false, false, true, false)
            end
        end
        Citizen.Wait(100)
    end
end
