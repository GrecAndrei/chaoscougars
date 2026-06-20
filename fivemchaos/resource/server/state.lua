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
    if type(src) ~= 'number' or src < 1 then return end
    if not GetPlayerName(src) then return end
    if State.players[src] then return end -- already joined, ignore duplicate
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
    if type(src) ~= 'number' or src < 1 then return end
    if type(pos) ~= 'table' then return end
    if type(pos.x) ~= 'number' or type(pos.y) ~= 'number' or type(pos.z) ~= 'number' then return end
    -- Clamp to a sane GTA V world bound. The map is roughly ±10000 on each
    -- axis; anything outside is either a cheat-injected coordinate or a
    -- corrupted GetEntityCoords return. Either way it breaks the difficulty
    -- math (sqrt of a huge squared distance = overflow).
    if math.abs(pos.x) > 100000 or math.abs(pos.y) > 100000 or math.abs(pos.z) > 10000 then
        return
    end
    if State.players[src] then
        State.players[src].pos = vector3(pos.x, pos.y, pos.z)
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
    if type(src) ~= 'number' or src < 1 then return end
    if State.players[src] then
        State.players[src].alive = true
        State.players[src].pos = Config.Start
    end
end)

RegisterNetEvent('cc:reached_finish', function()
    local src = source
    if type(src) ~= 'number' or src < 1 then return end
    if State.phase == Phase.RUNNING then
        local name = State.players[src] and State.players[src].name or 'Unknown'
        EndMission('WON', name .. ' reached Paleto Bay')
    end
end)

RegisterNetEvent('cc:spawn_load_inc', function()
    local src = source
    if type(src) ~= 'number' or src < 1 then return end
    if not State.players[src] then return end
    State.spawnLoad[src] = (State.spawnLoad[src] or 0) + 1
end)

RegisterNetEvent('cc:spawn_load_dec', function()
    local src = source
    if type(src) ~= 'number' or src < 1 then return end
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
    local previousPhase = State.phase
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
        -- Guard against the timeout firing AFTER a fresh mission was
        -- started (which would race-reset State.phase from RUNNING back
        -- to LOBBY mid-run). Only transition to LOBBY if the phase is
        -- still our own result.
        if State.phase ~= previousPhase and (State.phase == result) then
            State.phase = Phase.LOBBY
            for _, p in pairs(State.players) do
                p.alive = true
            end
            State.Broadcast('cc:state', Phase.LOBBY, 0)
        end
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

-- === CONFIG VALIDATION ===

-- Validate required Config values on resource start. Without this, a
-- typo (e.g. PauseTreshold instead of PauseThreshold) silently disables
-- the vote-to-pause feature. We log a single warning per bad key and
-- substitute a safe default so the resource still runs.
local function ValidateConfig()
    if type(Config) ~= 'table' then
        print('[CC] FATAL: Config table missing. Resource will not function.')
        return
    end
    local checks = {
        {key = 'MinPlayers',         v = Config.MinPlayers,         t = 'number', lo = 1, hi = 64,  def = 1},
        {key = 'MinSurvivors',       v = Config.MinSurvivors,       t = 'number', lo = 1, hi = 32,  def = 1},
        {key = 'PauseThreshold',     v = Config.PauseThreshold,     t = 'number', lo = 1, hi = 64,  def = 1},
        {key = 'VoteWindowSec',      v = Config.VoteWindowSec,      t = 'number', lo = 1, hi = 120, def = 30},
        {key = 'EffectDuration',     v = Config.EffectDuration,     t = 'number', lo = 1, hi = 600, def = 30},
        {key = 'ShortDuration',      v = Config.ShortDuration,      t = 'number', lo = 1, hi = 60,  def = 10},
        {key = 'ChaosIntervalBase',  v = Config.ChaosIntervalBase,  t = 'number', lo = 1, hi = 600, def = 30},
        {key = 'ChaosIntervalMin',   v = Config.ChaosIntervalMin,   t = 'number', lo = 1, hi = 600, def = 10},
        {key = 'MaxCougarsBase',     v = Config.MaxCougarsBase,     t = 'number', lo = 1, hi = 100, def = 6},
        {key = 'MaxCougarsMax',      v = Config.MaxCougarsMax,      t = 'number', lo = 1, hi = 100, def = 30},
        {key = 'SpawnCooldownBase',  v = Config.SpawnCooldownBase,  t = 'number', lo = 1, hi = 300, def = 30},
        {key = 'SpawnCooldownMin',   v = Config.SpawnCooldownMin,   t = 'number', lo = 1, hi = 300, def = 8},
        {key = 'SpawnAheadBase',     v = Config.SpawnAheadBase,     t = 'number', lo = 1, hi = 2000, def = 250},
        {key = 'SpawnAheadMin',      v = Config.SpawnAheadMin,      t = 'number', lo = 1, hi = 2000, def = 80},
        {key = 'SpawnLateral',       v = Config.SpawnLateral,       t = 'number', lo = 0, hi = 500, def = 25},
        {key = 'CougarDespawnDist',  v = Config.CougarDespawnDist,  t = 'number', lo = 50, hi = 5000, def = 600},
        {key = 'DifficultyExponent', v = Config.DifficultyExponent, t = 'number', lo = 0.1, hi = 5, def = 1.0},
        {key = 'WinRadius',          v = Config.WinRadius,          t = 'number', lo = 1, hi = 500, def = 50},
    }
    local bad = 0
    for _, c in ipairs(checks) do
        local ok = type(c.v) == c.t and c.v >= c.lo and c.v <= c.hi
        if not ok then
            bad = bad + 1
            print(('[CC] Config.%s invalid (got %s, expected %s in [%g, %g]) - using default %g'):format(
                c.key, tostring(c.v), c.t, c.lo, c.hi, c.def))
            Config[c.key] = c.def
        end
    end
    -- Also validate vector3 Start/Finish positions
    local function vecOk(name)
        local v = Config[name]
        return type(v) == 'table' and type(v.x) == 'number' and type(v.y) == 'number' and type(v.z) == 'number'
    end
    if not vecOk('Start') then
        bad = bad + 1
        print('[CC] Config.Start is not a valid vector3')
    end
    if not vecOk('Finish') then
        bad = bad + 1
        print('[CC] Config.Finish is not a valid vector3')
    end
    -- Validate BannedClasses is a table of {classNumber = true} entries where
    -- classNumber is in [0, 22] (FiveM has 22 vehicle classes, 0-22).
    if type(Config.BannedClasses) ~= 'table' then
        bad = bad + 1
        print('[CC] Config.BannedClasses is not a table - using defaults (14,15,16)')
        Config.BannedClasses = {[14]=true, [15]=true, [16]=true}
    else
        local rebuilt = {}
        for k, v in pairs(Config.BannedClasses) do
            if type(k) == 'number' and k >= 0 and k <= 22 and v == true then
                rebuilt[k] = true
            else
                bad = bad + 1
                print(('[CC] Config.BannedClasses[%s]=%s invalid - dropping'):format(tostring(k), tostring(v)))
            end
        end
        Config.BannedClasses = rebuilt
    end
    if vecOk('Start') and vecOk('Finish') and #(Config.Start - Config.Finish) < 100 then
        bad = bad + 1
        print('[CC] Config.Start and Config.Finish are too close (<100m)')
    end
    if bad > 0 then
        print(('[CC] Config validation: %d issue(s). Using safe defaults where needed.'):format(bad))
    else
        print('[CC] Config validated OK.')
    end
end

AddEventHandler('onResourceStart', function(name)
    if name ~= GetCurrentResourceName() then return end
    ValidateConfig()
end)
