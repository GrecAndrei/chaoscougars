function FX_PlayervehExplode(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    local lastTimestamp = GetGameTimer()
    local detonateTimer = 5000
    local beepTimer = 5000
    while DoesEntityExist(veh) and alive() do
        Citizen.Wait(0)
        local curTimestamp = GetGameTimer()
        detonateTimer = detonateTimer - (curTimestamp - lastTimestamp)
        lastTimestamp = curTimestamp
        if detonateTimer < beepTimer then
            beepTimer = beepTimer * 0.8
            PlaySoundFromEntity(-1, "Beep_Red", veh, "DLC_HEIST_HACKING_SNAKE_SOUNDS", true, false)
        end
        if detonateTimer <= 0 then
            ExplodeVehicle(veh, true, false)
            break
        end
        if not IsPedInVehicle(playerPed, veh, false) then break end
    end
end
