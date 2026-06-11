function FX_PlayerFlingPlayer(alive)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed, false)
    AddExplosion(pos.x, pos.y, pos.z - 1.0, 9, 100.0, true, false, 10.0, false)
    SetEntityInvincible(playerPed, true)
    Citizen.Wait(100)
    SetEntityInvincible(playerPed, false)
end
