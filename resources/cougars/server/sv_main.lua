-- Global state
JourneySession = {
    active = false,
    players = {}, -- {[source] = {position = vec3, deaths = 0}}
    teamDeaths = 0,
    distanceTraveled = 0,
    startTime = 0,
    cougars = {}, -- {[netId] = {type = 'normal', entity = id, position = vec3}}
    lastSpawnTime = 0,
    lastCropDusterTime = 0
}

-- Utility Functions
function GetPlayerCount()
    local count = 0
    for _ in pairs(JourneySession.players) do
        count = count + 1
    end
    return count
end

function GetTeamCenter()
    if GetPlayerCount() == 0 then return vec3(0, 0, 0) end
    
    local sumX, sumY, sumZ = 0, 0, 0
    for source, data in pairs(JourneySession.players) do
        sumX = sumX + data.position.x
        sumY = sumY + data.position.y
        sumZ = sumZ + data.position.z
    end
    
    local count = GetPlayerCount()
    return vec3(sumX / count, sumY / count, sumZ / count)
end

function GetDifficultyMultiplier()
    local distKm = JourneySession.distanceTraveled / 1000
    
    for i = #Config.DifficultyScaling, 1, -1 do
        if distKm >= Config.DifficultyScaling[i].distance then
            return Config.DifficultyScaling[i].multiplier
        end
    end
    
    return 1.0
end

print('^2[Cougar Journey] Resource started^7')

RegisterNetEvent('cougar:menuAction')
AddEventHandler('cougar:menuAction', function(action)
    print('^2[Menu] Received action: ' .. action .. '^7')
    
    if action == 'start' then
        ExecuteCommand('startjourney')
        TriggerClientEvent('cougar:setPlayerSkills', -1) -- Trigger client event for all players
    elseif action == 'stop' then
        ExecuteCommand('stopjourney')
    elseif action == 'spawn' then
        -- Count current cougars
        local count = 0
        for _ in pairs(JourneySession.cougars) do
            count = count + 1
        end
        
        if count >= Config.MaxAliveCougars then
            print('^1[Menu] Cannot spawn more - limit reached (' .. count .. '/' .. Config.MaxAliveCougars .. ')^7')
            return
        end
        
        -- Spawn only 3 at a time to prevent crashes
        local toSpawn = math.min(3, Config.MaxAliveCougars - count)
        
        for i = 1, toSpawn do
            local center = GetTeamCenter()
            local typeName, typeData = SelectCougarType()
            TriggerClientEvent('cougar:spawnRequest', -1, center, typeName or 'normal', typeData or Config.CougarTypes.normal)
        end
        
        print('^2[Menu] Spawned ' .. toSpawn .. ' cougars (Total: ' .. (count + toSpawn) .. '/' .. Config.MaxAliveCougars .. ')^7')
        
    elseif action == 'cropduster' then
        SpawnCropduster()
        print('^2[Menu] Spawned cropduster^7')
    elseif action == 'chaos' then
        if allChaosEffects and #allChaosEffects > 0 then
            local effect = allChaosEffects[math.random(#allChaosEffects)]
            TriggerSyncedChaosEffect(effect, 20000)
            print('^2[Menu] Chaos: ' .. effect .. '^7')
        end
    end
end)

RegisterNetEvent('cougar:spawnSpecificType')
AddEventHandler('cougar:spawnSpecificType', function(typeName)
    if not Config.CougarTypes[typeName] then
        print('^1Invalid cougar type: ' .. typeName .. '^7')
        return
    end
    
    local typeData = Config.CougarTypes[typeName]
    local center = GetTeamCenter()
    
    TriggerClientEvent('cougar:spawnRequest', -1, center, typeName, typeData)
    
    print('^2[Menu] Spawned ' .. typeName .. ' cougar^7')
end)

-- Player Status Sync
RegisterNetEvent('cougar:updatePlayerStatus')
AddEventHandler('cougar:updatePlayerStatus', function(health, isDead)
    local src = source

    if not JourneySession.active then return end
    if not JourneySession.players[src] then return end

    JourneySession.players[src].health = health
    JourneySession.players[src].isDead = isDead
end)

-- Send team info to requesting client
RegisterNetEvent('cougar:requestTeamInfo')
AddEventHandler('cougar:requestTeamInfo', function()
    local src = source
    
    if not JourneySession.active then return end
    
    local teamData = {}
    
    for playerId, playerData in pairs(JourneySession.players) do
        teamData[playerId] = {
            name = GetPlayerName(playerId),
            deaths = playerData.deaths,
            health = playerData.health or 0,
            isDead = playerData.isDead or false
        }
    end
    
    TriggerClientEvent('cougar:teamUpdate', src, teamData)
end)

RegisterNetEvent('cougar:requestRespawnLocation')
AddEventHandler('cougar:requestRespawnLocation', function()
    local src = source
    
    if not JourneySession.active then return end
    
    local center = GetTeamCenter()
    
    TriggerClientEvent('cougar:respawnAt', src, center)
end)

AddEventHandler('playerDropped', function()
    local src = source

    if JourneySession.players[src] then
        JourneySession.players[src] = nil
    end
end)
