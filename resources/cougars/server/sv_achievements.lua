Achievements = {
    -- Kills
    first_blood = {name = "First Blood", desc = "Kill your first cougar", icon = "🩸", requirement = 1, type = "kills"},
    hunter = {name = "Hunter", desc = "Kill 10 cougars", icon = "🎯", requirement = 10, type = "kills"},
    exterminator = {name = "Exterminator", desc = "Kill 50 cougars", icon = "💀", requirement = 50, type = "kills"},
    apex_predator = {name = "Apex Predator", desc = "Kill 100 cougars", icon = "👑", requirement = 100, type = "kills"},
    
    -- Survival
    survivor = {name = "Survivor", desc = "Survive for 5 minutes", icon = "⏱️", requirement = 300, type = "survival"},
    endurance = {name = "Endurance", desc = "Survive for 15 minutes", icon = "💪", requirement = 900, type = "survival"},
    immortal = {name = "Immortal", desc = "Survive for 30 minutes", icon = "✨", requirement = 1800, type = "survival"},
    
    -- Distance
    traveler = {name = "Traveler", desc = "Travel 2 km", icon = "🚶", requirement = 2000, type = "distance"},
    explorer = {name = "Explorer", desc = "Travel 5 km", icon = "🗺️", requirement = 5000, type = "distance"},
    odyssey = {name = "Odyssey", desc = "Travel 10 km", icon = "🌍", requirement = 10000, type = "distance"},
    
    -- Special
    zero_deaths = {name = "Flawless", desc = "Complete journey with 0 deaths", icon = "💎", requirement = 1, type = "special"},
    team_player = {name = "Team Player", desc = "Revive 5 teammates", icon = "❤️", requirement = 5, type = "special"},
    chaos_master = {name = "Chaos Master", desc = "Survive 20 chaos effects", icon = "🎭", requirement = 20, type = "special"},
    cougar_whisperer = {name = "Cougar Whisperer", desc = "Kill all cougar types", icon = "🐆", requirement = 10, type = "special"}
}

function CheckAchievements(playerId, statType, value)
    if not PlayerStats[playerId] then return end
    
    for achievementId, data in pairs(Achievements) do
        -- Skip if already unlocked
        if PlayerStats[playerId].achievements[achievementId] then
            goto continue
        end
        
        local unlocked = false
        
        if statType == 'kills' and data.type == 'kills' then
            if value >= data.requirement then
                unlocked = true
            end
        elseif statType == 'survival' and data.type == 'survival' then
            if value >= data.requirement then
                unlocked = true
            end
        elseif statType == 'distance' and data.type == 'distance' then
            if value >= data.requirement then
                unlocked = true
            end
        end
        
        if unlocked then
            PlayerStats[playerId].achievements[achievementId] = true
            
            -- Notify player
            TriggerClientEvent('cougar:achievementUnlocked', playerId, {
                id = achievementId,
                name = data.name,
                desc = data.desc,
                icon = data.icon
            })
            
            -- Notify everyone
            TriggerClientEvent('chat:addMessage', -1, {
                args = {'^3Achievement', GetPlayerName(playerId) .. ' unlocked: ' .. data.icon .. ' ' .. data.name}
            })
            
            print('^2[Achievement] ' .. GetPlayerName(playerId) .. ' unlocked: ' .. data.name .. '^7')
        end
        
        ::continue::
    end
end

-- Update distance achievements
RegisterNetEvent('cougar:distanceUpdated')
AddEventHandler('cougar:distanceUpdated', function(distance)
    local src = source
    
    if not PlayerStats[src] then
        InitPlayerStats(src)
    end
    
    PlayerStats[src].distanceTraveled = distance
    
    CheckAchievements(src, 'distance', distance)
end)

print('^2[Achievements System] Loaded^7')