function FX_PlayerForcefield(alive)
    while alive() do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed, false)
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and veh ~= playerVeh then
                local pos = GetEntityCoords(veh, false)
                local dist = #(pos - playerPos)
                if dist < 15.0 then
                    local dir = (pos - playerPos) / dist
                    ApplyForceToEntityCenterOfMass(veh, 1, dir.x * 50.0, dir.y * 50.0, 5.0, true, false, true, true)
                end
            end
        end
        Citizen.Wait(0)
    end
end
