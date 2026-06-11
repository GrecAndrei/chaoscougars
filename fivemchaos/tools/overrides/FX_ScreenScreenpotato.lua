function FX_ScreenScreenpotato(alive)
    while alive() do
        SetTimecycleModifier("Mp_apart_mid")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
