PlayerStats = {}
SessionLeaderboard = {
    mostKills = {player = nil, kills = 0},
    longestSurvival = {player = nil, time = 0},
    mostDistance = {player = nil, distance = 0}
}

-- Initialize player stats
function InitPlayerStats(playerId)
    PlayerStats[playerId] = {
        kills = 0,
        deaths = 0,
        survivalTime = 0,
        distanceTraveled = 0,
        damageDealt = 0,
        cougarsSpawned = 0,
        sessionsPlayed = 0,
        achievements = {}
    }
end

-- Comprehensive Cougar Death Handler
RegisterNetEvent('cougar:died')
AddEventHandler('cougar:died', function(netId, cougarType)
    local cougarEntity = NetToEntity(netId)
    if not DoesEntityExist(cougarEntity) then return end

    local killer = GetPedSourceOfDeath(cougarEntity)
    local killerPlayer = nil

    -- Check if killer is a player
    if IsEntityAPed(killer) and IsPedAPlayer(killer) then
        for _, id in ipairs(GetPlayers()) do
            if GetPlayerPed(id) == killer then
                killerPlayer = id
                break
            end
        end
    end

    if killerPlayer then
        local src = killerPlayer
        if not PlayerStats[src] then
            InitPlayerStats(src)
        end
        
        PlayerStats[src].kills = PlayerStats[src].kills + 1
        
        if PlayerStats[src].kills > SessionLeaderboard.mostKills.kills then
            SessionLeaderboard.mostKills.player = GetPlayerName(src)
            SessionLeaderboard.mostKills.kills = PlayerStats[src].kills
        end
        
        CheckAchievements(src, 'kills', PlayerStats[src].kills)
        TriggerClientEvent('cougar:myKill', src, cougarType)
    end

    -- Handle loot drops and other death events
    if JourneySession.cougars[netId] then
        local cougarData = JourneySession.cougars[netId]
        local typeData = Config.CougarTypes[cougarData.type]

        if typeData and typeData.dropOnDeath then
            TriggerClientEvent('cougar:spawnLoot', -1, cougarData.position, typeData.dropOnDeath)
        end

        if cougarData.type == 'beeper' and typeData then
            AddExplosion(cougarData.position.x, cougarData.position.y, cougarData.position.z, 2, typeData.explosionDamage, true, false, typeData.explosionRadius)
        end

        JourneySession.cougars[netId] = nil
    end
end)

-- Update survival time
Citizen.CreateThread(function()
    while true do
        Wait(1000)
        
        if JourneySession.active then
            for playerId, playerData in pairs(JourneySession.players) do
                if not PlayerStats[playerId] then
                    InitPlayerStats(playerId)
                end
                
                if not playerData.isDead then
                    PlayerStats[playerId].survivalTime = PlayerStats[playerId].survivalTime + 1
                    
                    if PlayerStats[playerId].survivalTime > SessionLeaderboard.longestSurvival.time then
                        SessionLeaderboard.longestSurvival.player = GetPlayerName(playerId)
                        SessionLeaderboard.longestSurvival.time = PlayerStats[playerId].survivalTime
                    end
                end
            end
        end
    end
end)

-- Send stats to client
RegisterNetEvent('cougar:requestStats')
AddEventHandler('cougar:requestStats', function()
    local src = source
    
    if not PlayerStats[src] then
        InitPlayerStats(src)
    end
    
    TriggerClientEvent('cougar:statsUpdate', src, PlayerStats[src])
end)

-- Send leaderboard to client
RegisterNetEvent('cougar:requestLeaderboard')
AddEventHandler('cougar:requestLeaderboard', function()
    local src = source
    
    local fullBoard = {}
    for playerId, stats in pairs(PlayerStats) do
        table.insert(fullBoard, {
            name = GetPlayerName(playerId),
            kills = stats.kills,
            deaths = stats.deaths,
            survivalTime = stats.survivalTime,
            distance = stats.distanceTraveled
        })
    end
    
    table.sort(fullBoard, function(a, b) return a.kills > b.kills end)
    
    TriggerClientEvent('cougar:leaderboardUpdate', src, {
        full = fullBoard,
        session = SessionLeaderboard
    })
end)

print('^2[Stats System] Loaded^7')