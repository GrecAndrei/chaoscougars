function FX_PlayerIgnite(alive)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        SetVehicleEngineHealth(playerVeh, -1.0)
        SetVehiclePetrolTankHealth(playerVeh, -1.0)
        SetVehicleBodyHealth(playerVeh, -1.0)
    else
        StartEntityFire(playerPed)
        Citizen.Wait(5000)
        StopEntityFire(playerPed)
    end
end
