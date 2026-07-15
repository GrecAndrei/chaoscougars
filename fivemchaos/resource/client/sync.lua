-- Shared with spawner.lua so async entity creation can abort cleanly when a
-- mission ends. This is intentionally one resource-level state object.
MyState = {
    phase = Phase.LOBBY,
    startTime = 0,
}

local iAmDowned = false
local downedTeammates = {}
local reviveTarget, reviveStartedAt = nil, 0

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

RegisterNetEvent('cc:state', function(phase, startTime)
    MyState.phase = phase
    MyState.startTime = startTime
    SendNUIMessage({type = 'state', phase = phase})
end)

RegisterNetEvent('cc:mission_start', function(data)
    MyState.phase = Phase.STARTING
    iAmDowned = false
    downedTeammates = {}
    local ped = PlayerPedId()

    -- A cancelled player effect must never carry invincibility into a new
    -- survival run. Reset both native variants before the start teleport.
    SetPlayerInvincible(PlayerId(), false)
    SetEntityInvincible(ped, false)

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
    iAmDowned = false
    downedTeammates = {}
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

RegisterNetEvent('cc:player_downed', function(serverId, pos)
    if type(serverId) ~= 'number' or type(pos) ~= 'table' then return end
    if serverId ~= GetPlayerServerId(PlayerId()) then
        downedTeammates[serverId] = vector3(pos.x, pos.y, pos.z)
    end
    SendNUIMessage({type = 'hit', variant = 'TEAMMATE DOWN!'})
end)

RegisterNetEvent('cc:player_revived', function(serverId)
    if type(serverId) == 'number' then downedTeammates[serverId] = nil end
    SendNUIMessage({type = 'hit', variant = 'PACK REVIVED!'})
end)

RegisterNetEvent('cc:revived', function(pos)
    if MyState.phase ~= Phase.RUNNING or type(pos) ~= 'table' then return end
    local ped = PlayerPedId()
    iAmDowned = false
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
            local myPos = GetEntityCoords(PlayerPedId())
            local targetId, targetPos, closest = nil, nil, math.huge
            for serverId, rememberedPos in pairs(downedTeammates) do
                local player = GetPlayerFromServerId(serverId)
                local ped = player ~= -1 and GetPlayerPed(player) or 0
                local pos = ped ~= 0 and DoesEntityExist(ped) and GetEntityCoords(ped) or rememberedPos
                local distance = #(myPos - pos)
                if distance < closest then targetId, targetPos, closest = serverId, pos, distance end
            end

            if targetId and targetPos then
                DrawReviveMarker(targetPos)
                if closest <= Config.ReviveDistance then
                    local percent = reviveTarget == targetId and math.min(100, math.floor((GetGameTimer() - reviveStartedAt) / Config.ReviveHoldMs * 100)) or 0
                    HelpText(('Hold ~INPUT_CONTEXT~ to revive teammate (%d%%)'):format(percent))
                    if IsControlPressed(0, 38) then
                        if reviveTarget ~= targetId then
                            reviveTarget, reviveStartedAt = targetId, GetGameTimer()
                        elseif GetGameTimer() - reviveStartedAt >= Config.ReviveHoldMs then
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
