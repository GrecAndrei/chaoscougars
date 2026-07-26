--[[
    Cross-resource API. FiveM resources run in separate Lua VMs, so
    resource_repl / resource_test can NOT read State/Config/Effects as
    globals — they were always nil over there. Everything they need goes
    through these exports (declared in fxmanifest.lua).

    Tables returned here are plain-data copies: FiveM serializes export
    return values, so never hand out live internal tables.
]]

exports('GetState', function()
    return {
        phase = State.phase,
        difficulty = State.difficulty,
        startTime = State.startTime,
        playerCount = State.PlayerCount(),
        aliveCount = State.AliveCount(),
        actIndex = State.actIndex or 0,
        heat = (Heat and Heat.value) or 0,
        meta = {
            additionalEffects = State.meta.additionalEffects,
            durationModifier = State.meta.durationModifier,
            timerModifier = State.meta.timerModifier,
            votingMode = State.meta.votingMode,
            disableChaos = State.meta.disableChaos,
            hideChaosUI = State.meta.hideChaosUI,
        },
    }
end)

exports('GetActiveEffects', function()
    local now = os.time()
    local list = {}
    for _, entry in ipairs(State.activeEffectsList) do
        if entry.expiresAt > now then
            list[#list + 1] = {
                id = entry.id,
                name = entry.name,
                sync_mode = entry.sync_mode,
                remaining = entry.expiresAt - now,
                executorId = entry.executorId,
            }
        end
    end
    return list
end)

exports('GetDirectorSnapshot', function()
    local types = {}
    for _, cougar in pairs(Director.cougars) do
        types[cougar.type] = (types[cougar.type] or 0) + 1
    end
    return {
        active = Director.active,
        count = Director.CountCougars(),
        cap = State.GetMaxCougars(),
        types = types,
    }
end)

exports('GetEffectById', function(id)
    if type(id) ~= 'string' then return nil end
    local fx = Effects.FindById(id)
    if not fx then return nil end
    return {
        id = fx.id,
        name = fx.name,
        fn = fx.fn,
        sync_mode = fx.sync_mode,
        instant = fx.instant or false,
        short = fx.short or false,
        severity = fx.severity or 2,
        runDisabled = fx.runDisabled or false,
    }
end)

-- Dispatch through the exact same path as the chaos loop and admin panel:
-- registry validation, channel reservation, META application, executor
-- selection all apply. Returns true if the effect actually dispatched.
exports('DispatchEffectById', function(id, duration)
    if type(id) ~= 'string' or id == '' then return false end
    local fx = Effects.FindById(id)
    if not fx then return false end
    if type(duration) ~= 'number' or duration <= 0 or duration > 600 then
        duration = fx.instant and 0 or (fx.short and Config.ShortDuration or Config.EffectDuration)
    end
    return Chaos.DispatchEffect(fx, duration, math.random(1, 2147483647)) == true
end)
