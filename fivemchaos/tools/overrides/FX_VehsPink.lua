function FX_VehsPink(alive)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) then
            SetVehicleCustomPrimaryColour(veh, 255, 105, 180)
            SetVehicleCustomSecondaryColour(veh, 255, 105, 180)
        end
    end
end
