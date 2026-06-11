function FX_PlayervehExit(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            TaskLeaveVehicle(ped, veh, 4160)
        end
    end
end
