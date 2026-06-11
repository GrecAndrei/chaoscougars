function FX_ScreenBouncyradar(alive)
    while alive() do
        ShakeGameplayCam("HAND_SHAKE", 0.5)
        Citizen.Wait(0)
    end
    StopGameplayCamShaking(true)
end
