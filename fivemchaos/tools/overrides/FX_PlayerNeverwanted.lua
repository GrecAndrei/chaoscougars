function FX_PlayerNeverwanted(alive)
    while alive() do
        SetPlayerWantedLevel(PlayerId(), 0, false)
        SetPlayerWantedLevelNow(PlayerId(), true)
        Citizen.Wait(0)
    end
end
