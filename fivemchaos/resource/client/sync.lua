local MyState = {
    phase = Phase.LOBBY,
    startTime = 0,
}

Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() do
        Citizen.Wait(50)
    end

    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    DoScreenFadeOut(0)

    Citizen.Wait(500)

    local ped = PlayerPedId()
    -- Only do the hard LSIA respawn if we're not already in a mission.
    -- Without this gate, a player connecting mid-mission would be teleported
    -- to the start position before the late-join sync arrives, fighting the
    -- mission-start teleport (and the player's actual position would be lost).
    --
    -- Race-safety: TriggerClientEvent messages can arrive BEFORE the
    -- session is fully started (FiveM fires them as soon as the connection
    -- is up, even during the loading-screen Wait). Wait an extra tick here
    -- to let any pending cc:state / cc:late_join_sync events drain into
    -- MyState before we check it.
    Citizen.Wait(100)
    if MyState.phase == Phase.LOBBY then
        NetworkResurrectLocalPlayer(Config.Start.x, Config.Start.y, Config.Start.z, 270.0, true, false)
        SetEntityCoords(ped, Config.Start.x, Config.Start.y, Config.Start.z, false, false, false, false)
        SetEntityVisible(ped, true, false)
        SetEntityHealth(ped, 200)
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, false)

        DoScreenFadeIn(500)
    end
    TriggerServerEvent('cc:join')
end)

RegisterNetEvent('cc:state', function(phase, startTime)
    MyState.phase = phase
    MyState.startTime = startTime
    SendNUIMessage({type = 'state', phase = phase})
end)

RegisterNetEvent('cc:mission_start', function(data)
    MyState.phase = Phase.STARTING
    local ped = PlayerPedId()

    SetEntityCoords(ped, data.start.x, data.start.y, data.start.z, false, false, false, false)
    Citizen.Wait(1000)

    local hash = GetHashKey(data.vehicle)
    RequestModel(hash)
    local t = 50
    while not HasModelLoaded(hash) and t > 0 do Citizen.Wait(100); t = t - 1 end

    local veh = CreateVehicle(hash, data.start.x, data.start.y, data.start.z + 1.0, 90.0, true, false)
    SetVehicleOnGroundProperly(veh)
    TaskWarpPedIntoVehicle(ped, veh, -1)
    SetVehicleEngineOn(veh, true, true, false)
    SetModelAsNoLongerNeeded(hash)

    SetNewWaypoint(data.finish.x, data.finish.y)
    SendNUIMessage({type = 'mission_start'})
end)

RegisterNetEvent('cc:mission_end', function(data)
    MyState.phase = data.result
    SendNUIMessage({type = 'mission_end', result = data.result, detail = data.detail, time = data.time, alive = data.alive})
end)

-- Position report
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if MyState.phase == Phase.RUNNING then
            TriggerServerEvent('cc:pos', GetEntityCoords(PlayerPedId()))
        end
    end
end)

-- Win detection
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if MyState.phase == Phase.RUNNING then
            if #(GetEntityCoords(PlayerPedId()) - Config.Finish) < Config.WinRadius then
                TriggerServerEvent('cc:reached_finish')
                Citizen.Wait(5000)
            end
        end
    end
end)

-- Death detection
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if MyState.phase == Phase.RUNNING and IsEntityDead(PlayerPedId()) then
            TriggerServerEvent('cc:died')
            Citizen.Wait(3000)

            local respawnPos = Config.Start
            NetworkResurrectLocalPlayer(respawnPos.x, respawnPos.y, respawnPos.z, 270.0, true, false)
            Citizen.Wait(500)

            local ped = PlayerPedId()
            SetEntityCoords(ped, respawnPos.x, respawnPos.y, respawnPos.z, false, false, false, false)
            SetEntityVisible(ped, true, false)
            SetEntityInvincible(ped, true)
            Citizen.Wait(2000)
            SetEntityInvincible(ped, false)

            local hash = GetHashKey(Config.StartVehicle)
            RequestModel(hash)
            local t = 50
            while not HasModelLoaded(hash) and t > 0 do Citizen.Wait(100); t = t - 1 end
            if HasModelLoaded(hash) then
                local veh = CreateVehicle(hash, respawnPos.x, respawnPos.y, respawnPos.z + 1.0, 90.0, true, false)
                SetVehicleOnGroundProperly(veh)
                TaskWarpPedIntoVehicle(ped, veh, -1)
                SetVehicleEngineOn(veh, true, true, false)
                SetModelAsNoLongerNeeded(hash)
            end

            TriggerServerEvent('cc:respawned')
            Citizen.Wait(5000)
        end
    end
end)

-- Vehicle enforcement
Citizen.CreateThread(function()
    while true do
        if MyState.phase == Phase.RUNNING then
            Citizen.Wait(500)
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            if veh ~= 0 and Config.BannedClasses[GetVehicleClass(veh)] then
                TaskLeaveVehicle(ped, veh, 16)
                Citizen.Wait(800)
                if DoesEntityExist(veh) then DeleteEntity(veh) end
                SendNUIMessage({type = 'hit', variant = 'NO AIRCRAFT!'})
            end
        else
            Citizen.Wait(2000)
        end
    end
end)

-- Pause vote: F9
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if (MyState.phase == Phase.RUNNING or MyState.phase == Phase.PAUSED) and IsControlJustPressed(0, 56) then
            TriggerServerEvent('cc:vote_pause')
        end
    end
end)

-- Owner-transfer safety net. AIIsMine re-requests control of an entity
-- when the engine hands ownership to a different player (e.g. after a
-- cougar strays far from its original spawning client, or the spawning
-- client disconnects). Network ownership can flip mid-game; this loop
-- scans for any nearby cougars whose owner we used to be but lost, and
-- re-requests control. Runs every 2s; cheap.
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        if MyState.phase == Phase.RUNNING then
            local myPed = PlayerPedId()
            if not myPed or not DoesEntityExist(myPed) then goto continue end
            local myPos = GetEntityCoords(myPed)
            for _, ped in ipairs(GetGamePool('CPed')) do
                if ped ~= myPed and not IsEntityDead(ped) and NetworkGetEntityIsNetworked(ped) then
                    local entPos = GetEntityCoords(ped)
                    if #(myPos - entPos) < 300.0 then
                        if NetworkGetEntityOwner(ped) ~= PlayerId() then
                            if not NetworkHasControlOfEntity(ped) then
                                NetworkRequestControlOfEntity(ped)
                            end
                        end
                    end
                end
            end
        end
        ::continue::
    end
end)
