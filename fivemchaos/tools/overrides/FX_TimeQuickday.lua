function FX_TimeQuickday(alive)
    while alive() do
        AddToClockTime(0, 1, 0)
        Citizen.Wait(0)
    end
end
