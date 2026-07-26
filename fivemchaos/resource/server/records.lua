--[[
    Run records. Nothing mattered twice before this file: no times, no
    history, no reason for run #2 beyond vibes. Stored via
    SaveResourceFile('records.json') so it survives restarts.

    Tracked:
      - all-time best win time (the number speedrunners chase)
      - per-day best (daily leaderboard bucket, kept 14 days)
      - last runs (short history shown in the lobby)
      - win/loss totals
]]

local RECORDS_FILE = 'records.json'
local MAX_HISTORY = 8

local records = {
    best = nil,          -- {time, date, players}
    daily = {},          -- ['YYYY-MM-DD'] = {time, players}
    runs = {},           -- newest first: {result, time, difficulty, players, date}
    totals = {wins = 0, losses = 0},
}

local function LoadRecords()
    local raw = LoadResourceFile(GetCurrentResourceName(), RECORDS_FILE)
    if not raw or raw == '' then return end
    local ok, data = pcall(json.decode, raw)
    if ok and type(data) == 'table' then
        records.best = data.best
        records.daily = type(data.daily) == 'table' and data.daily or {}
        records.runs = type(data.runs) == 'table' and data.runs or {}
        records.totals = type(data.totals) == 'table' and data.totals or {wins = 0, losses = 0}
        print(('[CC] Records loaded: best=%s, %d runs on file'):format(
            records.best and records.best.time or 'none', #records.runs))
    end
end

local function SaveRecords()
    -- Trim daily buckets to the last 14 distinct dates.
    local dates = {}
    for date in pairs(records.daily) do dates[#dates + 1] = date end
    table.sort(dates, function(a, b) return a > b end)
    for i = 15, #dates do records.daily[dates[i]] = nil end

    SaveResourceFile(GetCurrentResourceName(), RECORDS_FILE, json.encode(records), -1)
end

local function BroadcastRecords(target)
    local payload = {
        best = records.best,
        today = records.daily[os.date('%Y-%m-%d')],
        last = records.runs[1],
        totals = records.totals,
    }
    if target then
        TriggerClientEvent('cc:records', target, payload)
    else
        State.Broadcast('cc:records', payload)
    end
end

-- Fired by EndMission with the authoritative run summary.
AddEventHandler('cc:mission_finished', function(result, summary)
    if type(summary) ~= 'table' then return end
    local today = os.date('%Y-%m-%d')

    table.insert(records.runs, 1, {
        result = result,
        time = summary.time,
        difficulty = summary.difficulty,
        players = summary.players,
        date = today,
    })
    while #records.runs > MAX_HISTORY do table.remove(records.runs) end

    if result == 'WON' then
        records.totals.wins = records.totals.wins + 1
        local isRecord = not records.best or summary.time < records.best.time
        if isRecord then
            records.best = {time = summary.time, date = today, players = summary.players}
            State.Broadcast('cc:new_record', summary.time)
            print(('[CC] NEW RECORD: %ds'):format(summary.time))
        end
        local daily = records.daily[today]
        if not daily or summary.time < daily.time then
            records.daily[today] = {time = summary.time, players = summary.players}
        end
    else
        records.totals.losses = records.totals.losses + 1
    end

    SaveRecords()
    BroadcastRecords()
end)

-- Late joiners / fresh connects get the current records for the lobby card.
AddEventHandler('cc:player_joined_lobby', function(src)
    BroadcastRecords(src)
end)

RegisterCommand('cc_records', function(src)
    if src ~= 0 then return end
    print(('[CC] Best: %s | Today: %s | W/L: %d/%d'):format(
        records.best and (records.best.time .. 's on ' .. records.best.date) or 'none',
        records.daily[os.date('%Y-%m-%d')] and records.daily[os.date('%Y-%m-%d')].time .. 's' or 'none',
        records.totals.wins, records.totals.losses))
    for i, run in ipairs(records.runs) do
        print(('  %d. %s %s %ds @ %.0f%% (%dp)'):format(
            i, run.date, run.result, run.time or 0, (run.difficulty or 0) * 100, run.players or 0))
    end
end, false)

AddEventHandler('onResourceStart', function(name)
    if name ~= GetCurrentResourceName() then return end
    LoadRecords()
end)
