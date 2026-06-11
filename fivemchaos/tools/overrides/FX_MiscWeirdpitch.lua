function FX_MiscWeirdpitch(alive)
    while alive() do
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.4)
        SetGameplayCamShakeAmplitude(0.4)
        Citizen.Wait(250)
    end
    StopGameplayCamShaking(true)
end
