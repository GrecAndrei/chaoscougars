--[[
    Heat: one intensity score both the chaos loop and the cougar director
    read before acting. Replaces two independent RNG streams with a
    build -> peak -> relief curve (the L4D director idea, minimal version).

    Sources of heat:
      - effect dispatches (scaled by severity, halved for instants)
      - cougar spawns (scaled by threat tier)
      - a player going down (big spike + a grace window)
    Relief:
      - constant decay per second
      - a successful revive vents some heat

    Consumers:
      - chaos.lua: picks max severity by heat level, skips a cycle entirely
        at high heat, and holds all dispatches during the post-down grace
        window so the squad can actually attempt the rescue.
      - director.lua: holds new spawns at high heat (unless the field is
        empty), speeds up spawn cadence at low heat.
]]

Heat = {
    value = 0.0,
    graceUntil = 0,     -- os.time() until which chaos dispatches are held
    lowSince = 0,       -- when heat last dropped below LOW (0 = not low)
}

local DECAY_PER_SEC = 2.0
local MAX_HEAT = 120.0

Heat.LOW = 30.0
Heat.HIGH = 70.0

-- Threat tier per cougar type: how much a live one raises the temperature.
local SPAWN_HEAT = {
    fence = 4, ball_blue = 4, ball_purple = 4, stun = 5, car = 6,
    shooter = 6, phantom = 7, leech = 7, pouncer = 7, magnetic = 7,
    jesus = 8, splitter = 8, bomber = 8, swarm = 10, howler = 12, alpha = 18,
}

function Heat.Add(amount)
    if type(amount) ~= 'number' then return end
    Heat.value = math.max(0.0, math.min(MAX_HEAT, Heat.value + amount))
end

function Heat.OnEffectDispatched(fx)
    local severity = (fx and fx.severity) or 2
    local amount = severity * 8.0
    if fx and fx.instant then amount = amount * 0.5 end
    Heat.Add(amount)
end

function Heat.OnCougarSpawned(cougarType)
    Heat.Add(SPAWN_HEAT[cougarType] or 6)
end

function Heat.OnPlayerDowned()
    Heat.Add(30.0)
    -- Breathing room for the rescue attempt: chaos holds fire, director
    -- holds new spawns. Existing threats stay live — the rescue should be
    -- tense, not free.
    Heat.graceUntil = os.time() + 10
end

function Heat.OnPlayerRevived()
    Heat.Add(-15.0)
end

function Heat.InGrace()
    return os.time() < Heat.graceUntil
end

-- 'LOW' | 'MED' | 'HIGH'
function Heat.Level()
    if Heat.value >= Heat.HIGH then return 'HIGH' end
    if Heat.value >= Heat.LOW then return 'MED' end
    return 'LOW'
end

-- Max effect severity the chaos loop may pick right now.
function Heat.MaxSeverity()
    local level = Heat.Level()
    if level == 'HIGH' then return 1 end
    if level == 'MED' then return 2 end
    return 3
end

function Heat.Reset()
    Heat.value = 0.0
    Heat.graceUntil = 0
    Heat.lowSince = 0
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if State.phase == Phase.RUNNING then
            Heat.value = math.max(0.0, Heat.value - DECAY_PER_SEC)
            if Heat.value < Heat.LOW then
                if Heat.lowSince == 0 then Heat.lowSince = os.time() end
            else
                Heat.lowSince = 0
            end
        end
    end
end)

AddEventHandler('cc:chaos_start', Heat.Reset)
AddEventHandler('cc:chaos_stop', Heat.Reset)

RegisterCommand('cc_heat', function(src)
    if src ~= 0 then return end
    print(('[CC] Heat: %.1f (%s)%s | maxSeverity=%d | low for %ds'):format(
        Heat.value, Heat.Level(), Heat.InGrace() and ' [GRACE]' or '',
        Heat.MaxSeverity(),
        Heat.lowSince > 0 and (os.time() - Heat.lowSince) or 0))
end, false)
