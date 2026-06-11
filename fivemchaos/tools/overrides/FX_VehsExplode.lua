function FX_VehsExplode(alive)
    local playerVeh = GetVehiclePedIsIn(PlayerPedId(), false)
    local count = 3
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if veh ~= playerVeh then
            ExplodeVehicle(veh, true, false)
            count = count - 1
            if count == 0 then
                count = 3
                Citizen.Wait(0)
            end
        end
    end
end
