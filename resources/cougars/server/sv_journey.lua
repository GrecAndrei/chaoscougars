-- Start Journey Command
RegisterCommand('startjourney', function(source, args, rawCommand)
    if JourneySession.active then
        print('^1[Error] Journey already in progress!^7')
        return
    end
    
    -- Initialize session
    JourneySession.active = true
    JourneySession.teamDeaths = 0
    JourneySession.distanceTraveled = 0
    JourneySession.startTime = os.time()
    JourneySession.players = {}
    JourneySession.cougars = {}
    JourneySession.lastCenter = nil -- Add this line
    
    -- Get all players
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local playerPed = GetPlayerPed(playerId)
        local coords = GetEntityCoords(playerPed)
        
        JourneySession.players[playerId] = {
            position = vector3(coords.x, coords.y, coords.z),
            deaths = 0,
            health = GetEntityHealth(playerPed),
            isDead = false
        }
    end
    
    -- Notify all clients
    TriggerClientEvent('cougar:journeyStarted', -1)
    
    print('^2[Cougar Journey] Session started with ' .. GetPlayerCount() .. ' players^7')
end, false)

-- Stop Journey Command
RegisterCommand('stopjourney', function(source, args, rawCommand)
    if not JourneySession.active then
        if source and source > 0 then
            TriggerClientEvent('chat:addMessage', source, {
                args = {'^1Error', 'No journey in progress!'}
            })
        else
            print("Error: No journey in progress!")
        end
        return
    end
    
    -- Clean up all cougars
    for netId, cougarData in pairs(JourneySession.cougars) do
        if DoesEntityExist(cougarData.entity) then
            DeleteEntity(cougarData.entity)
        end
    end
    
    JourneySession.active = false
    JourneySession.cougars = {}
    
    TriggerClientEvent('cougar:journeyStopped', -1)
    
    print('^2[Cougar Journey] Session ended^7')
end, false)

-- Request HUD Data
RegisterNetEvent('cougar:requestHudData')
AddEventHandler('cougar:requestHudData', function()
    local src = source
    
    if JourneySession.active then
        TriggerClientEvent('cougar:updateHudData', src, 
            JourneySession.teamDeaths, 
            GetPlayerCount(), 
            JourneySession.distanceTraveled)
    end
end)

-- Player Position Update
RegisterNetEvent('cougar:updatePosition')
AddEventHandler('cougar:updatePosition', function(position)
    local src = source
    
    if not JourneySession.active then return end
    
    local pos = vector3(position.x or 0.0, position.y or 0.0, position.z or 0.0)
    
    if not JourneySession.players[src] then
        JourneySession.players[src] = {
            position = pos,
            deaths = 0,
            health = 0,
            isDead = false
        }
    else
        JourneySession.players[src].position = pos
    end
end)

-- Player Death
RegisterNetEvent('cougar:playerDied')
AddEventHandler('cougar:playerDied', function()
    local src = source
    
    if not JourneySession.active then return end
    if not JourneySession.players[src] then return end
    
    JourneySession.teamDeaths = JourneySession.teamDeaths + 1
    JourneySession.players[src].deaths = JourneySession.players[src].deaths + 1
    
    -- Check for game over
    if JourneySession.teamDeaths >= Config.MaxTeamDeaths then
        TriggerClientEvent('cougar:gameOver', -1, 'deaths')
        
        -- Reset after 10 seconds
        SetTimeout(10000, function()
            ExecuteCommand('stopjourney')
        end)
    else
        -- Notify team
        TriggerClientEvent('cougar:deathUpdate', -1, JourneySession.teamDeaths, Config.MaxTeamDeaths)
    end
end)

-- Rubber Band Check Thread
Citizen.CreateThread(function()
    while true do
        Wait(Config.PositionUpdateRate)
        
        if JourneySession.active and GetPlayerCount() > 0 then
            local center = GetTeamCenter()
            
            -- Check each player's distance from center
            for source, data in pairs(JourneySession.players) do
                local playerPed = GetPlayerPed(source)
                if DoesEntityExist(playerPed) then
                    local dist = #(data.position - center)
                    
                    if dist > Config.RubberBandRadius then
                        -- Teleport player back to center
                        SetEntityCoords(playerPed, center.x, center.y, center.z)
                        TriggerClientEvent('chat:addMessage', source, {
                            args = {'^3Warning', 'You strayed too far from the team!'}
                        })
                    end
                end
            end
        end
    end
end)

-- Distance Tracking System
Citizen.CreateThread(function()
    while true do
        Wait(1000) -- Update every second
        
        if JourneySession.active and GetPlayerCount() > 0 then
            local currentCenter = GetTeamCenter()
            
            if JourneySession.lastCenter then
                local moved = #(currentCenter - JourneySession.lastCenter)
                JourneySession.distanceTraveled = JourneySession.distanceTraveled + moved
            end
            
            JourneySession.lastCenter = currentCenter
        end
    end
end)

-- Distance Request Handler
RegisterNetEvent('cougar:requestDistance')
AddEventHandler('cougar:requestDistance', function()
    local src = source
    
    if not JourneySession.active then return end
    
    -- Calculate total distance traveled (rough estimate)
    -- In a full implementation, you'd track cumulative movement
    local distKm = JourneySession.distanceTraveled / 1000
    
    TriggerClientEvent('cougar:distanceUpdate', src, distKm)
end)
