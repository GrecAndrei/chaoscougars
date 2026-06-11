function FX_MiscCredits(alive)
    while alive() do
        SetTimecycleModifier("Barry1_Stoned")
        SetTimecycleModifierStrength(0.5)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
