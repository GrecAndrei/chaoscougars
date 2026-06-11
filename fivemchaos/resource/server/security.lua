RegisterNetEvent('cc:meta_set', function(key, value)
    local src = source
    if src ~= 0 and not IsPlayerAceAllowed(src, 'chaoscougar.admin') then
        print(('[CC] Blocked meta_set from player %d (%s): %s = %s'):format(
            src, GetPlayerName(src) or '?', tostring(key), tostring(value)))
        return
    end

    local allowed = {
        additionalEffects = true,
        durationModifier = true,
        timerModifier = true,
        votingMode = true,
        disableChaos = true,
        hideChaosUI = true,
    }
    if not allowed[key] then return end

    State.meta[key] = value
    if key == 'hideChaosUI' then
        State.Broadcast('cc:meta_ui', value and true or false)
    end
end)

RegisterNetEvent('cc:meta_set_internal', function(key, value)
    local allowed = {
        additionalEffects = true,
        durationModifier = true,
        timerModifier = true,
        votingMode = true,
        disableChaos = true,
        hideChaosUI = true,
    }
    if not allowed[key] then return end

    State.meta[key] = value
    if key == 'hideChaosUI' then
        State.Broadcast('cc:meta_ui', value and true or false)
    end
end)
