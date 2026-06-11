function FX_ScreenScreenfreakout(alive)
    while alive() do
        SetTimecycleModifier("trevorspliff")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
