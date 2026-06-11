--[[
    CC REPL Server
    Exposes HTTP endpoint for remote Lua execution.

    Endpoints:
      POST /exec         — execute Lua on server, return result
      POST /client_exec  — execute Lua on a specific client (body: {target: serverId, code: "..."})
      GET  /players      — list connected players
      GET  /status       — current game state
      POST /event        — trigger a server event (body: {name: "...", args: [...]})
      GET  /log          — get recent event log (last 50 entries)
]]

local LOG = {}
local MAX_LOG = 200

local function AddLog(category, msg)
    LOG[#LOG + 1] = {
        time = os.time(),
        cat = category,
        msg = msg
    }
    if #LOG > MAX_LOG then
        table.remove(LOG, 1)
    end
end

-- Capture prints from executed code
local function CapturePrint(...)
    local parts = {}
    for i = 1, select('#', ...) do
        parts[#parts + 1] = tostring(select(i, ...))
    end
    return table.concat(parts, '\t')
end

local function ExecLua(code)
    local output = {}
    local env = setmetatable({
        print = function(...)
            output[#output + 1] = CapturePrint(...)
        end,
        State = State,
        Config = Config,
        Effects = Effects,
    }, {__index = _G})

    local fn, err = load(code, '=repl', 't', env)
    if not fn then
        return false, 'PARSE: ' .. tostring(err)
    end

    local ok, result = pcall(fn)
    if not ok then
        return false, 'RUNTIME: ' .. tostring(result)
    end

    local out = table.concat(output, '\n')
    if result ~= nil then
        if out ~= '' then out = out .. '\n' end
        out = out .. tostring(result)
    end
    return true, out
end

-- Client response accumulator
local clientResponses = {}
local clientWaiters = {}

RegisterNetEvent('cc_repl:client_response', function(requestId, success, result)
    clientResponses[requestId] = {ok = success, result = result}
    if clientWaiters[requestId] then
        clientWaiters[requestId](success, result)
        clientWaiters[requestId] = nil
    end
end)

-- Track game events for the log
AddEventHandler('cc:phase_change', function(phase)
    AddLog('phase', 'Phase changed to: ' .. tostring(phase))
end)

AddEventHandler('playerConnecting', function(name)
    AddLog('player', name .. ' connecting')
end)

AddEventHandler('playerDropped', function(reason)
    AddLog('player', GetPlayerName(source) .. ' dropped: ' .. reason)
end)

RegisterNetEvent('cc:cougar_spawned', function(netId, cougarType, pos)
    AddLog('cougar', 'Spawned ' .. cougarType .. ' (net:' .. netId .. ')')
end)

RegisterNetEvent('cc:cougar_dead', function(netId)
    AddLog('cougar', 'Died net:' .. netId)
end)

-- HTTP Handler
SetHttpHandler(function(req, res)
    local path = req.path
    local method = req.method

    -- CORS
    res.writeHead(200, {
        ['Content-Type'] = 'application/json',
        ['Access-Control-Allow-Origin'] = '*',
    })

    if method == 'OPTIONS' then
        res.send('')
        return
    end

    -- GET /status
    if path == '/status' and method == 'GET' then
        local status = {
            phase = State and State.phase or 'unknown',
            difficulty = State and State.difficulty or 0,
            playerCount = #GetPlayers(),
            uptime = os.time(),
        }
        res.send(json.encode(status))
        return
    end

    -- GET /players
    if path == '/players' and method == 'GET' then
        local players = {}
        for _, id in ipairs(GetPlayers()) do
            players[#players + 1] = {
                id = tonumber(id),
                name = GetPlayerName(id),
                ping = GetPlayerPing(id),
            }
        end
        res.send(json.encode(players))
        return
    end

    -- GET /log
    if path == '/log' and method == 'GET' then
        local recent = {}
        local start = math.max(1, #LOG - 50)
        for i = start, #LOG do
            recent[#recent + 1] = LOG[i]
        end
        res.send(json.encode(recent))
        return
    end

    -- POST /exec
    if path == '/exec' and method == 'POST' then
        local body = req.body or ''
        if body == '' then
            res.send(json.encode({ok = false, error = 'empty body'}))
            return
        end

        local data = json.decode(body)
        local code = data and data.code or body

        AddLog('repl', 'exec: ' .. code:sub(1, 80))
        local ok, result = ExecLua(code)
        res.send(json.encode({ok = ok, result = result}))
        return
    end

    -- POST /client_exec
    if path == '/client_exec' and method == 'POST' then
        local data = json.decode(req.body or '{}')
        if not data.code then
            res.send(json.encode({ok = false, error = 'missing code field'}))
            return
        end

        local target = data.target or -1 -- -1 = all clients
        local requestId = tostring(os.time()) .. '_' .. math.random(10000, 99999)

        TriggerClientEvent('cc_repl:exec', target, requestId, data.code)
        AddLog('repl', 'client_exec[' .. tostring(target) .. ']: ' .. data.code:sub(1, 80))

        -- Wait up to 5s for response
        local responded = false
        local resultData = nil

        clientWaiters[requestId] = function(ok, result)
            responded = true
            resultData = {ok = ok, result = result}
        end

        local waitStart = os.time()
        Citizen.CreateThread(function()
            while not responded and os.time() - waitStart < 5 do
                Citizen.Wait(100)
            end
            if not responded then
                clientWaiters[requestId] = nil
                -- Can't send response after timeout in this model
            end
        end)

        -- For HTTP we can't easily async-wait, so we do a polling approach
        -- Actually FiveM HTTP handlers are sync, so let's just fire-and-forget
        -- and have the client result go to /log
        res.send(json.encode({ok = true, result = 'dispatched to client ' .. tostring(target), requestId = requestId}))
        return
    end

    -- POST /event
    if path == '/event' and method == 'POST' then
        local data = json.decode(req.body or '{}')
        if not data.name then
            res.send(json.encode({ok = false, error = 'missing event name'}))
            return
        end

        AddLog('repl', 'event: ' .. data.name)
        local args = data.args or {}
        TriggerEvent(data.name, table.unpack(args))
        res.send(json.encode({ok = true, result = 'event triggered'}))
        return
    end

    -- POST /client_event
    if path == '/client_event' and method == 'POST' then
        local data = json.decode(req.body or '{}')
        if not data.name then
            res.send(json.encode({ok = false, error = 'missing event name'}))
            return
        end

        local target = data.target or -1
        local args = data.args or {}
        AddLog('repl', 'client_event[' .. tostring(target) .. ']: ' .. data.name)
        TriggerClientEvent(data.name, target, table.unpack(args))
        res.send(json.encode({ok = true, result = 'client event triggered'}))
        return
    end

    -- GET /telemetry
    if path == '/telemetry' and method == 'GET' then
        res.send(json.encode(telemetry))
        return
    end

    res.send(json.encode({ok = false, error = 'unknown endpoint: ' .. path}))
end)

-- Telemetry from clients (position, speed, etc.)
local telemetry = {}
RegisterNetEvent('cc_repl:telemetry', function(data)
    telemetry[source] = data
    telemetry[source].name = GetPlayerName(source)
    telemetry[source].time = os.time()
end)

-- Force-trigger an effect by ID (for testing from CLI)
RegisterNetEvent('cc:force_effect', function(effectId)
    if not Effects then
        AddLog('repl', 'Effects table not available (main resource not running?)')
        return
    end
    local effect = Effects.FindById(effectId)
    if not effect then
        AddLog('repl', 'Effect not found: ' .. tostring(effectId))
        return
    end
    AddLog('repl', 'Force-triggering effect: ' .. effect.name)
    -- Use the chaos dispatch if available
    if DispatchEffect then
        DispatchEffect(effect)
    else
        TriggerClientEvent('cc:trigger_effect', -1, effect.id, effect.sync_mode, 30, os.time())
    end
end)

-- GET /telemetry endpoint
-- (handled in the main HTTP handler below, adding here for the log)

AddLog('system', 'CC REPL server started')
print('^2[CC-REPL]^0 HTTP REPL bridge active. Use curl http://localhost:30120/cc_repl/exec')
