function FX_MiscFlipUi(alive)
    while alive() do
        SetTimecycleModifier("CAMERA_BW")
        SetTimecycleModifierStrength(0.5)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
