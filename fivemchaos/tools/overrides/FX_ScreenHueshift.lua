function FX_ScreenHueshift(alive)
    while alive() do
        SetTimecycleModifier("phone_cam8")
        SetTimecycleModifierStrength(0.7)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
