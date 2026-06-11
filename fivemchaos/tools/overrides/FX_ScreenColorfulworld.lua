function FX_ScreenColorfulworld(alive)
    while alive() do
        SetTimecycleModifier("ufo_deathray")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
