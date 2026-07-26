--[[
    CC REPL Client
    Receives Lua code from server, executes in client context, returns result.
]]

local function ExecClientLua(code)
    local output = {}
    local env = setmetatable({
        print = function(...)
            local parts = {}
            for i = 1, select('#', ...) do
                parts[#parts + 1] = tostring(select(i, ...))
            end
            output[#output + 1] = table.concat(parts, '\t')
        end,
    }, {__index = _G})

    local fn, err = load(code, '=repl_client', 't', env)
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

-- Kill switch: client-side exec only runs when the server replicates
-- `setr chaoscougar_repl_enabled 1` (dev servers only). Without this gate,
-- an accidental `ensure resource_repl` on a public server hands any script
-- that can reach TriggerClientEvent a remote Lua exec on every player.
local function ReplEnabled()
    return GetConvar('chaoscougar_repl_enabled', '0') == '1'
end

RegisterNetEvent('cc_repl:exec', function(requestId, code)
    if not ReplEnabled() then
        TriggerServerEvent('cc_repl:client_response', requestId, false,
            'repl disabled (set `setr chaoscougar_repl_enabled 1` on a dev server)')
        return
    end
    local ok, result = ExecClientLua(code)
    TriggerServerEvent('cc_repl:client_response', requestId, ok, result)
end)

-- Convenience: report player position every 5s to server log
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) then
            local pos = GetEntityCoords(ped)
            local veh = GetVehiclePedIsIn(ped, false)
            local speed = veh ~= 0 and GetEntitySpeed(veh) * 3.6 or 0.0
            local vehName = veh ~= 0 and GetDisplayNameFromVehicleModel(GetEntityModel(veh)) or 'on foot'
            TriggerServerEvent('cc_repl:telemetry', {
                pos = {x = math.floor(pos.x), y = math.floor(pos.y), z = math.floor(pos.z)},
                speed = math.floor(speed),
                vehicle = vehName,
                health = GetEntityHealth(ped),
                inVehicle = veh ~= 0,
            })
        end
    end
end)
