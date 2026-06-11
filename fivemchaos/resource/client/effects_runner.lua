local activeTimers = {}

RegisterNetEvent('cc:trigger_effect', function(id, name, fnName, instant, duration, seed)
    local fx = Effects.FindById(id)
    SendNUIMessage({type = 'effect', id = id, name = name, duration = instant and 0 or duration})

    local fn = _G[fnName]
    if not fn then return end

    if instant then
        fn(seed)
    else
        if activeTimers[id] then activeTimers[id]() end

        local running = true
        activeTimers[id] = function() running = false end

        Citizen.CreateThread(function()
            fn(function() return running end, seed)
            activeTimers[id] = nil
        end)

        SetTimeout(duration * 1000, function()
            running = false
        end)
    end
end)

RegisterNetEvent('cc:late_join_sync', function(snapshot, difficulty, meta)
    for _, entry in ipairs(snapshot) do
        local fn = _G[entry.fn]
        if not fn then goto continue end

        local remaining = entry.remainingDuration
        if remaining <= 0 then goto continue end

        SendNUIMessage({type = 'effect', id = entry.id, name = entry.name or entry.id, duration = remaining})

        local running = true
        activeTimers[entry.id] = function() running = false end

        Citizen.CreateThread(function()
            fn(function() return running end, entry.seed)
            activeTimers[entry.id] = nil
        end)

        SetTimeout(remaining * 1000, function()
            running = false
        end)

        ::continue::
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
