journeyActive = journeyActive or false
teamDeaths = teamDeaths or 0
maxDeaths = maxDeaths or 2
localCougars = localCougars or {}

local myStats = {
    kills = 0,
    deaths = 0,
    survivalTime = 0,
    distanceTraveled = 0.0
}

local teamMembers = {}
local currentChaosEffect = "None"
local chaosEffectEndTime = 0
local journeyStartTime = 0

-- Journey start
RegisterNetEvent('cougar:journeyStarted')
AddEventHandler('cougar:journeyStarted', function()
    journeyActive = true
    journeyStartTime = GetGameTimer()
    myStats.survivalTime = 0
   myStats.kills = 0
   myStats.deaths = 0
   print('^2[HUD] Journey started, stats reset^7')
end)

RegisterNetEvent('cougar:journeyStopped')
AddEventHandler('cougar:journeyStopped', function()
    journeyActive = false
    currentChaosEffect = "None"
    chaosEffectEndTime = 0
    print('^2[HUD] Journey stopped^7')
end)

-- Survival timer
Citizen.CreateThread(function()
    while true do
        Wait(1000)
        
        if journeyActive and journeyStartTime > 0 then
            myStats.survivalTime = math.floor((GetGameTimer() - journeyStartTime) / 1000)
        end
    end
end)

-- Kill tracking (LOCAL event from cl_journey.lua)
RegisterNetEvent('cougar:myKill')
AddEventHandler('cougar:myKill', function(cougarType)
    myStats.kills = myStats.kills + 1
    print('^2[HUD] Kill registered! Total: ' .. myStats.kills .. '^7')
end)

-- Death tracking
Citizen.CreateThread(function()
    local wasAlive = true
    
    while true do
        Wait(1000)
        
        if journeyActive then
            local playerPed = PlayerPedId()
            local isAlive = not IsEntityDead(playerPed)
            
            if wasAlive and not isAlive then
                myStats.deaths = myStats.deaths + 1
                print('^1[HUD] Death registered! Total: ' .. myStats.deaths .. '^7')
            end
            
            wasAlive = isAlive
        end
    end
end)

-- Server updates
RegisterNetEvent('cougar:teamUpdate')
AddEventHandler('cougar:teamUpdate', function(teamData)
    teamMembers = teamData
end)

RegisterNetEvent('cougar:distanceUpdate')
AddEventHandler('cougar:distanceUpdate', function(distKm)
    myStats.distanceTraveled = distKm
end)

RegisterNetEvent('cougar:triggerChaosEffect')
AddEventHandler('cougar:triggerChaosEffect', function(effectId, duration)
    currentChaosEffect = effectId:gsub("_", " "):upper()
    chaosEffectEndTime = GetGameTimer() + duration
end)

-- Request updates
Citizen.CreateThread(function()
    while true do
        Wait(2000)
        
        if journeyActive then
            TriggerServerEvent('cougar:requestTeamInfo')
            TriggerServerEvent('cougar:requestDistance')
        end
    end
end)

-- Main HUD rendering
Citizen.CreateThread(function()
    while true do
        Wait(0)
        
        if journeyActive then
            local aliveCougars = 0
            if localCougars then
                for netId, data in pairs(localCougars) do
                    if DoesEntityExist(data.entity) and not IsEntityDead(data.entity) then
                        aliveCougars = aliveCougars + 1
                    end
                end
            end
            
            if GetGameTimer() > chaosEffectEndTime then
                currentChaosEffect = "None"
            end
            
            local teamCount = 0
            for _ in pairs(teamMembers) do teamCount = teamCount + 1 end
            
            local hudHeight = 0.22 + (teamCount * 0.02)
            local hudX = 0.15
            local hudY = 0.05 + (hudHeight / 2)
            
            -- Background
            DrawRect(hudX, hudY, 0.22, hudHeight, 0, 0, 0, 210)
            DrawRect(hudX, 0.05, 0.22, 0.003, 100, 255, 100, 255)
            
            local y = 0.03
            local leftX = 0.05
            
            -- Title
            DrawCleanText("COUGAR JOURNEY", hudX, y, 0.55, 4, 100, 255, 100, 255, true)
            y = y + 0.035
            
            -- Section: Your Stats
            DrawCleanText("YOUR STATS", leftX, y, 0.35, 4, 255, 255, 100, 255, false)
            y = y + 0.023
            
            -- Kills
            DrawCleanText("Kills: " .. myStats.kills, leftX, y, 0.38, 4, 255, 255, 255, 255, false)
            y = y + 0.020
            
            -- Deaths
            local dr, dg, db = 255, 255, 255
            if myStats.deaths >= 2 then dr, dg, db = 255, 50, 50
            elseif myStats.deaths >= 1 then dr, dg, db = 255, 150, 0 end
            
            DrawCleanText("Deaths: " .. myStats.deaths, leftX, y, 0.38, 4, dr, dg, db, 255, false)
            y = y + 0.020
            
            -- Time
            DrawCleanText("Time: " .. FormatTime(myStats.survivalTime), leftX, y, 0.38, 4, 100, 200, 255, 255, false)
            y = y + 0.020
            
            -- Distance
            DrawCleanText("Distance: " .. string.format("%.1f", myStats.distanceTraveled) .. " km", leftX, y, 0.38, 4, 150, 255, 150, 255, false)
            y = y + 0.028
            
            -- Section: Threats
            DrawCleanText("THREATS", leftX, y, 0.35, 4, 255, 100, 100, 255, false)
            y = y + 0.023
            
            -- Cougars
            local cr, cg, cb = 150, 255, 150
            if aliveCougars > 30 then cr, cg, cb = 255, 50, 50
            elseif aliveCougars > 15 then cr, cg, cb = 255, 150, 0 end
            
            DrawCleanText("Cougars: " .. aliveCougars, leftX, y, 0.38, 4, cr, cg, cb, 255, false)
            y = y + 0.020
            
            -- Team Deaths
            local tdr, tdg, tdb = 150, 255, 150
            if teamDeaths >= maxDeaths then tdr, tdg, tdb = 255, 50, 50
            elseif teamDeaths >= maxDeaths - 1 then tdr, tdg, tdb = 255, 150, 0 end
            
            DrawCleanText("Team Deaths: " .. teamDeaths .. "/" .. maxDeaths, leftX, y, 0.38, 4, tdr, tdg, tdb, 255, false)
            y = y + 0.028
            
            -- Chaos effect
            if currentChaosEffect ~= "None" then
                DrawCleanText("CHAOS ACTIVE", leftX, y, 0.35, 4, 200, 100, 255, 255, false)
                y = y + 0.023
                
                local timeLeft = math.ceil((chaosEffectEndTime - GetGameTimer()) / 1000)
                DrawCleanText(currentChaosEffect:sub(1, 18), leftX, y, 0.30, 4, 255, 150, 255, 255, false)
                y = y + 0.018
                
                DrawCleanText("(" .. timeLeft .. "s remaining)", leftX, y, 0.28, 4, 200, 150, 200, 255, false)
                y = y + 0.025
            end
            
            -- Team members
            if teamCount > 1 then
                DrawCleanText("TEAM (" .. teamCount .. ")", leftX, y, 0.32, 4, 150, 255, 150, 255, false)
                y = y + 0.020
                
                for playerId, data in pairs(teamMembers) do
                    local hr, hg, hb = 0, 255, 0
                    if data.health < 50 then hr, hg, hb = 255, 150, 0
                    elseif data.health < 25 then hr, hg, hb = 255, 50, 50 end
                    
                    if data.isDead then hr, hg, hb = 150, 150, 150 end
                    
                    local status = data.isDead and "[DEAD]" or ("[" .. data.health .. "%]")
                    local nameShort = string.sub(data.name, 1, 10)
                    
                    DrawCleanText(nameShort .. " " .. status, leftX, y, 0.28, 4, hr, hg, hb, 255, false)
                    y = y + 0.018
                end
            end
        end
    end
end)

function DrawCleanText(text, x, y, scale, font, r, g, b, a, centered)
    SetTextFont(font)
    SetTextProportional(false)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropshadow(2, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    if centered then SetTextCentre(true) end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

print('^2[HUD] Clean HUD loaded (no emojis)^7')
