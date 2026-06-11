function FX_PedsDriveBackwards(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and IsPedInAnyVehicle(ped, false) then
                local veh = GetVehiclePedIsIn(ped, false)
                SetDriveTaskDrivingStyle(ped, 1024)
                SetVehicleForwardSpeed(veh, -20.0)
            end
        end
        Citizen.Wait(100)
    end
end
