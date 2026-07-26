local hideChaosUI = false
local nuiReady = false

-- Queue of messages that arrived before the NUI finished loading. The NUI
-- triggers a 'ready' callback via panel.lua's `RegisterNUICallback('ready', ...)`;
-- we drain the queue at that point. Without this, the first ~hundreds of ms
-- of state broadcasts (cc:chaos_tick, cc:cougar_count, etc.) are dropped
-- because the UI page hasn't loaded yet.
local pendingMessages = {}
local MAX_PENDING = 64

-- Last-known snapshot of low-frequency values. cc:cougar_count only fires on
-- change, so while the chaos UI is hidden (meta effect) we would otherwise
-- come back with a stale counter until the next spawn/death. Timer and
-- difficulty rebroadcast every 1-2s and recover on their own.
local lastCougarCount = 0

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
    lastCougarCount = count
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

-- Act transitions are mission structure, not chaos noise: they bypass the
-- hideChaosUI gate on purpose (the "What's Happening??" joke hides effect
-- info, not where you are in the run).
RegisterNetEvent('cc:act', function(index, name, sub)
    if type(name) ~= 'string' then return end
    SendNUIMessage({type = 'act', name = name, sub = sub})
    -- Stinger: act 3 gets the heavy one.
    if index == 3 then
        PlaySoundFrontend(-1, 'RACE_PLACED', 'HUD_AWARDS', false)
    else
        PlaySoundFrontend(-1, 'CHECKPOINT_PERFECT', 'HUD_MINI_GAME_SOUNDSET', false)
    end
end)

RegisterNetEvent('cc:meta_ui', function(hidden)
    hideChaosUI = hidden and true or false
    -- Tell the NUI directly — SendHud would eat this exact message while
    -- hidden, which used to freeze the HUD on screen instead of hiding it
    -- (app.js's 'meta_ui' handler is what toggles the css class).
    SendNUIMessage({type = 'meta_ui', hidden = hideChaosUI})
    if not hideChaosUI then
        -- Coming back: refresh change-driven values that went stale.
        SendNUIMessage({type = 'cougars', count = lastCougarCount})
    end
end)

-- Records: lobby history card + the all-time best. Mission structure, not
-- chaos info — bypasses the hide gate like acts do.
RegisterNetEvent('cc:records', function(payload)
    if type(payload) ~= 'table' then return end
    SendNUIMessage({type = 'records', best = payload.best, today = payload.today,
        last = payload.last, totals = payload.totals})
end)

RegisterNetEvent('cc:new_record', function(timeSec)
    if type(timeSec) ~= 'number' then return end
    SendNUIMessage({type = 'new_record', time = timeSec})
    PlaySoundFrontend(-1, 'CHALLENGE_UNLOCKED', 'HUD_AWARDS', false)
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
