function FX_ScreenLsnoire(alive)
    while alive() do
        SetTimecycleModifier("NG_filmic01")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
