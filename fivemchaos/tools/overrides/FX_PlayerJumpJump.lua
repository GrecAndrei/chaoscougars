function FX_PlayerJumpJump(alive)
    while alive() do
        SetSuperJumpThisFrame(PlayerId())
        Citizen.Wait(0)
    end
end
