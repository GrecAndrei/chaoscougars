AddEventHandler('cc:player_joined_running', function(src)
    if State.phase ~= Phase.RUNNING and State.phase ~= Phase.PAUSED then return end

    local now = os.time()
    local snapshot = {}

    for _, entry in ipairs(State.activeEffectsList) do
        if entry.expiresAt > now then
            local remaining = entry.expiresAt - now
            if entry.sync_mode ~= SyncMode.SPAWN_SINGLE or entry.executorId == src then
                snapshot[#snapshot + 1] = {
                    id = entry.id,
                    fn = entry.fn,
                    name = entry.name,
                    sync_mode = entry.sync_mode,
                    remainingDuration = remaining,
                    seed = entry.seed,
                }
            end
        end
    end

    TriggerClientEvent('cc:late_join_sync', src, snapshot, State.difficulty, State.meta)
    TriggerClientEvent('cc:difficulty', src, State.difficulty)
end)
