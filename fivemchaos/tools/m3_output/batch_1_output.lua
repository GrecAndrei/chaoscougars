-- sync_mode: GLOBAL_OWNED
function FX_MiscOnebullet(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedArmed(playerPed, 7) then
            local weaponHash = GetCurrentPedWeapon(playerPed, true)
            local ammo = GetAmmoInClip(playerPed, weaponHash)
            if ammo > 1 then
                local diff = ammo - 1
                AddAmmoToPed(playerPed, weaponHash, diff)
                SetAmmoInClip(playerPed, weaponHash, 1)
            end
        end
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if IsPedArmed(ped, 7) then
                local weaponHash = GetCurrentPedWeapon(ped, true)
                local ammo = GetAmmoInClip(ped, weaponHash)
                if ammo > 1 then
                    local diff = ammo - 1
                    AddAmmoToPed(ped, weaponHash, diff)
                    SetAmmoInClip(ped, weaponHash, 1)
                end
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_MiscPause(alive)
    SetControlNormal(0, 199, 1.0)
end

-- sync_mode: LOCAL
function FX_MiscPayRespects(alive)
    while alive() do
        TaskPlayAnim(PlayerPedId(), "mp_player_int_upperfinger", "mp_player_int_finger_01", 8.0, -1.0, -1, 49, 0.0, false, false, false)
        Citizen.Wait(5000)
    end
end

-- sync_mode: VISUAL
function FX_MiscPortrait(alive)
    while alive() do
        SetTimecycleModifier("phone_cam1")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: LOCAL
function FX_MiscQuickSprunkStop(alive)
    while alive() do
        SetTimeScale(0.5)
        Citizen.Wait(2500)
        SetTimeScale(2.0)
        Citizen.Wait(2500)
    end
    SetTimeScale(1.0)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsRainbowweps(alive)
    local weapons = {
        GetHashKey("WEAPON_PISTOL"), GetHashKey("WEAPON_SMG"), GetHashKey("WEAPON_ASSAULTRIFLE"),
        GetHashKey("WEAPON_PUMPSHOTGUN"), GetHashKey("WEAPON_GRENADE"),
        GetHashKey("WEAPON_RPG"), GetHashKey("WEAPON_MINIGUN"),
    }
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            RemoveAllPedWeapons(ped, true)
            GiveWeaponToPed(ped, weapons[math.random(#weapons)], 9999, true, true)
        end)
        Citizen.Wait(5000)
    end
end

-- sync_mode: LOCAL
function FX_MiscRampjam(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if not IsPedInAnyVehicle(playerPed, false) then
            local pos = GetEntityCoords(playerPed, false)
            local heading = GetEntityHeading(playerPed)
            local rampHash = GetHashKey("prop_mp_ramp_03")
            RequestModel(rampHash)
            while not HasModelLoaded(rampHash) do Citizen.Wait(0) end
            local ramp = CreateObject(rampHash, pos.x, pos.y + 3.0, pos.z, true, true, true)
            SetModelAsNoLongerNeeded(rampHash)
            SetEntityHeading(ramp, heading)
            FreezeEntityPosition(ramp, true)
            SetObjectAsNoLongerNeeded(ramp)
        end
        Citizen.Wait(500)
    end
end

-- sync_mode: LOCAL
function FX_MiscRandomWaypoint(alive)
    local x = math.random(-4000, 4000) + 0.0
    local y = math.random(-4000, 4000) + 0.0
    SetNewWaypoint(x, y)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName("New waypoint set!")
    EndTextCommandThefeedPostTicker(false, false)
end

-- sync_mode: VISUAL
function FX_MiscCredits(alive)
    while alive() do
        SetTimecycleModifier("Barry1_Stoned")
        SetTimecycleModifierStrength(0.5)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscSolidProps(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedObject(function(obj)
            FreezeEntityPosition(obj, true)
            SetEntityDynamic(obj, false)
        end)
        Citizen.Wait(1000)
    end
end

-- sync_mode: LOCAL
function FX_MiscSpawnufo(alive)
    local hash = GetHashKey("p_spinning_anus_s")
    local playerPos = GetEntityCoords(PlayerPedId(), false)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
    end

    CreateObject(hash, playerPos.x, playerPos.y, playerPos.z, true, true, false)
    SetModelAsNoLongerNeeded(hash)
end

-- sync_mode: LOCAL
function FX_MiscSpawnferriswheel(alive)
    local hash = GetHashKey("prop_ld_ferris_wheel")
    local playerPos = GetEntityCoords(PlayerPedId(), false)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
    end

    CreateObject(hash, playerPos.x, playerPos.y, playerPos.z, true, true, false)
    SetModelAsNoLongerNeeded(hash)
end

-- sync_mode: LOCAL
function FX_MiscSpawnOrangeBall(alive)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed, false)
    local ballHash = GetHashKey("prop_beach_ball_01")
    RequestModel(ballHash)
    while not HasModelLoaded(ballHash) do Citizen.Wait(0) end
    local ball = CreateObject(ballHash, pos.x, pos.y + 10.0, pos.z + 1.0, true, true, false)
    SetModelAsNoLongerNeeded(ballHash)
    ActivatePhysics(ball)
    ApplyForceToEntityCenterOfMass(ball, 1, 0.0, 500.0, 200.0, true, false, true, true)
    SetObjectAsNoLongerNeeded(ball)
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscSpinningProps(alive)
    local ROTATION_SPEED = (1.3 * 360.0) / 1000.0
    local lastTick = GetGameTimer()

    while alive() do
        local currentTick = GetGameTimer()
        local tickDelta = currentTick - lastTick
        lastTick = currentTick

        OwnershipGuard.ForEachOwnedObject(function(prop)
            local rotation = GetEntityRotation(prop, 2)
            SetEntityRotation(prop, rotation.x, rotation.y, rotation.z + (ROTATION_SPEED * tickDelta), 2, true)
        end)

        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscStuffguns(alive)
    while alive() do
        local function checkPed(ped)
            if DoesEntityExist(ped) and IsPedShooting(ped) then
                local spawnPos
                local spawnRot
                if IsPedAPlayer(ped) then
                    local camCoords = GetGameplayCamCoord()
                    local pedPos = GetEntityCoords(ped, false)
                    local dist = #(pedPos - camCoords)
                    spawnPos = camCoords + (((GetGameplayCamRot(2).z - GetEntityHeading(ped)) > 180 and -1 or 1) * GetGameplayCamRot(2))
                    spawnRot = GetGameplayCamRot(2)
                else
                    spawnPos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
                    spawnRot = GetEntityRotation(ped, 2)
                end
                local isShotgun = GetWeapontypeGroup(GetSelectedPedWeapon(ped)) == GetHashKey("GROUP_SHOTGUN")
                local count = isShotgun and 3 or 1
                for i = 0, count - 1 do
                    local sPos = spawnPos
                    if isShotgun then
                        sPos = vector3(spawnPos.x, spawnPos.y, spawnPos.z - 0.25 + i * 0.25)
                    end
                    local thing = nil
                    local pick = math.random(0, 2)
                    if pick == 0 then
                        local props = GetGamePool('CObject')
                        if #props > 0 then
                            thing = props[math.random(#props)]
                        end
                    elseif pick == 1 then
                        local peds = GetGamePool('CPed')
                        if #peds > 0 then
                            thing = peds[math.random(#peds)]
                        end
                    else
                        local vehs = GetGamePool('CVehicle')
                        if #vehs > 0 then
                            thing = vehs[math.random(#vehs)]
                        end
                    end
                    if thing and DoesEntityExist(thing) and OwnershipGuard.IsOwner(thing) then
                        SetEntityNoCollisionEntity(ped, thing, true)
                        SetEntityCoords(thing, sPos.x, sPos.y, sPos.z, false, false, false, false)
                        SetEntityRotation(thing, spawnRot.x, spawnRot.y, spawnRot.z, 2, true)
                        if GetEntityType(thing) == 1 then
                            ClearPedTasksImmediately(thing)
                            SetPedToRagdoll(thing, 2000, 2000, 0, true, true, false)
                        end
                        ApplyForceToEntityCenterOfMass(thing, 0, 0.0, 1000.0, 0.0, true, false, true, true)
                    end
                    if i > 0 then Citizen.Wait(0) end
                end
            end
        end
        checkPed(PlayerPedId())
        OwnershipGuard.ForEachOwnedPed(checkPed)
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_MiscSuperstunt(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local rampPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)

    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    if not IsPedInVehicle(playerPed, playerVeh, true) then
        local vehModel = GetHashKey("adder")
        RequestModel(vehModel)
        while not HasModelLoaded(vehModel) do
            Citizen.Wait(0)
        end
        playerVeh = CreateVehicle(vehModel, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, true)
        SetModelAsNoLongerNeeded(vehModel)
        SetPedIntoVehicle(playerPed, playerVeh, -1)
    end

    local rampModel = GetHashKey("prop_mp_ramp_03")
    RequestModel(rampModel)
    while not HasModelLoaded(rampModel) do
        Citizen.Wait(0)
    end

    local ramp = CreateObject(rampModel, rampPos.x, rampPos.y, rampPos.z, true, false, false)
    SetModelAsNoLongerNeeded(rampModel)
    PlaceObjectOnGroundProperly(ramp)

    rampPos = GetEntityCoords(ramp, false)
    SetEntityCoords(ramp, rampPos.x, rampPos.y, rampPos.z - 0.3, true, true, true, false)
    SetEntityRotation(ramp, GetEntityPitch(playerVeh), -GetEntityRoll(playerVeh), GetEntityHeading(playerVeh), 0, true)

    local forward = GetEntityForwardVector(playerVeh)
    SetEntityVelocity(playerVeh, forward.x * 7000.0, forward.y * 7000.0, forward.z * 7000.0)

    SetEntityInvincible(playerPed, true)
    SetEntityInvincible(playerVeh, true)
    Citizen.Wait(500)
    SetEntityInvincible(playerPed, false)
    SetEntityInvincible(playerVeh, false)
end

-- sync_mode: META
function FX_Chaosmode(alive)
    TriggerServerEvent("cc:meta_set_internal", "additionalEffects", 3)
    TriggerServerEvent("cc:meta_set_internal", "timerModifier", 3.0)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set_internal", "additionalEffects", 0)
    TriggerServerEvent("cc:meta_set_internal", "timerModifier", 1.0)
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscUturn(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) and not IsPedAPlayer(GetPedInVehicleSeat(veh, -1, false)) then
            local heading = GetEntityHeading(veh)
            SetEntityHeading(veh, heading + 180.0)
            local vel = GetEntityVelocity(veh)
            SetEntityVelocity(veh, -vel.x, -vel.y, vel.z)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_MiscFakeuturn(alive)
    local function DoUTurn()
        local camHeading = GetGameplayCamRelativeHeading()

        local function flipEnt(ent)
            local rot = GetEntityRotation(ent, 2)
            local vel = GetEntityVelocity(ent)
            SetEntityRotation(ent, -rot.x, -rot.y, rot.z + 180.0, 2, true)
            SetEntityVelocity(ent, -vel.x, -vel.y, -vel.z)
        end

        OwnershipGuard.ForEachOwnedPed(flipEnt)
        OwnershipGuard.ForEachOwnedVehicle(flipEnt)
        OwnershipGuard.ForEachOwnedObject(flipEnt)

        SetGameplayCamRelativeHeading(camHeading)
    end

    DoUTurn()
    Citizen.Wait(math.random(6000, 9000))
    DoUTurn()
end

-- sync_mode: SPAWN_SINGLE
function FX_MiscVehicleRain(alive)
    local lastTick = 0
    local vehModels = {
        GetHashKey("adder"),
        GetHashKey("t20"),
        GetHashKey("zentorno"),
        GetHashKey("infernus"),
        GetHashKey("turismor"),
        GetHashKey("cheetah"),
        GetHashKey("entityxf"),
        GetHashKey("vacca"),
        GetHashKey("banshee"),
        GetHashKey("comet2"),
        GetHashKey("feltzer2"),
        GetHashKey("ninef"),
        GetHashKey("sultan"),
        GetHashKey("penumbra"),
        GetHashKey("seminole")
    }

    for _, model in ipairs(vehModels) do
        RequestModel(model)
    end

    while alive() do
        local curTick = GetGameTimer()
        if curTick > lastTick + 500 then
            lastTick = curTick

            local playerPos = GetEntityCoords(PlayerPedId(), false)
            local spawnPos = vector3(
                playerPos.x + math.random(-100, 100),
                playerPos.y + math.random(-100, 100),
                playerPos.z + math.random(25, 50)
            )

            local model = vehModels[math.random(1, #vehModels)]
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end

            local veh = CreateVehicle(model, spawnPos.x, spawnPos.y, spawnPos.z, GetEntityHeading(PlayerPedId()), true, true)
            SetVehicleModKit(veh, 0)
            SetVehicleWheelType(veh, math.random(0, 12))

            for i = 0, 49 do
                local maxMod = GetNumVehicleMods(veh, i)
                SetVehicleMod(veh, i, maxMod > 0 and math.random(0, maxMod - 1) or 0, math.random(0, 1) == 1)
                ToggleVehicleMod(veh, i, math.random(0, 1) == 1)
            end

            SetVehicleTyresCanBurst(veh, math.random(0, 1) == 1)
            SetVehicleWindowTint(veh, math.random(0, 6))
        end
        Citizen.Wait(0)
    end

    for _, model in ipairs(vehModels) do
        SetModelAsNoLongerNeeded(model)
    end
end

-- sync_mode: VISUAL
function FX_MiscWeirdpitch(alive)
    while alive() do
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.4)
        SetGameplayCamShakeAmplitude(0.4)
        Citizen.Wait(250)
    end
    StopGameplayCamShaking(true)
end

-- sync_mode: SPAWN_SINGLE
function FX_WorldWhalerain(alive)
    local wh = GetHashKey("a_c_humpback")
    RequestModel(wh)
    while not HasModelLoaded(wh) do Citizen.Wait(0) end
    while alive() do
        local playerPos = GetEntityCoords(PlayerPedId(), false)
        local pos = vector3(
            playerPos.x + math.random(-100, 100),
            playerPos.y + math.random(-100, 100),
            playerPos.z + math.random(50, 100)
        )
        local whale = CreatePed(28, wh, pos.x, pos.y, pos.z, 0.0, true, false)
        SetPedToRagdoll(whale, 5000, 5000, 0, true, true, false)
        SetPedAsNoLongerNeeded(whale)
        Citizen.Wait(750)
    end
    SetModelAsNoLongerNeeded(wh)
end

-- sync_mode: SPAWN_SINGLE
function FX_MiscWitnessProtection(alive)
    local orbitingPeds = {}
    local pedCount = 20
    while alive() do
        local player = PlayerPedId()
        local count = 5
        if #orbitingPeds == 0 then
            local pedHash = GetHashKey("MP_M_FIBSec_01")
            LoadModel(pedHash)
            for i = 0, pedCount - 1 do
                local ped = CreatePed(-1, pedHash, 0, 0, 0, 0, true, false)
                SetEntityHasGravity(ped, false)
                SetPedCanRagdoll(ped, false)
                SetEntityCollision(ped, false, true)
                SetPedCanBeTargettedByPlayer(ped, player, false)
                local offset = (360.0 / pedCount) * i
                table.insert(orbitingPeds, {ped = ped, angle = offset})
                count = count - 1
                if count == 0 then
                    Citizen.Wait(0)
                    count = 5
                end
            end
        end
        local entityToCircle = player
        if IsPedInAnyVehicle(player, false) then
            entityToCircle = GetVehiclePedIsIn(player, false)
        end
        local min, max = GetModelDimensions(GetEntityModel(entityToCircle))
        local height = max.z - min.z
        local zCorrection = (-height / 2) + 0.3
        local heading = GetEntityHeading(entityToCircle)
        for i = #orbitingPeds, 1, -1 do
            local pedInfo = orbitingPeds[i]
            if IsPedDeadOrDying(pedInfo.ped, false) then
                SetEntityHealth(pedInfo.ped, 0, 0)
                SetEntityAlpha(pedInfo.ped, 0, true)
                SetPedAsNoLongerNeeded(pedInfo.ped)
                DeletePed(pedInfo.ped)
                table.remove(orbitingPeds, i)
                count = count - 1
                if count == 0 then
                    Citizen.Wait(0)
                    count = 5
                end
            else
                local coord = GetCoordAround(entityToCircle, heading - pedInfo.angle, 3, zCorrection, true)
                SetEntityCoords(pedInfo.ped, coord.x, coord.y, coord.z, false, false, false, false)
                SetEntityHeading(pedInfo.ped, pedInfo.angle + 90)
                TaskStandStill(pedInfo.ped, 5000)
                pedInfo.angle = pedInfo.angle + 1
            end
        end
        Citizen.Wait(0)
    end
    local count = 5
    for i = #orbitingPeds, 1, -1 do
        local pedInfo = orbitingPeds[i]
        SetEntityHealth(pedInfo.ped, 0, 0)
        SetEntityAlpha(pedInfo.ped, 0, true)
        SetPedAsNoLongerNeeded(pedInfo.ped)
        DeletePed(pedInfo.ped)
        count = count - 1
        if count == 0 then
            Citizen.Wait(0)
            count = 5
        end
    end
end

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
        local playerPed = PlayerPedId()
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) and not IsEntityDead(ped, false) then
                TaskCombatPed(ped, playerPed, 0, 16)
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
    local function applyPacks(ped)
        for _, pack in ipairs(packs) do
            ApplyPedDamagePack(ped, pack, 0.0, 10.0)
        end
    end
    applyPacks(PlayerPedId())
    OwnershipGuard.ForEachOwnedPed(applyPacks)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsBusbois(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local busHash = GetHashKey("bus")
    local maxDistance = 120.0
    RequestModel(busHash)
    while not HasModelLoaded(busHash) do Citizen.Wait(0) end
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if not IsPedDeadOrDying(ped, true) then
            local pedPos = GetEntityCoords(ped, false)
            local dist = #(playerPos - pedPos)
            if dist <= maxDistance then
                local heading = GetEntityHeading(ped)
                local veh = CreateVehicle(busHash, pedPos.x, pedPos.y, pedPos.z, heading, true, false, false)
                SetVehicleEngineOn(veh, true, true, false)
                SetPedIntoVehicle(ped, veh, -1)
            end
        end
    end)
    SetModelAsNoLongerNeeded(busHash)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsCatguns(alive)
    local catHash = GetHashKey("a_c_cat_01")
    RequestModel(catHash)
    while alive() do
        local function checkPed(ped)
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
        checkPed(PlayerPedId())
        OwnershipGuard.ForEachOwnedPed(checkPed)
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
    local playerPed = PlayerPedId()
    local weaponHash = GetHashKey("WEAPON_MACHINEPISTOL")
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if IsPedInAnyVehicle(ped, false) then
                SetBlockingOfNonTemporaryEvents(ped, true)
                GiveWeaponToPed(ped, weaponHash, 9999, true, true)
                TaskDriveBy(ped, playerPed, 0, 0.0, 0.0, 0.0, -1.0, 5, false, 0xC6EE6B4C)
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: VISUAL
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
    local hash = GetHashKey("WEAPON_RPG")
    GiveWeaponToPed(PlayerPedId(), hash, 9999, true, true)
    SetCurrentPedWeapon(PlayerPedId(), hash, true)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        GiveWeaponToPed(ped, hash, 9999, true, true)
        SetCurrentPedWeapon(ped, hash, true)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsStungun(alive)
    local hash = GetHashKey("WEAPON_STUNGUN")
    GiveWeaponToPed(PlayerPedId(), hash, 9999, true, true)
    SetCurrentPedWeapon(PlayerPedId(), hash, true)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        GiveWeaponToPed(ped, hash, 9999, true, true)
        SetCurrentPedWeapon(ped, hash, true)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsMinigun(alive)
    local hash = GetHashKey("WEAPON_MINIGUN")
    GiveWeaponToPed(PlayerPedId(), hash, 9999, true, true)
    SetCurrentPedWeapon(PlayerPedId(), hash, true)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        GiveWeaponToPed(ped, hash, 9999, true, true)
        SetCurrentPedWeapon(ped, hash, true)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsUpnatomizer(alive)
    local hash = GetHashKey("WEAPON_RAYPISTOL")
    GiveWeaponToPed(PlayerPedId(), hash, 9999, true, true)
    SetCurrentPedWeapon(PlayerPedId(), hash, true)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        GiveWeaponToPed(ped, hash, 9999, true, true)
        SetCurrentPedWeapon(ped, hash, true)
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
    local hash = GetHashKey("WEAPON_RAILGUN")
    GiveWeaponToPed(PlayerPedId(), hash, 9999, true, true)
    SetCurrentPedWeapon(PlayerPedId(), hash, true)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        GiveWeaponToPed(ped, hash, 9999, true, true)
        SetCurrentPedWeapon(ped, hash, true)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsBattleaxe(alive)
    local hash = GetHashKey("WEAPON_BATTLEAXE")
    GiveWeaponToPed(PlayerPedId(), hash, 9999, true, true)
    SetCurrentPedWeapon(PlayerPedId(), hash, true)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        GiveWeaponToPed(ped, hash, 9999, true, true)
        SetCurrentPedWeapon(ped, hash, true)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayervehExit(alive)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local veh = GetVehiclePedIsIn(playerPed, false)
        TaskLeaveVehicle(playerPed, veh, 4160)
    end
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
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then
        local rot = GetEntityRotation(playerPed, 2)
        SetEntityRotation(playerPed, rot.x + 180.0, rot.y, rot.z, 2, true)
    end
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
                TaskLookAtEntity(ped, PlayerPedId(), -1, 2048, 3)
            end
        end)
        Citizen.Wait(0)
    end
end

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
                local pedPos = GetEntityCoords(ped, false)
                local pedExists = DoesEntityExist(ped)
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
    for _, ped in ipairs(wentThroughPeds) do
        SetPedConfigFlag(ped, 292, false)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsGiveProps(alive)
    local props = {
        GetHashKey("prop_beach_ball_01"), GetHashKey("prop_donut_01"), GetHashKey("prop_snow_flower_01"),
        GetHashKey("prop_roadcone02a"), GetHashKey("prop_bin_01a"), GetHashKey("prop_cs_sol_phone"),
    }
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if DoesEntityExist(ped) then
            local prop = props[math.random(#props)]
            RequestModel(prop)
            while not HasModelLoaded(prop) do Citizen.Wait(0) end
            local obj = CreateObject(prop, 0, 0, 0, true, true, false)
            SetModelAsNoLongerNeeded(prop)
            AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 2, true)
        end
    end)
end

-- sync_mode: LOCAL
function FX_PedsGrappleGuns(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) and IsPedShooting(ped) then
                local target = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if DoesEntityExist(target) and OwnershipGuard.IsOwner(target) then
                    local pedPos = GetEntityCoords(ped, false)
                    local targPos = GetEntityCoords(target, false)
                    local dir = (pedPos - targPos) / #(pedPos - targPos)
                    ApplyForceToEntityCenterOfMass(target, 1, dir.x * 50.0, dir.y * 50.0, 20.0, true, false, true, true)
                end
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: VISUAL
function FX_PedsGunsmoke(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) and IsPedShooting(ped) then
                UseParticleFxAsset("core")
                local pos = GetEntityCoords(ped, false)
                StartParticleFxNonLoopedAtCoord("exp_grd_flare", pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 0.5, false, false, false)
            end
        end)
        Citizen.Wait(0)
    end
end
