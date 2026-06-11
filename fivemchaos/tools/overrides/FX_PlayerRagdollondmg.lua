function FX_PlayerRagdollondmg(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if HasEntityBeenDamagedByAnyPed(playerPed) or HasEntityBeenDamagedByAnyVehicle(playerPed) then
            ClearEntityLastDamageEntity(playerPed)
            SetPedToRagdoll(playerPed, 750, 750, 0, true, true, false)
        end
        Citizen.Wait(100)
    end
end
