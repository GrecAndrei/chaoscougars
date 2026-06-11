function FX_MiscDvdscreensaver(alive)
    while alive() do
        SetTimecycleModifier("scanline_cam_cheap")
        SetTimecycleModifierStrength(0.5)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
