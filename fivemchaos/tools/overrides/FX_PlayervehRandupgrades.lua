function FX_PlayervehRandupgrades(alive)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) then
            SetVehicleModKit(veh, 0)
            for i = 0, 49 do
                local max = GetNumVehicleMods(veh, i)
                if max > 0 then
                    SetVehicleMod(veh, i, math.random(0, max - 1), true)
                end
            end
        end
    end
end
