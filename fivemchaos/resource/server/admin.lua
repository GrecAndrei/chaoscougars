RegisterNetEvent('cc:admin_start', function()
    StartMission()
end)

RegisterNetEvent('cc:admin_stop', function()
    EndMission('LOST', 'Admin stopped')
end)

RegisterNetEvent('cc:admin_pause', function(paused)
    PauseMission(paused)
end)

RegisterNetEvent('cc:admin_effect', function(id)
    local fx = Effects.FindById(id)
    if not fx then return end
    local duration = fx.instant and 0 or (fx.short and Config.ShortDuration or Config.EffectDuration)
    local seed = math.random(1, 2147483647)
    local sync_mode = fx.sync_mode or SyncMode.LOCAL

    if sync_mode == SyncMode.SPAWN_SINGLE then
        local executor = source
        TriggerClientEvent('cc:trigger_effect', executor, fx.id, fx.name, fx.fn, fx.instant, duration, seed)
    else
        TriggerClientEvent('cc:trigger_effect', -1, fx.id, fx.name, fx.fn, fx.instant, duration, seed)
    end
end)

RegisterNetEvent('cc:admin_spawn_cougar', function(cougarType, pos)
    local src = source
    TriggerClientEvent('cc:spawn_cougar', src, cougarType, pos)
end)

RegisterNetEvent('cc:admin_kill_cougars', function()
    TriggerClientEvent('cc:despawn_all_cougars', -1)
    TriggerEvent('cc:director_stop')
    Citizen.Wait(100)
    if State.phase == Phase.RUNNING then
        TriggerEvent('cc:director_start')
    end
end)
