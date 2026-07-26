--[[
    Effect tuning layer. Runs AFTER both registries are appended to
    Effects.Pool and BEFORE Effects.FinalizeRegistry() (which now lives at
    the bottom of this file), so flag corrections here affect channel
    assignment and validation.

    Why this file exists instead of editing effects_generated_registry.lua:
    that file is produced by tools/transpile_effects.py. Hand edits there die
    on the next regeneration; overrides here survive it.

    Three jobs:
      1. OVERRIDES  - fix registry flags that contradict the effect body
                      (instant effects whose bodies loop on alive(), and
                      timed effects whose bodies are one-shots).
      2. RUN_DISABLED - effects that are fine in a sandbox chaos mod but
                      run-ruining in a point-A-to-B race (progress-erasing
                      teleports, uncounterable instant death). They stay in
                      the registry and remain admin-dispatchable via
                      cc_effect / the panel; they are only removed from the
                      random pool (Effects.GetRandom skips runDisabled).
      3. Severity + crowd stamping - every effect gets fx.severity
                      (1=mild, 2=medium, 3=spicy) for the server heat
                      director, and fx.needsCrowd for effects that operate
                      on ambient peds and do nothing on empty country roads.
]]

-- ===========================================================================
-- 1. Flag corrections
-- ===========================================================================

local OVERRIDES = {
    -- Marked instant but the body loops on alive(). The runner calls
    -- instant effects as fn(seed), so `alive` arrives as a number and the
    -- body crashes with "attempt to call a number value" every time it
    -- fires. These clearly want a duration -> timed, short.
    misc_fakecrash          = {instant = false, short = true},
    misc_quick_sprunk_stop  = {instant = false, short = true},
    peds_ignite             = {instant = false, short = true},
    playerveh_tprandompeds  = {instant = false, short = true},
    player_fakedeath        = {instant = false, short = true},
    player_hacking          = {instant = false, short = true},
    player_rocket           = {instant = false, short = true},
    playerveh_explode       = {instant = false, short = true},

    -- Timed in the registry but the body is a one-shot with no alive()
    -- loop. The server reserved their scope channel for the full duration
    -- while nothing ran, starving every other effect in that scope.
    misc_airstrike          = {instant = true, short = nil},
    misc_news_team          = {instant = true, short = nil},
    peds_flip               = {instant = true, short = nil},
    peds_kifflom            = {instant = true, short = nil},
    peds_roasting           = {instant = true, short = nil},
    peds_sayhi              = {instant = true, short = nil},
}

-- ===========================================================================
-- 2. Banned from the random pool (kept for admin/manual dispatch)
-- ===========================================================================

local RUN_DISABLED = {
    -- Progress-erasing or progress-skipping teleports. In a race, a random
    -- teleport is the game rolling a die and deciding the run. tp_fake /
    -- tp_fakex2 / player_tpfront stay in: they are the good version of the
    -- joke (progress-neutral).
    'tp_lsairport',              -- teleports you back to the START
    'tp_mazebanktower',
    'tp_fortzancudo',
    'tp_mountchilliad',
    'tp_skyfall',
    'tp_random',
    'tp_mission',
    'player_tptowaypoint',       -- free fast-travel to your own waypoint
    'player_tptowaypointopposite',
    'player_tp_store',
    'player_tp_stunt',
    'misc_go_to_jail',           -- teleport to LS jail = back across the map
    -- Uncounterable instant death. With the co-op downed system this burns
    -- a revive on a coin flip; solo it is instant mission-over.
    'player_suicide',
}

-- ===========================================================================
-- 3. Severity + crowd stamping for the heat director
-- ===========================================================================

-- Explicit wins over pattern, pattern wins over default (2 = medium).
local SEVERITY_EXPLICIT = {
    -- The fake-out jokes are harmless by design.
    tp_fake = 1, tp_fakex2 = 1, player_tpfront = 1, nothing = 1,
    misc_pause = 1, misc_fakecrash = 2, player_fakestars = 1,
    -- Heavy hitters that pattern rules would miss.
    playerveh_despawn = 3,       -- deletes the squad car
    vehs_disassemble = 3,
    vehs_detach_wheel = 3,
    playerveh_lock = 2,
    misc_get_towed = 3,
    veh_repossession = 3,
    chaosmode = 3, meta_super_chaos = 3, meta_chaos_ramp = 3,
    meta_timer_5x = 3, meta_timerspeed_5x = 3,
}

local SPICY_PATTERNS = {
    'gravity', 'superhot', '^time_x', 'slow_mo', 'very_fast', 'gamespeed',
    'blackout', 'extreme_dark', 'blackhole', 'meteor', 'upupaway',
    'launch_', 'invert', 'explode', 'detonate', 'ignite', 'ohko', 'one_hit',
    'no_steering', 'confused_controls', 'reverse_only', 'cant_move',
    'killengine', 'beyblade', 'lag$', 'flip_screen', 'mirrored',
    'foldedscreen', 'fourthdimension', 'screenpotato', 'textureless',
    'shattered', 'freakout', 'dimwarp', 'warpedcam', 'localcoop',
    'fckautorotate', 'lockdoors', 'lock_doors',
}

local MILD_PATTERNS = {
    -- Traffic paint jobs and cosmetics
    '^vehs_red$', '^vehs_blue$', '^vehs_green$', '^vehs_chrome$',
    '^vehs_pink$', '^vehs_rainbow$', 'randtraffic', 'randclothes',
    -- Audio gags
    'highpitch', 'lowpitch', 'weirdpitch', 'muffled', 'arenawars', 'honk',
    -- Social / ambient ped flavor
    'sayhi', 'insult', 'kifflom', 'wave', 'peds_sit', 'peds_dance',
    'levitate', 'phones', 'stop_stare', 'hands_up', 'bloody', 'headless',
    'smoketrails', 'gunsmoke', 'famous', 'roasting', 'news',
    -- Harmless screen/HUD flavor
    'moneydrops', 'money_rain', 'fireworks', 'pay_respects', 'credits',
    'waypoint', 'radar', 'maximap', 'portrait', 'dvdscreensaver', 'nosky',
    'nophone', 'esp$', 'fake_', 'binoculars',
}

-- GLOBAL_OWNED effects prefixed ped/peds operate on ambient population via
-- ForEachOwnedPed. On the empty stretches north of the city they fire into
-- a vacuum. SPAWN_SINGLE ped effects create their own actors and are fine.
local function StampCrowd(fx)
    if fx.sync_mode == SyncMode.GLOBAL_OWNED and fx.id:match('^peds?_') then
        fx.needsCrowd = true
    end
end

local function MatchAny(id, patterns)
    for _, p in ipairs(patterns) do
        if id:find(p) then return true end
    end
    return false
end

local function StampSeverity(fx)
    if SEVERITY_EXPLICIT[fx.id] then
        fx.severity = SEVERITY_EXPLICIT[fx.id]
    elseif MatchAny(fx.id, SPICY_PATTERNS) then
        fx.severity = 3
    elseif MatchAny(fx.id, MILD_PATTERNS) then
        fx.severity = 1
    else
        fx.severity = 2
    end
end

-- ===========================================================================
-- Apply
-- ===========================================================================

local disabledSet = {}
for _, id in ipairs(RUN_DISABLED) do disabledSet[id] = true end

local overridden, disabled = 0, 0
for _, fx in ipairs(Effects.Pool) do
    local patch = OVERRIDES[fx.id]
    if patch then
        for k, v in pairs(patch) do fx[k] = v end
        -- `short = nil` in a patch can't clear via pairs(); handle explicitly.
        if patch.instant == true then fx.short = nil end
        overridden = overridden + 1
    end
    if disabledSet[fx.id] then
        fx.runDisabled = true
        disabled = disabled + 1
    end
    StampSeverity(fx)
    StampCrowd(fx)
end

print(('[CC] Effect tuning: %d flag overrides, %d pulled from random pool, %d total effects'):format(
    overridden, disabled, #Effects.Pool))

-- Validate and index. Moved here from effects_generated_registry.lua so
-- tuning always applies before channels/validation are computed.
Effects.FinalizeRegistry()
