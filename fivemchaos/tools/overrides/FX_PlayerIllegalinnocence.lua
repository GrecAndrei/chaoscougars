function FX_PlayerIllegalinnocence(alive)
    ClearPlayerWantedLevel(PlayerId())
    while alive() do
        SetMaxWantedLevel(0)
        Citizen.Wait(0)
    end
    SetMaxWantedLevel(5)
end
