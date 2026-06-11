function FX_PlayerKickflip(alive)
    local playerPed = PlayerPedId()
    local entityToFlip
    if IsPedInAnyVehicle(playerPed, false) then
        entityToFlip = GetVehiclePedIsIn(playerPed, false)
    else
        entityToFlip = playerPed
        SetPedToRagdoll(playerPed, 200, 0, 0, true, true, false)
    end
    -- Memory::ApplyForceToEntity(entityToFlip, 1, 0, 0, 10, 2, 0, 0, 0, true, true, true, false, true)
    ApplyForceToEntity(entityToFlip, 1, 0.0, 0.0, 10.0, 2.0, 0.0, 0.0, 0.0, 1, true, true, true, false, true)
end
