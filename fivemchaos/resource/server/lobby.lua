--[[
    Lobby ready-up. The old flow needed someone at the server console to
    type cc_start; now the squad readies up in-game (E at the lobby) and the
    run launches itself when everyone is in. Console cc_start and the admin
    panel still work as overrides.
]]

local ready = {}

local function ReadyCount()
    local n = 0
    for src in pairs(ready) do
        if State.players[src] then n = n + 1 else ready[src] = nil end
    end
    return n
end

local function BroadcastReady()
    State.Broadcast('cc:ready_count', ReadyCount(), State.PlayerCount())
end

RegisterNetEvent('cc:ready', function()
    local src = source
    if type(src) ~= 'number' or src < 1 then return end
    if not State.players[src] then return end
    if State.phase ~= Phase.LOBBY then return end

    ready[src] = not ready[src] and true or nil
    BroadcastReady()

    local count = ReadyCount()
    if count >= Config.MinPlayers and count >= State.PlayerCount() and count > 0 then
        print(('[CC] Lobby: all %d ready — launching'):format(count))
        StartMission()
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    if ready[src] then
        ready[src] = nil
        if State.phase == Phase.LOBBY then BroadcastReady() end
    end
end)

-- Reset between missions so stale ready flags can't insta-launch the next
-- lobby the moment one player presses E.
AddEventHandler('cc:chaos_start', function() ready = {} end)
AddEventHandler('cc:chaos_stop', function()
    ready = {}
    BroadcastReady()
end)
