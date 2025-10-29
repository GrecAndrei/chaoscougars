print("^2========================================")
print("^2[COUGAR] cl_cougars.lua IS LOADING")
print("^2========================================")

-- ============================================
-- COUGAR SPAWNING SYSTEM - COMPLETE
-- ============================================

-- Global tables
localCougars = {}
cougarAIThreads = {}
missionActive = false

local serverDrivenSpawns = true

local function loadModel(hash)
    if not IsModelInCdimage(hash) then
        return false
    end

    RequestModel(hash)

    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(50)
    end

    return HasModelLoaded(hash)
end

local function ensureCougarData(typeName)
    if not Config or not Config.CougarTypes then
        print("^1[COUGAR] Config missing, cannot spawn type: " .. tostring(typeName))
        return nil
    end

    if Config.CougarTypes[typeName] then
        return Config.CougarTypes[typeName]
    end

    print("^1[COUGAR] Unknown type '" .. tostring(typeName) .. "', defaulting to normal")
    return Config.CougarTypes.normal
end

local function normalizePosition(pos)
    if not pos then
        local coords = GetEntityCoords(PlayerPedId())
        return {x = coords.x, y = coords.y, z = coords.z}
    end

    if type(pos) == "vector3" then
        return {x = pos.x, y = pos.y, z = pos.z}
    end

    if type(pos) == "table" then
        return {
            x = pos.x or pos[1] or 0.0,
            y = pos.y or pos[2] or 0.0,
            z = pos.z or pos[3] or 0.0
        }
    end

    local coords = GetEntityCoords(PlayerPedId())
    return {x = coords.x, y = coords.y, z = coords.z}
end

local function attachVisualObject(cougar, typeData)
    if not typeData or not typeData.visualObject then
        return nil
    end

    local objectHash = GetHashKey(typeData.visualObject)
    if not loadModel(objectHash) then
        print("^1[COUGAR] Failed to load prop model: " .. tostring(typeData.visualObject))
        return nil
    end

    local coords = GetEntityCoords(cougar)
    local prop = CreateObject(objectHash, coords.x, coords.y, coords.z, true, true, false)

    if DoesEntityExist(prop) then
        AttachEntityToEntity(prop, cougar, GetPedBoneIndex(cougar, 11816), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        return prop
    end

    return nil
end

local function registerCougar(entity, typeName, typeData, origin)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    local coords = GetEntityCoords(entity)

    localCougars[netId] = {
        entity = entity,
        type = typeName,
        data = typeData,
        prop = nil,
        spawnTime = GetGameTimer(),
        origin = origin or "client",
        reportedDead = false
    }

    return netId, coords
end

local function cleanupCougar(netId, deleteEntity)
    local data = localCougars[netId]
    if not data then return end

    if data.prop and DoesEntityExist(data.prop) then
        DeleteEntity(data.prop)
    end

    if deleteEntity and data.entity and DoesEntityExist(data.entity) then
        DeleteEntity(data.entity)
    end

    localCougars[netId] = nil
    cougarAIThreads[netId] = nil
end

local function configureCougar(entity, typeData)
    SetEntityAsMissionEntity(entity, true, true)
    SetBlockingOfNonTemporaryEvents(entity, true)
    SetPedKeepTask(entity, true)
    SetPedFleeAttributes(entity, 0, false)
    SetPedCombatAttributes(entity, 46, true)
    SetPedCombatAttributes(entity, 5, true)
    SetPedConfigFlag(entity, 281, true)
    SetPedConfigFlag(entity, 208, true)
    SetPedCombatMovement(entity, 2)
    SetPedCombatRange(entity, 2)
    SetPedCombatAbility(entity, 100)
    SetPedSeeingRange(entity, 100.0)
    SetPedHearingRange(entity, 100.0)
    SetPedAlertness(entity, 3)
    SetPedMoveRateOverride(entity, 1.0)
    SetPedDesiredMoveBlendRatio(entity, 3.0)

    if typeData then
        if typeData.health then
            SetEntityMaxHealth(entity, typeData.health)
            SetEntityHealth(entity, typeData.health)
        end

        if typeData.weapon then
            GiveWeaponToPed(entity, GetHashKey(typeData.weapon), 120, false, true)
            SetPedAccuracy(entity, typeData.accuracy or 25)
        end
    end
end

local function spawnCougarAtPosition(spawnPos, typeName, typeData, origin)
    typeData = typeData or ensureCougarData(typeName)
    if not typeData then
        return nil
    end

    local modelHash = GetHashKey(typeData.model or 'a_c_mtlion')
    if not loadModel(modelHash) then
        print("^1[COUGAR] Failed to load model for type: " .. tostring(typeName))
        return nil
    end

    local foundGround, groundZ = GetGroundZFor_3dCoord(spawnPos.x, spawnPos.y, spawnPos.z + 50.0, false)
    local spawnZ = spawnPos.z
    if foundGround then
        spawnZ = groundZ
    end

    local cougar = CreatePed(28, modelHash, spawnPos.x, spawnPos.y, spawnZ, 0.0, true, true)
    if not DoesEntityExist(cougar) then
        print("^1[COUGAR] Failed to create cougar entity")
        return nil
    end

    NetworkRegisterEntityAsNetworked(cougar)
    local attempts = 0
    local netIdCheck = NetworkGetNetworkIdFromEntity(cougar)
    while netIdCheck == 0 and attempts < 10 do
        Wait(0)
        netIdCheck = NetworkGetNetworkIdFromEntity(cougar)
        attempts = attempts + 1
    end
    if netIdCheck ~= 0 then
        SetNetworkIdExistsOnAllMachines(netIdCheck, true)
        SetNetworkIdCanMigrate(netIdCheck, true)
    end

    configureCougar(cougar, typeData)

    local netId, coords = registerCougar(cougar, typeName, typeData, origin)

    local prop = attachVisualObject(cougar, typeData)
    if prop then
        localCougars[netId].prop = prop
    end

    local target = PlayerPedId()
    TaskCombatPed(cougar, target, 0, 16)

    return netId, coords, cougar
end

-- ============================================
-- CONFIGURATION
-- ============================================

local SpawnConfig = {
    MaxCougars = 60,
    
    SpawnRate = {
        Vehicle = {min = 10, max = 15, interval = 3500},
        Foot = {min = 3, max = 5, interval = 6000}
    },
    
    Zones = {
        ahead = 70,
        sides = 20,
        behind = 10
    },
    
    Distance = {
        ahead = {min = 150, max = 250},
        sides = {min = 100, max = 150},
        behind = {min = 80, max = 120}
    },
    
    Despawn = {
        behind = 200,
        total = 350
    },
    
    Speed = {
        ahead = 0.4,
        behind = 1.8,
        min = 8.0,
        max = 45.0
    }
}

print("^2[COUGAR] Spawn system loaded")

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

function GetTeamCenterPosition()
    local players = GetActivePlayers()
    local totalX, totalY, totalZ = 0, 0, 0
    local count = 0
    
    for _, player in ipairs(players) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)
            totalX = totalX + coords.x
            totalY = totalY + coords.y
            totalZ = totalZ + coords.z
            count = count + 1
        end
    end
    
    if count > 0 then
        return vector3(totalX / count, totalY / count, totalZ / count)
    else
        return GetEntityCoords(PlayerPedId())
    end
end

function GetAverageTeamVelocity()
    local players = GetActivePlayers()
    local totalX, totalY, totalZ = 0, 0, 0
    local count = 0
    
    for _, player in ipairs(players) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            local vel = GetEntityVelocity(ped)
            totalX = totalX + vel.x
            totalY = totalY + vel.y
            totalZ = totalZ + vel.z
            count = count + 1
        end
    end
    
    if count > 0 then
        return vector3(totalX / count, totalY / count, totalZ / count)
    else
        return vector3(0, 0, 0)
    end
end

function GetTeamHeading()
    local vel = GetAverageTeamVelocity()
    local speed = math.sqrt(vel.x * vel.x + vel.y * vel.y)
    
    if speed > 0.5 then
        return math.deg(math.atan2(vel.y, vel.x))
    else
        return GetEntityHeading(PlayerPedId())
    end
end

function IsPointVisibleToAnyPlayer(x, y, z)
    local players = GetActivePlayers()
    
    for _, player in ipairs(players) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            if IsPointOnScreen(x, y, z) then
                return true
            end
        end
    end
    
    return false
end

function GetClosestPlayer(cougar)
    local cougarPos = GetEntityCoords(cougar)
    local closestPlayer = nil
    local closestDist = 999999
    
    local players = GetActivePlayers()
    for _, player in ipairs(players) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            local dist = #(cougarPos - GetEntityCoords(ped))
            if dist < closestDist then
                closestDist = dist
                closestPlayer = ped
            end
        end
    end
    
    return closestPlayer
end

function IsTeamInVehicle()
    local players = GetActivePlayers()
    local inVehicleCount = 0
    
    for _, player in ipairs(players) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) and IsPedInAnyVehicle(ped, false) then
            inVehicleCount = inVehicleCount + 1
        end
    end
    
    return inVehicleCount > 0
end

function GetRandomCougarType()
    local roll = math.random(100)
    
    if roll <= 20 then return "normal"
    elseif roll <= 40 then return "shooter"
    elseif roll <= 55 then return "blueBall"
    elseif roll <= 65 then return "purpleBall"
    elseif roll <= 77 then return "barrier"
    elseif roll <= 85 then return "jesus"
    elseif roll <= 90 then return "health"
    elseif roll <= 95 then return "armor"
    elseif roll <= 98 then return "ammo"
    else return "beeper"
    end
end

-- ============================================
-- DIRECTIONAL SPAWN FUNCTION
-- ============================================

function SpawnCougarDirectional(cougarType)
    print("^5[DEBUG] SpawnCougarDirectional called with type: " .. tostring(cougarType))
    
    local teamCenter = GetTeamCenterPosition()
    print("^5[DEBUG] Team center: " .. tostring(teamCenter))
    
    local teamHeading = GetTeamHeading()
    print("^5[DEBUG] Team heading: " .. tostring(teamHeading))
    
    local roll = math.random(100)
    local zone, angle, distance
    
    if roll <= SpawnConfig.Zones.ahead then
        zone = "ahead"
        angle = teamHeading + math.random(-45, 45)
        distance = math.random(SpawnConfig.Distance.ahead.min, SpawnConfig.Distance.ahead.max)
    elseif roll <= (SpawnConfig.Zones.ahead + SpawnConfig.Zones.sides) then
        zone = "sides"
        local side = math.random(0, 1) == 0 and -90 or 90
        angle = teamHeading + side + math.random(-30, 30)
        distance = math.random(SpawnConfig.Distance.sides.min, SpawnConfig.Distance.sides.max)
    else
        zone = "behind"
        angle = teamHeading + 180 + math.random(-30, 30)
        distance = math.random(SpawnConfig.Distance.behind.min, SpawnConfig.Distance.behind.max)
    end
    
    print("^5[DEBUG] Zone: " .. zone .. ", Distance: " .. distance)
    
    local angleRad = math.rad(angle)
    local spawnX = teamCenter.x + math.cos(angleRad) * distance
    local spawnY = teamCenter.y + math.sin(angleRad) * distance
    local spawnZ = teamCenter.z
    
    print("^5[DEBUG] Spawn coords: " .. spawnX .. ", " .. spawnY .. ", " .. spawnZ)
    
    -- SKIP visibility check for now (testing)
    -- if IsPointVisibleToAnyPlayer(spawnX, spawnY, spawnZ) then
    --     print("^1[DEBUG] Point visible, skipping")
    --     return nil
    -- end
    
    local netId, coords, cougar = spawnCougarAtPosition({x = spawnX, y = spawnY, z = spawnZ}, cougarType, nil, "client")
    if not netId or not cougar then
        return nil
    end

    if localCougars[netId] then
        localCougars[netId].zone = zone
    end

    print("^2[SPAWN SUCCESS] " .. cougarType .. " in " .. zone)

    StartCougarAI(cougar, cougarType)

    return cougar
end

-- ============================================
-- AI MOVEMENT SYSTEM
-- ============================================

function StartCougarAI(cougar, cougarType)
    local netId = NetworkGetNetworkIdFromEntity(cougar)
    
    if cougarAIThreads[netId] then
        return
    end
    
    cougarAIThreads[netId] = true
    
    Citizen.CreateThread(function()
        local previousVelocity = {x = 0.0, y = 0.0, z = 0.0}
        
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) and missionActive do
            local cougarCoords = GetEntityCoords(cougar)
            
            -- CRITICAL: Request collision at cougar's position every frame
            RequestCollisionAtCoord(cougarCoords.x, cougarCoords.y, cougarCoords.z)
            
            -- Wait for collision to load (prevents falling through)
            local timeout = 0
            while not HasCollisionLoadedAroundEntity(cougar) and timeout < 5 do
                Wait(10)
                timeout = timeout + 1
            end
            
            local target = PlayerPedId()
            local playerVehicle = GetVehiclePedIsIn(target, false)
            local inVehicle = playerVehicle ~= 0
            
            if not inVehicle then
                -- ON FOOT
                TaskCombatPed(cougar, target, 0, 16)
                SetPedDesiredMoveBlendRatio(cougar, 3.0)
                SetPedMoveRateOverride(cougar, 1.5)
                Wait(1500)
            else
                -- IN VEHICLE: TaskGoToEntity (smoother for moving targets)
                local vehicleCoords = GetEntityCoords(playerVehicle)
                local cougarCoords = GetEntityCoords(cougar)
                local distance = #(cougarCoords - vehicleCoords)
                
                if distance > 5.0 and distance < 150.0 then
                    -- TaskGoToEntity: automatically follows moving target
                    TaskGoToEntity(cougar, playerVehicle, -1, 4.0, 3.0, 1073741824, 0)
                    
                    -- Speed override
                    SetPedMoveRateOverride(cougar, 2.5)
                    SetPedDesiredMoveBlendRatio(cougar, 3.0)
                    
                    Wait(1000)  -- Less frequent updates since it tracks automatically
                elseif distance <= 5.0 then
                    TaskGoToEntity(cougar, playerVehicle, -1, 4.0, 1.5, 1073741824, 0)
                    SetPedMoveRateOverride(cougar, 1.0)
                    Wait(1000)
                else
                    Wait(500)
                end
            end
        end
        
        cougarAIThreads[netId] = nil
    end)
end

-- ============================================
-- SERVER-SPAWNED COUGAR HANDLERS
-- ============================================

RegisterNetEvent('cougar:spawnRequest')
AddEventHandler('cougar:spawnRequest', function(spawnPos, typeName, typeData)
    if not missionActive then
        return
    end

    local position = normalizePosition(spawnPos)
    local netId, coords, cougar = spawnCougarAtPosition(position, typeName, typeData, "server")

    if netId and cougar then
        StartCougarAI(cougar, typeName)
        if netId ~= 0 then
            TriggerServerEvent('cougar:spawnedConfirm', netId, typeName or "normal", {x = coords.x, y = coords.y, z = coords.z})
        else
            print('^1[COUGAR] Invalid network id for spawned cougar^7')
        end
    end
end)

RegisterNetEvent('cougar:spawned')
AddEventHandler('cougar:spawned', function(netId, typeName, typeData)
    if not missionActive then
        return
    end

    local entity = NetworkGetEntityFromNetworkId(netId)
    if entity == 0 then
        NetworkRequestControlOfNetworkId(netId)
        Wait(0)
        entity = NetworkGetEntityFromNetworkId(netId)
    end
    if entity == 0 then
        print('^1[COUGAR] Failed to resolve entity for NetID ' .. tostring(netId) .. '^7')
        return
    end

    typeData = typeData or ensureCougarData(typeName)

    localCougars[netId] = localCougars[netId] or {
        spawnTime = GetGameTimer(),
        origin = "server"
    }

    local data = localCougars[netId]
    data.entity = entity
    data.type = typeName
    data.data = typeData

    configureCougar(entity, typeData)
    StartCougarAI(entity, typeName)
end)

RegisterNetEvent('cougar:cougarRemoved')
AddEventHandler('cougar:cougarRemoved', function(netId)
    cleanupCougar(netId, false)
end)

Citizen.CreateThread(function()
    while true do
        Wait(1000)

        if missionActive then
            for netId, data in pairs(localCougars) do
                local entity = data.entity

                if not entity or not DoesEntityExist(entity) then
                    local networkEntity = NetworkGetEntityFromNetworkId(netId)
                    if networkEntity ~= 0 and DoesEntityExist(networkEntity) then
                        data.entity = networkEntity
                        entity = networkEntity
                    else
                        cleanupCougar(netId, false)
                        goto continue_cougar
                    end
                end

                if IsEntityDead(entity) and not data.reportedDead then
                    data.reportedDead = true
                    TriggerServerEvent('cougar:died', netId, data.type or "normal")
                    cleanupCougar(netId, false)
                    goto continue_cougar
                end

                ::continue_cougar::
            end
        end
    end
end)

-- ============================================
-- CONTINUOUS SPAWN LOOP
-- ============================================

Citizen.CreateThread(function()
    while true do
        if missionActive then
            if serverDrivenSpawns then
                Wait(1000)
                goto continue
            end

            local currentCount = 0
            for _ in pairs(localCougars) do
                currentCount = currentCount + 1
            end
            
            if currentCount < SpawnConfig.MaxCougars then
                local inVehicle = IsTeamInVehicle()
                local spawnRate = inVehicle and SpawnConfig.SpawnRate.Vehicle or SpawnConfig.SpawnRate.Foot
                local spawnCount = math.random(spawnRate.min, spawnRate.max)
                local needed = math.min(spawnCount, SpawnConfig.MaxCougars - currentCount)
                
                for i = 1, needed do
                    local cougarType = GetRandomCougarType()
                    SpawnCougarDirectional(cougarType)
                    Wait(50)
                end
                
                print("^2[SPAWN] Total: " .. (currentCount + needed) .. "/60")
            end
            
            local inVehicle = IsTeamInVehicle()
            local interval = inVehicle and SpawnConfig.SpawnRate.Vehicle.interval or SpawnConfig.SpawnRate.Foot.interval
            Wait(interval)
        else
            Wait(1000)
        end

        ::continue::
    end
end)

-- ============================================
-- DESPAWN & RESPAWN SYSTEM
-- ============================================

Citizen.CreateThread(function()
    while true do
        Wait(2000)
        
        if missionActive then
            if serverDrivenSpawns then
                for netId, cougarData in pairs(localCougars) do
                    if not cougarData.entity or not DoesEntityExist(cougarData.entity) then
                        cleanupCougar(netId, false)
                    end
                end
                goto continue_tick
            end

            local teamCenter = GetTeamCenterPosition()
            local teamVel = GetAverageTeamVelocity()
            local teamSpeed = #(teamVel)
            
            local teamForward = vector2(0, 1)
            if teamSpeed > 0.5 then
                teamForward = vector2(teamVel.x / teamSpeed, teamVel.y / teamSpeed)
            end
            
            for netId, cougarData in pairs(localCougars) do
                if DoesEntityExist(cougarData.entity) and not IsEntityDead(cougarData.entity) then
                    local cougarPos = GetEntityCoords(cougarData.entity)
                    local distance = #(cougarPos - teamCenter)
                    
                    local toCougar = vector2(cougarPos.x - teamCenter.x, cougarPos.y - teamCenter.y)
                    local dotProduct = toCougar.x * teamForward.x + toCougar.y * teamForward.y
                    
                    local shouldDespawn = false
                    
                    if dotProduct < -SpawnConfig.Despawn.behind then
                        shouldDespawn = true
                    elseif distance > SpawnConfig.Despawn.total then
                        shouldDespawn = true
                    end
                    
                    if shouldDespawn then
                        print("^1[DESPAWN] " .. cougarData.type .. " at " .. math.floor(distance) .. "m")
                        
                        if cougarData.prop and DoesEntityExist(cougarData.prop) then
                            DeleteEntity(cougarData.prop)
                        end
                        DeleteEntity(cougarData.entity)
                        
                        if not serverDrivenSpawns then
                            SpawnCougarDirectional(cougarData.type)
                        end

                        localCougars[netId] = nil
                    end
                else
                    if cougarData.prop and DoesEntityExist(cougarData.prop) then
                        DeleteEntity(cougarData.prop)
                    end
                    localCougars[netId] = nil
                end
            end
        end

        ::continue_tick::
    end
end)

-- ============================================
-- COMMANDS
-- ============================================

-- Event handlers for mission control
RegisterNetEvent('cougar:startMission')
AddEventHandler('cougar:startMission', function()
    missionActive = true
    print("^2[JOURNEY] Started - Spawning enabled")
end)

RegisterNetEvent('cougar:stopMission')
AddEventHandler('cougar:stopMission', function()
    missionActive = false
    
    for netId, cougarData in pairs(localCougars) do
        if DoesEntityExist(cougarData.entity) then
            DeleteEntity(cougarData.entity)
        end
        if cougarData.prop and DoesEntityExist(cougarData.prop) then
            DeleteEntity(cougarData.prop)
        end
    end
    localCougars = {}
    
    print("^1[JOURNEY] Stopped - Cleaned up")
end)

RegisterCommand('testspawn', function()
    print("^3[TEST] testspawn command received")
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    local forwardX = coords.x + math.sin(math.rad(heading)) * 10
    local forwardY = coords.y + math.cos(math.rad(heading)) * 10
    
    local modelHash = GetHashKey('a_c_mtlion')
    RequestModel(modelHash)
    
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end
    
    if not HasModelLoaded(modelHash) then
        print("^1[TEST] MODEL FAILED TO LOAD")
        return
    end
    
    local cougar = CreatePed(28, modelHash, forwardX, forwardY, coords.z, 0.0, true, false)
    
    if not DoesEntityExist(cougar) then
        print("^1[TEST] FAILED - Entity doesn't exist")
        return
    end

    -- FORCE TO GROUND IMMEDIATELY
    Wait(100)
    local spawnCoords = GetEntityCoords(cougar)
    local foundGround, groundZ = GetGroundZFor_3dCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z + 100.0, false)
    if foundGround then
        SetEntityCoordsNoOffset(cougar, spawnCoords.x, spawnCoords.y, groundZ + 0.5, false, false, false)
        print("^3[TEST] Snapped to ground: " .. groundZ)
    else
        print("^1[TEST] Ground not found!")
    end

    print("^2[TEST] Cougar spawned: " .. cougar)
    
    Wait(100)
    
    -- FULL SETUP
    SetEntityAsMissionEntity(cougar, true, true)
    SetEntityInvincible(cougar, false)
    SetEntityMaxHealth(cougar, 150)
    SetEntityHealth(cougar, 150)
    
    -- Never flee
    SetBlockingOfNonTemporaryEvents(cougar, true)
    SetPedKeepTask(cougar, true)
    SetPedFleeAttributes(cougar, 0, false)
    SetPedCombatAttributes(cougar, 46, true)
    SetPedCombatAttributes(cougar, 5, true)
    SetPedCombatAttributes(cougar, 1424, true)
    SetPedConfigFlag(cougar, 281, true)
    SetPedConfigFlag(cougar, 208, true)
    
    -- Combat setup (instant aggression)
    SetPedCombatMovement(cougar, 2)
    SetPedCombatRange(cougar, 2)
    SetPedCombatAbility(cougar, 100)
    SetPedSeeingRange(cougar, 100.0)
    SetPedHearingRange(cougar, 100.0)
    SetPedAlertness(cougar, 3)
    
    -- Force sprint
    SetPedMoveRateOverride(cougar, 1.0)
    SetPedDesiredMoveBlendRatio(cougar, 3.0)
    
    -- Collision protection
    SetEntityCanBeDamaged(cougar, true)
    SetPedCanRagdoll(cougar, false)
    
    -- IMMEDIATE TASK
    TaskCombatPed(cougar, playerPed, 0, 16)
    
    print("^2[TEST] AI setup complete - should attack now")
    

    
    -- AI THREAD (ROBUST GROUND COLLISION FIX)
    Citizen.CreateThread(function()
        -- Set ped properties to prevent falling
        SetEntityMaxSpeed(cougar, 30.0) -- Limit max speed
        
        -- Initial ground snap
        local initCoords = GetEntityCoords(cougar)
        local foundGround, initGroundZ = GetGroundZFor_3dCoord(initCoords.x, initCoords.y, initCoords.z + 10.0, false)
        if foundGround then
            SetEntityCoordsNoOffset(cougar, initCoords.x, initCoords.y, initGroundZ + 0.5, false, false, false)
        end
        
        while DoesEntityExist(cougar) and not IsEntityDead(cougar) do
            local target = PlayerPedId()
            local playerVehicle = GetVehiclePedIsIn(target, false)
            local inVehicle = playerVehicle ~= 0
            
            -- ROBUST GROUND CHECK: Every frame, ensure ped is on ground
            local cougarCoords = GetEntityCoords(cougar)
            local foundGround, groundZ = GetGroundZFor_3dCoord(cougarCoords.x, cougarCoords.y, cougarCoords.z + 10.0, false)
            
            if foundGround then
                -- If ped is significantly below ground, force to ground level
                if cougarCoords.z < groundZ - 1.0 then
                    -- Set to ground with slight offset to prevent constant snapping
                    SetEntityCoordsNoOffset(cougar, cougarCoords.x, cougarCoords.y, groundZ + 0.2, false, false, false)
                end
            end
            
            if not inVehicle then
                -- ON FOOT: Combat task
                TaskCombatPed(cougar, target, 0, 16)
                Wait(1500)
            else
                -- IN VEHICLE: TaskGoToEntity (smoother for moving targets)
                local vehicleCoords = GetEntityCoords(playerVehicle)
                local cougarCoords = GetEntityCoords(cougar)
                local distance = #(cougarCoords - vehicleCoords)
                
                if distance > 5.0 and distance < 150.0 then
                    -- TaskGoToEntity: automatically follows moving target
                    TaskGoToEntity(cougar, playerVehicle, -1, 4.0, 3.0, 1073741824, 0)
                    
                    -- Speed override
                    SetPedMoveRateOverride(cougar, 2.5)
                    SetPedDesiredMoveBlendRatio(cougar, 3.0)
                    
                    Wait(1000)  -- Less frequent updates since it tracks automatically
                elseif distance <= 5.0 then
                    TaskGoToEntity(cougar, playerVehicle, -1, 4.0, 1.5, 1073741824, 0)
                    SetPedMoveRateOverride(cougar, 1.0)
                    Wait(1000)
                else
                    Wait(500)
                end
            end
        end
        
        print("^1[TEST] AI thread ended")
    end)
end)
