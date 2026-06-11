function FX_VehsBeyblade(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and IsVehicleSeatFree(veh, -1, false) then
                ApplyForceToEntity(veh, 3, 100.0, 0.0, 0.0, 0.0, 4.0, 0.0, 0, true, true, true, true, true)
                ApplyForceToEntity(veh, 3, -100.0, 0.0, 0.0, 0.0, -4.0, 0.0, 0, true, true, true, true, true)
                SetEntityInvincible(veh, true)
            end
        end
        Citizen.Wait(0)
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        SetEntityInvincible(veh, false)
    end
end
