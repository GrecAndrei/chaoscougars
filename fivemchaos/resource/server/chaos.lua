local Chaos = {
    active = false,
    timer = 0,
    recentEffects = {},
    activeEffects = {},
    maxRecent = 15,
    maxConcurrent = 8,
}

local loopRunning = false

-- Per-META-effect reset generation. When the same META effect is dispatched
-- again before its previous reset SetTimeout fires, the generation is bumped
-- and the older SetTimeout becomes a no-op.
local metaResetGens = {}

-- Apply or revert a META effect's server-side state changes. META effects no
-- longer rely on the client firing cc:meta_set_internal (which now requires
-- admin ACE for defense in depth); the server is the source of truth.
local function ApplyMetaChange(fx, on)
    if not fx.meta then return end
    for _, m in ipairs(fx.meta) do
        State.meta[m.key] = on and m.on or m.off
        if m.key == 'hideChaosUI' then
            State.Broadcast('cc:meta_ui', State.meta.hideChaosUI and true or false)
        end
    end
end

local function CleanActiveEffects()
    local now = os.time()
    for id, expiry in pairs(Chaos.activeEffects) do
        if now > expiry then
            Chaos.activeEffects[id] = nil
        end
    end
end

local function DispatchEffect(fx, duration, seed)
    -- Validate that the effect is real and the fn is a known FX_* name from
    -- the registry. Prevents a malicious admin (or future code path) from
    -- passing an arbitrary global function name to the client, where the
    -- effects_runner.lua does `_G[fnName]()` and would happily call
    -- `os.execute` or any other global.
    if not fx or not fx.fn or not Effects._validFns or not Effects._validFns[fx.fn] then
        print(('[CC] Refused to dispatch effect with unknown fn (id=%s)'):format(tostring(fx and fx.id or 'nil')))
        return
    end
    if type(duration) ~= 'number' or duration < 0 or duration > 600 then
        print(('[CC] Refused to dispatch effect with bad duration=%s'):format(tostring(duration)))
        return
    end
    if type(seed) ~= 'number' then
        print(('[CC] Refused to dispatch effect with non-number seed=%s'):format(tostring(seed)))
        return
    end

    local sync_mode = fx.sync_mode or SyncMode.LOCAL

    -- Source the truth from the registry; never trust the caller's instant flag.
    local instant = fx.instant and true or false
    if instant then duration = 0 end

    if sync_mode == SyncMode.META then
        -- Apply server-side meta state BEFORE broadcasting. The client
        -- META effect body becomes a no-op (just `while alive() do wait end`).
        ApplyMetaChange(fx, true)
        if not instant then
            local id = fx.id
            local gen = (metaResetGens[id] or 0) + 1
            metaResetGens[id] = gen
            SetTimeout(duration * 1000, function()
                if metaResetGens[id] ~= gen then return end
                ApplyMetaChange(fx, false)
            end)
        end
        State.Broadcast('cc:trigger_effect', fx.id, fx.name, fx.fn, instant, duration, seed)
        State.TrackEffect(fx.id, fx.name, fx.fn, sync_mode, duration, seed, nil)

    elseif sync_mode == SyncMode.SPAWN_SINGLE then
        local executor = State.PickExecutor()
        if not executor then return end
        TriggerClientEvent('cc:trigger_effect', executor, fx.id, fx.name, fx.fn, instant, duration, seed)
        State.TrackEffect(fx.id, fx.name, fx.fn, sync_mode, duration, seed, executor)

    else
        State.Broadcast('cc:trigger_effect', fx.id, fx.name, fx.fn, instant, duration, seed)
        if not instant then
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
                    -- Cap the number of concurrently-active non-instant
                    -- effects so the client doesn't end up running 15+ loops
                    -- per frame (Citizen.Wait(0) tight loops, RenderScriptCams,
                    -- SetTimecycleModifier, etc.) which causes FPS drops.
                    local concurrent = 0
                    for _ in pairs(Chaos.activeEffects) do concurrent = concurrent + 1 end
                    if concurrent >= Chaos.maxConcurrent then
                        Chaos.timer = interval
                        goto continue
                    end
                    local burst = 1 + math.max(0, tonumber(State.meta.additionalEffects or 0) or 0)
                    for _ = 1, burst do
                        if concurrent >= Chaos.maxConcurrent then break end
                        local fx = Effects.GetRandom(Chaos.recentEffects, Chaos.activeEffects)
                        if not fx then break end
                        Chaos.recentEffects[fx.id] = true

                        local count = 0
                        for __ in pairs(Chaos.recentEffects) do count = count + 1 end
                        if count > Chaos.maxRecent then Chaos.recentEffects = {} end

                        local duration = fx.instant and 0 or (fx.short and Config.ShortDuration or Config.EffectDuration)
                        duration = math.max(1, math.floor(duration * (State.meta.durationModifier or 1.0)))

                        if not fx.instant then
                            Chaos.activeEffects[fx.id] = os.time() + duration
                            concurrent = concurrent + 1
                        end

                        local seed = math.random(1, 2147483647)
                        DispatchEffect(fx, duration, seed)
                    end
                end

                Chaos.timer = interval
                ::continue::
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
    Chaos.recentEffects = {}
    -- Cancel any pending meta reset timers. The SetTimeouts will still fire,
    -- but each will see its generation is no longer current and become a
    -- no-op. This guarantees a clean reset on next mission start.
    metaResetGens = {}
    State.Broadcast('cc:clear_effects')
    -- Despawn cougars and spawned-ped corpses too. cc:despawn_all_cougars is
    -- also broadcast on mission end (via cc:director_stop), so this is
    -- defensive — in the current flow both fire, but the spawner is now
    -- idempotent (Cleanup claims activeCougars first).
    State.Broadcast('cc:despawn_all_cougars')
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
