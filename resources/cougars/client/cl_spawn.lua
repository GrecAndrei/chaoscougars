local spawnPoint = nil
local destinationPoint = nil

-- Set spawn and destination on journey start
RegisterNetEvent('cougar:journeyStarted')
AddEventHandler('cougar:journeyStarted', function()
    -- Random spawn locations (one edge of map)
    local spawns = {
        {x = 1550.0, y = 6600.0, z = 20.0, name = "North Edge"},
        {x = -3000.0, y = 3500.0, z = 10.0, name = "West Coast"},
        {x = 2800.0, y = -600.0, z = 70.0, name = "East Hills"}
    }
    
    -- Destinations (opposite edges)
    local destinations = {
        {x = -1000.0, y = -2800.0, z = 13.0, name = "Airport"},
        {x = 450.0, y = -3200.0, z = 6.0, name = "LS Docks"},
        {x = -1800.0, y = -1200.0, z = 13.0, name = "Beach"}
    }
    
    spawnPoint = spawns[math.random(#spawns)]
    destinationPoint = destinations[math.random(#destinations)]
    
    -- Teleport to spawn
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, spawnPoint.x, spawnPoint.y, spawnPoint.z, false, false, false, true)
    
    -- Set waypoint to destination
    SetNewWaypoint(destinationPoint.x, destinationPoint.y)
    
    -- Notification
    TriggerEvent('chat:addMessage', {
        args = {'^2Journey Started', 'Spawned at: ' .. spawnPoint.name .. ' | Destination: ' .. destinationPoint.name}
    })
end)

-- Custom respawn on death
Citizen.CreateThread(function()
    while true do
        Wait(500)
        
        if journeyActive then
            local playerPed = PlayerPedId()
            
            if IsEntityDead(playerPed) then
                -- Wait for respawn
                while IsEntityDead(playerPed) do
                    Wait(100)
                end
                
                -- Respawn at team center
                TriggerServerEvent('cougar:requestRespawnLocation')
            end
        end
    end
end)

RegisterNetEvent('cougar:respawnAt')
AddEventHandler('cougar:respawnAt', function(coords)
    local playerPed = PlayerPedId()
    
    -- Teleport to team
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
    
    -- Heal and give brief invulnerability
    SetEntityHealth(playerPed, 200)
    SetPedArmour(playerPed, 50)
    SetEntityInvincible(playerPed, true)
    
    -- Visual effect
    StartScreenEffect("RaceTurbo", 3000, false)
    
    Wait(3000)
    SetEntityInvincible(playerPed, false)
    
    TriggerEvent('chat:addMessage', {
        args = {'^3Respawned', 'You were teleported to your team'}
    })
end)

print('^2[Spawn System] Loaded^7')