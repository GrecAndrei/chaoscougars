function FX_ScreenFoldedscreen(alive)
    while alive() do
        SetTimecycleModifier("Tunnel")
        SetTimecycleModifierStrength(0.8)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
