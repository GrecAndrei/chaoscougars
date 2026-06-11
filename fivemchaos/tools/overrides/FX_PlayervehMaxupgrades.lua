function FX_PlayervehMaxupgrades(alive)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) then
            SetVehicleModKit(veh, 0)
            for i = 0, 49 do
                local max = GetNumVehicleMods(veh, i)
                if max > 0 then
                    SetVehicleMod(veh, i, max - 1, true)
                    ToggleVehicleMod(veh, i, true)
                end
            end
            SetVehicleTyresCanBurst(veh, false)
            SetVehicleWindowTint(veh, 1)
            SetVehicleCustomPrimaryColour(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
            SetVehicleCustomSecondaryColour(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
            for i = 0, 3 do
                SetVehicleNeonLightEnabled(veh, i, true)
            end
        end
    end
end
