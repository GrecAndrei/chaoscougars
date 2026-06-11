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
