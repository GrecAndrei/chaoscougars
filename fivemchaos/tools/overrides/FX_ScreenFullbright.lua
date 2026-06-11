function FX_ScreenFullbright(alive)
    SetClockTime(0, 0, 0)
    while alive() do
        SetTransitionTimecycleModifier("int_lesters", 5.0)
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
