function FX_PlayerGravity(alive)
    local playerPed = PlayerPedId()
    while alive() do
        SetEntityHasGravity(playerPed, false)
        local vel = GetEntityVelocity(playerPed)
        SetEntityVelocity(playerPed, vel.x, vel.y, vel.z - 5.0)
        Citizen.Wait(0)
    end
    SetEntityHasGravity(playerPed, true)
end
