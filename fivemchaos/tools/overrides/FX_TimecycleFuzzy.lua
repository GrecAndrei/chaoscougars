function FX_TimecycleFuzzy(alive)
    while alive() do
        SetTransitionTimecycleModifier("Broken_camera_fuzz", 5.0)
        SetTimecycleModifierStrength(0.5)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
