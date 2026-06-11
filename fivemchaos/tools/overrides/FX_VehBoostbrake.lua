function FX_VehBoostbrake(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) then
                local speed = GetEntitySpeed(veh)
                if speed > 1.0 and GetEntityHeightAboveGround(veh) <= 2.0 then
                    SetVehicleForwardSpeed(veh, speed * -1.5)
                end
            end
        end
        Citizen.Wait(0)
    end
end
