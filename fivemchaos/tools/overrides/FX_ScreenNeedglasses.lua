function FX_ScreenNeedglasses(alive)
    while alive() do
        SetTransitionTimecycleModifier("hud_def_blur", 5.0)
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
