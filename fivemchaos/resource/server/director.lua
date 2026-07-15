--[[
    Server-authoritative Director.
    Uses difficulty scaling for spawn rate, count, and positioning.
    Distributes spawns across players (not just lead).
]]

Director = {
    active = false,
    cougars = {},
    spawnRequests = {},
    lastSpawn = 0,
}

local CougarTypes = {
    {type = 'fence',       weight = 30,  minDiff = 0.0},
    {type = 'car',         weight = 20,  minDiff = 0.1},
    {type = 'shooter',     weight = 18,  minDiff = 0.15},
    {type = 'ball_blue',   weight = 12,  minDiff = 0.0},
    {type = 'ball_purple', weight = 10,  minDiff = 0.05},
    {type = 'stun',        weight = 14,  minDiff = 0.1},
    {type = 'phantom',     weight = 8,   minDiff = 0.25},
    {type = 'jesus',       weight = 8,   minDiff = 0.3},
    {type = 'swarm',       weight = 6,   minDiff = 0.4},
    {type = 'magnetic',    weight = 6,   minDiff = 0.35},
    {type = 'bomber',      weight = 5,   minDiff = 0.5},
    {type = 'splitter',    weight = 5,   minDiff = 0.45},
    -- New predators deliberately open up across the run instead of merely
    -- increasing health pools.  Each one creates a different driving choice.
    {type = 'pouncer',     weight = 10,  minDiff = 0.2},
    {type = 'leech',       weight = 7,   minDiff = 0.3},
    {type = 'howler',      weight = 5,   minDiff = 0.5},
    {type = 'alpha',       weight = 3,   minDiff = 0.8},
}

local CougarTypeSet = {}
for _, entry in ipairs(CougarTypes) do CougarTypeSet[entry.type] = true end

local function PickCougarType()
    local available = {}
    local total = 0
    for _, c in ipairs(CougarTypes) do
        if State.difficulty >= c.minDiff then
            available[#available + 1] = c
            total = total + c.weight
        end
    end
    if #available == 0 then return 'fence' end

    local roll = math.random() * total
    local sum = 0
    for _, c in ipairs(available) do
        sum = sum + c.weight
        if roll <= sum then return c.type end
    end
    return 'fence'
end

function Director.CountCougars()
    local n = 0
    for _ in pairs(Director.cougars) do n = n + 1 end
    return n
end
local CountCougars = Director.CountCougars

local function IsValidSpawnPos(pos)
    local posType = type(pos)
    return (posType == 'table' or posType == 'userdata' or posType == 'vector3')
        and type(pos.x) == 'number' and pos.x == pos.x and math.abs(pos.x) <= 100000
        and type(pos.y) == 'number' and pos.y == pos.y and math.abs(pos.y) <= 100000
        and type(pos.z) == 'number' and pos.z == pos.z and math.abs(pos.z) <= 10000
end

local function IsNearRequestedPos(actual, expected)
    local dx, dy, dz = actual.x - expected.x, actual.y - expected.y, actual.z - expected.z
    return dx * dx + dy * dy + dz * dz <= 2500 -- terrain adjustment / spawn spread
end

local function SpawnReportQuota(cougarType)
    if cougarType == 'splitter' then return 7 end
    if cougarType == 'swarm' then return 5 end
    return 1
end

-- A client has to create the networked entity, but it may only report an
-- entity that the server specifically asked that exact client to create.
-- Splitters can legitimately create up to seven descendants from one request.
function Director.QueueSpawn(cougarType, pos, targetId)
    if type(targetId) ~= 'number' or not State.players[targetId] then return nil end
    if type(cougarType) ~= 'string' or cougarType == '' or not IsValidSpawnPos(pos) then return nil end

    local requestId
    repeat
        requestId = ('%x:%x'):format(math.random(1, 0x7fffffff), GetGameTimer())
    until not Director.spawnRequests[requestId]

    Director.spawnRequests[requestId] = {
        targetId = targetId,
        cougarType = cougarType,
        pos = {x = pos.x, y = pos.y, z = pos.z},
        maxReports = SpawnReportQuota(cougarType),
        reports = 0,
        active = 0,
        expiresAt = os.time() + 3600,
    }
    TriggerClientEvent('cc:spawn_cougar', -1, cougarType, pos, targetId, requestId)
    return requestId
end

-- Pick a random alive player to be the spawn target
local function PickTargetPlayer()
    local alive = {}
    for id, p in pairs(State.players) do
        if p.alive and p.pos then
            alive[#alive + 1] = {id = id, pos = p.pos}
        end
    end
    if #alive == 0 then return nil end

    -- 60% chance to target lead player, 40% random
    table.sort(alive, function(a, b)
        return #(a.pos - Config.Finish) < #(b.pos - Config.Finish)
    end)

    if math.random() < 0.6 then
        return alive[1]
    end
    return alive[math.random(#alive)]
end

local function GetSpawnPos(target)
    if not target or not target.pos then return nil end

    local toFinish = Config.Finish - target.pos
    local dist = #toFinish
    if dist < Config.WinRadius then return nil end

    local dir = toFinish / dist
    local ahead = State.GetSpawnAhead()
    local spawnPoint = target.pos + dir * ahead

    -- Lateral randomness
    local perp = vector3(-dir.y, dir.x, 0.0)
    local lat = (math.random() - 0.5) * 2.0 * Config.SpawnLateral
    spawnPoint = spawnPoint + perp * lat

    -- Sometimes spawn flanking or behind (higher difficulty)
    if math.random() < State.difficulty * 0.3 then
        -- Flank spawn: closer, more lateral
        spawnPoint = target.pos + dir * (ahead * 0.3) + perp * (math.random() > 0.5 and 50 or -50)
    end

    return spawnPoint
end

local function DirectorLoop()
    Citizen.CreateThread(function()
        while Director.active do
            Citizen.Wait(1000)

            local now = os.time()
            local cooldown = State.GetSpawnCooldown()
            if now - Director.lastSpawn < cooldown then goto skip end
            if CountCougars() >= State.GetMaxCougars() then goto skip end

            local target = PickTargetPlayer()
            if not target then goto skip end

            local pos = GetSpawnPos(target)
            if not pos then goto skip end

            -- Re-validate the target is still a connected alive player.
            -- PickTargetPlayer uses a snapshot of State.players, so a
            -- disconnect between snapshot and broadcast would broadcast a
            -- spawn to a phantom target id. cc:spawn_cougar on the client
            -- side gates on targetPlayerId == myServerId, so a phantom id
            -- would mean every client short-circuits and no one ever
            -- claims ownership -> cougar just stands there.
            if not State.players[target.id] or not State.players[target.id].alive then
                goto skip
            end

            -- Defensive cap check. CountCougars can briefly exceed
            -- State.GetMaxCougars() if cc:cougar_spawned broadcasts
            -- arrive out-of-order with the next spawn decision. Cap to
            -- 2x MaxCougars as a sanity floor.
            local cap = State.GetMaxCougars() * 2
            if CountCougars() >= cap then
                print(('[CC] Director: cougar cap hit (%d >= %d), skipping spawn'):format(CountCougars(), cap))
                goto skip
            end

            local cougarType = PickCougarType()
            -- A swarm represents five actual hostile entities. Do not let a
            -- single director tick exceed the configured world threat cap.
            if CountCougars() + SpawnReportQuota(cougarType) > State.GetMaxCougars() then
                goto skip
            end
            Director.lastSpawn = now

            -- Broadcast to ALL clients: the target client becomes the owner of
            -- the cougar's network id, and the rest just render/observe it.
            -- Sending only to target.id lets FiveM migrate ownership to the
            -- host, which means the spawning client never sees IsOwner()==true
            -- and every owner-gated AI/effect branch never runs -> the cougar
            -- just stands there doing nothing.
            Director.QueueSpawn(cougarType, pos, target.id)

            ::skip::
        end
    end)
end

local function CleanupLoop()
    Citizen.CreateThread(function()
        while Director.active do
            Citizen.Wait(5000)
            for netId, cougar in pairs(Director.cougars) do
                local tooFar = true
                for _, p in pairs(State.players) do
                    if p.alive and p.pos and #(p.pos - cougar.pos) < Config.CougarDespawnDist then
                        tooFar = false
                        break
                    end
                end
                if tooFar then
                    State.Broadcast('cc:despawn_cougar', netId)
                    Director.cougars[netId] = nil
                    State.Broadcast('cc:cougar_count', CountCougars())
                end
            end
            local now = os.time()
            for requestId, request in pairs(Director.spawnRequests) do
                if request.expiresAt <= now and request.active == 0 then
                    Director.spawnRequests[requestId] = nil
                end
            end
        end
    end)
end

RegisterNetEvent('cc:cougar_spawned', function(netId, cougarType, pos, requestId)
    local src = source
    if type(src) ~= 'number' or not State.players[src] then return end
    if type(netId) ~= 'number' or netId <= 0 or netId % 1 ~= 0 then return end
    if type(cougarType) ~= 'string' or cougarType == '' or not IsValidSpawnPos(pos) then return end
    if type(requestId) ~= 'string' then return end
    if Director.cougars[netId] then return end

    local request = Director.spawnRequests[requestId]
    if not request
        or request.targetId ~= src
        or request.cougarType ~= cougarType
        or request.reports >= request.maxReports
        -- A splitter's descendants are created where their parent dies, so
        -- only its first report can be tied to the original request point.
        or (cougarType ~= 'splitter' and not IsNearRequestedPos(pos, request.pos)) then
        return
    end

    request.reports = request.reports + 1
    request.active = request.active + 1
    Director.cougars[netId] = {type = cougarType, spawnTime = os.time(), pos = pos, owner = src, requestId = requestId}
    State.Broadcast('cc:cougar_count', CountCougars())
end)

RegisterNetEvent('cc:cougar_dead', function(netId)
    local src = source
    if type(src) ~= 'number' or type(netId) ~= 'number' or netId <= 0 or netId % 1 ~= 0 then return end
    local cougar = Director.cougars[netId]
    if not cougar or cougar.owner ~= src then return end
    Director.cougars[netId] = nil
    local request = Director.spawnRequests[cougar.requestId]
    if request then
        request.active = math.max(0, request.active - 1)
        if request.reports >= request.maxReports and request.active == 0 then
            Director.spawnRequests[cougar.requestId] = nil
        end
    end
    State.Broadcast('cc:cougar_count', CountCougars())
end)

-- Owner clients report live positions every two seconds. This is deliberately
-- accepted only from the client that the server assigned to create the entity,
-- so it cannot be used to keep arbitrary cougars alive forever.
RegisterNetEvent('cc:cougar_pos', function(netId, pos)
    local src = source
    if type(src) ~= 'number' or type(netId) ~= 'number' or not IsValidSpawnPos(pos) then return end
    local cougar = Director.cougars[netId]
    if not cougar or cougar.owner ~= src then return end
    cougar.pos = vector3(pos.x, pos.y, pos.z)
end)

-- Debug command: dump director state
RegisterCommand('cc_director', function(src)
    if src ~= 0 then return end
    local types = {}
    for _, c in pairs(Director.cougars) do
        types[c.type] = (types[c.type] or 0) + 1
    end
    local sorted = {}
    for t, n in pairs(types) do sorted[#sorted + 1] = n .. 'x ' .. t end
    table.sort(sorted)
    print('[CC] Director: ' .. tostring(Director.active)
        .. ' | cougars=' .. CountCougars() .. '/' .. State.GetMaxCougars()
        .. ' | difficulty=' .. string.format('%.2f', State.difficulty)
        .. ' | cooldown=' .. string.format('%.1fs', State.GetSpawnCooldown())
        .. ' | lastSpawn=' .. (os.time() - Director.lastSpawn) .. 's ago'
    )
    if #sorted > 0 then
        print('[CC] Types: ' .. table.concat(sorted, ', '))
    end
end, false)

-- Server-console test hook.  This also makes it possible for an operator to
-- run a deliberate encounter without needing to wait for the weighted pool.
-- It shares QueueSpawn with normal spawns, so request ownership and cap
-- bookkeeping are exercised exactly as they are during a real run.
RegisterCommand('cc_spawn', function(src, args)
    if src ~= 0 then return end
    local cougarType = args[1]
    if not CougarTypeSet[cougarType] then
        print('[CC] Usage: cc_spawn <type>')
        return
    end
    if State.phase ~= Phase.RUNNING then
        print('[CC] Cannot spawn a cougar outside a running mission')
        return
    end
    if CountCougars() + SpawnReportQuota(cougarType) > State.GetMaxCougars() then
        print('[CC] Spawn cap would be exceeded')
        return
    end
    local target = PickTargetPlayer()
    local pos = target and GetSpawnPos(target)
    if not pos then
        print('[CC] No valid target or spawn position')
        return
    end
    Director.QueueSpawn(cougarType, pos, target.id)
    print(('[CC] Forced %s encounter for %s'):format(cougarType, GetPlayerName(target.id) or tostring(target.id)))
end, false)

AddEventHandler('cc:director_start', function()
    if Director.active then return end
    Director.active = true
    Director.cougars = {}
    Director.spawnRequests = {}
    Director.lastSpawn = 0
    DirectorLoop()
    CleanupLoop()
end)

AddEventHandler('cc:director_stop', function()
    Director.active = false
    State.Broadcast('cc:despawn_all_cougars', true)
    Director.cougars = {}
    Director.spawnRequests = {}
end)

-- When a player drops, immediately despawn the cougars they created. This
-- deliberately uses the recorded owner instead of State.players[src]: the
-- State playerDropped handler is registered first and removes that entry
-- before this handler runs.
AddEventHandler('playerDropped', function()
    if not Director.active then return end
    local src = source
    local removed = 0
    for netId, cougar in pairs(Director.cougars) do
        if cougar.owner == src then
            State.Broadcast('cc:despawn_cougar', netId)
            Director.cougars[netId] = nil
            removed = removed + 1
        end
    end
    for requestId, request in pairs(Director.spawnRequests) do
        if request.targetId == src then Director.spawnRequests[requestId] = nil end
    end
    if removed > 0 then
        State.Broadcast('cc:cougar_count', CountCougars())
    end
end)
