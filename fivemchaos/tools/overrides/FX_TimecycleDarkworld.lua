function FX_TimecycleDarkworld(alive)
    while alive() do
        SetArtificialLightsState(true)
        SetTransitionTimecycleModifier("dlc_island_vault", 5.0)
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    SetArtificialLightsState(false)
    ClearTimecycleModifier()
end
