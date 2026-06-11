function FX_PlayerInvincible(alive)
    while alive() do
        SetPlayerInvincible(PlayerId(), true)
        Citizen.Wait(0)
    end
    SetPlayerInvincible(PlayerId(), false)
end
