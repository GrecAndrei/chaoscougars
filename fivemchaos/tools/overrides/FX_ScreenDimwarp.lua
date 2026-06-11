function FX_ScreenDimwarp(alive)
    while alive() do
        SetTimecycleModifier("hud_def_blur")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
