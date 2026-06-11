function FX_PlayervehBreakdoors(alive)
    local count = 10
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        for i = 0, 5 do
            SetVehicleDoorBroken(veh, i, false)
            count = count - 1
            if count == 0 then
                count = 10
                Citizen.Wait(0)
            end
        end
    end
end
