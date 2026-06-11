function FX_PlayerFakedeath(alive)
    local playerPed = PlayerPedId()
    local currentMode = 0
    local lastModeTime = 0
    local nextModeTime = 0
    RequestScriptAudioBank("OFFMISSION_WASTED", false, -1)
    while currentMode < 4 do
        Citizen.Wait(0)
        if currentMode > 1 then
            HideHudAndRadarThisFrame()
        end
        local curTime = GetGameTimer()
        if curTime - lastModeTime <= nextModeTime then
            -- still waiting, skip rest
        elseif currentMode == 0 then
            nextModeTime = 999999
            lastModeTime = curTime
            currentMode = 1
        elseif currentMode == 1 then
            SetPlayerInvincible(PlayerId(), true)
            if math.random(0, 1) == 0 then
                if not IsPedInAnyVehicle(playerPed, false) then
                    if IsPedOnFoot(playerPed) and GetPedParachuteState(playerPed) == -1 then
                        RequestAnimDict("mp_suicide")
                        while not HasAnimDictLoaded("mp_suicide") do Citizen.Wait(0) end
                        GiveWeaponToPed(playerPed, GetHashKey("WEAPON_PISTOL"), 1, true, true)
                        TaskPlayAnim(playerPed, "mp_suicide", "pistol", 8.0, -1.0, 1150, 1, 0.0, false, false, false)
                        nextModeTime = 750
                    end
                elseif IsPedInAnyVehicle(playerPed, false) then
                    local veh = GetVehiclePedIsIn(playerPed, false)
                    local detonateTimer = 5000
                    local beepTimer = 5000
                    local lastTimestamp = GetGameTimer()
                    local exploding = true
                    while DoesEntityExist(veh) and exploding do
                        Citizen.Wait(0)
                        local curTimestamp = GetGameTimer()
                        detonateTimer = detonateTimer - (curTimestamp - lastTimestamp)
                        lastTimestamp = curTimestamp
                        if detonateTimer < beepTimer then
                            beepTimer = beepTimer * 0.8
                            PlaySoundFromEntity(-1, "Beep_Red", veh, "DLC_HEIST_HACKING_SNAKE_SOUNDS", true, false)
                        end
                        if detonateTimer <= 0 then
                            exploding = false
                            ExplodeVehicle(veh, true, false)
                        end
                        if not IsPedInVehicle(playerPed, veh, false) then
                            exploding = false
                        end
                    end
                    nextModeTime = 2000
                end
            end
            if nextModeTime == 999999 then
                nextModeTime = 2000
            end
            currentMode = 2
            lastModeTime = GetGameTimer()
        elseif currentMode == 2 then
            SetPlayerInvincible(PlayerId(), true)
            PlaySoundFrontend(-1, "Bed", "WastedSounds", true)
            nextModeTime = 5000
            lastModeTime = curTime
            currentMode = 3
        elseif currentMode == 3 then
            SetPlayerInvincible(PlayerId(), true)
            nextModeTime = 1500
            lastModeTime = curTime
            currentMode = 4
        end
    end
    SetPlayerInvincible(PlayerId(), false)
    ClearPedTasksImmediately(playerPed)
    SetEntityHealth(playerPed, 200)
    ReleaseNamedScriptAudioBank("OFFMISSION_WASTED")
end
