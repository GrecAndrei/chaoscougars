--[[
    CC Test Harness - Client
    Handles client-side test participation: vehicle spawning, ownership checks,
    late join verification, and phase tracking.
]]

local TAG = '[CC_TEST_CLIENT]'
local lastPhase = nil
local spawnedVehicles = {}
local lateJoinListening = false

--------------------------------------------------------------------------------
-- Phase tracking
--------------------------------------------------------------------------------
RegisterNetEvent('cc:state', function(phase, startTime)
    lastPhase = phase
end)

RegisterNetEvent('cc_test:query_phase', function()
    TriggerServerEvent('cc_test:phase_ack', lastPhase)
end)

--------------------------------------------------------------------------------
-- Ownership test: spawn vehicles
--------------------------------------------------------------------------------
RegisterNetEvent('cc_test:spawn_vehicles', function(count)
    print(TAG .. ' Spawning ' .. count .. ' vehicles for ownership test')
    spawnedVehicles = {}

    Citizen.CreateThread(function()
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for i = 1, count do
            local offset = vector3(i * 6.0, 0.0, 0.0)
            local spawnPos = pos + offset

            local model = GetHashKey('adder')
            RequestModel(model)
            local timeout = 0
            while not HasModelLoaded(model) and timeout < 5000 do
                Citizen.Wait(100)
                timeout = timeout + 100
            end

            if HasModelLoaded(model) then
                local veh = CreateVehicle(model, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, true)
                if DoesEntityExist(veh) then
                    local netId = NetworkGetNetworkIdFromEntity(veh)
                    spawnedVehicles[#spawnedVehicles + 1] = {
                        netId = netId,
                        entity = veh,
                        owner = GetPlayerServerId(PlayerId()),
                    }
                    print(TAG .. '   Spawned vehicle ' .. i .. ' netId=' .. netId)
                end
            end

            Citizen.Wait(500)
        end

        -- Report spawned vehicles to server
        print(TAG .. ' Spawned ' .. #spawnedVehicles .. ' vehicles')
        TriggerServerEvent('cc_test:vehicles_spawned', #spawnedVehicles)
    end)
end)

--------------------------------------------------------------------------------
-- Ownership test: attempt to modify vehicles (called on non-owner)
--------------------------------------------------------------------------------
RegisterNetEvent('cc_test:attempt_modify', function()
    print(TAG .. ' Attempting to modify nearby vehicles (ownership test)')

    Citizen.CreateThread(function()
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local myId = GetPlayerServerId(PlayerId())

        -- Find nearby vehicles
        local handle, veh = FindFirstVehicle()
        local found = handle ~= -1

        while found do
            if DoesEntityExist(veh) then
                local netId = NetworkGetNetworkIdFromEntity(veh)
                local owner = NetworkGetEntityOwner(veh)
                local ownerServerId = GetPlayerServerId(owner)

                -- Check if we are NOT the owner
                local isConflict = (ownerServerId ~= myId)

                -- Attempt a modification (change color)
                local canControl = NetworkRequestControlOfEntity(veh)
                Citizen.Wait(100)

                if NetworkHasControlOfEntity(veh) and isConflict then
                    -- We got control of someone else's vehicle - this is a conflict
                    TriggerServerEvent('cc_test:ownership_report', netId, ownerServerId, myId, true)
                elseif not NetworkHasControlOfEntity(veh) and isConflict then
                    -- Correctly denied - no conflict
                    TriggerServerEvent('cc_test:ownership_report', netId, ownerServerId, myId, false)
                end
            end

            found, veh = FindNextVehicle(handle)
        end
        EndFindVehicle(handle)
    end)
end)

--------------------------------------------------------------------------------
-- Late join test: prepare to listen
--------------------------------------------------------------------------------
RegisterNetEvent('cc_test:prepare_latejoin', function()
    print(TAG .. ' Preparing for late join sync test')
    lateJoinListening = true
end)

-- Override/hook the late join sync to report back to server
RegisterNetEvent('cc:late_join_sync', function(snapshot, difficulty, meta)
    if lateJoinListening then
        lateJoinListening = false
        local count = 0
        if snapshot then
            for _ in ipairs(snapshot) do count = count + 1 end
        end
        print(TAG .. ' Received late_join_sync with ' .. count .. ' effects')
        TriggerServerEvent('cc_test:latejoin_ack', count)
    end
end)

--------------------------------------------------------------------------------
-- Startup
--------------------------------------------------------------------------------
Citizen.CreateThread(function()
    Citizen.Wait(2000)
    print(TAG .. ' Test client loaded')
end)
