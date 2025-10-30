-- Global state
JourneySession = {
    active = false,
    players = {}, -- {[source] = {position = vec3, deaths = 0}}
    teamDeaths = 0,
    distanceTraveled = 0,
    startTime = 0,
    cougars = {}, -- {[netId] = {type = 'normal', entity = id, position = vec3}}
    lastSpawnTime = 0,
    lastCropDusterTime = 0,
    spawnController = nil,
    debug = {
        enabled = Config.DebugDefaults.enabled,
        godMode = Config.DebugDefaults.godMode,
        infiniteDeaths = Config.DebugDefaults.infiniteDeaths
    }
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

function GetNearestAlivePlayer(exclude)
    local nearest = nil
    local nearestDist = math.huge
    local excludeId = tonumber(exclude) or exclude
    local reference = JourneySession.players[excludeId]
    local origin = reference and reference.position
    if not origin then
        local ped = GetPlayerPed(excludeId)
        if ped ~= 0 and DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)
            origin = vector3(coords.x, coords.y, coords.z)
        end
    end

    for playerId, data in pairs(JourneySession.players) do
        if playerId ~= excludeId and not data.eliminated then
            local ped = GetPlayerPed(playerId)
            if ped ~= 0 and DoesEntityExist(ped) and not IsEntityDead(ped) then
                local pos = data.position
                if not pos then
                    local coords = GetEntityCoords(ped)
                    pos = vector3(coords.x, coords.y, coords.z)
                end

                local distance = math.huge
                if origin and pos then
                    distance = #(pos - origin)
                end

                if distance < nearestDist then
                    nearestDist = distance
                    nearest = tonumber(playerId) or playerId
                end
            end
        end
    end

    if not nearest then
        for playerId, data in pairs(JourneySession.players) do
            if playerId ~= excludeId and not (data and data.eliminated) then
                nearest = tonumber(playerId) or playerId
                break
            end
        end
    end

    return nearest
end

function RefreshSpawnController()
    local bestKey = nil
    local bestNumeric = nil

    for playerId, data in pairs(JourneySession.players) do
        if data and data.eliminated then goto continue end
        local numericId = tonumber(playerId) or playerId
        local ped = GetPlayerPed(numericId)
        if ped ~= 0 and DoesEntityExist(ped) then
            local numValue = tonumber(numericId)
            if numValue then
                if not bestNumeric or numValue < bestNumeric then
                    bestNumeric = numValue
                    bestKey = numericId
                end
            elseif not bestKey then
                bestKey = numericId
            end
        end
        ::continue::
    end

    JourneySession.spawnController = bestKey
    return bestKey
end

function GetSpawnController()
    if not JourneySession.active then return nil end

    local controller = JourneySession.spawnController
    if controller then
        local data = JourneySession.players[controller] or JourneySession.players[tostring(controller)]
        if data and data.eliminated then
            controller = nil
        end
    end
    if controller then
        local ped = GetPlayerPed(controller)
        if ped ~= 0 and DoesEntityExist(ped) then
            return controller
        end
    end

    return RefreshSpawnController()
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
            local controller = GetSpawnController()
            
            if controller then
                print(string.format('^2[Menu] Requesting %s cougar via controller %s^7', typeName or 'normal', tostring(controller)))
                TriggerClientEvent('cougar:spawnRequest', controller, center, typeName or 'normal', typeData or Config.CougarTypes.normal)
            else
                local players = GetPlayers()
                if #players > 0 then
                    local fallback = tonumber(players[1]) or players[1]
                    print('^3[Menu] No controller - using fallback player ' .. tostring(fallback) .. '^7')
                    TriggerClientEvent('cougar:spawnRequest', fallback, center, typeName or 'normal', typeData or Config.CougarTypes.normal)
                else
                    print('^1[Menu] No players available to spawn cougars^7')
                end
            end
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
    elseif action == 'toggleDebug' then
        JourneySession.debug.enabled = not JourneySession.debug.enabled
        if not JourneySession.debug.enabled then
            JourneySession.debug.godMode = false
            JourneySession.debug.infiniteDeaths = false
        end
        TriggerClientEvent('cougar:debugState', -1, JourneySession.debug)
        print(string.format('^2[Debug] Debug mode %s^7', JourneySession.debug.enabled and 'enabled' or 'disabled'))
    elseif action == 'toggleDebugGod' then
        if not JourneySession.debug.enabled then
            print('^1[Debug] Enable debug mode first^7')
            return
        end
        JourneySession.debug.godMode = not JourneySession.debug.godMode
        TriggerClientEvent('cougar:debugState', -1, JourneySession.debug)
        print(string.format('^2[Debug] God mode %s^7', JourneySession.debug.godMode and 'enabled' or 'disabled'))
    elseif action == 'toggleDebugDeaths' then
        if not JourneySession.debug.enabled then
            print('^1[Debug] Enable debug mode first^7')
            return
        end
        JourneySession.debug.infiniteDeaths = not JourneySession.debug.infiniteDeaths
        TriggerClientEvent('cougar:debugState', -1, JourneySession.debug)
        if JourneySession.debug.infiniteDeaths then
            for playerId, data in pairs(JourneySession.players) do
                data.eliminated = false
                local serverId = tonumber(playerId) or playerId
                TriggerClientEvent('cougar:playerEliminated', -1, serverId, false)
                TriggerClientEvent('cougar:stopSpectate', serverId)
            end
        end
        print(string.format('^2[Debug] Unlimited deaths %s^7', JourneySession.debug.infiniteDeaths and 'enabled' or 'disabled'))
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
    
    local controller = GetSpawnController()
    
    if controller then
        print(string.format('^2[Menu] Requesting %s cougar via controller %s^7', typeName, tostring(controller)))
        TriggerClientEvent('cougar:spawnRequest', controller, center, typeName, typeData)
    else
        local players = GetPlayers()
        if #players > 0 then
            local fallback = tonumber(players[1]) or players[1]
            print('^3[Menu] No controller - using fallback player ' .. tostring(fallback) .. '^7')
            TriggerClientEvent('cougar:spawnRequest', fallback, center, typeName, typeData)
        else
            print('^1[Menu] No players available to spawn cougars^7')
        end
    end
    
    print('^2[Menu] Spawned ' .. typeName .. ' cougar^7')
end)

-- Player Status Sync
RegisterNetEvent('cougar:updatePlayerStatus')
AddEventHandler('cougar:updatePlayerStatus', function(health, isDead)
    local src = source

    if not JourneySession.active then return end
    local playerData = JourneySession.players[src] or JourneySession.players[tostring(src)]
    if not playerData then return end

    playerData.health = health
    playerData.isDead = isDead
end)

-- Send team info to requesting client
RegisterNetEvent('cougar:requestTeamInfo')
AddEventHandler('cougar:requestTeamInfo', function()
    local src = source
    
    if not JourneySession.active then return end
    
    local teamData = {}
    
    for playerId, playerData in pairs(JourneySession.players) do
        local serverId = tonumber(playerId) or playerId
        teamData[tostring(serverId)] = {
            name = GetPlayerName(serverId),
            deaths = playerData.deaths,
            health = playerData.health or 0,
            isDead = playerData.isDead or false,
            eliminated = playerData.eliminated or false
        }
    end
    
    TriggerClientEvent('cougar:teamUpdate', src, teamData)
end)

RegisterNetEvent('cougar:requestRespawnLocation')
AddEventHandler('cougar:requestRespawnLocation', function()
    local src = source
    
    if not JourneySession.active then return end
    local playerData = JourneySession.players[src] or JourneySession.players[tostring(src)]
    if playerData and playerData.eliminated and not JourneySession.debug.infiniteDeaths then
        return
    end
    
    local center = GetTeamCenter()
    
    if playerData then
        playerData.isDead = false
    end
    TriggerClientEvent('cougar:stopSpectate', src)
    TriggerClientEvent('cougar:respawnAt', src, center)
end)

AddEventHandler('playerDropped', function()
    local src = source

    JourneySession.players[src] = nil
    JourneySession.players[tostring(src)] = nil
    if JourneySession.spawnController == src or JourneySession.spawnController == tostring(src) then
        RefreshSpawnController()
    end
end)
