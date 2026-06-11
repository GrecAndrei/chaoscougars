function FX_WorldBlackout(alive)
    SetClockTime(0, 0, 0)
    while alive() do
        SetArtificialLightsState(true)
        Citizen.Wait(0)
    end
    SetArtificialLightsState(false)
end
