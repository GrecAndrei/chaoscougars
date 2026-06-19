State = {
    phase = Phase.LOBBY,
    players = {},
    startTime = 0,
    difficulty = 0.0,
    activeEffectsList = {},
    spawnLoad = {},
    meta = {
        additionalEffects = 0,
        durationModifier = 1.0,
        timerModifier = 1.0,
        votingMode = 'none',
        disableChaos = false,
        hideChaosUI = false,
    },
}

function State.ResetMeta()
    State.meta = {
        additionalEffects = 0,
        durationModifier = 1.0,
        timerModifier = 1.0,
        votingMode = 'none',
        disableChaos = false,
        hideChaosUI = false,
    }
    State.Broadcast('cc:meta_ui', State.meta.hideChaosUI)
end

function State.PlayerCount()
    local n = 0
    for _ in pairs(State.players) do n = n + 1 end
    return n
end

function State.AliveCount()
    local n = 0
    for _, p in pairs(State.players) do
        if p.alive then n = n + 1 end
    end
    return n
end

function State.Broadcast(event, ...)
    -- Defensive: prevent a bug or future code path from passing a string-typed
    -- event name (TriggerClientEvent will throw a confusing native error).
    if type(event) ~= 'string' or event == '' then
        print(('[CC] State.Broadcast refused non-string event=%s'):format(tostring(event)))
        return
    end
    -- Cap the payload to roughly FiveM's per-event size limit (~64KB after
    -- protocol overhead). FiveM will refuse oversized events with a generic
    -- "ERR_NETWORK_MESSAGE_TOO_LARGE" and the player gets a desync.
    local args = {...}
    local size = #event
    for i = 1, select('#', ...) do
        local a = select(i, ...)
        local t = type(a)
        if t == 'string' then size = size + #a
        elseif t == 'table' then size = size + 256
        elseif t == 'number' or t == 'boolean' then size = size + 8
        else size = size + 64 end
    end
    if size > 32768 then
        print(('[CC] State.Broadcast refused oversized payload event=%s size=%d'):format(event, size))
        return
    end
    TriggerClientEvent(event, -1, ...)
end

function State.Scale(base, target, exponent)
    exponent = exponent or Config.DifficultyExponent
    local t = State.difficulty ^ exponent
    return base + (target - base) * t
end

function State.GetChaosInterval()
    return State.Scale(Config.ChaosIntervalBase, Config.ChaosIntervalMin)
end

function State.GetMaxCougars()
    return math.floor(State.Scale(Config.MaxCougarsBase, Config.MaxCougarsMax))
end

function State.GetSpawnCooldown()
    return State.Scale(Config.SpawnCooldownBase, Config.SpawnCooldownMin)
end

function State.GetSpawnAhead()
    return State.Scale(Config.SpawnAheadBase, Config.SpawnAheadMin)
end

function State.UpdateDifficulty()
    local totalDist = #(Config.Start - Config.Finish)
    local bestProgress = 0.0
    for _, p in pairs(State.players) do
        if p.alive and p.pos then
            local toFinish = #(p.pos - Config.Finish)
            local progress = math.max(0, 1.0 - toFinish / totalDist)
            if progress > bestProgress then bestProgress = progress end
        end
    end
    State.difficulty = math.min(1.0, math.max(0.0, bestProgress))
end

function State.TrackEffect(id, name, fn, sync_mode, duration, seed, executorId)
    State.activeEffectsList[#State.activeEffectsList + 1] = {
        id = id,
        name = name,
        fn = fn,
        sync_mode = sync_mode,
        expiresAt = os.time() + duration,
        seed = seed,
        executorId = executorId,
    }
end

function State.CleanExpiredEffects()
    local now = os.time()
    local cleaned = {}
    for _, entry in ipairs(State.activeEffectsList) do
        if entry.expiresAt > now then
            cleaned[#cleaned + 1] = entry
        end
    end
    State.activeEffectsList = cleaned
end

function State.PickExecutor()
    local best, bestLoad = nil, 99999
    for id, p in pairs(State.players) do
        if p.alive then
            local load = State.spawnLoad[id] or 0
            if load < bestLoad then
                best = id
                bestLoad = load
            end
        end
    end
    return best
end

-- === PLAYER EVENTS ===

RegisterNetEvent('cc:join', function()
    local src = source
    State.players[src] = {
        name = GetPlayerName(src),
        alive = true,
        pos = vector3(0, 0, 0),
    }
    State.spawnLoad[src] = 0
    TriggerClientEvent('cc:state', src, State.phase, State.startTime)

    if State.phase == Phase.RUNNING or State.phase == Phase.PAUSED then
        TriggerEvent('cc:player_joined_running', src)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    State.players[src] = nil
    State.spawnLoad[src] = nil
    if State.phase == Phase.RUNNING and State.AliveCount() < Config.MinSurvivors then
        EndMission('LOST', 'Not enough players')
    end
end)

RegisterNetEvent('cc:pos', function(pos)
    local src = source
    if State.players[src] then
        State.players[src].pos = pos
    end
end)

RegisterNetEvent('cc:died', function()
    local src = source
    if not State.players[src] or not State.players[src].alive then return end
    State.players[src].alive = false
    State.Broadcast('cc:player_died', src, State.AliveCount())

    if State.phase == Phase.RUNNING and State.AliveCount() < Config.MinSurvivors then
        EndMission('LOST', 'All players dead')
    end
end)

RegisterNetEvent('cc:respawned', function()
    local src = source
    if State.players[src] then
        State.players[src].alive = true
        State.players[src].pos = Config.Start
    end
end)

RegisterNetEvent('cc:reached_finish', function()
    local src = source
    if State.phase == Phase.RUNNING then
        local name = State.players[src] and State.players[src].name or 'Unknown'
        EndMission('WON', name .. ' reached Paleto Bay')
    end
end)

RegisterNetEvent('cc:spawn_load_inc', function()
    local src = source
    State.spawnLoad[src] = (State.spawnLoad[src] or 0) + 1
end)

RegisterNetEvent('cc:spawn_load_dec', function()
    local src = source
    State.spawnLoad[src] = math.max(0, (State.spawnLoad[src] or 1) - 1)
end)

-- === DIFFICULTY UPDATE LOOP ===
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        if State.phase == Phase.RUNNING then
            State.UpdateDifficulty()
            State.Broadcast('cc:difficulty', State.difficulty)
            State.CleanExpiredEffects()
        end
    end
end)

-- === RESOURCE LIFECYCLE ===

-- Resource stop. Without this, in-flight meta effects (durationModifier,
-- timerModifier, hideChaosUI, etc.) would leave State.meta permanently
-- altered after a /restart fivemchaos, and the next mission would start
-- with stale state (e.g., chaos disabled forever). Also resets phase to
-- LOBBY so a future /restart doesn't leave the game stuck in WON/LOST.
AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    State.phase = Phase.LOBBY
    State.meta = {
        additionalEffects = 0,
        durationModifier = 1.0,
        timerModifier = 1.0,
        votingMode = 'none',
        disableChaos = false,
        hideChaosUI = false,
    }
    State.activeEffectsList = {}
    Chaos.active = false
    Chaos.activeEffects = {}
    Chaos.recentEffects = {}
    Chaos.timer = 0
    Director.active = false
    Director.cougars = {}
    -- Broadcast clear + despawn so any late straggling client cleans up.
    State.Broadcast('cc:clear_effects')
    State.Broadcast('cc:despawn_all_cougars')
    State.Broadcast('cc:meta_ui', false)
end)

-- === MISSION LIFECYCLE ===

function StartMission()
    if State.phase ~= Phase.LOBBY then return end
    if State.PlayerCount() < Config.MinPlayers then
        print('[CC] Not enough players')
        return
    end

    State.phase = Phase.STARTING
    State.startTime = os.time()
    State.difficulty = 0.0
    State.activeEffectsList = {}
    State.spawnLoad = {}
    State.ResetMeta()

    for id, p in pairs(State.players) do
        p.alive = true
        p.pos = Config.Start
        State.spawnLoad[id] = 0
    end

    State.Broadcast('cc:mission_start', {
        start = Config.Start,
        finish = Config.Finish,
        vehicle = Config.StartVehicle,
    })

    SetTimeout(3000, function()
        State.phase = Phase.RUNNING
        State.Broadcast('cc:state', Phase.RUNNING, State.startTime)
        TriggerEvent('cc:chaos_start')
        TriggerEvent('cc:director_start')
    end)
end

function EndMission(result, detail)
    if State.phase ~= Phase.RUNNING and State.phase ~= Phase.PAUSED then return end
    State.phase = result
    local elapsed = os.time() - State.startTime

    State.Broadcast('cc:mission_end', {
        result = result,
        detail = detail,
        time = elapsed,
        alive = State.AliveCount(),
        difficulty = State.difficulty,
    })

    TriggerEvent('cc:chaos_stop')
    TriggerEvent('cc:director_stop')
    State.ResetMeta()
    State.activeEffectsList = {}

    SetTimeout(12000, function()
        State.phase = Phase.LOBBY
        for _, p in pairs(State.players) do
            p.alive = true
        end
        State.Broadcast('cc:state', Phase.LOBBY, 0)
    end)
end

function PauseMission(paused)
    if paused and State.phase == Phase.RUNNING then
        State.phase = Phase.PAUSED
        State.Broadcast('cc:state', Phase.PAUSED, State.startTime)
        TriggerEvent('cc:chaos_pause')
        TriggerEvent('cc:director_stop')
    elseif not paused and State.phase == Phase.PAUSED then
        State.phase = Phase.RUNNING
        State.Broadcast('cc:state', Phase.RUNNING, State.startTime)
        TriggerEvent('cc:chaos_resume')
        TriggerEvent('cc:director_start')
    end
end

RegisterCommand('cc_start', function(src)
    if src ~= 0 then return end
    StartMission()
end, false)

RegisterCommand('cc_stop', function(src)
    if src ~= 0 then return end
    EndMission('LOST', 'Admin stopped')
end, false)

RegisterCommand('cc_difficulty', function(src, args)
    if src ~= 0 then return end
    print(('[CC] Difficulty: %.2f | Chaos interval: %.1fs | Max cougars: %d | Spawn cooldown: %.1fs'):format(
        State.difficulty, State.GetChaosInterval(), State.GetMaxCougars(), State.GetSpawnCooldown()
    ))
end, false)
