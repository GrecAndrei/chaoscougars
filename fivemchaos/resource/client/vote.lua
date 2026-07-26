--[[
    Client side of squad effect voting. The server broadcasts 3 candidates
    when the chaos timer expires; players press 1/2/3 to cast (re-pressing
    switches your ballot). The vote panel NUI already renders numbered
    options — this file just feeds it and reads the keys.
]]

local voteActive = false
local voteDeadline = 0

local function PushVote(options, timeLeft, totalPlayers)
    local opts = {}
    for i, option in ipairs(options) do
        opts[i] = {name = option.name, votes = tonumber(option.votes) or 0}
    end
    SendNUIMessage({type = 'vote', options = opts, timeLeft = timeLeft, threshold = totalPlayers})
end

RegisterNetEvent('cc:effect_vote', function(options, windowSec, totalPlayers)
    if type(options) ~= 'table' or #options < 2 then return end
    voteActive = true
    voteDeadline = GetGameTimer() + (tonumber(windowSec) or 8) * 1000
    PushVote(options, tonumber(windowSec) or 8, totalPlayers)
    PlaySoundFrontend(-1, 'TIMER_STOP', 'HUD_MINI_GAME_SOUNDSET', false)
end)

RegisterNetEvent('cc:effect_vote_update', function(options, totalPlayers)
    if not voteActive or type(options) ~= 'table' then return end
    local remaining = math.max(0, math.ceil((voteDeadline - GetGameTimer()) / 1000))
    PushVote(options, remaining, totalPlayers)
end)

RegisterNetEvent('cc:vote_end', function()
    voteActive = false
end)

Citizen.CreateThread(function()
    -- INPUT_SELECT_WEAPON_UNARMED / _MELEE / _SHOTGUN = keyboard 1 / 2 / 3
    local keys = {157, 158, 160}
    while true do
        if voteActive and MyState.phase == Phase.RUNNING then
            Citizen.Wait(0)
            for i, key in ipairs(keys) do
                if IsControlJustPressed(0, key) then
                    TriggerServerEvent('cc:effect_vote_cast', i)
                    PlaySoundFrontend(-1, 'HIGHLIGHT_NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
                end
            end
            if GetGameTimer() > voteDeadline + 1500 then voteActive = false end
        else
            Citizen.Wait(250)
        end
    end
end)
