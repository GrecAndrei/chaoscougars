function FX_PlayerRagdoll(alive)
    local playerPed = PlayerPedId()
    ClearPedTasksImmediately(playerPed)
    SetPedToRagdoll(playerPed, 10000, 10000, 0, true, true, false)
end
