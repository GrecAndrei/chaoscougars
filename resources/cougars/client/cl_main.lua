
journeyActive = false

local lastDeathState = false

RegisterNetEvent('cougar:journeyStarted')
AddEventHandler('cougar:journeyStarted', function()
    journeyActive = true
    TriggerEvent('cougar:startMission')
end)

RegisterNetEvent('cougar:journeyStopped')
AddEventHandler('cougar:journeyStopped', function()
    journeyActive = false
    TriggerEvent('cougar:stopMission')
    lastDeathState = false
end)

Citizen.CreateThread(function()
    local updateInterval = Config and Config.PositionUpdateRate or 200

    while true do
        Wait(updateInterval)

        if journeyActive then
            local ped = PlayerPedId()

            if DoesEntityExist(ped) then
                local coords = GetEntityCoords(ped)
                TriggerServerEvent('cougar:updatePosition', {x = coords.x, y = coords.y, z = coords.z})

                local isDead = IsEntityDead(ped)
                local health = math.floor(GetEntityHealth(ped))

                TriggerServerEvent('cougar:updatePlayerStatus', health, isDead)

                if isDead and not lastDeathState then
                    TriggerServerEvent('cougar:playerDied')
                end

                lastDeathState = isDead
            end
        end
    end
end)

RegisterCommand('startjourney', function()
    TriggerEvent('cougar:startMission')
    print("^2[JOURNEY] Mission started - Continuous spawning enabled")
end)

RegisterCommand('stopjourney', function()
    TriggerEvent('cougar:stopMission')
    print("^1[JOURNEY] Mission stopped - All cougars cleaned up")
end)
