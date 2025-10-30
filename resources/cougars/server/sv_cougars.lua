local function ensureModel(hash)
    if type(hash) ~= 'number' then
        hash = GetHashKey(hash)
    end

    if not IsModelInCdimage(hash) then
        return false
    end

    Citizen.InvokeNative(0x963D27A58DF860AC, hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        Wait(50)
        if GetGameTimer() > timeout then
            return false
        end
    end
    return true
end

-- Weighted Random Selection
function SelectCougarType()
    -- Calculate total weight
    local totalWeight = 0
    for typeName, typeData in pairs(Config.CougarTypes) do
        totalWeight = totalWeight + typeData.weight
    end
    
    -- Generate random value between 0 and total weight
    local randomValue = math.random() * totalWeight
    
    local cumulative = 0
    for typeName, typeData in pairs(Config.CougarTypes) do
        cumulative = cumulative + typeData.weight
        if randomValue <= cumulative then
            print('^2[Server] Selected cougar type: ' .. typeName .. '^7')
            return typeName, typeData
        end
    end
    
    -- Fallback to normal if nothing selected
    print('^3[Server] Fallback to normal cougar^7')
    return 'normal', Config.CougarTypes.normal
end


-- Server just decides what to spawn and where
Citizen.CreateThread(function()
    while true do
        Wait(Config.SpawnInterval * 1000)
        
        if JourneySession.active and GetPlayerCount() > 0 then
            local aliveCougars = 0
            
            -- Count alive cougars
            for netId, cougarData in pairs(JourneySession.cougars) do
                -- Don't count dead or old cougars
                aliveCougars = aliveCougars + 1
            end
            
            local multiplier = GetDifficultyMultiplier()
            local maxCougars = math.floor(Config.MaxAliveCougars * multiplier)
            
            if aliveCougars < maxCougars then
                local center = GetTeamCenter()
                
                -- Calculate random spawn position within configured distance
                local angle = math.random() * 2 * math.pi
                local distance = Config.SpawnDistance.min + math.random() * (Config.SpawnDistance.max - Config.SpawnDistance.min)
                
                local spawnPos = {
                    x = center.x + math.cos(angle) * distance,
                    y = center.y + math.sin(angle) * distance, 
                    z = center.z
                }
                
                -- SELECT RANDOM TYPE (FIX)
                local typeName, typeData = SelectCougarType()
                
                if not typeName or not typeData then
                    print('^1[Server] Failed to select cougar type, using normal^7')
                    typeName = 'normal'
                    typeData = Config.CougarTypes.normal
                end
                
                local controller = GetSpawnController()
                
                if controller then
                    print(string.format('^2[Server] Spawning %s cougar via controller %s^7', typeName, controller))
                    TriggerClientEvent('cougar:spawnRequest', controller, spawnPos, typeName, typeData)
                else
                    local players = GetPlayers()
                    if #players > 0 then
                        local fallback = tonumber(players[1]) or players[1]
                        print('^3[Server] No controller - using fallback player ' .. tostring(fallback) .. '^7')
                        TriggerClientEvent('cougar:spawnRequest', fallback, spawnPos, typeName, typeData)
                    else
                        print('^1[Server] Unable to spawn cougar - no fallback player available^7')
                    end
                end
            end
        end
    end
end)

-- Client reports back when cougar is spawned
RegisterNetEvent('cougar:spawnedConfirm')
AddEventHandler('cougar:spawnedConfirm', function(netId, typeName, position)
    print('^3[Server] Received spawn confirmation for NetID: ' .. netId .. ', Type: ' .. typeName .. '^7')
    JourneySession.cougars[netId] = {
        type = typeName,
        position = position,
        spawnTime = os.time()
    }
    
    local typeData = Config.CougarTypes[typeName] or Config.CougarTypes.normal
    TriggerClientEvent('cougar:spawned', -1, netId, typeName, typeData)
end)

-- Cougar Death Handler
RegisterNetEvent('cougar:died')
AddEventHandler('cougar:died', function(netId, reportedType)
    if not JourneySession.cougars[netId] then return end
    
    local cougarData = JourneySession.cougars[netId]
    local typeKey = reportedType or cougarData.type or 'normal'
    local typeData = Config.CougarTypes[typeKey] or Config.CougarTypes.normal
    
    -- Handle loot drops
    if typeData.dropOnDeath then
        TriggerClientEvent('cougar:spawnLoot', -1, cougarData.position, typeData.dropOnDeath)
    end
    
    -- Handle beeper explosion
    if cougarData.type == 'beeper' then
        -- Trigger explosion at cougar position
        AddExplosion(cougarData.position.x, cougarData.position.y, cougarData.position.z, 
                     2, -- explosion type
                     typeData.explosionDamage,
                     true, false, typeData.explosionRadius)
    end
    
    -- Remove from tracking
    JourneySession.cougars[netId] = nil
    TriggerClientEvent('cougar:cougarRemoved', -1, netId)
end)

-- Beeper Explosion Handler
RegisterNetEvent('cougar:beeperExplode')
AddEventHandler('cougar:beeperExplode', function(netId)
    if not JourneySession.cougars[netId] then return end
    
    local cougarData = JourneySession.cougars[netId]
    local typeData = Config.CougarTypes.beeper
    
    -- Trigger explosion at cougar position
    AddExplosion(cougarData.position.x, cougarData.position.y, cougarData.position.z, 
                 2, -- explosion type
                 typeData.explosionDamage,
                 true, false, typeData.explosionRadius)
    
    -- Remove from tracking and delete entity
    if DoesEntityExist(cougarData.entity) then
        DeleteEntity(cougarData.entity)
    end
    
    JourneySession.cougars[netId] = nil
    
    -- Notify all clients to handle the explosion locally
    TriggerClientEvent('cougar:beeperExplode', -1, netId)
end)

-- ============================================
-- CROPDUSTER EVENT SYSTEM
-- ============================================

function SpawnCropduster()
    if not JourneySession.active or GetPlayerCount() == 0 then return end
    
    local center = GetTeamCenter()
    
    -- Spawn far away, flying toward team
    local angle = math.random() * 2 * math.pi
    local distance = 500
    
    local spawnPos = vec3(
        center.x + math.cos(angle) * distance,
        center.y + math.sin(angle) * distance,
        center.z + 200 -- High altitude
    )
    
    -- Load plane model first (CRITICAL IN FIVEM)
    local planeHash = GetHashKey('duster')
    if not ensureModel(planeHash) then
        print('^1[Cropduster] Failed to load plane model^7')
        return
    end
    
    -- Spawn plane
    local plane = CreateVehicle(planeHash, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, true)
    
    -- FiveM: Use SetEntityAsMissionEntity
    SetEntityAsMissionEntity(plane, true, true)
    SetVehicleHasBeenOwnedByPlayer(plane, true)
    local planeNetId = NetworkGetNetworkIdFromEntity(plane)
    if planeNetId ~= 0 then
        SetNetworkIdExistsOnAllMachines(planeNetId, true)
        SetNetworkIdCanMigrate(planeNetId, true)
    end
    
    -- Set heading toward team
    local heading = math.atan2(center.y - spawnPos.y, center.x - spawnPos.x) * 180 / math.pi
    SetEntityHeading(plane, heading)
    SetVehicleForwardSpeed(plane, 50.0)
    SetVehicleEngineOn(plane, true, true, false)
    
    -- Store cougar references
    local cougarRefs = {}
    
    -- Spawn cougars with proper model loading
    for i = 1, Config.CropDusterCougarCount do
        local typeName, typeData = SelectCougarType()
        local cougarHash = GetHashKey(typeData.model)
        
        -- Request model first (CRITICAL IN FIVEM)
        if not ensureModel(cougarHash) then
            print('^1[Cropduster] Failed to load cougar model^7')
            break
        end
        
        local cougar = CreatePed(4, cougarHash, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, true)
        
        -- FiveM: Use SetEntityAsMissionEntity
        SetEntityAsMissionEntity(cougar, true, true)
        SetVehicleHasBeenOwnedByPlayer(cougar, true)
        local refNetId = NetworkGetNetworkIdFromEntity(cougar)
        if refNetId ~= 0 then
            SetNetworkIdExistsOnAllMachines(refNetId, true)
            SetNetworkIdCanMigrate(refNetId, true)
        end
        
        -- Put cougar in plane
        SetPedIntoVehicle(cougar, plane, i - 2) -- -1 = driver, -2 = passenger, etc.
        
        table.insert(cougarRefs, {entity = cougar, type = typeName, data = typeData})
    end
    
    print('^3[Cropduster] Spawned with ' .. #cougarRefs .. ' cougars, heading toward team^7')
    
    -- Notify all players
    TriggerClientEvent('chat:addMessage', -1, {
        args = {'^3WARNING', 'Incoming cropduster detected!'}
    })
    
    -- Monitor plane and crash it when close
    Citizen.CreateThread(function()
        local crashed = false
        
        while DoesEntityExist(plane) and not crashed do
            Wait(500)
            
            local planePos = GetEntityCoords(plane)
            local dist = #(vec3(planePos.x, planePos.y, planePos.z) - center)
            
            if dist < 150 then
                -- Crash sequence
                SetVehicleEngineHealth(plane, -1.0)
                SetEntityHealth(plane, 0)
                
                -- Explosion
                AddExplosion(planePos.x, planePos.y, planePos.z, 5, 50.0, true, false, 10.0)
                
                -- Eject and configure cougars
                for _, cougarData in ipairs(cougarRefs) do
                    if DoesEntityExist(cougarData.entity) then
                        -- Eject from plane
                        TaskLeaveVehicle(cougarData.entity, plane, 4096)
                        
                        Wait(100)
                        
                        -- Setup as hostile
                        SetPedRelationshipGroupHash(cougarData.entity, GetHashKey('COUGAR'))
                        SetPedCombatAttributes(cougarData.entity, 46, true)
                        SetPedCombatAbility(cougarData.entity, 2)
                        
                        -- Get network ID and add to tracking
                        local netId = NetworkGetNetworkIdFromEntity(cougarData.entity)
                        local cougarPos = GetEntityCoords(cougarData.entity)
                        
                        JourneySession.cougars[netId] = {
                            type = cougarData.type,
                            entity = cougarData.entity,
                            position = vec3(cougarPos.x, cougarPos.y, cougarPos.z),
                            spawnTime = os.time()
                        }
                        
                        -- Notify clients
                        TriggerClientEvent('cougar:spawned', -1, netId, cougarData.type, cougarData.data)
                        
                        -- Make aggressive
                        local nearestPlayer = GetNearestPlayer(vec3(cougarPos.x, cougarPos.y, cougarPos.z))
                        if nearestPlayer then
                            TaskCombatPed(cougarData.entity, GetPlayerPed(nearestPlayer), 0, 16)
                        end
                    end
                end
                
                crashed = true
                print('^2[Cropduster] Crashed! Cougars deployed.^7')
                
                -- Trigger chaos effect (everyone ragdolls from explosion)
                TriggerEvent('cougar:triggerChaosEffect', 'player_ragdoll', 3000)
            end -- This 'end' is for 'if dist < 150 then'
            
            -- Timeout after 60 seconds
            if os.time() - JourneySession.startTime > 60 then
                crashed = true
            end
        end -- This 'end' is for 'while DoesEntityExist(plane) and not crashed do'
        
        -- Cleanup plane after 10 seconds
        Wait(10000)
        if DoesEntityExist(plane) then
            DeleteEntity(plane)
        end
    end) -- This 'end)' is for 'Citizen.CreateThread(function()''
end -- This 'end' is for 'function SpawnCropduster()''

-- Cropduster spawn loop with difficulty scaling
Citizen.CreateThread(function()
    while true do
        if JourneySession.active then
            local multiplier = GetDifficultyMultiplier()
            -- At higher difficulties, spawn more frequently (divide by multiplier)
            local adjustedInterval = Config.CropDusterInterval / multiplier
            
            SpawnCropduster()
            
            -- Wait for the adjusted interval
            Wait(adjustedInterval * 1000)
        else
            -- If not active, still wait to avoid busy loop
            Wait(Config.CropDusterInterval * 1000)
        end
    end
end)

function GetNearestPlayer(position)
    local nearest = nil
    local nearestDist = math.huge
    
    for source, data in pairs(JourneySession.players) do
        local dist = #(data.position - position)
        if dist < nearestDist then
            nearestDist = dist
            nearest = source
        end
    end
    
    return nearest
end

-- Server-side cleanup
Citizen.CreateThread(function()
    while true do
        Wait(10000) -- Every 10 seconds
        
        if JourneySession.active then
            local cleaned = 0
            local currentTime = os.time()
            
            for netId, cougarData in pairs(JourneySession.cougars) do
                if currentTime - cougarData.spawnTime > Config.MaxCougarLifetime then
                    JourneySession.cougars[netId] = nil
                    TriggerClientEvent('cougar:cougarRemoved', -1, netId)
                    cleaned = cleaned + 1
                end
            end
            
            if cleaned > 0 then
                print('^3[Cleanup] Server removed ' .. cleaned .. ' cougars^7')
            end
        end
    end
end)
