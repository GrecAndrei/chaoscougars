function FX_PlayerHeal(alive)
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    SetPedArmour(playerPed, 100)
    AddArmourToPed(playerPed, 100)
end
