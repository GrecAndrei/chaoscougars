function FX_PlayerSuperrun(alive)
    local playerId = PlayerId()
    while alive() do
        SetRunSprintMultiplierForPlayer(playerId, 1.49)
        SetSuperJumpThisFrame(playerId)
        Citizen.Wait(0)
    end
    SetRunSprintMultiplierForPlayer(playerId, 1.0)
end
