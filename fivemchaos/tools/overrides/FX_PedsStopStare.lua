function FX_PedsStopStare(alive)
    local playerPed = PlayerPedId()
    for _, ped in ipairs(GetGamePool('CPed')) do
        if IsPedInAnyVehicle(ped, true) then
            local veh = GetVehiclePedIsIn(ped, true)
            TaskLeaveVehicle(ped, veh, 256)
            BringVehicleToHalt(veh, 0.1, 10, 0)
        end
        if ped ~= playerPed then
            TaskTurnPedToFaceEntity(ped, playerPed, -1)
            TaskLookAtEntity(ped, playerPed, -1, 2048, 3)
        end
    end
end
