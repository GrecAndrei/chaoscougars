--[[
    Admin panel server-side handlers.

    SECURITY: every endpoint here is gated on the `chaoscougar.admin` ACE.
    Previously these were un-gated NetEvents; any connected player could
    pause/resume the mission, fire any effect, or spawn cougars. Now they
    require the same admin ACE as `cc:meta_set`.

    RATE LIMIT: per-source debounce so a runaway admin client (or a malicious
    one with admin ACE) cannot DoS the server with hundreds of
    `cc:admin_effect` calls per second.
]]

local lastAdminActionAt = {}
local ADMIN_COOLDOWN_MS = 250

local function adminGate(src, action)
    if type(src) ~= 'number' or src < 1 then return false end
    if not GetPlayerName(src) then return false end
    if not IsPlayerAceAllowed(src, 'chaoscougar.admin') then
        print(('[CC] Blocked admin.%s from player %d (%s)'):format(
            action, src, GetPlayerName(src) or '?'))
        return false
    end
    local now = GetGameTimer()
    if lastAdminActionAt[src] and (now - lastAdminActionAt[src]) < ADMIN_COOLDOWN_MS then
        return false
    end
    lastAdminActionAt[src] = now
    return true
end

AddEventHandler('playerDropped', function()
    lastAdminActionAt[source] = nil
end)

RegisterNetEvent('cc:admin_start', function()
    local src = source
    if not adminGate(src, 'start') then return end
    StartMission()
end)

RegisterNetEvent('cc:admin_stop', function()
    local src = source
    if not adminGate(src, 'stop') then return end
    EndMission('LOST', 'Admin stopped')
end)

RegisterNetEvent('cc:admin_pause', function(paused)
    local src = source
    if not adminGate(src, 'pause') then return end
    PauseMission(paused and true or false)
end)

RegisterNetEvent('cc:admin_effect', function(id)
    local src = source
    if not adminGate(src, 'effect') then return end
    if type(id) ~= 'string' or id == '' or #id > 64 then return end
    local fx = Effects.FindById(id)
    if not fx then return end
    -- Validate the fn is a known FX_* name from the registry, so the client's
    -- `_G[fnName]()` lookup is constrained to the project's effect functions.
    if not Effects._validFns or not Effects._validFns[fx.fn] then return end
    local duration = fx.instant and 0 or (fx.short and Config.ShortDuration or Config.EffectDuration)
    local seed = math.random(1, 2147483647)
    Chaos.DispatchEffect(fx, duration, seed, src)
end)

RegisterNetEvent('cc:admin_spawn_cougar', function(cougarType, pos)
    local src = source
    if not adminGate(src, 'spawn_cougar') then return end
    if type(cougarType) ~= 'string' or cougarType == '' then return end
    -- Validate pos is a 3D vector
    local posType = type(pos)
    if (posType ~= 'table' and posType ~= 'userdata' and posType ~= 'vector3')
        or type(pos.x) ~= 'number' or type(pos.y) ~= 'number' or type(pos.z) ~= 'number' then
        return
    end
    -- Use the same server-issued spawn request as the director. This keeps
    -- manually spawned cougars inside the client-report authorization path.
    Director.QueueSpawn(cougarType, pos, src)
end)

RegisterNetEvent('cc:admin_kill_cougars', function()
    local src = source
    if not adminGate(src, 'kill_cougars') then return end
    TriggerClientEvent('cc:despawn_all_cougars', -1)
    TriggerEvent('cc:director_stop')
    Citizen.Wait(100)
    if State.phase == Phase.RUNNING then
        TriggerEvent('cc:director_start')
    end
end)
