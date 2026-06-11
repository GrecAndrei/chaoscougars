function FX_MiscFakecrash(alive)
    while alive() do
        SetTimecycleModifier("damage")
        SetTimecycleModifierStrength(1.0)
        ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 0.03)
        Citizen.Wait(100)
    end
    ClearTimecycleModifier()
    StopGameplayCamShaking(true)
end
