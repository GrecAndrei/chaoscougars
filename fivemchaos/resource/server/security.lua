local CC_META_ALLOWED = {
    additionalEffects = true,
    durationModifier = true,
    timerModifier = true,
    votingMode = true,
    disableChaos = true,
    hideChaosUI = true,
}

-- Returns true if src is the server console (src == 0) or has the admin ACE.
-- `src` is an integer in FiveM but a malicious client can sometimes attempt to
-- spoof via trigger exploits; the IsPlayerAceAllowed call uses FiveM's
-- authoritative server-side check, so this is safe.
local function isAdmin(src)
    if type(src) ~= 'number' then return false end
    src = math.floor(src)
    if src == 0 then return true end
    if src < 1 then return false end
    return IsPlayerAceAllowed(src, 'chaoscougar.admin') == true
end

local function setMeta(key, value, who)
    if type(key) ~= 'string' or key == '' then return false end
    if not CC_META_ALLOWED[key] then
        print(('[CC] [%s] Refused unknown meta key=%s'):format(who, tostring(key)))
        return false
    end
    -- Type-validate each known meta key. Without this a malicious admin could
    -- set `additionalEffects = 1e9` (int overflow in burst loop), or
    -- `durationModifier = -1` (negative duration), or `hideChaosUI = "yes"`
    -- (truthy string vs boolean).
    if key == 'additionalEffects' then
        if type(value) ~= 'number' then return false end
        value = math.floor(value)
        if value < 0 or value > 16 then value = math.max(0, math.min(16, value)) end
    elseif key == 'durationModifier' or key == 'timerModifier' then
        if type(value) ~= 'number' then return false end
        if value < 0.1 or value > 10 then value = math.max(0.1, math.min(10, value)) end
    elseif key == 'votingMode' then
        if type(value) ~= 'string' then return false end
        if value ~= 'none' and value ~= 'pause' and value ~= 'chaos' then return false end
    elseif key == 'disableChaos' or key == 'hideChaosUI' then
        value = (value and value ~= false and value ~= 0) and true or false
    end
    State.meta[key] = value
    if key == 'hideChaosUI' then
        State.Broadcast('cc:meta_ui', value and true or false)
    end
    return true
end

RegisterNetEvent('cc:meta_set', function(key, value)
    local src = source
    if not isAdmin(src) then
        print(('[CC] Blocked meta_set from player %d (%s): %s = %s'):format(
            src, GetPlayerName(src) or '?', tostring(key), tostring(value)))
        return
    end
    setMeta(key, value, 'meta_set')
end)

RegisterNetEvent('cc:meta_set_internal', function(key, value)
    local src = source
    -- SECURITY: previously this handler had no auth check, so any client
    -- could call TriggerServerEvent('cc:meta_set_internal', 'disableChaos',
    -- true) and freeze the chaos loop, or set 'additionalEffects' to a huge
    -- value. Now requires the same admin ACE as cc:meta_set.
    if not isAdmin(src) then
        print(('[CC] Blocked meta_set_internal from player %d (%s): %s = %s'):format(
            src, GetPlayerName(src) or '?', tostring(key), tostring(value)))
        return
    end
    setMeta(key, value, 'meta_set_internal')
end)
