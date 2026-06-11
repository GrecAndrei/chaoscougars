function FX_ScreenInvertedcolors(alive)
    while alive() do
        SetTimecycleModifier("ArenaEMP")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end
