function FX_ScreenLsd(alive)
    while alive() do
        SetTimecycleModifier("drug_drive_blend01")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
