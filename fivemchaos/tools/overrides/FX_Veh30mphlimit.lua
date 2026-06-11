function FX_Veh30mphlimit(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and not IsPedAPlayer(GetPedInVehicleSeat(veh, -1, false)) then
                SetEntityMaxSpeed(veh, 13.41)
            end
        end
        Citizen.Wait(0)
    end
end
