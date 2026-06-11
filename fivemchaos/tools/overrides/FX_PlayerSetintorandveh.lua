function FX_PlayerSetintorandveh(alive)
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    local vehs = {}
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) and veh ~= playerVeh and IsVehicleSeatFree(veh, -1, false) then
            table.insert(vehs, veh)
        end
    end
    if #vehs > 0 then
        SetPedIntoVehicle(playerPed, vehs[math.random(#vehs)], -1)
    end
end
