function FX_ScreenShatteredscreen(alive)
    while alive() do
        SetTimecycleModifier("Broken_camera_fuzz")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
