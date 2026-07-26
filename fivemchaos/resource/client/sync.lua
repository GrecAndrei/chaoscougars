-- Shared with spawner.lua so async entity creation can abort cleanly when a
-- mission ends. This is intentionally one resource-level state object.
MyState = {
    phase = Phase.LOBBY,
    startTime = 0,
}

local iAmDowned = false
-- serverId -> {pos = vector3, deadline = GetGameTimer()-based ms}
local downedTeammates = {}
local reviveTarget, reviveStartedAt = nil, 0
local bleedoutGeneration = 0
local spectating = false

local function StopSpectate()
    if spectating then
        spectating = false
        NetworkSetInSpectatorMode(false, PlayerPedId())
    end
end

local function StartSpectate()
    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local ped = GetPlayerPed(playerId)
            if ped and DoesEntityExist(ped) and not IsEntityDead(ped) then
                spectating = true
                NetworkSetInSpectatorMode(true, ped)
                SendNUIMessage({type = 'hit', variant = 'SPECTATING THE PACK'})
                return
            end
        end
    end
end

local function HelpText(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, false, 1)
end

local function DrawReviveMarker(pos)
    DrawMarker(0, pos.x, pos.y, pos.z + 1.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.35, 0.35, 0.35, 235, 55, 55, 185, false, true, 2, false, nil, nil, false)
end

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

local startVehicle = 0

RegisterNetEvent('cc:state', function(phase, startTime)
    MyState.phase = phase
    MyState.startTime = startTime
    -- Grid start: the squad sits frozen through the countdown; the
    -- authoritative GO is the server flipping to RUNNING.
    if phase ~= Phase.STARTING and startVehicle ~= 0 then
        if DoesEntityExist(startVehicle) then
            FreezeEntityPosition(startVehicle, false)
        end
        startVehicle = 0
        if phase == Phase.RUNNING then
            PlaySoundFrontend(-1, 'Beep_Green', 'DLC_HEIST_HACKING_SNAKE_SOUNDS', false)
        end
    end
    SendNUIMessage({type = 'state', phase = phase})
end)

RegisterNetEvent('cc:mission_start', function(data)
    MyState.phase = Phase.STARTING
    iAmDowned = false
    downedTeammates = {}
    bleedoutGeneration = bleedoutGeneration + 1
    StopSpectate()
    SendNUIMessage({type = 'bleedout_end'})
    local ped = PlayerPedId()

    -- A cancelled player effect must never carry invincibility into a new
    -- survival run. Reset both native variants before the start teleport.
    SetPlayerInvincible(PlayerId(), false)
    SetEntityInvincible(ped, false)

    -- Grid slot: two columns, staggered rows, so squad cars spawn as a
    -- starting grid instead of four vehicles intersecting at one coordinate.
    local slot = tonumber(data.slot) or 0
    local col, row = slot % 2, math.floor(slot / 2)
    local sx = data.start.x + col * 5.0
    local sy = data.start.y - row * 7.0

    SetEntityCoords(ped, sx, sy, data.start.z, false, false, false, false)
    Citizen.Wait(1000)

    local hash = GetHashKey(data.vehicle)
    RequestModel(hash)
    local t = 50
    while not HasModelLoaded(hash) and t > 0 do Citizen.Wait(100); t = t - 1 end

    local veh = CreateVehicle(hash, sx, sy, data.start.z + 1.0, 90.0, true, false)
    SetVehicleOnGroundProperly(veh)
    TaskWarpPedIntoVehicle(ped, veh, -1)
    SetVehicleEngineOn(veh, true, true, false)
    SetModelAsNoLongerNeeded(hash)

    -- Hold the grid until the server flips to RUNNING (see cc:state).
    startVehicle = veh
    FreezeEntityPosition(veh, true)

    SetNewWaypoint(data.finish.x, data.finish.y)
    SendNUIMessage({type = 'mission_start'})

    -- Countdown beeps behind the NUI's 3-2-1.
    Citizen.CreateThread(function()
        for _ = 1, 3 do
            if MyState.phase ~= Phase.STARTING then return end
            PlaySoundFrontend(-1, 'Beep_Red', 'DLC_HEIST_HACKING_SNAKE_SOUNDS', false)
            Citizen.Wait(1000)
        end
    end)
end)

RegisterNetEvent('cc:mission_end', function(data)
    MyState.phase = data.result
    iAmDowned = false
    downedTeammates = {}
    bleedoutGeneration = bleedoutGeneration + 1
    StopSpectate()
    SendNUIMessage({type = 'bleedout_end'})
    SendNUIMessage({type = 'mission_end', result = data.result, detail = data.detail,
        time = data.time, alive = data.alive, stats = data.stats})

    -- Endings deserve a beat: brief slow-mo on both outcomes. Delayed past
    -- the cc:clear_effects hard reset (which lands in the same broadcast
    -- burst and would immediately stomp SetTimeScale).
    local result = data.result
    SetTimeout(200, function()
        if MyState.phase ~= result then return end
        SetTimeScale(result == 'WON' and 0.35 or 0.3)
        SetTimeout(2600, function()
            SetTimeScale(1.0)
        end)
    end)

    -- Victory fireworks over the squad during the slow-mo.
    if result == 'WON' then
        Citizen.CreateThread(function()
            RequestNamedPtfxAsset('proj_indep_firework_v2')
            local t = 30
            while not HasNamedPtfxAssetLoaded('proj_indep_firework_v2') and t > 0 do
                Citizen.Wait(100); t = t - 1
            end
            if t == 0 then return end
            local pos = GetEntityCoords(PlayerPedId())
            for _ = 1, 6 do
                UseParticleFxAsset('proj_indep_firework_v2')
                StartParticleFxNonLoopedAtCoord('scr_indep_fireworks',
                    pos.x + math.random(-25, 25), pos.y + math.random(-25, 25), pos.z + math.random(18, 32),
                    0.0, 0.0, 0.0, 1.0, false, false, false)
                PlaySoundFrontend(-1, 'CHALLENGE_UNLOCKED', 'HUD_AWARDS', false)
                Citizen.Wait(450)
            end
        end)
    end
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

-- Finish-line beacon: a tall light column over Paleto visible from the
-- highway, so the last kilometer feels like a finish and not a coordinate.
Citizen.CreateThread(function()
    while true do
        if MyState.phase == Phase.RUNNING
            and #(GetEntityCoords(PlayerPedId()) - Config.Finish) < 700.0 then
            Citizen.Wait(0)
            DrawMarker(1, Config.Finish.x, Config.Finish.y, Config.Finish.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                Config.WinRadius * 2.0, Config.WinRadius * 2.0, 120.0,
                142, 189, 122, 110, false, false, 2, false, nil, nil, false)
        else
            Citizen.Wait(1000)
        end
    end
end)

-- Co-op death / downed state. The old automatic solo respawn made teammates
-- irrelevant. A downed player now stays put until a living teammate performs
-- a validated revive; a solo run still ends immediately on death server-side.
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if MyState.phase == Phase.RUNNING and not iAmDowned and IsEntityDead(PlayerPedId()) then
            iAmDowned = true
            TriggerServerEvent('cc:died')
        end
    end
end)

RegisterNetEvent('cc:player_downed', function(serverId, pos, aliveCount, windowSec)
    if type(serverId) ~= 'number' or type(pos) ~= 'table' then return end
    if serverId ~= GetPlayerServerId(PlayerId()) then
        downedTeammates[serverId] = {
            pos = vector3(pos.x, pos.y, pos.z),
            deadline = GetGameTimer() + (tonumber(windowSec) or Config.ReviveWindowSec) * 1000,
        }
        -- Only teammates get the callout; the downed player just went down
        -- and does not need to be told about themselves.
        SendNUIMessage({type = 'hit', variant = 'TEAMMATE DOWN!'})
    end
end)

-- Downed player's own bleed-out clock. When it expires unrescued, they
-- shift to spectating the surviving pack instead of staring at their corpse
-- for the rest of the run.
RegisterNetEvent('cc:bleedout', function(windowSec)
    if type(windowSec) ~= 'number' or windowSec <= 0 then return end
    iAmDowned = true
    bleedoutGeneration = bleedoutGeneration + 1
    local generation = bleedoutGeneration
    SendNUIMessage({type = 'bleedout', seconds = windowSec})
    SetTimeout(math.floor(windowSec * 1000), function()
        if generation ~= bleedoutGeneration then return end
        if MyState.phase == Phase.RUNNING and iAmDowned then
            SendNUIMessage({type = 'bleedout_end'})
            StartSpectate()
        end
    end)
    -- Heartbeat under the last ten seconds.
    Citizen.CreateThread(function()
        local deadline = GetGameTimer() + windowSec * 1000
        while generation == bleedoutGeneration and iAmDowned and MyState.phase == Phase.RUNNING do
            local left = deadline - GetGameTimer()
            if left <= 0 then break end
            if left <= 10000 then
                PlaySoundFrontend(-1, 'Beep_Red', 'DLC_HEIST_HACKING_SNAKE_SOUNDS', false)
                Citizen.Wait(1000)
            else
                Citizen.Wait(500)
            end
        end
    end)
end)

RegisterNetEvent('cc:player_revived', function(serverId)
    if type(serverId) == 'number' then downedTeammates[serverId] = nil end
    SendNUIMessage({type = 'hit', variant = 'PACK REVIVED!'})
end)

RegisterNetEvent('cc:revived', function(pos)
    if MyState.phase ~= Phase.RUNNING or type(pos) ~= 'table' then return end
    local ped = PlayerPedId()
    iAmDowned = false
    bleedoutGeneration = bleedoutGeneration + 1
    StopSpectate()
    SendNUIMessage({type = 'bleedout_end'})
    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, GetEntityHeading(ped), true, false)
    Citizen.Wait(100)
    ped = PlayerPedId()
    SetEntityCoords(ped, pos.x, pos.y, pos.z, false, false, false, false)
    SetEntityHealth(ped, 130)
    SetEntityVisible(ped, true, false)
    SetPlayerInvincible(PlayerId(), true)
    SetEntityInvincible(ped, true)
    SendNUIMessage({type = 'hit', variant = 'BACK IN THE PACK!'})
    SetTimeout(Config.ReviveInvulnMs, function()
        if MyState.phase == Phase.RUNNING and not IsEntityDead(PlayerPedId()) then
            SetPlayerInvincible(PlayerId(), false)
            SetEntityInvincible(PlayerPedId(), false)
        end
    end)
    TriggerServerEvent('cc:pos', GetEntityCoords(ped))
end)

-- In-world rescue interaction. No extra dashboard: a red marker and a held
-- E prompt appear only beside a downed teammate. The server re-checks every
-- distance/phase condition before accepting the completed revive.
Citizen.CreateThread(function()
    while true do
        if MyState.phase ~= Phase.RUNNING or iAmDowned then
            reviveTarget, reviveStartedAt = nil, 0
            Citizen.Wait(500)
        else
            Citizen.Wait(0)
            local now = GetGameTimer()
            local myPos = GetEntityCoords(PlayerPedId())
            local targetId, targetPos, targetDeadline, closest = nil, nil, 0, math.huge
            for serverId, entry in pairs(downedTeammates) do
                if now > entry.deadline then
                    -- Window expired: the server will refuse the revive, so
                    -- stop advertising the rescue.
                    downedTeammates[serverId] = nil
                    SendNUIMessage({type = 'hit', variant = 'TEAMMATE LOST'})
                else
                    local player = GetPlayerFromServerId(serverId)
                    local ped = player ~= -1 and GetPlayerPed(player) or 0
                    local pos = ped ~= 0 and DoesEntityExist(ped) and GetEntityCoords(ped) or entry.pos
                    local distance = #(myPos - pos)
                    if distance < closest then
                        targetId, targetPos, targetDeadline, closest = serverId, pos, entry.deadline, distance
                    end
                end
            end

            if targetId and targetPos then
                DrawReviveMarker(targetPos)
                local secondsLeft = math.max(0, math.ceil((targetDeadline - now) / 1000))
                if closest <= Config.ReviveDistance then
                    local percent = reviveTarget == targetId and math.min(100, math.floor((now - reviveStartedAt) / Config.ReviveHoldMs * 100)) or 0
                    HelpText(('Hold ~INPUT_CONTEXT~ to revive teammate (%d%%) — %ds left'):format(percent, secondsLeft))
                    if IsControlPressed(0, 38) then
                        if reviveTarget ~= targetId then
                            reviveTarget, reviveStartedAt = targetId, now
                        elseif now - reviveStartedAt >= Config.ReviveHoldMs then
                            TriggerServerEvent('cc:revive', targetId)
                            reviveTarget, reviveStartedAt = nil, 0
                        end
                    else
                        reviveTarget, reviveStartedAt = nil, 0
                    end
                else
                    reviveTarget, reviveStartedAt = nil, 0
                end
            else
                reviveTarget, reviveStartedAt = nil, 0
            end
        end
    end
end)

-- Pack surge: nearby alive teammates share a small recovery pulse. It is a
-- nudge toward formation driving, never a shield or a damage bypass.
local packSurgeGeneration = 0
RegisterNetEvent('cc:pack_surge', function(nearby)
    if MyState.phase ~= Phase.RUNNING or iAmDowned then return end
    nearby = math.max(1, math.min(3, tonumber(nearby) or 1))
    local ped = PlayerPedId()
    if IsEntityDead(ped) then return end
    -- Make the pack bonus visible: the HUD chip is why players learn to
    -- drive in formation.
    SendNUIMessage({type = 'pride', count = nearby + 1})
    SetEntityHealth(ped, math.min(200, GetEntityHealth(ped) + Config.PackHealthRestore * nearby))
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 or not DoesEntityExist(vehicle) or not NetworkHasControlOfEntity(vehicle) then return end
    SetVehicleEngineHealth(vehicle, math.min(1000.0, GetVehicleEngineHealth(vehicle) + Config.PackEngineRepair * nearby))
    packSurgeGeneration = packSurgeGeneration + 1
    local generation = packSurgeGeneration
    SetVehicleCheatPowerIncrease(vehicle, 1.08 + nearby * 0.02)
    SetTimeout(1200, function()
        if generation == packSurgeGeneration and DoesEntityExist(vehicle) then
            SetVehicleCheatPowerIncrease(vehicle, 1.0)
        end
    end)
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

-- Lobby ready-up: press E, run launches itself when the whole squad is in.
Citizen.CreateThread(function()
    while true do
        if MyState.phase == Phase.LOBBY then
            Citizen.Wait(0)
            HelpText('Press ~INPUT_CONTEXT~ to ready up')
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('cc:ready')
            end
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent('cc:ready_count', function(readyCount, total)
    if type(readyCount) ~= 'number' or type(total) ~= 'number' then return end
    SendNUIMessage({type = 'ready_count', ready = readyCount, total = total})
end)

-- Resource restart mid-run must not strand the client in a broken state:
-- frozen grid vehicle, spectator cam, or ending slow-mo.
AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    StopSpectate()
    SetTimeScale(1.0)
    if startVehicle ~= 0 and DoesEntityExist(startVehicle) then
        FreezeEntityPosition(startVehicle, false)
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
