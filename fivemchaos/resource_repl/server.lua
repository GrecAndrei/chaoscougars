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

-- The main mod runs in a SEPARATE Lua VM: its State/Config/Effects globals
-- were never visible here (they read as nil). All game access goes through
-- the fivemchaos exports declared in its fxmanifest.
local CC_RESOURCE = 'fivemchaos'

local function ccCall(exportName, ...)
    local args = {...}
    local ok, result = pcall(function()
        return exports[CC_RESOURCE][exportName](nil, table.unpack(args))
    end)
    if not ok then return nil, 'fivemchaos not running or export failed: ' .. tostring(result) end
    return result
end

-- Telemetry from clients (position, speed, etc.). Declared BEFORE the HTTP
-- handler closure below — it used to be declared after, so /telemetry
-- captured a nil global and always returned null.
local telemetry = {}
RegisterNetEvent('cc_repl:telemetry', function(data)
    if type(data) ~= 'table' then return end
    telemetry[source] = data
    telemetry[source].name = GetPlayerName(source)
    telemetry[source].time = os.time()
end)

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
        -- Game access helpers (exports-backed; the old `State = State` style
        -- bindings were always nil across the resource boundary):
        --   cc.state()          -> phase/difficulty/players/meta/heat
        --   cc.effects()        -> active effect list
        --   cc.effect(id)       -> registry entry
        --   cc.director()       -> cougar snapshot
        --   cc.dispatch(id[,d]) -> fire an effect through the real pipeline
        cc = {
            state    = function() return ccCall('GetState') end,
            effects  = function() return ccCall('GetActiveEffects') end,
            effect   = function(id) return ccCall('GetEffectById', id) end,
            director = function() return ccCall('GetDirectorSnapshot') end,
            dispatch = function(id, duration) return ccCall('DispatchEffectById', id, duration) end,
        },
        json = json,
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
--
-- SECURITY: every endpoint that can affect the game or execute code is
-- gated on the `chaoscougar.dev` ACE. Read-only endpoints (/status,
-- /players, /log) are un-gated so anyone with the RCON port can inspect
-- game state for debugging. Without this gate the server exposes a full
-- Lua RCE via POST /exec and a ServerEvent injection via POST /event.
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

    local function deny(reason)
        res.send(json.encode({ok = false, error = reason or 'forbidden'}))
    end

    -- Returns true if the request was authenticated as a dev operator.
    -- Devs pass `X-CC-Dev-Token: <token>` header, OR the request originated
    -- from the server console (curl localhost:30120 by the host machine).
    -- The token is read from the `chaoscougar_dev_token` ConVar, which must
    -- be set in server.cfg before starting the resource. If the convar is
    -- unset, the REPL is fully locked down.
    local function isDev()
        local token = req.headers and req.headers['x-cc-dev-token']
        if type(token) ~= 'string' or token == '' then return false end
        local expected = GetConvar('chaoscougar_dev_token', '')
        if expected == '' then return false end
        return token == expected
    end

    -- All endpoints require the dev token. /status, /players, /log leak
    -- player names, IPs, and game state — anyone with the RCON port and a
    -- script kiddie recon tool can scrape them. The previous behavior of
    -- leaving read-only endpoints open was a footgun. Set
    -- `chaoscougar_dev_token` in server.cfg to enable any endpoint.
    if path == '/status' and method == 'GET' then
        if not isDev() then deny('dev token required'); return end
        local gameState = ccCall('GetState')
        local status = {
            phase = gameState and gameState.phase or 'unknown',
            difficulty = gameState and gameState.difficulty or 0,
            heat = gameState and gameState.heat or 0,
            act = gameState and gameState.actIndex or 0,
            alive = gameState and gameState.aliveCount or 0,
            playerCount = #GetPlayers(),
            uptime = os.time(),
        }
        res.send(json.encode(status))
        return
    end

    -- GET /players
    if path == '/players' and method == 'GET' then
        if not isDev() then deny('dev token required'); return end
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
        if not isDev() then deny('dev token required'); return end
        local recent = {}
        local start = math.max(1, #LOG - 50)
        for i = start, #LOG do
            recent[#recent + 1] = LOG[i]
        end
        res.send(json.encode(recent))
        return
    end

    -- POST /exec  (DEV ONLY)
    if path == '/exec' and method == 'POST' then
        if not isDev() then deny('dev token required'); return end
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

    -- POST /client_exec  (DEV ONLY)
    if path == '/client_exec' and method == 'POST' then
        if not isDev() then deny('dev token required'); return end
        local data = json.decode(req.body or '{}')
        if not data.code then
            res.send(json.encode({ok = false, error = 'missing code field'}))
            return
        end

        local target = data.target or -1 -- -1 = all clients
        local requestId = tostring(os.time()) .. '_' .. math.random(10000, 99999)

        TriggerClientEvent('cc_repl:exec', target, requestId, data.code)
        AddLog('repl', 'client_exec[' .. tostring(target) .. ']: ' .. data.code:sub(1, 80))

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
            end
        end)

        res.send(json.encode({ok = true, result = 'dispatched to client ' .. tostring(target), requestId = requestId}))
        return
    end

    -- POST /event  (DEV ONLY)
    if path == '/event' and method == 'POST' then
        if not isDev() then deny('dev token required'); return end
        local data = json.decode(req.body or '{}')
        if not data.name or type(data.name) ~= 'string' then
            res.send(json.encode({ok = false, error = 'missing event name'}))
            return
        end

        AddLog('repl', 'event: ' .. data.name)
        local args = data.args or {}
        TriggerEvent(data.name, table.unpack(args))
        res.send(json.encode({ok = true, result = 'event triggered'}))
        return
    end

    -- POST /client_event  (DEV ONLY)
    if path == '/client_event' and method == 'POST' then
        if not isDev() then deny('dev token required'); return end
        local data = json.decode(req.body or '{}')
        if not data.name or type(data.name) ~= 'string' then
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
        if not isDev() then deny('dev token required'); return end
        res.send(json.encode(telemetry))
        return
    end

    res.send(json.encode({ok = false, error = 'unknown endpoint: ' .. path}))
end)

-- Force-trigger an effect by ID (for testing from CLI). Gated on dev ACE.
-- Routed through the fivemchaos DispatchEffectById export so it uses the
-- real dispatch pipeline (the old fallback hand-rolled a cc:trigger_effect
-- with the wrong argument order and silently no-oped).
RegisterNetEvent('cc:force_effect', function(effectId)
    if type(source) ~= 'number' or source < 1 then return end
    if not IsPlayerAceAllowed(source, 'chaoscougar.dev') then
        print(('[CC-REPL] Blocked cc:force_effect from player %d (%s)'):format(
            source, GetPlayerName(source) or '?'))
        return
    end
    if type(effectId) ~= 'string' or effectId == '' then return end
    local dispatched, err = ccCall('DispatchEffectById', effectId)
    if err then
        AddLog('repl', 'force_effect failed: ' .. err)
    elseif dispatched then
        AddLog('repl', 'Force-triggered effect: ' .. effectId)
    else
        AddLog('repl', 'Effect refused (unknown id or conflict): ' .. tostring(effectId))
    end
end)

AddLog('system', 'CC REPL server started')
print('^2[CC-REPL]^0 HTTP REPL bridge active. Use curl http://localhost:30120/cc_repl/exec')
