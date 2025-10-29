local myStats = {kills = 0, deaths = 0, survivalTime = 0, achievements = {}}
local leaderboard = {full = {}, session = {}}
local showStatsMenu = false

-- Request stats periodically
Citizen.CreateThread(function()
    while true do
        Wait(5000)
        
        if journeyActive then
            TriggerServerEvent('cougar:requestStats')
            TriggerServerEvent('cougar:requestLeaderboard')
        end
    end
end)

-- Receive stats
RegisterNetEvent('cougar:statsUpdate')
AddEventHandler('cougar:statsUpdate', function(stats)
    myStats = stats
end)

RegisterNetEvent('cougar:leaderboardUpdate')
AddEventHandler('cougar:leaderboardUpdate', function(data)
    leaderboard = data
end)

-- Achievement popup
RegisterNetEvent('cougar:achievementUnlocked')
AddEventHandler('cougar:achievementUnlocked', function(achievement)
    -- Visual effect
    PlaySoundFrontend(-1, "MEDAL_BRONZE", "HUD_AWARDS", true)
    StartScreenEffect("RaceTurbo", 2000, false)
    
    -- Show popup for 5 seconds
    local startTime = GetGameTimer()
    
    Citizen.CreateThread(function()
        while GetGameTimer() - startTime < 5000 do
            Wait(0)
            
            -- Background
            DrawRect(0.5, 0.15, 0.35, 0.12, 0, 0, 0, 220)
            DrawRect(0.5, 0.15, 0.35, 0.003, 255, 215, 0, 255)
            
            -- Title
            DrawAdvancedText("ACHIEVEMENT UNLOCKED!", 0.5, 0.10, 0.5, 4, 255, 215, 0, 255, true)
            
            -- Icon and name
            DrawAdvancedText(achievement.icon .. " " .. achievement.name, 0.5, 0.14, 0.45, 4, 255, 255, 255, 255, true)
            
            -- Description
            DrawAdvancedText(achievement.desc, 0.5, 0.175, 0.35, 4, 200, 200, 200, 255, true)
        end
    end)
end)

-- Toggle stats menu with TAB
Citizen.CreateThread(function()
    while true do
        Wait(0)
        
        if journeyActive then
            -- Hold TAB to show
            if IsControlPressed(0, 37) then -- TAB
                showStatsMenu = true
            else
                showStatsMenu = false
            end
            
            if showStatsMenu then
                DrawStatsMenu()
            end
        end
    end
end)

function DrawStatsMenu()
    -- Background
    DrawRect(0.5, 0.5, 0.5, 0.6, 0, 0, 0, 230)
    
    local y = 0.25
    
    -- Title
    DrawAdvancedText("📊 LEADERBOARD & STATS", 0.5, y, 0.6, 4, 100, 255, 100, 255, true)
    y = y + 0.04
    
    -- My stats
    DrawAdvancedText("YOUR STATS", 0.3, y, 0.4, 4, 255, 255, 100, 255, false)
    y = y + 0.025
    
    DrawAdvancedText("Kills: " .. myStats.kills, 0.3, y, 0.35, 4, 255, 255, 255, 255, false)
    y = y + 0.022
    
    DrawAdvancedText("Deaths: " .. myStats.deaths, 0.3, y, 0.35, 4, 255, 255, 255, 255, false)
    y = y + 0.022
    
    DrawAdvancedText("Survival: " .. FormatTime(myStats.survivalTime), 0.3, y, 0.35, 4, 255, 255, 255, 255, false)
    y = y + 0.022
    
    local achievementCount = 0
    for _ in pairs(myStats.achievements) do achievementCount = achievementCount + 1 end
    
    DrawAdvancedText("Achievements: " .. achievementCount .. "/15", 0.3, y, 0.35, 4, 255, 255, 255, 255, false)
    
    -- Top 5 leaderboard
    y = 0.29
    DrawAdvancedText("TOP PLAYERS", 0.65, y, 0.4, 4, 255, 255, 100, 255, false)
    y = y + 0.025
    
    for i = 1, math.min(5, #leaderboard.full) do
        local player = leaderboard.full[i]
        local color = {255, 255, 255}
        
        if i == 1 then color = {255, 215, 0}
        elseif i == 2 then color = {192, 192, 192}
        elseif i == 3 then color = {205, 127, 50} end
        
        DrawAdvancedText(i .. ". " .. player.name .. " - " .. player.kills .. " kills", 0.65, y, 0.32, 4, color[1], color[2], color[3], 255, false)
        y = y + 0.02
    end
    
    -- Session records
    y = y + 0.03
    DrawAdvancedText("SESSION RECORDS", 0.5, y, 0.4, 4, 255, 100, 100, 255, true)
    y = y + 0.025
    
    if leaderboard.session.mostKills.player then
        DrawAdvancedText("🏆 Most Kills: " .. leaderboard.session.mostKills.player .. " (" .. leaderboard.session.mostKills.kills .. ")", 0.5, y, 0.35, 4, 255, 255, 255, 255, true)
        y = y + 0.022
    end
    
    if leaderboard.session.longestSurvival.player then
        DrawAdvancedText("⏱️ Longest Survival: " .. leaderboard.session.longestSurvival.player .. " (" .. FormatTime(leaderboard.session.longestSurvival.time) .. ")", 0.5, y, 0.35, 4, 255, 255, 255, 255, true)
    end
    
    -- Hint
    DrawAdvancedText("Hold TAB to view stats", 0.5, 0.92, 0.3, 4, 150, 150, 150, 255, true)
end

function FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

function DrawAdvancedText(text, x, y, scale, font, r, g, b, a, centered)
    SetTextFont(font)
    SetTextProportional(false)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropshadow(1, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    if centered then SetTextCentre(true) end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

print('^2[Stats Display] Loaded^7')