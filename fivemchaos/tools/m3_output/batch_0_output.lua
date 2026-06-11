-- sync_mode: META
function FX_MetaSpawnMultipleEffects(alive)
    TriggerServerEvent("cc:meta_set_internal", "additionalEffects", 2)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set_internal", "additionalEffects", 0)
end

-- sync_mode: META
function FX_MetaEffectDuration05x(alive)
    TriggerServerEvent("cc:meta_set_internal", "durationModifier", 0.5)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set_internal", "durationModifier", 1.0)
end

-- sync_mode: META
function FX_MetaEffectDuration2x(alive)
    TriggerServerEvent("cc:meta_set_internal", "durationModifier", 2.0)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set_internal", "durationModifier", 1.0)
end

-- sync_mode: META
function FX_MetaHideChaosUi(alive)
    TriggerServerEvent("cc:meta_set_internal", "hideChaosUI", true)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set_internal", "hideChaosUI", false)
end

-- sync_mode: META
function FX_MetaNochaos(alive)
    TriggerServerEvent("cc:meta_set_internal", "disableChaos", true)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set_internal", "disableChaos", false)
end

-- sync_mode: META
function FX_MetaReInvoke(alive)
    TriggerServerEvent("cc:meta_set_internal", "additionalEffects", 1)
    Citizen.Wait(100)
    TriggerServerEvent("cc:meta_set_internal", "additionalEffects", 0)
end

-- sync_mode: META
function FX_MetaTimerspeed05x(alive)
    TriggerServerEvent("cc:meta_set_internal", "timerModifier", 0.5)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set_internal", "timerModifier", 1.0)
end

-- sync_mode: META
function FX_MetaTimerspeed2x(alive)
    TriggerServerEvent("cc:meta_set_internal", "timerModifier", 2.0)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set_internal", "timerModifier", 1.0)
end

-- sync_mode: META
function FX_MetaTimerspeed5x(alive)
    TriggerServerEvent("cc:meta_set_internal", "timerModifier", 5.0)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set_internal", "timerModifier", 1.0)
end

-- sync_mode: META
function FX_MetaVotingmodeMajority(alive)
    TriggerServerEvent("cc:meta_set_internal", "votingMode", "majority")
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set_internal", "votingMode", "none")
end

-- sync_mode: META
function FX_MetaVotingmodeAntimajority(alive)
    TriggerServerEvent("cc:meta_set_internal", "votingMode", "antimajority")
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set_internal", "votingMode", "none")
end

-- sync_mode: VISUAL
function FX_MiscAirstrike(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local pos = GetEntityCoords(playerPed, false)
    local weaponHash = GetHashKey("WEAPON_AIRSTRIKE_ROCKET")
    if not HasWeaponAssetLoaded(weaponHash) then
        RequestWeaponAsset(weaponHash, 31, 0)
    end
    while not HasWeaponAssetLoaded(weaponHash) do
        Citizen.Wait(0)
    end
    local offset = vector3(math.random(-20, 20), math.random(-20, 20), 30.0)
    ShootSingleBulletBetweenCoords(pos.x + offset.x, pos.y + offset.y, pos.z + offset.z,
        pos.x + offset.x, pos.y + offset.y, 0.0, 250, true, weaponHash, PlayerPedId(), true, false, 1.0)
end

-- sync_mode: GLOBAL_OWNED
function FX_WorldBlackhole(alive)
    local ms_BlackHolePos = GetEntityCoords(PlayerPedId(), false)
    ms_BlackHolePos = vector3(
        ms_BlackHolePos.x + math.random(-1000, 1000),
        ms_BlackHolePos.y + math.random(-1000, 1000),
        ms_BlackHolePos.z + math.random(400, 800)
    )
    local ms_CurRadius = 0.0
    local playerVeh = GetVehiclePedIsIn(PlayerPedId(), false)
    while alive() do
        if ms_CurRadius < 200.0 then
            ms_CurRadius = ms_CurRadius + 0.2 + GetFrameTime()
        end
        DrawSphere(ms_BlackHolePos.x, ms_BlackHolePos.y, ms_BlackHolePos.z, ms_CurRadius, 0, 0, 0, 1.0)
        ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 0.1 * ms_CurRadius / 200.0)
        local function applyBlackhole(entity)
            if not DoesEntityExist(entity) then return end
            if entity == playerVeh and GetEntityHeightAboveGround(entity) <= 2.0 then return end
            local pos = GetEntityCoords(entity, false)
            local vel = GetEntityVelocity(entity)
            local newVel = vector3(
                (ms_BlackHolePos.x - pos.x) - (2.0 * vel.x),
                (ms_BlackHolePos.y - pos.y) - (2.0 * vel.y),
                (ms_BlackHolePos.z - pos.z) - (2.0 * vel.z)
            )
            ApplyForceToEntityCenterOfMass(entity, 0, newVel.x, newVel.y, newVel.z, true, false, true, true)
            local dist = #(pos - ms_BlackHolePos)
            if dist < ms_CurRadius then
                if IsEntityAPed(entity) then
                    SetEntityHealth(entity, 0, 0)
                elseif IsEntityAVehicle(entity) then
                    ExplodeVehicle(entity, true, false)
                end
                if not IsEntityAMissionEntity(entity) then
                    DeleteEntity(entity)
                end
            end
        end
        OwnershipGuard.ForEachOwnedPed(applyBlackhole)
        OwnershipGuard.ForEachOwnedVehicle(applyBlackhole)
        OwnershipGuard.ForEachOwnedObject(applyBlackhole)
        Citizen.Wait(0)
    end
end

-- sync_mode: VISUAL
function FX_WorldBlackout(alive)
    SetClockTime(0, 0, 0)
    while alive() do
        SetArtificialLightsState(true)
        Citizen.Wait(0)
    end
    SetArtificialLightsState(false)
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscBoostVelocity(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) and not IsPedAPlayer(GetPedInVehicleSeat(veh, -1, false)) then
            local vel = GetEntityVelocity(veh)
            SetEntityVelocity(veh, vel.x * 3.0, vel.y * 3.0, vel.z * 3.0)
        end
    end)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            local vel = GetEntityVelocity(ped)
            SetEntityVelocity(ped, vel.x * 3.0, vel.y * 3.0, vel.z * 3.0)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscCloneOnDeath(alive)
    local temporarilyInvincibleEntities = {}
    local excludeEntities = {}
    local function inExclude(e)
        for _, v in ipairs(excludeEntities) do if v == e then return true end end
        return false
    end
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if IsEntityDead(ped, 0) then table.insert(excludeEntities, ped) end
    end)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if IsEntityDead(veh, 0) then table.insert(excludeEntities, veh) end
    end)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) and IsEntityDead(ped, 0) and not inExclude(ped) then
                table.insert(excludeEntities, ped)
                local clone = CreatePoolClonePed(ped)
                if IsPedInAnyVehicle(ped, false) then
                    local pedVehicle = GetVehiclePedIsIn(ped, false)
                    local pedSeatIndex = -2
                    local maxSeats = GetVehicleModelNumberOfSeats(GetEntityModel(pedVehicle))
                    for i = -1, maxSeats - 1 do
                        if not IsVehicleSeatFree(pedVehicle, i, false) and GetPedInVehicleSeat(pedVehicle, i, 0) == ped then
                            pedSeatIndex = i
                            break
                        end
                    end
                    if not IsPedAPlayer(ped) then
                        SetEntityAsMissionEntity(ped, true, true)
                        DeleteEntity(ped)
                        SetPedIntoVehicle(clone, pedVehicle, pedSeatIndex)
                    end
                end
            end
        end)
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and IsEntityDead(veh, 0) and not inExclude(veh) then
                table.insert(excludeEntities, veh)
                local cloneVeh = CreatePoolCloneVehicle(veh)
                local maxSeats = GetVehicleModelNumberOfSeats(GetEntityModel(veh))
                for i = -1, maxSeats - 1 do
                    if not IsVehicleSeatFree(veh, i, false) then
                        SetPedIntoVehicle(GetPedInVehicleSeat(veh, i, 0), cloneVeh, i)
                    end
                end
                if GetIsVehicleEngineRunning(veh) then
                    SetVehicleEngineOn(cloneVeh, true, true, false)
                end
                SetEntityInvincible(cloneVeh, true)
                table.insert(temporarilyInvincibleEntities, {entity = cloneVeh, endInvincibilityTick = GetGameTimer() + 500})
            end
        end)
        for i = #temporarilyInvincibleEntities, 1, -1 do
            local inv = temporarilyInvincibleEntities[i]
            if not DoesEntityExist(inv.entity) or GetGameTimer() >= inv.endInvincibilityTick then
                if DoesEntityExist(inv.entity) then
                    SetEntityInvincible(inv.entity, false)
                end
                table.remove(temporarilyInvincibleEntities, i)
            else
                SetEntityInvincible(inv.entity, true)
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_CocktailShaker(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedObject(function(obj)
            if DoesEntityExist(obj) and math.random() < 0.05 then
                ApplyForceToEntityCenterOfMass(obj, 1, math.random(-20, 20), math.random(-20, 20), 10.0, false, false, true, false)
            end
        end)
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and math.random() < 0.02 then
                ApplyForceToEntityCenterOfMass(veh, 1, math.random(-10, 10), math.random(-10, 10), 5.0, false, false, true, false)
            end
        end)
        Citizen.Wait(100)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscEarthquake(alive)
    while alive() do
        ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 0.35)
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and math.random() < 0.08 then
                ApplyForceToEntity(veh, 1, math.random(-5, 5), math.random(-5, 5), 10.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end)
        Citizen.Wait(150)
    end
    StopGameplayCamShaking(true)
end

-- sync_mode: VISUAL
function FX_MiscEsp(alive)
    local maxDistance = 75.0
    local thickness = 0.001
    local lineColor = {r = 255, g = 0, b = 0, a = 255}
    local boneIds = {0x0, 0x2e28, 0xe39f, 0xf9bb, 0x3779, 0xca72, 0x9000, 0xcc4d, 0xe0fd, 0x5c01, 0x60f0, 0x60f1, 0x60f2, 0xfcd9, 0xb1c5, 0xeeeb, 0x49d9, 0x29d2, 0x9d4d, 0x6e5c, 0xdead, 0x9995, 0x796e}
    local connections = {
        {0x0, 0xe0fd}, {0xe0fd, 0x5c01}, {0x5c01, 0x60f0}, {0x60f0, 0x60f1},
        {0x60f1, 0x60f2}, {0x60f2, 0x9995}, {0x9995, 0x796e},
        {0xe0fd, 0xfcd9}, {0xfcd9, 0xb1c5}, {0xb1c5, 0xeeeb}, {0xeeeb, 0x49d9},
        {0xe0fd, 0x29d2}, {0x29d2, 0x9d4d}, {0x9d4d, 0x6e5c}, {0x6e5c, 0xdead},
        {0x0, 0x2e28}, {0x2e28, 0xe39f}, {0xe39f, 0xf9bb}, {0xf9bb, 0x3779},
        {0x2e28, 0xca72}, {0xca72, 0x9000}, {0x9000, 0xcc4d},
    }
    local points = {}
    while alive() do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and IsEntityOnScreen(ped) and not IsEntityDead(ped, false)
            and not IsPedAPlayer(ped) and #(GetEntityCoords(ped) - playerCoords) < maxDistance then
                for i = 1, #boneIds do
                    points[i] = GetPedBoneCoords(ped, boneIds[i], 0.0, 0.0, 0.0)
                end
                for _, conn in ipairs(connections) do
                    if points[conn[1]] and points[conn[2]] then
                        DrawLine(
                            points[conn[1]].x, points[conn[1]].y, points[conn[1]].z,
                            points[conn[2]].x, points[conn[2]].y, points[conn[2]].z,
                            lineColor.r, lineColor.g, lineColor.b, lineColor.a
                        )
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: VISUAL
function FX_MiscFakecrash(alive)
    while alive() do
        SetTimecycleModifier("damage")
        SetTimecycleModifierStrength(1.0)
        ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 0.03)
        Citizen.Wait(100)
    end
    ClearTimecycleModifier()
    StopGameplayCamShaking(true)
end

-- sync_mode: VISUAL
function FX_MiscFireworks(alive)
    local lastFirework = 0
    SetClockTime(0, 0, 0)
    while alive() do
        local currentTime = GetGameTimer()
        if currentTime - lastFirework > 500 then
            lastFirework = currentTime
            local pos = GetEntityCoords(PlayerPedId(), true)
            RequestNamedPtfxAsset("proj_indep_firework_v2")
            while not HasNamedPtfxAssetLoaded("proj_indep_firework_v2") do Citizen.Wait(0) end
            UseParticleFxAsset("proj_indep_firework_v2")
            StartParticleFxNonLoopedAtCoord("scr_indep_fireworks",
                pos.x + math.random(-30, 30), pos.y + math.random(-30, 30), pos.z + math.random(15, 35),
                0.0, 0.0, 0.0, 1.0, false, false, false)
        end
        Citizen.Wait(10)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscFlamethrower(alive)
    local MAX_DURATION_BETWEEN_SHOTS = 10
    local MAX_DURATION_ANIMATION = 150
    local animationHandleByPed = {}
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
        Citizen.Wait(0)
    end
    while alive() do
        local firingPeds = {}
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if IsPedShooting(ped) then
                local weapon = GetSelectedPedWeapon(ped)
                if GetWeaponDamageType(weapon) == 3 then
                    table.insert(firingPeds, ped)
                end
            end
        end)
        local delayRemovePeds = 25
        for ped, animInfo in pairs(animationHandleByPed) do
            if not DoesEntityExist(ped) or animInfo.FxHandle <= 0
            or animInfo.FullDuration > MAX_DURATION_ANIMATION
            or ((not IsPedShooting(ped) and IsPedWeaponReadyToShoot(ped))
                and animInfo.DurationSinceLastShot > MAX_DURATION_BETWEEN_SHOTS) then
                StopParticleFxLooped(animInfo.FxHandle, false)
                animationHandleByPed[ped] = nil
            else
                animInfo.FullDuration = animInfo.FullDuration + 1.0
                animInfo.DurationSinceLastShot = animInfo.DurationSinceLastShot + 1.0
            end
            delayRemovePeds = delayRemovePeds - 1
            if delayRemovePeds == 0 then
                delayRemovePeds = 25
                Citizen.Wait(0)
            end
        end
        local delayAnimationStart = 25
        for _, ped in ipairs(firingPeds) do
            if animationHandleByPed[ped] == nil then
                UseParticleFxAsset("core")
                local weapon = GetCurrentPedWeaponEntityIndex(ped, 0)
                local handle = StartParticleFxLoopedOnEntity("ent_sht_flame", weapon, 1, 0, 0, 90, 0, 90, 2, false, false, false)
                animationHandleByPed[ped] = {FxHandle = handle, FullDuration = 0, DurationSinceLastShot = 0}
            else
                animationHandleByPed[ped].DurationSinceLastShot = 0
            end
            delayAnimationStart = delayAnimationStart - 1
            if delayAnimationStart == 0 then
                delayAnimationStart = 25
                Citizen.Wait(0)
            end
        end
        Citizen.Wait(0)
    end
    RemoveNamedPtfxAsset("core")
end

-- sync_mode: VISUAL
function FX_MiscFpsLimit(alive)
    local lagTimeDelay = 40
    while alive() do
        local lastUpdateTick = GetGameTimer()
        while lastUpdateTick > GetGameTimer() - lagTimeDelay do
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_MiscGetTowed(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    local vehCoords = GetEntityCoords(veh, false)
    local towHash = GetHashKey("towtruck")
    RequestModel(towHash)
    while not HasModelLoaded(towHash) do Citizen.Wait(0) end
    local towTruck = CreateVehicle(towHash, vehCoords.x + 10.0, vehCoords.y + 10.0, vehCoords.z, 0.0, true, false)
    SetModelAsNoLongerNeeded(towHash)
    SetVehicleOnGroundProperly(towTruck)
    AttachEntityToEntity(veh, towTruck, 0, 0.0, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    local driverHash = GetHashKey("s_m_m_trucker_01")
    RequestModel(driverHash)
    while not HasModelLoaded(driverHash) do Citizen.Wait(0) end
    local driver = CreatePedInsideVehicle(towTruck, 26, driverHash, -1, true, false)
    SetModelAsNoLongerNeeded(driverHash)
    TaskVehicleDriveWander(driver, towTruck, 40.0, 786603)
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscGhostWorld(alive)
    while alive() do
        SetAiWeaponDamageModifier(0.0)
        SetAiMeleeWeaponDamageModifier(0.0)
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                SetEntityAlpha(ped, 128, false)
            end
        end)
        Citizen.Wait(0)
    end
    ResetAiWeaponDamageModifier()
    ResetAiMeleeWeaponDamageModifier()
end

-- sync_mode: LOCAL
function FX_MiscGoToJail(alive)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)

    local carModel = GetHashKey("POLICE2")
    RequestModel(carModel)
    while not HasModelLoaded(carModel) do
        Citizen.Wait(0)
    end

    local car = CreateVehicle(carModel, pos.x, pos.y, pos.z, heading, true, true)
    SetModelAsNoLongerNeeded(carModel)

    local copModel = GetHashKey("S_M_Y_Cop_01")
    RequestModel(copModel)
    while not HasModelLoaded(copModel) do
        Citizen.Wait(0)
    end

    local cop = CreatePedInsideVehicle(car, 4, copModel, -1, true, false)
    SetModelAsNoLongerNeeded(copModel)

    SetPedIntoVehicle(playerPed, car, 1)
    SetVehicleSiren(car, true)

    TaskVehicleDriveToCoordLongrange(cop, car, 473.1, -1023.5, 28.1, 9999.0, 537395716, 10.0)
    SetBlockingOfNonTemporaryEvents(cop, true)

    SetEntityAsNoLongerNeeded(cop)
    SetEntityAsNoLongerNeeded(car)
end

-- sync_mode: VISUAL
function FX_Lowgravity(alive)
    while alive() do SetGravityLevel(1); Citizen.Wait(0) end
    SetGravityLevel(0)
end

-- sync_mode: VISUAL
function FX_Verylowgravity(alive)
    while alive() do SetGravityLevel(2); Citizen.Wait(0) end
    SetGravityLevel(0)
end

-- sync_mode: VISUAL
function FX_Insanegravity(alive)
    while alive() do SetGravityLevel(3); Citizen.Wait(0) end
    SetGravityLevel(0)
end

-- sync_mode: GLOBAL_OWNED
function FX_Invertgravity(alive)
    while alive() do
        SetGravityLevel(3)
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) then
                ApplyForceToEntityCenterOfMass(ped, 1, 0.0, 0.0, 50.0, true, false, true, true)
            end
        end)
        Citizen.Wait(100)
    end
    SetGravityLevel(0)
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscSidewaysGravity(alive)
    while alive() do
        SetGravityLevel(3)
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) then
                ApplyForceToEntityCenterOfMass(ped, 1, 30.0, 0.0, 0.0, true, false, true, true)
            end
        end)
        Citizen.Wait(100)
    end
    SetGravityLevel(0)
end

-- sync_mode: VISUAL
function FX_MiscRandomgravity(alive)
    while alive() do
        local g = math.random(1, 3)
        SetGravityLevel(g)
        Citizen.Wait(3000)
    end
    SetGravityLevel(0)
end

-- sync_mode: VISUAL
function FX_MiscHighpitch(alive)
    local targetPitch = 750.0 + math.random() * (2000.0 - 750.0)
    while alive() do
        Citizen.Wait(0)
    end
end

-- sync_mode: VISUAL
function FX_PlayerArenawarstheme(alive)
    TriggerMusicEvent("AW_LOBBY_MUSIC_START")
    while alive() do
        Citizen.Wait(1000)
    end
    TriggerMusicEvent("MP_MC_CMH_IAA_FINALE_START")
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscInvertvelocity(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) and not IsPedAPlayer(GetPedInVehicleSeat(veh, -1, false)) then
            local vel = GetEntityVelocity(veh)
            SetEntityVelocity(veh, -vel.x, -vel.y, -vel.z)
        end
    end)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            SetPedToRagdoll(ped, 1000, 1000, 0, true, true, false)
            local vel = GetEntityVelocity(ped)
            SetEntityVelocity(ped, -vel.x, -vel.y, -vel.z)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscJumpyProps(alive)
    local propDataMap = {}
    while alive() do
        OwnershipGuard.ForEachOwnedObject(function(prop)
            local coords = GetEntityCoords(prop, false)
            if propDataMap[prop] == nil then
                propDataMap[prop] = {originalZ = coords.z, startOffset = GetGameTimer() + prop}
            end
            local data = propDataMap[prop]
            local Z = data.originalZ + math.max(math.sin((GetGameTimer() - data.startOffset) / 150.0) * 2.5, 0.0)
            SetEntityCoords(prop, coords.x, coords.y, Z, false, false, false, false)
        end)
        Citizen.Wait(0)
    end
    for prop, data in pairs(propDataMap) do
        if DoesEntityExist(prop) then
            local coords = GetEntityCoords(prop, false)
            SetEntityCoords(prop, coords.x, coords.y, data.originalZ, false, false, false, false)
        end
    end
    propDataMap = {}
end

-- sync_mode: GLOBAL_OWNED
function FX_TimeLag(alive)
    local ms_State = 0
    local ms_ToTpPeds = {}
    local ms_ToTpVehs = {}
    local lastTick = 0
    while alive() do
        local curTick = GetGameTimer()
        if curTick > lastTick + 500 then
            lastTick = curTick
            ms_State = ms_State + 1
            if ms_State == 4 then ms_State = 0 end
            if ms_State == 2 then
                OwnershipGuard.ForEachOwnedPed(function(ped)
                    if not IsPedInAnyVehicle(ped, true) and GetVehiclePedIsEntering(ped) == 0 then
                        local pedPos = GetEntityCoords(ped, false)
                        ms_ToTpPeds[ped] = pedPos
                    end
                end)
                OwnershipGuard.ForEachOwnedVehicle(function(veh)
                    local vehPos = GetEntityCoords(veh, false)
                    ms_ToTpVehs[veh] = vehPos
                end)
            elseif ms_State == 3 then
                local camHeading = GetGameplayCamRelativeHeading()
                for veh, tpPos in pairs(ms_ToTpVehs) do
                    if OwnershipGuard.IsOwner(veh) then
                        local vel = GetEntityVelocity(veh)
                        local heading = GetEntityHeading(veh)
                        local forwardSpeed = GetEntitySpeed(veh)
                        if GetEntitySpeedVector(veh, true).y < 0 then
                            forwardSpeed = forwardSpeed * -1
                        end
                        SetEntityCoordsNoOffset(veh, tpPos.x, tpPos.y, tpPos.z, false, false, false)
                        SetEntityHeading(veh, heading)
                        SetEntityVelocity(veh, vel.x, vel.y, vel.z)
                        SetVehicleForwardSpeed(veh, forwardSpeed)
                    end
                end
                ms_ToTpVehs = {}
                SetGameplayCamRelativeHeading(camHeading)
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: VISUAL
function FX_MiscLowpitch(alive)
    local targetPitch = -900.0 + math.random() * (-300.0 - (-900.0))
    while alive() do
        Citizen.Wait(0)
    end
end

-- sync_mode: VISUAL
function FX_WorldLowpoly(alive)
    while alive() do
        SetTimecycleModifier("yell_tunnel_nodirect")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_Meteorrain(alive)
    while alive() do
        local playerPos = GetEntityCoords(PlayerPedId(), false)
        local pos = vector3(
            playerPos.x + math.random(-100, 100),
            playerPos.y + math.random(-100, 100),
            playerPos.z + math.random(50, 100)
        )
        local weaponHash = GetHashKey("WEAPON_AIRSTRIKE_ROCKET")
        if not HasWeaponAssetLoaded(weaponHash) then
            RequestWeaponAsset(weaponHash, 31, 0)
        end
        while not HasWeaponAssetLoaded(weaponHash) do Citizen.Wait(0) end
        ShootSingleBulletBetweenCoords(pos.x, pos.y, pos.z, pos.x, pos.y, 0.0, 200, true, weaponHash, PlayerPedId(), true, false, 1.0)
        Citizen.Wait(150)
    end
end

-- sync_mode: LOCAL
function FX_MiscMidas(alive)
    local model = GetHashKey("prop_money_bag_01")
    RequestModel(model)

    while alive() do
        local playerPed = PlayerPedId()
        local cE = playerPed

        if IsPedInAnyVehicle(playerPed, false) then
            cE = GetVehiclePedIsIn(playerPed, false)
            ToggleVehicleMod(cE, 20, true)
            SetVehicleTyreSmokeColor(cE, 255, 215, 0)
            ClearVehicleCustomPrimaryColour(cE)
            ClearVehicleCustomSecondaryColour(cE)
            SetVehicleColours(cE, 158, 158)
            SetVehicleExtraColours(cE, 160, 158)
            SetVehicleEnveffScale(cE, 0.0)
            SetVehicleDirtLevel(cE, 0.0)
        end

        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if IsEntityTouchingEntity(cE, veh) then
                ToggleVehicleMod(veh, 20, true)
                SetVehicleTyreSmokeColor(veh, 255, 215, 0)
                ClearVehicleCustomPrimaryColour(veh)
                ClearVehicleCustomSecondaryColour(veh)
                SetVehicleColours(veh, 158, 158)
                SetVehicleExtraColours(veh, 160, 158)
                SetVehicleEnveffScale(veh, 0.0)
                SetVehicleDirtLevel(veh, 0.0)
            end
        end)

        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsEntityAMissionEntity(ped) or IsCutscenePlaying() then
                if IsEntityTouchingEntity(cE, ped) then
                    local pos = GetEntityCoords(ped, false)
                    CreateAmbientPickup(GetHashKey("PICKUP_MONEY_SECURITY_CASE"), pos.x, pos.y, pos.z, 0, 1000, model, false, true)
                    SetEntityCoords(ped, 0.0, 0.0, 0.0, false, false, false, false)
                    SetPedAsNoLongerNeeded(ped)
                    DeletePed(ped)
                end
            end
        end)

        OwnershipGuard.ForEachOwnedObject(function(prop)
            if IsEntityTouchingEntity(cE, prop) and not IsPedClimbing(cE) then
                if not IsEntityAMissionEntity(prop) or IsCutscenePlaying() then
                    if not GetEntityAttachedTo(prop) then
                        local pos = GetEntityCoords(prop, false)
                        CreateAmbientPickup(GetHashKey("PICKUP_MONEY_SECURITY_CASE"), pos.x, pos.y, pos.z, 0, 1000, model, false, true)
                        SetEntityCoords(prop, 0.0, 0.0, 0.0, false, false, false, false)
                        SetEntityAsNoLongerNeeded(prop)
                        DeleteEntity(prop)
                    end
                end
            end
        end)

        if IsPedArmed(playerPed, 7) then
            local weaponHash = GetCurrentPedWeapon(playerPed, true)
            SetPedWeaponTintIndex(playerPed, weaponHash, 2)
        end

        Citizen.Wait(0)
    end

    SetModelAsNoLongerNeeded(model)
end

-- sync_mode: LOCAL
function FX_PlayerMoneydrops(alive)
    local model = GetHashKey("prop_money_bag_01")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end

    while alive() do
        local playerPos = GetEntityCoords(PlayerPedId(), false)
        CreateAmbientPickup(GetHashKey("PICKUP_MONEY_SECURITY_CASE"),
            playerPos.x + math.random(-20, 20),
            playerPos.y + math.random(-20, 20),
            playerPos.z + math.random(5, 10),
            0, 1000, model, false, true)
        Citizen.Wait(0)
    end

    SetModelAsNoLongerNeeded(model)
end

-- sync_mode: VISUAL
function FX_MiscMuffledAudio(alive)
    while alive() do
        Citizen.Wait(1000)
    end
end

-- sync_mode: SPAWN_SINGLE
function FX_MiscNewsTeam(alive)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed, false)
    local modelHash = GetHashKey("s_m_m_news_01")
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local newsGuy = CreatePed(26, modelHash, pos.x + 3.0, pos.y, pos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(modelHash)
    GiveWeaponToPed(newsGuy, GetHashKey("WEAPON_MICROSMG"), 9999, true, true)
    SetPedCombatAttributes(newsGuy, 5, true)
    local target = GetNearestPlayerPed(GetEntityCoords(newsGuy))
    if target and target ~= 0 then
        TaskCombatPed(newsGuy, target, 0, 16)
    end
    RetargetSpawnedPed(newsGuy, 5000)
end

-- sync_mode: LOCAL
function FX_PlayerNophone(alive)
    while alive() do
        DestroyMobilePhone()
        Citizen.Wait(0)
    end
    CreateMobilePhone(0)
end

-- sync_mode: VISUAL
function FX_MiscNosky(alive)
    while alive() do
        SetCloudHatTransition("altostratus", 0.0)
        Citizen.Wait(0)
    end
    SetCloudHatTransition("Clear", 1.0)
end

-- sync_mode: LOCAL
function FX_Nothing(alive)
end

-- sync_mode: VISUAL
function FX_MiscRemoveWater(alive)
    while alive() do
        SetDeepOceanScaler(0.0)
        Citizen.Wait(0)
    end
    SetDeepOceanScaler(1.0)
end

-- sync_mode: LOCAL
function FX_MiscNowaypoint(alive)
    DeleteWaypoint()
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscOilleaks(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and GetEntitySpeed(veh) > 2.0 then
                SetVehicleEngineHealth(veh, -4000.0)
            end
        end)
        Citizen.Wait(2500)
    end
end
