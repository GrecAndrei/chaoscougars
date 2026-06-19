-- Per-effect timer state. activeTimers[id] holds:
--   .gen     - monotonically increasing generation number for this effect id
--   .cancel  - function that sets the effect's `running` flag to false
-- The generation is captured by every SetTimeout closure created for that
-- effect invocation. When the SetTimeout fires, it only cancels if its
-- captured generation is still the current one — so a retrigger at time T
-- into a duration-D effect bumps the generation, and the OLD SetTimeout
-- becomes a no-op when it fires at (D - T). Without this, retriggered
-- effects were killed early by the previous trigger's timer.
local activeTimers = {}

RegisterNetEvent('cc:trigger_effect', function(id, name, fnName, instant, duration, seed)
    -- Defensive: a malformed/typed `id` would break the activeTimers table
    -- (non-string keys can collide with other systems that share the same
    -- table). Reject any non-string/non-positive-length id.
    if type(id) ~= 'string' or id == '' then return end
    if type(fnName) ~= 'string' or fnName == '' then return end

    local fx = Effects.FindById(id)
    SendNUIMessage({type = 'effect', id = id, name = name, duration = instant and 0 or duration})

    local fn = _G[fnName]
    if not fn then return end

    if instant then
        fn(seed)
    else
        local prev = activeTimers[id]
        local gen = (prev and prev.gen or 0) + 1
        if prev and prev.cancel then prev.cancel() end

        local running = true
        local cancel = function() running = false end
        activeTimers[id] = {gen = gen, cancel = cancel}

        Citizen.CreateThread(function()
            fn(function() return running end, seed)
            if activeTimers[id] and activeTimers[id].gen == gen then
                activeTimers[id] = nil
            end
        end)

        SetTimeout(duration * 1000, function()
            if activeTimers[id] and activeTimers[id].gen == gen then
                cancel()
            end
        end)
    end
end)

RegisterNetEvent('cc:late_join_sync', function(snapshot, difficulty, meta, cougars)
    if type(snapshot) ~= 'table' then return end
    for _, entry in ipairs(snapshot) do
        if type(entry) == 'table' and type(entry.id) == 'string' and type(entry.fn) == 'string' then
            local fn = _G[entry.fn]
            if not fn then goto continue end

            local remaining = entry.remainingDuration or 0
            if remaining <= 0 then goto continue end

            SendNUIMessage({type = 'effect', id = entry.id, name = entry.name or entry.id, duration = remaining})

            local running = true
            activeTimers[entry.id] = {gen = 1, cancel = function() running = false end}

            Citizen.CreateThread(function()
                fn(function() return running end, entry.seed)
                if activeTimers[entry.id] and activeTimers[entry.id].gen == 1 then
                    activeTimers[entry.id] = nil
                end
            end)

            SetTimeout(remaining * 1000, function()
                if activeTimers[entry.id] and activeTimers[entry.id].gen == 1 then
                    if activeTimers[entry.id].cancel then activeTimers[entry.id].cancel() end
                end
            end)
        end

        ::continue::
    end

    -- The cougar entities are streamed to us via normal network sync; the
    -- cougars array here is just metadata for the HUD / debug overlay. The
    -- server has already sent cc:cougar_count, which is what the HUD reads.
    if cougars and #cougars > 0 then
        print(('[CC] Late-join: %d active cougar(s) in flight'):format(#cougars))
    end

    if meta and meta.hideChaosUI then
        SendNUIMessage({type = 'meta_ui', hidden = true})
    end
end)

RegisterNetEvent('cc:clear_effects', function()
    for _, cancel in pairs(activeTimers) do cancel() end
    activeTimers = {}

    ClearTimecycleModifier()
    SetTimeScale(1.0)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    SetNightvision(false)
    SetSeethrough(false)
    SetGravityLevel(0)
    RenderScriptCams(false, false, 0, true, true)
    StopGameplayCamShaking(true)
    ClearWeatherTypePersist()
    SetArtificialLightsState(false)

    local ped = PlayerPedId()
    SetEntityInvincible(ped, false)
    SetEntityMaxHealth(ped, 200)
    ResetPedMovementClipset(ped, 0.0)

    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        SetVehicleEnginePowerMultiplier(veh, 1.0)
        SetVehicleReduceGrip(veh, false)
        SetEntityInvincible(veh, false)
    end

    SendNUIMessage({type = 'effects_cleared'})
end)

-- Resource stop. Without this, every active FX_* effect's exit-cleanup
-- code (e.g., ClearTimecycleModifier, SetGravityLevel(0), SetEntityMaxHealth
-- restore, etc.) is skipped when the Citizen thread is killed. The result
-- is a permanently-degraded client: stuck gravity level, max-health 1,
-- invincible vehicle, weather persist, cam locked, etc. Wire the same
-- reset that cc:clear_effects does.
AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end

    -- Cancel every active effect's `running` flag so its while-loop exits
    -- and its own cleanup block runs. We can't wait for them synchronously,
    -- so we also fire the same one-shot reset that cc:clear_effects does.
    for _, entry in pairs(activeTimers) do
        if entry and entry.cancel then entry.cancel() end
    end
    activeTimers = {}

    ClearTimecycleModifier()
    SetTimeScale(1.0)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    SetNightvision(false)
    SetSeethrough(false)
    SetGravityLevel(0)
    RenderScriptCams(false, false, 0, true, true)
    StopGameplayCamShaking(true)
    ClearWeatherTypePersist()
    SetArtificialLightsState(false)
    NetworkClearClockTimeOverride()

    local ped = PlayerPedId()
    if ped and DoesEntityExist(ped) then
        SetEntityInvincible(ped, false)
        SetEntityMaxHealth(ped, 200)
        ResetPedMovementClipset(ped, 0.0)
        SetPedIsDrunk(ped, false)
        SetAmbientVoiceName(ped, GetHashKey('A_M_Y_ACULT_01_WHITE_FULL_01'))
        SetSuperJumpThisFrame(PlayerId())
    end

    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 and DoesEntityExist(veh) then
        SetVehicleEnginePowerMultiplier(veh, 1.0)
        SetVehicleReduceGrip(veh, false)
        SetEntityInvincible(veh, false)
        SetEntityProofs(veh, false, false, false, false, false, false, false, false)
        ResetEntityAlpha(veh)
    end

    -- Tell the HUD UI to reset its hide flag and any other state.
    SendNUIMessage({type = 'effects_cleared'})
    SendNUIMessage({type = 'meta_ui', hidden = false})
end)
