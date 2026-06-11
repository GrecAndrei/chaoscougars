function FX_PlayerUpupaway(alive)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        local playerVel = GetEntityVelocity(playerVeh)
        SetEntityVelocity(playerVeh, playerVel.x, playerVel.y, 100.0)
    else
        local playerVel = GetEntityVelocity(playerPed)
        SetPedToRagdoll(playerPed, 10000, 10000, 0, true, true, false)
        Citizen.Wait(0)
        SetEntityVelocity(playerPed, playerVel.x, playerVel.y, 100.0)
    end
end
