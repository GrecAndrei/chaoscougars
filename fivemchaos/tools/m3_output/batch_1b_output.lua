-- sync_mode: GLOBAL_OWNED
function FX_Peds2xAnimationSpeed(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) then
                SetPedMoveRateOverride(ped, 2.0)
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsAimbot(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            SetPedAccuracy(ped, 100)
            SetPedFiringPattern(ped, 0xC6EE6B4C)
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsAttackplayer(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) and not IsEntityDead(ped, false) then
                local target = GetNearestPlayerPed(GetEntityCoords(ped))
                if target then
                    TaskCombatPed(ped, target, 0, 16)
                end
            end
        end)
        Citizen.Wait(1000)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsBlind(alive)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        ClearPedTasks(ped)
        SetBlockingOfNonTemporaryEvents(ped, true)
    end)
    while alive() do
        SetEveryoneIgnorePlayer(PlayerId(), true)
        OwnershipGuard.ForEachOwnedPed(function(ped)
            SetPedSeeingRange(ped, 0.0)
            SetPedHearingRange(ped, 0.0)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedShootRate(ped, 0)
            SetPedFiringPattern(ped, -490063247)
        end)
        Citizen.Wait(0)
    end
    SetEveryoneIgnorePlayer(PlayerId(), false)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        SetPedSeeingRange(ped, 9999.0)
        SetPedHearingRange(ped, 9999.0)
        SetBlockingOfNonTemporaryEvents(ped, false)
        SetPedShootRate(ped, 100)
        SetPedFiringPattern(ped, -957453492)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsBloody(alive)
    local packs = {
        "TD_SHOTGUN_FRONT_KILL",
        "BigRunOverByVehicle",
        "Dirt_Mud",
        "Explosion_Large",
        "RunOverByVehicle",
        "Splashback_Face_0",
        "Splashback_Face_1",
        "SCR_Shark",
        "SCR_Cougar",
        "Car_Crash_Heavy",
        "TD_SHOTGUN_REAR_KILL",
        "SCR_Torture",
        "TD_melee_face_l",
        "MTD_melee_face_r",
        "MTD_melee_face_jaw",
    }
    OwnershipGuard.ForEachOwnedPed(function(ped)
        for _, pack in ipairs(packs) do
            ApplyPedDamagePack(ped, pack, 0.0, 10.0)
        end
    end)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsBusbois(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local busHash = GetHashKey("bus")
    local maxDistance = 120.0
    RequestModel(busHash)
    while not HasModelLoaded(busHash) do Citizen.Wait(0) end
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) then
            local pedPos = GetEntityCoords(ped, false)
            local dist = #(playerPos - pedPos)
            if dist <= maxDistance then
                local heading = GetEntityHeading(ped)
                local veh = CreateVehicle(busHash, pedPos.x, pedPos.y, pedPos.z, heading, true, false, false)
                SetVehicleEngineOn(veh, true, true, false)
                SetPedIntoVehicle(ped, veh, -1)
            end
        end
    end
    SetModelAsNoLongerNeeded(busHash)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsCatguns(alive)
    local catHash = GetHashKey("a_c_cat_01")
    RequestModel(catHash)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and IsPedShooting(ped) then
                local spawnPos
                local spawnRot
                if IsPedAPlayer(ped) then
                    local camCoords = GetGameplayCamCoord()
                    local pedPos = GetEntityCoords(ped, false)
                    local dist = #(pedPos - camCoords)
                    local camRot = GetGameplayCamRot(2)
                    local fwd = vector3(
                        math.sin(camRot.z * math.pi / 180) * -1,
                        math.cos(camRot.z * math.pi / 180) * -1,
                        math.sin(camRot.x * math.pi / 180)
                    )
                    spawnPos = camCoords + fwd * (dist + 0.5)
                    spawnRot = camRot
                else
                    spawnPos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)
                    spawnRot = GetEntityRotation(ped, 2)
                end
                local isShotgun = GetWeapontypeGroup(GetSelectedPedWeapon(ped)) == GetHashKey("GROUP_SHOTGUN")
                local catCount = isShotgun and 3 or 1
                for i = 0, catCount - 1 do
                    local sPos = spawnPos
                    if isShotgun then sPos = vector3(spawnPos.x, spawnPos.y, spawnPos.z - 0.25 + i * 0.25) end
                    if HasModelLoaded(catHash) then
                        local cat = CreatePed(28, catHash, sPos.x, sPos.y, sPos.z, 0.0, true, false)
                        SetEntityRotation(cat, spawnRot.x, spawnRot.y, spawnRot.z, 2, true)
                        SetPedToRagdoll(cat, 3000, 3000, 0, true, true, false)
                        ApplyForceToEntityCenterOfMass(cat, 1, 0.0, 300.0, 0.0, false, true, true, false)
                        SetPedAsNoLongerNeeded(cat)
                    end
                    if i > 0 then Citizen.Wait(0) end
                end
            end
        end
        Citizen.Wait(0)
    end
    SetModelAsNoLongerNeeded(catHash)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsCops(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) then
                SetPedAsCop(ped, true)
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsDriveBackwards(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) and IsPedInAnyVehicle(ped, false) then
                local veh = GetVehiclePedIsIn(ped, false)
                SetDriveTaskDrivingStyle(ped, 1024)
                SetVehicleForwardSpeed(veh, -20.0)
            end
        end)
        Citizen.Wait(100)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsDriveby(alive)
    local weaponHash = GetHashKey("WEAPON_MACHINEPISTOL")
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if IsPedInAnyVehicle(ped, false) then
                local target = GetNearestPlayerPed(GetEntityCoords(ped))
                if target then
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    GiveWeaponToPed(ped, weaponHash, 9999, true, true)
                    TaskDriveBy(ped, target, 0, 0.0, 0.0, 0.0, -1.0, 5, false, 0xC6EE6B4C)
                end
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsEternalScreams(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) and IsEntityDead(ped, false) then
                PlayPain(ped, 7, 0, 0)
            end
        end)
        Citizen.Wait(100)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsGiverpg(alive)
    local weaponHash = GetHashKey("WEAPON_RPG")
    OwnershipGuard.ForEachOwnedPed(function(ped)
        GiveWeaponToPed(ped, weaponHash, 9999, true, true)
        SetCurrentPedWeapon(ped, weaponHash, true)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsStungun(alive)
    local weaponHash = GetHashKey("WEAPON_STUNGUN")
    OwnershipGuard.ForEachOwnedPed(function(ped)
        GiveWeaponToPed(ped, weaponHash, 9999, true, true)
        SetCurrentPedWeapon(ped, weaponHash, true)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsMinigun(alive)
    local weaponHash = GetHashKey("WEAPON_MINIGUN")
    OwnershipGuard.ForEachOwnedPed(function(ped)
        GiveWeaponToPed(ped, weaponHash, 9999, true, true)
        SetCurrentPedWeapon(ped, weaponHash, true)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsUpnatomizer(alive)
    local weaponHash = GetHashKey("WEAPON_RAYPISTOL")
    OwnershipGuard.ForEachOwnedPed(function(ped)
        GiveWeaponToPed(ped, weaponHash, 9999, true, true)
        SetCurrentPedWeapon(ped, weaponHash, true)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsRandomwep(alive)
    local weapons = {
        GetHashKey("WEAPON_PISTOL"), GetHashKey("WEAPON_SMG"), GetHashKey("WEAPON_ASSAULTRIFLE"),
        GetHashKey("WEAPON_PUMPSHOTGUN"), GetHashKey("WEAPON_GRENADE"), GetHashKey("WEAPON_MOLOTOV"),
        GetHashKey("WEAPON_RPG"), GetHashKey("WEAPON_MINIGUN"),
    }
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if DoesEntityExist(ped) then
            GiveWeaponToPed(ped, weapons[math.random(#weapons)], 9999, true, true)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsRailgun(alive)
    local weaponHash = GetHashKey("WEAPON_RAILGUN")
    OwnershipGuard.ForEachOwnedPed(function(ped)
        GiveWeaponToPed(ped, weaponHash, 9999, true, true)
        SetCurrentPedWeapon(ped, weaponHash, true)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsBattleaxe(alive)
    local weaponHash = GetHashKey("WEAPON_BATTLEAXE")
    OwnershipGuard.ForEachOwnedPed(function(ped)
        GiveWeaponToPed(ped, weaponHash, 9999, true, true)
        SetCurrentPedWeapon(ped, weaponHash, true)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayervehExit(alive)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            TaskLeaveVehicle(ped, veh, 4160)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsExplosive(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            if maxHealth > 0 and (IsPedInjured(ped) or IsPedRagdoll(ped)) then
                local pedPos = GetEntityCoords(ped, false)
                AddExplosion(pedPos.x, pedPos.y, pedPos.z, 4, 9999.0, true, false, 1.0, false)
                SetEntityHealth(ped, 0, false)
                SetEntityMaxHealth(ped, 0)
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerExplosivecombat(alive)
    while alive() do
        SetExplosiveMeleeThisFrame(PlayerId())
        SetExplosiveAmmoThisFrame(PlayerId())
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsFlip(alive)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if not IsPedInAnyVehicle(ped, false) then
            local rot = GetEntityRotation(ped, 2)
            SetEntityRotation(ped, rot.x + 180.0, rot.y, rot.z, 2, true)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayerFamous(alive)
    while alive() do
        SetEveryoneIgnorePlayer(PlayerId(), false)
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) then
                local target = GetNearestPlayerPed(GetEntityCoords(ped))
                if target then
                    TaskLookAtEntity(ped, target, -1, 2048, 3)
                end
            end
        end)
        Citizen.Wait(0)
    end
end

-- MANUAL OVERRIDE from PedsFrozen.cpp

-- sync_mode: GLOBAL_OWNED
function FX_PedsFrozen(alive)
    local lastTick = GetGameTimer()
    local wentThroughPeds = {}
    while alive() do
        local curTick = GetGameTimer()
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed, false)
        if lastTick < curTick - 1000 then
            lastTick = curTick
            OwnershipGuard.ForEachOwnedPed(function(ped)
                local pedPos = GetEntityCoords(ped, false)
                if GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, pedPos.x, pedPos.y, pedPos.z, false) < 50.0 then
                    SetPedConfigFlag(ped, 292, true)
                    table.insert(wentThroughPeds, ped)
                end
            end)
            for i = #wentThroughPeds, 1, -1 do
                local ped = wentThroughPeds[i]
                local pedExists = DoesEntityExist(ped)
                local pedPos = pedExists and GetEntityCoords(ped, false) or vector3(0, 0, 0)
                if not pedExists or GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, pedPos.x, pedPos.y, pedPos.z, false) > 50.0 then
                    if pedExists then
                        SetPedConfigFlag(ped, 292, false)
                    end
                    table.remove(wentThroughPeds, i)
                end
            end
            SetPedConfigFlag(PlayerPedId(), 292, false)
        end
        Citizen.Wait(0)
    end
    -- OnStop cleanup
    OwnershipGuard.ForEachOwnedPed(function(ped)
        SetPedConfigFlag(ped, 292, false)
    end)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsGiveProps(alive)
    local props = {
        GetHashKey("prop_beach_ball_01"), GetHashKey("prop_donut_01"), GetHashKey("prop_snow_flower_01"),
        GetHashKey("prop_roadcone02a"), GetHashKey("prop_bin_01a"), GetHashKey("prop_cs_sol_phone"),
    }
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            local prop = props[math.random(#props)]
            RequestModel(prop)
            while not HasModelLoaded(prop) do Citizen.Wait(0) end
            local obj = CreateObject(prop, 0, 0, 0, true, true, false)
            SetModelAsNoLongerNeeded(prop)
            AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 2, true)
        end
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsGrappleGuns(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) and IsPedShooting(ped) then
                local target = GetNearestPlayerPed(GetEntityCoords(ped))
                if target and DoesEntityExist(target) then
                    local pedPos = GetEntityCoords(ped, false)
                    local targPos = GetEntityCoords(target, false)
                    local diff = pedPos - targPos
                    local dist = #diff
                    if dist > 0.01 then
                        local dir = diff / dist
                        ApplyForceToEntityCenterOfMass(target, 1, dir.x * 50.0, dir.y * 50.0, 20.0, true, false, true, true)
                    end
                end
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: VISUAL
function FX_PedsGunsmoke(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and IsPedShooting(ped) and not IsPedAPlayer(ped) then
                UseParticleFxAsset("core")
                local pos = GetEntityCoords(ped, false)
                StartParticleFxNonLoopedAtCoord("exp_grd_flare", pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 0.5, false, false, false)
            end
        end
        Citizen.Wait(0)
    end
end
