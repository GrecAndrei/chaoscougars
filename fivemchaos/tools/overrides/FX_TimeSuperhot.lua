local lastCheck = 0

function FX_TimeSuperhot(alive)
    while alive() do
        local currentTime = GetGameTimer()
        if currentTime - lastCheck > 100 then
            lastCheck = currentTime
            local playerPed = PlayerPedId()
            local gameSpeed = 1.0
            if not IsPedGettingIntoAVehicle(playerPed) and not IsPedClimbing(playerPed)
               and not IsPedDiving(playerPed) and not IsPedJumpingOutOfVehicle(playerPed)
               and not IsPedRagdoll(playerPed) and not IsPedGettingUp(playerPed) then
                local speed = GetEntitySpeed(playerPed)
                gameSpeed = math.max(math.min(speed, 4.0) / 4.0, 0.2)
            end
            SetTimeScale(gameSpeed)
        end
        Citizen.Wait(0)
    end
    SetTimeScale(1.0)
end
