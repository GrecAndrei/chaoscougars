AddEventHandler('cc:player_joined_running', function(src)
    if State.phase ~= Phase.RUNNING and State.phase ~= Phase.PAUSED then return end

    local now = os.time()
    local snapshot = {}

    for _, entry in ipairs(State.activeEffectsList) do
        if entry.expiresAt > now then
            -- Skip META effects: their state is already applied server-side
            -- via State.meta (which is sent below). Re-dispatching them on
            -- the client just runs a no-op META body, which is harmless but
            -- wastes a thread slot and creates a phantom HUD timer card.
            if entry.sync_mode == SyncMode.META then goto continue end
            -- Skip SPAWN_SINGLE effects targeted at a different player; the
            -- executor is the only client who should run the body, and the
            -- late joiner isn't it.
            if entry.sync_mode ~= SyncMode.SPAWN_SINGLE or entry.executorId == src then
                snapshot[#snapshot + 1] = {
                    id = entry.id,
                    fn = entry.fn,
                    name = entry.name,
                    sync_mode = entry.sync_mode,
                    remainingDuration = entry.expiresAt - now,
                    seed = entry.seed,
                }
            end
        end
        ::continue::
    end

    -- Build a snapshot of active cougars so the late-joiner gets the right
    -- HUD count and knows which cougar types are in flight (entity sync
    -- already streams the actual cougar entities; we just need the count
    -- and metadata for the HUD / debug).
    --
    -- Cap to MAX_LATE_JOIN_COUGARS to keep the trigger payload well under
    -- FiveM's per-event size limit. Late joiners don't need full positional
    -- detail; just type+netId for the debug log.
    local MAX_LATE_JOIN_COUGARS = 32
    local cougars = {}
    local count = 0
    for netId, cougar in pairs(Director.cougars) do
        if count >= MAX_LATE_JOIN_COUGARS then break end
        cougars[#cougars + 1] = {
            netId = netId,
            type = cougar.type,
        }
        count = count + 1
    end

    TriggerClientEvent('cc:late_join_sync', src, snapshot, State.difficulty, State.meta, cougars)
    TriggerClientEvent('cc:cougar_count', src, CountCougars())
    TriggerClientEvent('cc:difficulty', src, State.difficulty)
end)
