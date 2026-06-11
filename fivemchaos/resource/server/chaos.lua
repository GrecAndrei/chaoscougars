local Chaos = {
    active = false,
    timer = 0,
    recentEffects = {},
    activeEffects = {},
    maxRecent = 15,
}

local loopRunning = false

local function CleanActiveEffects()
    local now = os.time()
    for id, expiry in pairs(Chaos.activeEffects) do
        if now > expiry then
            Chaos.activeEffects[id] = nil
        end
    end
end

local function DispatchEffect(fx, duration, seed)
    local sync_mode = fx.sync_mode or SyncMode.LOCAL

    if sync_mode == SyncMode.META then
        State.Broadcast('cc:trigger_effect', fx.id, fx.name, fx.fn, fx.instant, duration, seed)
        State.TrackEffect(fx.id, fx.name, fx.fn, sync_mode, duration, seed, nil)

    elseif sync_mode == SyncMode.SPAWN_SINGLE then
        local executor = State.PickExecutor()
        if not executor then return end
        TriggerClientEvent('cc:trigger_effect', executor, fx.id, fx.name, fx.fn, fx.instant, duration, seed)
        State.TrackEffect(fx.id, fx.name, fx.fn, sync_mode, duration, seed, executor)

    else
        State.Broadcast('cc:trigger_effect', fx.id, fx.name, fx.fn, fx.instant, duration, seed)
        if not fx.instant then
            State.TrackEffect(fx.id, fx.name, fx.fn, sync_mode, duration, seed, nil)
        end
    end
end

local function ChaosLoop()
    if loopRunning then return end
    loopRunning = true

    Citizen.CreateThread(function()
        local interval = State.GetChaosInterval()
        Chaos.timer = interval

        while Chaos.active do
            Citizen.Wait(1000)
            Chaos.timer = Chaos.timer - (State.meta.timerModifier or 1.0)

            interval = State.GetChaosInterval()

            State.Broadcast('cc:chaos_tick', math.max(0, math.ceil(Chaos.timer)), math.floor(interval))

            if Chaos.timer <= 0 then
                if not State.meta.disableChaos then
                    CleanActiveEffects()
                    local burst = 1 + math.max(0, tonumber(State.meta.additionalEffects or 0) or 0)
                    for _ = 1, burst do
                        local fx = Effects.GetRandom(Chaos.recentEffects, Chaos.activeEffects)
                        Chaos.recentEffects[fx.id] = true

                        local count = 0
                        for __ in pairs(Chaos.recentEffects) do count = count + 1 end
                        if count > Chaos.maxRecent then Chaos.recentEffects = {} end

                        local duration = fx.instant and 0 or (fx.short and Config.ShortDuration or Config.EffectDuration)
                        duration = math.max(1, math.floor(duration * (State.meta.durationModifier or 1.0)))

                        if not fx.instant then
                            Chaos.activeEffects[fx.id] = os.time() + duration
                        end

                        local seed = math.random(1, 2147483647)
                        DispatchEffect(fx, duration, seed)
                    end
                end

                Chaos.timer = interval
            end
        end

        loopRunning = false
    end)
end

AddEventHandler('cc:chaos_start', function()
    Chaos.active = true
    Chaos.recentEffects = {}
    Chaos.activeEffects = {}
    ChaosLoop()
end)

AddEventHandler('cc:chaos_stop', function()
    Chaos.active = false
    Chaos.timer = 0
    Chaos.activeEffects = {}
    State.Broadcast('cc:clear_effects')
end)

AddEventHandler('cc:chaos_pause', function()
    Chaos.active = false
end)

AddEventHandler('cc:chaos_resume', function()
    Chaos.active = true
    ChaosLoop()
end)

RegisterCommand('cc_effect', function(src, args)
    if src ~= 0 then return end
    local id = args[1]
    if not id then print('[CC] Usage: cc_effect <id>'); return end
    local fx = Effects.FindById(id)
    if not fx then print('[CC] Unknown: ' .. id); return end
    local duration = fx.instant and 0 or (fx.short and Config.ShortDuration or Config.EffectDuration)
    local seed = math.random(1, 2147483647)
    DispatchEffect(fx, duration, seed)
end, false)

RegisterCommand('cc_effects', function(src)
    if src ~= 0 then return end
    for i, fx in ipairs(Effects.Pool) do
        print(('  %02d. %-20s %-15s %s%s'):format(i, fx.id, fx.sync_mode or '?', fx.name, fx.instant and ' [instant]' or ''))
    end
end, false)
