--[[
    Vote-to-pause system. Players press a key, votes accumulate,
    threshold triggers pause/unpause.
]]

local votes = {}
local voteExpiry = {}
local lastVoteAt = {}

-- Per-player debounce: prevents a held F9 from spamming cc:vote_pause 60
-- times per second. The FiveM key handler can fire repeatedly while a key
-- is held; without this, the vote count flips on/off faster than the
-- expiry timer can settle, and the broadcast storms every client.
local VOTE_COOLDOWN_MS = 750

RegisterNetEvent('cc:vote_pause', function()
    local src = source
    -- Validate the source is a real connected player (defense against
    -- spoofed NetEvents from REPL or other resources).
    if type(src) ~= 'number' or src < 1 then return end
    if not GetPlayerName(src) then return end

    local now = GetGameTimer()
    if lastVoteAt[src] and (now - lastVoteAt[src]) < VOTE_COOLDOWN_MS then
        return
    end
    lastVoteAt[src] = now

    if votes[src] then
        votes[src] = nil
        voteExpiry[src] = nil
    else
        votes[src] = true
        voteExpiry[src] = now + Config.VoteWindowSec * 1000
    end

    local count = 0
    for _ in pairs(votes) do count = count + 1 end

    State.Broadcast('cc:vote_update', count, Config.PauseThreshold)

    if count >= Config.PauseThreshold then
        if State.phase == 'RUNNING' then
            PauseMission(true)
        elseif State.phase == 'PAUSED' then
            PauseMission(false)
        end
        votes = {}
        voteExpiry = {}
        State.Broadcast('cc:vote_end')
    end
end)

-- Expire old votes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local now = GetGameTimer()
        local hadExpirations = false
        for src, expiry in pairs(voteExpiry) do
            if now > expiry then
                votes[src] = nil
                voteExpiry[src] = nil
                hadExpirations = true
            end
        end
        if hadExpirations then
            local count = 0
            for _ in pairs(votes) do count = count + 1 end
            if count == 0 then
                State.Broadcast('cc:vote_end')
            else
                State.Broadcast('cc:vote_update', count, Config.PauseThreshold)
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    votes[src] = nil
    voteExpiry[src] = nil
    lastVoteAt[src] = nil
end)
