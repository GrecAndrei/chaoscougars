function FX_ScreenTextureless(alive)
    while alive() do
        SetTimecycleModifier("int_lesters")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
