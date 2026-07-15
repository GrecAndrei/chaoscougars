Chaos = {
    active = false,
    timer = 0,
    recentEffects = {},
    activeEffects = {},
    activeChannels = {},
    maxRecent = 15,
    maxConcurrent = 8,
}

local loopRunning = false

-- Per-META-effect reset generation. When the same META effect is dispatched
-- again before its previous reset SetTimeout fires, the generation is bumped
-- and the older SetTimeout becomes a no-op.
local metaResetGens = {}
local activeMetaEffects = {}
local metaSequence = 0
local META_DEFAULTS = {
    additionalEffects = 0,
    durationModifier = 1.0,
    timerModifier = 1.0,
    votingMode = 'none',
    disableChaos = false,
    hideChaosUI = false,
}

-- Apply or revert a META effect's server-side state changes. META effects no
-- longer rely on the client firing cc:meta_set_internal (which now requires
-- admin ACE for defense in depth); the server is the source of truth.
--
-- Per-entry validation: a corrupt or future-modified registry entry could
-- have a non-string key or nil on/off values, which would wipe State.meta.
-- We re-route every entry through State.setMeta (defined in security.lua)
-- which type-validates, clamps, and broadcasts hideChaosUI updates.
local function ApplyMetaChange(fx, on)
    if not fx.meta then return end
    if type(fx.meta) ~= 'table' then return end

    if on then
        metaSequence = metaSequence + 1
        local values = {}
        for _, m in ipairs(fx.meta) do
            if type(m) == 'table' and type(m.key) == 'string' then values[m.key] = m.on end
        end
        activeMetaEffects[fx.id] = {sequence = metaSequence, values = values}
    else
        activeMetaEffects[fx.id] = nil
    end

    -- META effects can overlap (for example two timer-speed modifiers).
    -- Recompute each affected key from the latest active effect instead of
    -- blindly writing its default when one of the effects ends.
    for _, m in ipairs(fx.meta) do
        if type(m) == 'table' and type(m.key) == 'string' then
            local winner, winnerSequence = nil, -1
            for _, active in pairs(activeMetaEffects) do
                if active.values[m.key] ~= nil and active.sequence > winnerSequence then
                    winner = active.values[m.key]
                    winnerSequence = active.sequence
                end
            end
            local value = winner ~= nil and winner or META_DEFAULTS[m.key]
            if State.setMeta then State.setMeta(m.key, value, 'meta_apply') end
        end
    end
end

local function CleanActiveEffects()
    local now = os.time()
    for id, entry in pairs(Chaos.activeEffects) do
        local expiresAt = type(entry) == 'table' and entry.expiresAt or entry
        if type(expiresAt) ~= 'number' or now >= expiresAt then
            if type(entry) == 'table' then
                for _, channel in ipairs(entry.channels or {}) do
                    local remaining = (Chaos.activeChannels[channel] or 1) - 1
                    Chaos.activeChannels[channel] = remaining > 0 and remaining or nil
                end
            end
            Chaos.activeEffects[id] = nil
        end
    end
end

-- Reserve persistent state before broadcasting so an automatic burst and a
-- manual cc_effect command cannot both start incompatible effects in the
-- same server tick.  The server is the single arbiter; clients never have to
-- guess which cleanup routine should win.
local function ReserveEffect(fx, duration)
    if fx.instant then return true end
    CleanActiveEffects()
    if Effects.ConflictsWithActive(fx, Chaos.activeEffects, Chaos.activeChannels) then
        print(('[CC] Skipped conflicting effect: %s'):format(fx.id))
        return false
    end

    local channels = fx.channels or {}
    Chaos.activeEffects[fx.id] = {
        expiresAt = os.time() + duration,
        channels = channels,
    }
    for _, channel in ipairs(channels) do
        Chaos.activeChannels[channel] = (Chaos.activeChannels[channel] or 0) + 1
    end
    return true
end

local function DispatchEffect(fx, duration, seed, preferredExecutor)
    -- Validate that the effect is real and the fn is a known FX_* name from
    -- the registry. Prevents a malicious admin (or future code path) from
    -- passing an arbitrary global function name to the client, where the
    -- effects_runner.lua does `_G[fnName]()` and would happily call
    -- `os.execute` or any other global.
    if not fx or not fx.id or type(fx.id) ~= 'string' then
        print(('[CC] Refused to dispatch effect with bad id (fx=%s)'):format(tostring(fx and fx.id or 'nil')))
        return false
    end
    if not Effects._byId or not Effects._byId[fx.id] then
        print(('[CC] Refused to dispatch effect not in registry (id=%s)'):format(fx.id))
        return false
    end
    -- Source id/fn from the registry rather than trusting the caller's table.
    -- A caller could construct a fake fx object that shares the id but points
    -- fn at a global like `os.execute`.
    local registered = Effects._byId[fx.id]
    fx = registered
    if not fx.fn or not Effects._validFns or not Effects._validFns[fx.fn] then
        print(('[CC] Refused to dispatch effect with unknown fn (id=%s)'):format(fx.id))
        return false
    end
    if type(duration) ~= 'number' or duration < 0 or duration > 600 then
        print(('[CC] Refused to dispatch effect with bad duration=%s'):format(tostring(duration)))
        return false
    end
    if type(seed) ~= 'number' then
        print(('[CC] Refused to dispatch effect with non-number seed=%s'):format(tostring(seed)))
        return false
    end

    local sync_mode = fx.sync_mode or SyncMode.LOCAL
    if not Effects._validSyncModes or not Effects._validSyncModes[sync_mode] then
        print(('[CC] Refused to dispatch effect with bad sync_mode (id=%s, sync=%s)'):format(fx.id, tostring(sync_mode)))
        return false
    end

    -- Source the truth from the registry; never trust the caller's instant flag.
    local instant = fx.instant and true or false
    if instant then duration = 0 end

    if sync_mode == SyncMode.META then
        if not fx.meta or type(fx.meta) ~= 'table' then
            print(('[CC] Refused to dispatch META effect without meta table (id=%s)'):format(fx.id))
            return false
        end
        if not ReserveEffect(fx, duration) then return false end
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
        local executor = preferredExecutor
        if not executor or not State.players[executor] or not State.players[executor].alive then
            executor = State.PickExecutor()
        end
        if not executor then return false end
        if not ReserveEffect(fx, duration) then return false end
        TriggerClientEvent('cc:trigger_effect', executor, fx.id, fx.name, fx.fn, instant, duration, seed)
        State.TrackEffect(fx.id, fx.name, fx.fn, sync_mode, duration, seed, executor)

    else
        if not ReserveEffect(fx, duration) then return false end
        State.Broadcast('cc:trigger_effect', fx.id, fx.name, fx.fn, instant, duration, seed)
        if not instant then
            State.TrackEffect(fx.id, fx.name, fx.fn, sync_mode, duration, seed, nil)
        end
    end
    return true
end

-- Admin controls use this entry point so manual effects receive the exact
-- same META application, active-effect tracking, and executor rules as the
-- automatic chaos loop.
function Chaos.DispatchEffect(fx, duration, seed, preferredExecutor)
    return DispatchEffect(fx, duration, seed, preferredExecutor)
end

local function ChaosLoop()
    if loopRunning then return end
    loopRunning = true

    -- On first start (not a resume), seed the timer to the full interval so
    -- the chaos effect doesn't fire immediately. On resume, leave Chaos.timer
    -- alone so the player doesn't lose time on the clock.
    if not Chaos.resumeInProgress then
        Chaos.timer = State.GetChaosInterval()
    end
    Chaos.resumeInProgress = false

    Citizen.CreateThread(function()
        local interval = State.GetChaosInterval()

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
                        local fx = Effects.GetRandom(Chaos.recentEffects, Chaos.activeEffects, Chaos.activeChannels)
                        if not fx then break end

                        local duration = fx.instant and 0 or (fx.short and Config.ShortDuration or Config.EffectDuration)
                        duration = math.max(1, math.floor(duration * (State.meta.durationModifier or 1.0)))
                        local seed = math.random(1, 2147483647)
                        if DispatchEffect(fx, duration, seed) then
                            Chaos.recentEffects[fx.id] = true
                            local count = 0
                            for __ in pairs(Chaos.recentEffects) do count = count + 1 end
                            if count > Chaos.maxRecent then Chaos.recentEffects = {} end
                            if not fx.instant then concurrent = concurrent + 1 end
                        end
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
    Chaos.resumeInProgress = false
    Chaos.recentEffects = {}
    Chaos.activeEffects = {}
    Chaos.activeChannels = {}
    activeMetaEffects = {}
    ChaosLoop()
    print('[CC] Chaos started; maxRecent=' .. Chaos.maxRecent .. ' maxConcurrent=' .. Chaos.maxConcurrent)
end)

AddEventHandler('cc:chaos_stop', function()
    Chaos.active = false
    Chaos.timer = 0
    Chaos.activeEffects = {}
    Chaos.activeChannels = {}
    Chaos.recentEffects = {}
    Chaos.resumeInProgress = false
    -- Cancel any pending meta reset timers. The SetTimeouts will still fire,
    -- but each will see its generation is no longer current and become a
    -- no-op. This guarantees a clean reset on next mission start.
    -- Do not reset the generation table.  Reusing generation 1 after a
    -- stop/start lets an old SetTimeout cancel a newly-dispatched META effect.
    -- Bump every known generation instead, invalidating every pending timer.
    for id, gen in pairs(metaResetGens) do metaResetGens[id] = gen + 1 end
    activeMetaEffects = {}
    State.Broadcast('cc:clear_effects')
    -- Despawn cougars and spawned-ped corpses too. cc:despawn_all_cougars is
    -- also broadcast on mission end (via cc:director_stop), so this is
    -- defensive — in the current flow both fire, but the spawner is now
    -- idempotent (Cleanup claims activeCougars first).
    State.Broadcast('cc:despawn_all_cougars')
    print('[CC] Chaos stopped')
end)

AddEventHandler('cc:chaos_pause', function()
    Chaos.active = false
end)

AddEventHandler('cc:chaos_resume', function()
    Chaos.active = true
    Chaos.resumeInProgress = true
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

RegisterCommand('cc_active', function(src)
    if src ~= 0 then return end
    local now = os.time()
    print('[CC] Active effects:')
    if #State.activeEffectsList == 0 then print('  (none)') end
    for i, entry in ipairs(State.activeEffectsList) do
        local remaining = math.max(0, entry.expiresAt - now)
        print(('  %02d. %-22s %-15s %s expires=%ds seed=%s'):format(
            i, entry.id, entry.sync_mode or '?', entry.name or '?', remaining, tostring(entry.seed)))
    end
    print('[CC] Recent effects:')
    local n = 0
    for id, _ in pairs(Chaos.recentEffects) do
        n = n + 1
        print('  ' .. id)
    end
    if n == 0 then print('  (none)') end
end, false)
