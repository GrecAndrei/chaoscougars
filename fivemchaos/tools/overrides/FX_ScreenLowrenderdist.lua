function FX_ScreenLowrenderdist(alive)
    while alive() do
        SetTransitionTimecycleModifier("Mp_apart_mid", 5.0)
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
