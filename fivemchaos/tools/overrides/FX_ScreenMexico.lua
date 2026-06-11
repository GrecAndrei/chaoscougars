function FX_ScreenMexico(alive)
    while alive() do
        SetTransitionTimecycleModifier("trevorspliff", 5.0)
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
