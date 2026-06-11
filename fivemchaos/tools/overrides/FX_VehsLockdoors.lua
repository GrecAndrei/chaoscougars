function FX_VehsLockdoors(alive)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) then
            SetVehicleDoorsLocked(veh, 2)
        end
    end
end
