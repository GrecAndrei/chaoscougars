--[[
    Vote-the-chaos: when the chaos timer expires, instead of the server
    rolling in private, the squad gets 3 candidate effects on screen and
    ~8 seconds to argue about it. Majority wins; ties and silence fall back
    to a random pick among the leaders. The winning effect goes through the
    exact same DispatchEffect pipeline as a normal roll.

    Active when Config.VoteEffects is on OR a META effect sets
    State.meta.votingMode = 'chaos'. Needs 2+ connected players — solo
    "voting" is just an effect picker and kills the chaos.
]]

EffectVote = {
    active = false,
    options = {},        -- array of {id, name}
    votes = {},          -- src -> option index
    generation = 0,
}

local function CountBallots()
    local counts = {}
    for i = 1, #EffectVote.options do counts[i] = 0 end
    for _, choice in pairs(EffectVote.votes) do
        if counts[choice] then counts[choice] = counts[choice] + 1 end
    end
    return counts
end

local function BroadcastTally()
    local counts = CountBallots()
    local options = {}
    for i, opt in ipairs(EffectVote.options) do
        options[i] = {name = opt.name, votes = counts[i]}
    end
    State.Broadcast('cc:effect_vote_update', options, State.PlayerCount())
end

function EffectVote.ShouldVote()
    if EffectVote.active then return false end
    if State.PlayerCount() < 2 then return false end
    return Config.VoteEffects == true or State.meta.votingMode == 'chaos'
end

-- Returns true if a vote started (the chaos loop then re-arms its timer and
-- moves on; the winner dispatches asynchronously when the window closes).
function EffectVote.Begin(pickOpts)
    if EffectVote.active then return false end

    -- Draw distinct candidates through the normal filtered roll so recent
    -- effects, conflicts, heat severity, and crowd rules all still apply.
    local picked, seen = {}, {}
    for _ = 1, 12 do
        if #picked >= 3 then break end
        local fx = Effects.GetRandom(Chaos.recentEffects, Chaos.activeEffects, Chaos.activeChannels, pickOpts)
        if not fx then break end
        if not seen[fx.id] then
            seen[fx.id] = true
            picked[#picked + 1] = fx
        end
    end
    if #picked < 2 then return false end -- not enough variety; caller rolls normally

    EffectVote.active = true
    EffectVote.votes = {}
    EffectVote.options = {}
    EffectVote.generation = EffectVote.generation + 1
    local generation = EffectVote.generation
    for i, fx in ipairs(picked) do
        EffectVote.options[i] = {id = fx.id, name = fx.name}
    end

    local window = Config.VoteEffectWindowSec or 8
    State.Broadcast('cc:effect_vote', EffectVote.options, window, State.PlayerCount())

    SetTimeout(window * 1000, function()
        if EffectVote.generation ~= generation then return end
        EffectVote.Resolve()
    end)
    return true
end

function EffectVote.Resolve()
    if not EffectVote.active then return end
    EffectVote.active = false
    State.Broadcast('cc:vote_end')

    if State.phase ~= Phase.RUNNING then return end

    local counts = CountBallots()
    local best, leaders = -1, {}
    for i = 1, #EffectVote.options do
        if counts[i] > best then
            best = counts[i]
            leaders = {i}
        elseif counts[i] == best then
            leaders[#leaders + 1] = i
        end
    end
    local choice = EffectVote.options[leaders[math.random(#leaders)]]
    local fx = choice and Effects.FindById(choice.id)
    if not fx then return end

    local duration = fx.instant and 0 or (fx.short and Config.ShortDuration or Config.EffectDuration)
    duration = math.max(1, math.floor(duration * (State.meta.durationModifier or 1.0)))
    if Chaos.DispatchEffect(fx, duration, math.random(1, 2147483647)) then
        Chaos.MarkRecent(fx)
        print(('[CC] Vote resolved: %s (%d ballots)'):format(fx.id, best))
    end
end

RegisterNetEvent('cc:effect_vote_cast', function(optionIndex)
    local src = source
    if type(src) ~= 'number' or src < 1 then return end
    if not State.players[src] then return end
    if not EffectVote.active then return end
    if State.phase ~= Phase.RUNNING then return end
    if type(optionIndex) ~= 'number' or optionIndex % 1 ~= 0 then return end
    if optionIndex < 1 or optionIndex > #EffectVote.options then return end
    -- Re-voting switches your ballot; that is intentional (arguing is the point).
    EffectVote.votes[src] = optionIndex
    BroadcastTally()
end)

AddEventHandler('playerDropped', function()
    local src = source
    if EffectVote.votes[src] then
        EffectVote.votes[src] = nil
        if EffectVote.active then BroadcastTally() end
    end
end)

-- Mission stop while a vote is open: invalidate the pending resolution.
AddEventHandler('cc:chaos_stop', function()
    if EffectVote.active then
        EffectVote.active = false
        EffectVote.generation = EffectVote.generation + 1
        State.Broadcast('cc:vote_end')
    end
end)
