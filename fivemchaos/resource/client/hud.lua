local hideChaosUI = false
local nuiReady = false

-- Queue of messages that arrived before the NUI finished loading. The NUI
-- triggers a 'ready' callback via panel.lua's `RegisterNUICallback('ready', ...)`;
-- we drain the queue at that point. Without this, the first ~hundreds of ms
-- of state broadcasts (cc:chaos_tick, cc:cougar_count, etc.) are dropped
-- because the UI page hasn't loaded yet.
local pendingMessages = {}
local MAX_PENDING = 64

local function SendHud(message)
    if hideChaosUI then return end
    if not nuiReady then
        if #pendingMessages < MAX_PENDING then
            pendingMessages[#pendingMessages + 1] = message
        end
        return
    end
    SendNUIMessage(message)
end

RegisterNetEvent('cc:chaos_tick', function(remaining, total)
    SendHud({type = 'timer', remaining = remaining, total = total})
end)

RegisterNetEvent('cc:cougar_count', function(count)
    SendHud({type = 'cougars', count = count})
end)

RegisterNetEvent('cc:vote_update', function(count, threshold)
    SendHud({type = 'vote', options = {{name = 'Pause', votes = count}}, timeLeft = 5, threshold = threshold})
end)

RegisterNetEvent('cc:vote_end', function()
    SendHud({type = 'vote_end'})
end)

RegisterNetEvent('cc:player_died', function(serverId, aliveCount)
    local name = GetPlayerName(GetPlayerFromServerId(serverId)) or 'Someone'
    SendHud({type = 'death', player = name, alive = aliveCount})
end)

RegisterNetEvent('cc:difficulty', function(diff)
    SendHud({type = 'difficulty', value = diff})
end)

RegisterNetEvent('cc:meta_ui', function(hidden)
    hideChaosUI = hidden and true or false
    if hideChaosUI then
        SendHud({type = 'effects_cleared'})
    end
end)

-- NUI 'ready' callback: drain queued messages. Registered here (rather than
-- in panel.lua) so that all HUD broadcasts are guaranteed to be drained in
-- the same callback order they were queued. FiveM invokes every matching
-- callback for a given name, so this handler complements the one in
-- panel.lua that signals the NUI is interactive.
RegisterNUICallback('ready', function(_, cb)
    nuiReady = true
    local q = pendingMessages
    pendingMessages = {}
    for i = 1, #q do
        SendNUIMessage(q[i])
    end
    cb({})
end)

