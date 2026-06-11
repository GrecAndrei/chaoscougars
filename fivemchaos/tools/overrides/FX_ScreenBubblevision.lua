function FX_ScreenBubblevision(alive)
    while alive() do
        SetTransitionTimecycleModifier("ufo_deathray", 5.0)
        SetTimecycleModifierStrength(1.0)
        SetAudioSpecialEffectMode(1)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
