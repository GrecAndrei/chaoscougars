function FX_PlayerLaggyCamera(alive)
    while alive() do
        ShakeGameplayCam("HAND_SHAKE", 1.5)
        Citizen.Wait(0)
    end
    StopGameplayCamShaking(true)
end
