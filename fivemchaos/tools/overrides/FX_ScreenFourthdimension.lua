function FX_ScreenFourthdimension(alive)
    while alive() do
        SetTimecycleModifier("phone_cam8")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
