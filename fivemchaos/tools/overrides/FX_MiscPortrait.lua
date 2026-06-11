function FX_MiscPortrait(alive)
    while alive() do
        SetTimecycleModifier("phone_cam1")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
