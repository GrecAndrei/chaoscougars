function FX_PlayervehLock(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            SetVehicleDoorsLocked(veh, 4)
        end
        Citizen.Wait(0)
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        SetVehicleDoorsLocked(veh, 1)
    end
end
