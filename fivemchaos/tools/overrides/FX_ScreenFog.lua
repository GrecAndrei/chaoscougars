function FX_ScreenFog(alive)
    while alive() do
        SetTransitionTimecycleModifier("prologue_ending_fog", 5.0)
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
