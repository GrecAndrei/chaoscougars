--[[
    Vote-to-pause system. Players press a key, votes accumulate,
    threshold triggers pause/unpause.
]]

local votes = {}
local voteExpiry = {}

RegisterNetEvent('cc:vote_pause', function()
    local src = source
    local now = GetGameTimer()

    if votes[src] then
        votes[src] = nil
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
    end
end)

-- Expire old votes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local now = GetGameTimer()
        for src, expiry in pairs(voteExpiry) do
            if now > expiry then
                votes[src] = nil
                voteExpiry[src] = nil
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    votes[src] = nil
    voteExpiry[src] = nil
end)
