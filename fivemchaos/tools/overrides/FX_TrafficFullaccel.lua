function FX_TrafficFullaccel(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and not IsPedAPlayer(GetPedInVehicleSeat(veh, -1, false)) then
                SetVehicleForwardSpeed(veh, GetVehicleModelEstimatedMaxSpeed(GetEntityModel(veh)) * 2.0)
            end
        end
        Citizen.Wait(250)
    end
end
