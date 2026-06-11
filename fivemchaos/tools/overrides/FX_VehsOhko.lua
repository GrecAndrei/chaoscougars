function FX_VehsOhko(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and HasEntityCollidedWithAnything(veh) and GetEntitySpeed(veh) > 5.0 then
                ExplodeVehicle(veh, true, false)
            end
        end
        Citizen.Wait(500)
    end
end
