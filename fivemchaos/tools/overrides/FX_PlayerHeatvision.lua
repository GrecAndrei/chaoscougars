function FX_PlayerHeatvision(alive)
    while alive() do
        SetSeethrough(true)
        Citizen.Wait(0)
    end
    SetSeethrough(false)
end
