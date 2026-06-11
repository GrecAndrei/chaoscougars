function FX_PlayerDrunk(alive)
    RequestAnimSet("move_m@drunk@verydrunk")
    while alive() do
        SetPedMovementClipset(PlayerPedId(), "move_m@drunk@verydrunk", 1.0)
        ShakeGameplayCam("DRUNK_SHAKE", 1.0)
        SetPedIsDrunk(PlayerPedId(), true)
        Citizen.Wait(100)
    end
    ResetPedMovementClipset(PlayerPedId(), 0.0)
    StopGameplayCamShaking(true)
end
