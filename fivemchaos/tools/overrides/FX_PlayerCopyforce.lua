function FX_PlayerCopyforce(alive)
    while alive() do
        local playerPed = PlayerPedId()
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        if playerVeh ~= 0 then
            local vel = GetEntityVelocity(playerVeh)
            for _, veh in ipairs(GetGamePool('CVehicle')) do
                if DoesEntityExist(veh) and veh ~= playerVeh then
                    ApplyForceToEntityCenterOfMass(veh, 1, vel.x * 5.0, vel.y * 5.0, vel.z, true, false, true, true)
                end
            end
        end
        Citizen.Wait(0)
    end
end
