local spawnPoint = nil
local destinationPoint = nil
local INVULN_DURATION_MS = 4000
local isEliminated = false
local isSpectating = false
local currentSpectateTarget = nil
local function placePedSafely(ped, coords)
    if not DoesEntityExist(ped) then return end

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)

    local tries = 0
    local foundGround, groundZ = false, coords.z

    while tries < 12 do
        foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 100.0, false)
        if foundGround then
            break
        end
        Wait(100)
        tries = tries + 1
    end

    if foundGround then
        SetEntityCoords(ped, coords.x, coords.y, groundZ + 0.5, false, false, false, true)
    else
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z + 1.0, false, false, false)
    end
end

local function protectPed(ped, durationMs)
    if not DoesEntityExist(ped) then return end

    SetEntityInvincible(ped, true)
    Citizen.SetTimeout(durationMs, function()
        if journeyActive and DoesEntityExist(ped) then
            SetEntityInvincible(ped, false)
        end
    end)
end

-- Set spawn and destination on journey start
RegisterNetEvent('cougar:journeyStarted')
AddEventHandler('cougar:journeyStarted', function()
    isEliminated = false
    isSpectating = false
    currentSpectateTarget = nil
    if destinationPoint and destinationPoint.blip and DoesBlipExist(destinationPoint.blip) then
        RemoveBlip(destinationPoint.blip)
    end

    local spawns = {
        {x = 1550.0, y = 6600.0, z = 20.0, name = "North Edge"}
    }
    
    local destinations = {
        {x = -1000.0, y = -2800.0, z = 13.0, name = "Airport"}
    }
    
    spawnPoint = spawns[1]
    destinationPoint = destinations[1]
    
    -- Teleport to spawn
    local playerPed = PlayerPedId()
    placePedSafely(playerPed, spawnPoint)
    protectPed(playerPed, INVULN_DURATION_MS)
    
    -- Set waypoint to destination
    local objectiveBlip = AddBlipForCoord(destinationPoint.x, destinationPoint.y, destinationPoint.z)
    SetBlipSprite(objectiveBlip, 280) -- Mission objective blip
    SetBlipColour(objectiveBlip, 5)
    SetBlipScale(objectiveBlip, 1.0)
    SetBlipRoute(objectiveBlip, true)
    SetBlipRouteColour(objectiveBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Journey Objective")
    EndTextCommandSetBlipName(objectiveBlip)
    destinationPoint.blip = objectiveBlip
    
    -- Notification
    TriggerEvent('chat:addMessage', {
        args = {'^2Journey Started', 'Spawned at: ' .. spawnPoint.name .. ' | Destination: ' .. destinationPoint.name}
    })
end)

RegisterNetEvent('cougar:journeyStopped')
AddEventHandler('cougar:journeyStopped', function()
    if destinationPoint and destinationPoint.blip and DoesBlipExist(destinationPoint.blip) then
        RemoveBlip(destinationPoint.blip)
    end
    NetworkSetInSpectatorMode(false, 0)
    isSpectating = false
    currentSpectateTarget = nil
    isEliminated = false
    if destinationPoint then
        destinationPoint.blip = nil
    end
end)

RegisterNetEvent('cougar:playerEliminated')
AddEventHandler('cougar:playerEliminated', function(serverId, state)
    if (tonumber(serverId) or serverId) == GetPlayerServerId(PlayerId()) then
        isEliminated = state
        if not state then
            NetworkSetInSpectatorMode(false, 0)
            FreezeEntityPosition(PlayerPedId(), false)
            isSpectating = false
        end
    end
end)

RegisterNetEvent('cougar:startSpectate')
AddEventHandler('cougar:startSpectate', function(targetServerId)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    isSpectating = true
    currentSpectateTarget = targetServerId

    if targetServerId then
        local targetPlayer = GetPlayerFromServerId(targetServerId)
        if targetPlayer ~= -1 then
            NetworkSetInSpectatorMode(true, GetPlayerPed(targetPlayer))
        end
    else
        NetworkSetInSpectatorMode(true, ped)
    end
end)

RegisterNetEvent('cougar:stopSpectate')
AddEventHandler('cougar:stopSpectate', function()
    local ped = PlayerPedId()
    NetworkSetInSpectatorMode(false, 0)
    FreezeEntityPosition(ped, false)
    isSpectating = false
    currentSpectateTarget = nil
end)

RegisterNetEvent('cougar:gameOver')
AddEventHandler('cougar:gameOver', function(reason)
    local ped = PlayerPedId()
    NetworkSetInSpectatorMode(false, 0)
    FreezeEntityPosition(ped, false)
    isSpectating = false
    currentSpectateTarget = nil
    isEliminated = false
end)

RegisterNetEvent('cougar:debugState')
AddEventHandler('cougar:debugState', function(state)
    if state and state.infiniteDeaths then
        isEliminated = false
    end
end)

-- Custom respawn on death
Citizen.CreateThread(function()
    while true do
        Wait(500)
        
        if journeyActive and not isSpectating then
            local playerPed = PlayerPedId()

            if IsEntityDead(playerPed) then
                -- Wait for respawn
                while IsEntityDead(playerPed) do
                    Wait(100)
                end
                
                if not isEliminated then
                    TriggerServerEvent('cougar:requestRespawnLocation')
                end
            end
        end
    end
end)

RegisterNetEvent('cougar:respawnAt')
AddEventHandler('cougar:respawnAt', function(coords)
    local playerPed = PlayerPedId()
    
    -- Teleport to team
    placePedSafely(playerPed, coords)
    
    -- Heal and give brief invulnerability
    SetEntityHealth(playerPed, 200)
    SetPedArmour(playerPed, 50)
    protectPed(playerPed, INVULN_DURATION_MS)
    
    -- Visual effect
    StartScreenEffect("RaceTurbo", 3000, false)
    
    TriggerEvent('chat:addMessage', {
        args = {'^3Respawned', 'You were teleported to your team'}
    })
end)

print('^2[Spawn System] Loaded^7')
