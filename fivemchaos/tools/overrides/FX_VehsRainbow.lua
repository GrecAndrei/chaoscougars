function FX_VehsRainbow(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) then
                SetVehicleCustomPrimaryColour(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
                SetVehicleCustomSecondaryColour(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
            end
        end
        Citizen.Wait(500)
    end
end
