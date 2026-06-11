function FX_PlayerRocket(alive)
    local playerPed = PlayerPedId()
    local parachuteHash = GetHashKey("GADGET_PARACHUTE")
    ClearPedTasksImmediately(playerPed)
    SetPedToRagdoll(playerPed, 10000, 10000, 0, true, true, false)
    GiveWeaponToPed(playerPed, parachuteHash, 1, true, false)
    local lastTimestamp = GetGameTimer()
    local launchTimer = 5000
    local beepTimer = 5000
    while true do
        SetEntityInvincible(playerPed, true)
        local curTimestamp = GetGameTimer()
        launchTimer = launchTimer - (curTimestamp - lastTimestamp)
        lastTimestamp = curTimestamp
        if launchTimer < beepTimer then
            beepTimer = beepTimer * 0.8
            UseParticleFxAsset("core")
            PlaySoundFromEntity(-1, "Beep_Red", playerPed, "DLC_HEIST_HACKING_SNAKE_SOUNDS", true, false)
            StartParticleFxLoopedOnEntity("exp_air_molotov", playerPed, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, false, false, false)
            SetEntityVelocity(playerPed, 0.0, 0.0, 5.0)
            if launchTimer <= 0 then
                SetEntityHealth(playerPed, 0)
                AddExplosion(
                    GetEntityCoords(playerPed).x, GetEntityCoords(playerPed).y, GetEntityCoords(playerPed).z,
                    9, 100.0, true, false, 3.0, false
                )
                break
            end
        end
        Citizen.Wait(0)
    end
end
