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

RegisterNetEvent('cc_repl:exec', function(requestId, code)
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
