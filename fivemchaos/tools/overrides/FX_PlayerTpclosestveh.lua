function FX_PlayerTpclosestveh(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    local closestVeh = 0
    local closestDist = 9999.0
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) and veh ~= playerVeh then
            local vehPos = GetEntityCoords(veh, false)
            local dist = #(vehPos - playerPos)
            if dist < closestDist then
                closestVeh = veh
                closestDist = dist
            end
        end
    end
    if closestVeh ~= 0 and IsVehicleSeatFree(closestVeh, -1, false) then
        SetPedIntoVehicle(playerPed, closestVeh, -1)
    end
end
