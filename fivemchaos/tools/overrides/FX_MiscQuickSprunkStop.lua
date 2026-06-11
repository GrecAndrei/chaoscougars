function FX_MiscQuickSprunkStop(alive)
    while alive() do
        SetTimeScale(0.5)
        Citizen.Wait(2500)
        SetTimeScale(2.0)
        Citizen.Wait(2500)
    end
    SetTimeScale(1.0)
end
