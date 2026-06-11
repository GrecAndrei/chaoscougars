function FX_ScreenLocalcoop(alive)
    while alive() do
        SetTimecycleModifier("yell_tunnel_nodirect")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
