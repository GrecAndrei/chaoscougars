local hideChaosUI = false

local function SendHud(message)
    if hideChaosUI then return end
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
        SendNUIMessage({type = 'effects_cleared'})
    end
end)

