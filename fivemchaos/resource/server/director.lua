--[[
    Server-authoritative Director.
    Uses difficulty scaling for spawn rate, count, and positioning.
    Distributes spawns across players (not just lead).
]]

local Director = {
    active = false,
    cougars = {},
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
}

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

local function CountCougars()
    local n = 0
    for _ in pairs(Director.cougars) do n = n + 1 end
    return n
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

            local cougarType = PickCougarType()
            Director.lastSpawn = now

            TriggerClientEvent('cc:spawn_cougar', target.id, cougarType, pos)

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
                end
            end
        end
    end)
end

RegisterNetEvent('cc:cougar_spawned', function(netId, cougarType, pos)
    Director.cougars[netId] = {type = cougarType, spawnTime = os.time(), pos = pos}
    State.Broadcast('cc:cougar_count', CountCougars())
end)

RegisterNetEvent('cc:cougar_dead', function(netId)
    Director.cougars[netId] = nil
    State.Broadcast('cc:cougar_count', CountCougars())
end)

AddEventHandler('cc:director_start', function()
    if Director.active then return end
    Director.active = true
    Director.cougars = {}
    Director.lastSpawn = 0
    DirectorLoop()
    CleanupLoop()
end)

AddEventHandler('cc:director_stop', function()
    Director.active = false
    State.Broadcast('cc:despawn_all_cougars', true)
    Director.cougars = {}
end)
