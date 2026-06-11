function FX_ScreenTnpanel(alive)
    while alive() do
        SetTimecycleModifier("Tunnel")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
