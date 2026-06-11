function FX_PlayerNightvision(alive)
    while alive() do
        SetNightvision(true)
        Citizen.Wait(0)
    end
    SetNightvision(false)
end
