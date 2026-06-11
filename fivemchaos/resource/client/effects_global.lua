-- sync_mode: GLOBAL_OWNED — iterates world entities, only modifies owned ones

function FX_BouncyCars(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if not IsEntityInAir(veh) and math.random() < 0.03 then
                ApplyForceToEntity(veh, 1, 0.0, 0.0, math.random(8, 15) + 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end)
        Citizen.Wait(50)
    end
end

function FX_FlipCars()
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        local rot = GetEntityRotation(veh, 2)
        SetEntityRotation(veh, rot.x + 180.0, rot.y, rot.z, 2, true)
    end)
end

function FX_LaunchCars()
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        ApplyForceToEntity(veh, 1, 0.0, 0.0, 40.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
    end)
end

function FX_PopTires()
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        for i = 0, 7 do SetVehicleTyreBurst(veh, i, true, 1000.0) end
    end)
end

function FX_Beyblade(alive)
    while alive() do
        local playerVeh = GetVehiclePedIsIn(PlayerPedId(), false)
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if veh ~= playerVeh and GetEntitySpeed(veh) > 3.0 then
                SetEntityInvincible(veh, true)
                SetVehicleReduceGrip(veh, true)
                ApplyForceToEntity(veh, 3, 100.0, 0.0, 0.0, 0.0, 4.0, 0.0, 0, true, true, true, true, true)
                ApplyForceToEntity(veh, 3, -100.0, 0.0, 0.0, 0.0, -4.0, 0.0, 0, true, true, true, true, true)
            end
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetEntityInvincible(veh, false)
        SetVehicleReduceGrip(veh, false)
    end)
end

function FX_LockDoors()
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetVehicleDoorsLocked(veh, 2)
    end)
    SetTimeout(15000, function()
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            SetVehicleDoorsLocked(veh, 0)
        end)
    end)
end

function FX_Forcefield(alive)
    while alive() do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        OwnershipGuard.ForEachOwnedPed(function(entity)
            local epos = GetEntityCoords(entity)
            local dist = #(pos - epos)
            if dist < 15.0 and dist > 0.1 then
                local force = (15.0 - dist) / 15.0 * 100.0
                local dir = epos - pos
                dir = dir / #dir
                if not IsPedRagdoll(entity) then
                    SetPedToRagdoll(entity, 3000, 3000, 0, true, true, false)
                end
                ApplyForceToEntity(entity, 3, dir.x * force, dir.y * force, dir.z * force + 5.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
            end
        end)

        OwnershipGuard.ForEachOwnedVehicle(function(entity)
            if not IsPedInVehicle(ped, entity, false) then
                local epos = GetEntityCoords(entity)
                local dist = #(pos - epos)
                if dist < 15.0 and dist > 0.1 then
                    local force = (15.0 - dist) / 15.0 * 80.0
                    local dir = epos - pos
                    dir = dir / #dir
                    ApplyForceToEntity(entity, 3, dir.x * force, dir.y * force, dir.z * force, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
                end
            end
        end)

        Citizen.Wait(0)
    end
end

-- === PEDS (owned only) ===

function FX_PedRiot(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(p)
            if not IsPedInCombat(p, 0) then
                TaskCombatHatedTargetsAroundPed(p, 100.0, 0)
            end
        end)
        Citizen.Wait(3000)
    end
end

function FX_PedAttack(alive)
    while alive() do
        local nearest = GetNearestPlayerPed(GetEntityCoords(PlayerPedId()))
        OwnershipGuard.ForEachOwnedPed(function(p)
            local target = GetNearestPlayerPed(GetEntityCoords(p)) or PlayerPedId()
            TaskCombatPed(p, target, 0, 16)
        end)
        Citizen.Wait(5000)
    end
end

function FX_PedFlee()
    OwnershipGuard.ForEachOwnedPed(function(p)
        local nearest = GetNearestPlayerPed(GetEntityCoords(p)) or PlayerPedId()
        TaskSmartFleePed(p, nearest, 200.0, -1, false, false)
    end)
end

function FX_PedExplode(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(p)
            if IsEntityDead(p) then
                local pos = GetEntityCoords(p)
                AddExplosion(pos.x, pos.y, pos.z, 2, 4.0, true, false, 0.5)
                DeleteEntity(p)
            end
        end)
        Citizen.Wait(300)
    end
end

function FX_PedWeapons()
    local weps = {`WEAPON_PISTOL`, `WEAPON_MICROSMG`, `WEAPON_BAT`, `WEAPON_KNIFE`, `WEAPON_SHOTGUN`}
    OwnershipGuard.ForEachOwnedPed(function(p)
        GiveWeaponToPed(p, weps[math.random(#weps)], 200, false, true)
    end)
end

function FX_PedRockets()
    OwnershipGuard.ForEachOwnedPed(function(p)
        GiveWeaponToPed(p, `WEAPON_RPG`, 10, false, true)
    end)
end

function FX_PedRagdoll()
    OwnershipGuard.ForEachOwnedPed(function(p)
        SetPedToRagdoll(p, 5000, 5000, 0, false, false, false)
    end)
end

-- === MISC (world entities, owned) ===

function FX_Earthquake(alive)
    while alive() do
        ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 0.08)
        local shook = math.random() * 14.0 - 7.0
        OwnershipGuard.ForEachOwnedVehicle(function(entity)
            ApplyForceToEntity(entity, 1, 0.0, 0.0, shook, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end)
        OwnershipGuard.ForEachOwnedObject(function(entity)
            ApplyForceToEntity(entity, 1, 0.0, 0.0, shook * 0.5, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end)
        Citizen.Wait(0)
    end
    StopGameplayCamShaking(true)
end

function FX_BlackHole(alive, seed)
    local playerPos = GetEntityCoords(PlayerPedId())
    math.randomseed(seed or os.time())
    local holePos = vector3(
        playerPos.x + math.random(-200, 200),
        playerPos.y + math.random(-200, 200),
        playerPos.z + math.random(100, 300)
    )
    local radius = 0.0

    while alive() do
        if radius < 150.0 then radius = radius + 0.3 end
        ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 0.05 * (radius / 150.0))
        DrawMarker(28, holePos.x, holePos.y, holePos.z, 0, 0, 0, 0, 0, 0, radius, radius, radius, 0, 0, 0, 200, false, false, 2, false, nil, nil, false)

        OwnershipGuard.ForEachOwnedVehicle(function(entity)
            if not IsPedInVehicle(PlayerPedId(), entity, false) then
                local epos = GetEntityCoords(entity)
                local dist = #(epos - holePos)
                if dist < radius * 2 then
                    local dir = holePos - epos
                    local vel = GetEntityVelocity(entity)
                    local force = vector3(
                        (dir.x) - vel.x * 2.0,
                        (dir.y) - vel.y * 2.0,
                        (dir.z) - vel.z * 2.0
                    )
                    ApplyForceToEntity(entity, 1, force.x, force.y, force.z, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                    if dist < radius * 0.5 then
                        ExplodeVehicle(entity, true, false)
                    end
                end
            end
        end)

        Citizen.Wait(0)
    end
    StopGameplayCamShaking(true)
end

function FX_JumpyProps(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedObject(function(obj)
            if math.random() < 0.02 then
                ApplyForceToEntity(obj, 1, 0.0, 0.0, math.random(5, 20) + 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end)
        Citizen.Wait(100)
    end
end

function FX_GhostWorld(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if not IsPedInVehicle(PlayerPedId(), veh, false) then
                SetEntityAlpha(veh, 50, false)
                SetEntityCollision(veh, false, false)
            end
        end)
        Citizen.Wait(500)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        ResetEntityAlpha(veh)
        SetEntityCollision(veh, true, true)
    end)
end

function FX_OilLeaks(alive)
    while alive() do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 and GetEntitySpeed(veh) > 5.0 and math.random() < 0.15 then
            SetVehicleReduceGrip(veh, true)
            Citizen.Wait(300)
            SetVehicleReduceGrip(veh, false)
        end
        Citizen.Wait(100)
    end
end

function FX_MoneyRain()
    local pos = GetEntityCoords(PlayerPedId())
    for i = 1, 30 do
        local x = pos.x + math.random(-15, 15)
        local y = pos.y + math.random(-15, 15)
        CreateAmbientPickup(`PICKUP_MONEY_CASE`, x, y, pos.z + 25.0, 0, 1000, 0, false, true)
    end
end

-- === NEW: VEHICLE GLOBAL ===

function FX_AllHonk(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if GetIsVehicleEngineRunning(veh) and math.random() < 0.3 then
                StartVehicleHorn(veh, 200, `HELDDOWN`, false)
            end
        end)
        Citizen.Wait(400)
    end
end

function FX_InvisibleCars(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if not IsPedInVehicle(PlayerPedId(), veh, false) then
                SetEntityAlpha(veh, 0, false)
                SetEntityCollision(veh, false, false)
            end
        end)
        Citizen.Wait(500)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        ResetEntityAlpha(veh)
        SetEntityCollision(veh, true, true)
    end)
end

function FX_TractorBeam(alive)
    while alive() do
        local ppos = GetEntityCoords(PlayerPedId())
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if not IsPedInVehicle(PlayerPedId(), veh, false) then
                local vpos = GetEntityCoords(veh)
                local dist = #(vpos - ppos)
                if dist > 5.0 and dist < 200.0 then
                    local dir = ppos - vpos
                    ApplyForceToEntity(veh, 1, dir.x * 0.6, dir.y * 0.6, dir.z * 0.6, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                end
            end
        end)
        Citizen.Wait(0)
    end
end

function FX_CarsToPlayer(alive)
    while alive() do
        local ppos = GetEntityCoords(PlayerPedId())
        local myVeh = GetVehiclePedIsIn(PlayerPedId(), false)
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if veh ~= myVeh then
                local vpos = GetEntityCoords(veh)
                local dist = #(vpos - ppos)
                if dist > 20.0 and dist < 300.0 then
                    local dir = ppos - vpos
                    local vel = GetEntityVelocity(veh)
                    ApplyForceToEntity(veh, 1, dir.x * 1.2, dir.y * 1.2, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                end
            end
        end)
        Citizen.Wait(50)
    end
end

-- === NEW: PEDS GLOBAL ===

function FX_PedsZombies()
    local zombie = `u_m_y_zombie_01`
    RequestModel(zombie)
    local timeout = 0
    while not HasModelLoaded(zombie) and timeout < 100 do
        Citizen.Wait(10)
        timeout = timeout + 1
    end
    if not HasModelLoaded(zombie) then return end

    local myPed = PlayerPedId()
    local spawns = {}
    OwnershipGuard.ForEachOwnedPed(function(p)
        if p ~= myPed and not IsPedInAnyVehicle(p, true) and not IsEntityDead(p) then
            local pos = GetEntityCoords(p)
            local z = CreatePed(4, zombie, pos.x, pos.y, pos.z, math.random(0, 360) + 0.0, true, true)
            if z ~= 0 then spawns[#spawns + 1] = z end
            DeleteEntity(p)
        end
    end)

    for _, z in ipairs(spawns) do
        GiveWeaponToPed(z, `WEAPON_BAT`, 1, false, true)
        local target = GetNearestPlayerPed(GetEntityCoords(z)) or myPed
        TaskCombatPed(z, target, 0, 16)
        SetPedFleeAttributes(z, 0, false)
        SetBlockingOfNonTemporaryEvents(z, true)
        SetPedKeepTask(z, true)
    end

    SetModelAsNoLongerNeeded(zombie)
end

function FX_PedsWave(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(p)
            if not IsPedInAnyVehicle(p, true) and not IsEntityDead(p) and not IsPedUsingAnyScenario(p) then
                TaskStartScenarioInPlace(p, 'WORLD_HUMAN_CHEERING', 0, true)
                SetPedKeepTask(p, true)
            end
        end)
        Citizen.Wait(2000)
    end
    OwnershipGuard.ForEachOwnedPed(function(p)
        ClearPedTasks(p)
        SetPedKeepTask(p, false)
    end)
end

function FX_PedsSit(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(p)
            if not IsPedInAnyVehicle(p, true) and not IsEntityDead(p) and not IsPedUsingAnyScenario(p) then
                TaskStartScenarioInPlace(p, 'WORLD_HUMAN_PICNIC', 0, true)
                SetPedKeepTask(p, true)
            end
        end)
        Citizen.Wait(2000)
    end
    OwnershipGuard.ForEachOwnedPed(function(p)
        ClearPedTasks(p)
        SetPedKeepTask(p, false)
    end)
end

function FX_PedsLevitate(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(p)
            if not IsPedInAnyVehicle(p, true) and not IsEntityDead(p) then
                ApplyForceToEntity(p, 1, 0.0, 0.0, 1.5, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end)
        Citizen.Wait(0)
    end
end

function FX_PedsDance(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(p)
            if not IsPedInAnyVehicle(p, true) and not IsEntityDead(p) and not IsPedUsingAnyScenario(p) then
                TaskStartScenarioInPlace(p, 'WORLD_HUMAN_MUSICIAN', 0, true)
                SetPedKeepTask(p, true)
            end
        end)
        Citizen.Wait(2000)
    end
    OwnershipGuard.ForEachOwnedPed(function(p)
        ClearPedTasks(p)
        SetPedKeepTask(p, false)
    end)
end

-- === NEW: MISC WORLD ===

function FX_LavaGround(alive)
    local fires = {}
    while alive() do
        local pos = GetEntityCoords(PlayerPedId())
        for i = 1, 3 do
            local x = pos.x + math.random(-30, 30)
            local y = pos.y + math.random(-30, 30)
            local found, groundZ = GetGroundZFor_3dCoord(x, y, pos.z + 50.0, false)
            if found then
                fires[#fires + 1] = StartScriptFire(x, y, groundZ, 25, false)
            end
        end
        Citizen.Wait(500)
    end
    for _, handle in ipairs(fires) do
        RemoveScriptFire(handle)
    end
end

function FX_ShrinkRay()
    OwnershipGuard.ForEachOwnedVehicle(function(v) SetEntityScale(v, 0.3, 0.3, 0.3) end)
    OwnershipGuard.ForEachOwnedPed(function(p)
        if p ~= PlayerPedId() then SetPedScale(p, 0.4) end
    end)
    OwnershipGuard.ForEachOwnedObject(function(o) SetEntityScale(o, 0.3, 0.3, 0.3) end)
end

function FX_GrowRay()
    OwnershipGuard.ForEachOwnedVehicle(function(v) SetEntityScale(v, 2.0, 2.0, 2.0) end)
    OwnershipGuard.ForEachOwnedPed(function(p)
        if p ~= PlayerPedId() then SetPedScale(p, 1.8) end
    end)
    OwnershipGuard.ForEachOwnedObject(function(o) SetEntityScale(o, 2.0, 2.0, 2.0) end)
end

function FX_ColorSwap()
    local palette = {0, 27, 38, 64, 70, 88, 111, 134, 135, 142}
    OwnershipGuard.ForEachOwnedVehicle(function(v)
        local c = palette[math.random(#palette)]
        SetVehicleColours(v, c, c)
    end)
end
