-- sync_mode: GLOBAL_OWNED
function FX_MiscOnebullet(alive)
    while alive() do
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

-- sync_mode: VISUAL
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
    while alive() do
        local weapons = {
            GetHashKey("WEAPON_PISTOL"), GetHashKey("WEAPON_SMG"), GetHashKey("WEAPON_ASSAULTRIFLE"),
            GetHashKey("WEAPON_PUMPSHOTGUN"), GetHashKey("WEAPON_GRENADE"),
            GetHashKey("WEAPON_RPG"), GetHashKey("WEAPON_MINIGUN"),
        }
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                RemoveAllPedWeapons(ped, true)
                GiveWeaponToPed(ped, weapons[math.random(#weapons)], 9999, true, true)
            end
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
            if DoesEntityExist(obj) and not IsEntityAMissionEntity(obj) then
                FreezeEntityPosition(obj, true)
                SetEntityDynamic(obj, false)
            end
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
        OwnershipGuard.ForEachOwnedPed(function(ped)
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
        end)
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

        OwnershipGuard.ForEachOwnedVehicle(function(ent)
            local rot = GetEntityRotation(ent, 2)
            local vel = GetEntityVelocity(ent)
            SetEntityRotation(ent, -rot.x, -rot.y, rot.z + 180.0, 2, true)
            SetEntityVelocity(ent, -vel.x, -vel.y, -vel.z)
        end)
        OwnershipGuard.ForEachOwnedPed(function(ent)
            local rot = GetEntityRotation(ent, 2)
            local vel = GetEntityVelocity(ent)
            SetEntityRotation(ent, -rot.x, -rot.y, rot.z + 180.0, 2, true)
            SetEntityVelocity(ent, -vel.x, -vel.y, -vel.z)
        end)
        OwnershipGuard.ForEachOwnedObject(function(ent)
            local rot = GetEntityRotation(ent, 2)
            local vel = GetEntityVelocity(ent)
            SetEntityRotation(ent, -rot.x, -rot.y, rot.z + 180.0, 2, true)
            SetEntityVelocity(ent, -vel.x, -vel.y, -vel.z)
        end)

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

            local target = GetNearestPlayerPed(GetEntityCoords(PlayerPedId()))
            local targetPos = GetEntityCoords(target, false)
            local spawnPos = vector3(
                targetPos.x + math.random(-100, 100),
                targetPos.y + math.random(-100, 100),
                targetPos.z + math.random(25, 50)
            )

            local model = vehModels[math.random(1, #vehModels)]
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end

            local veh = CreateVehicle(model, spawnPos.x, spawnPos.y, spawnPos.z, GetEntityHeading(target), true, true)
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
    while alive() do
        local target = GetNearestPlayerPed(GetEntityCoords(PlayerPedId()))
        local targetPos = GetEntityCoords(target, false)
        local wh = GetHashKey("a_c_humpback")
        RequestModel(wh)
        while not HasModelLoaded(wh) do Citizen.Wait(0) end
        local pos = vector3(
            targetPos.x + math.random(-100, 100),
            targetPos.y + math.random(-100, 100),
            targetPos.z + math.random(50, 100)
        )
        local whale = CreatePed(28, wh, pos.x, pos.y, pos.z, 0.0, true, false)
        RetargetSpawnedPed(whale, 1000)
        SetPedToRagdoll(whale, 5000, 5000, 0, true, true, false)
        SetPedAsNoLongerNeeded(whale)
        SetModelAsNoLongerNeeded(wh)
        Citizen.Wait(750)
    end
end

-- sync_mode: SPAWN_SINGLE
function FX_MiscWitnessProtection(alive)
    local orbitingPeds = {}
    local pedCount = 20
    while alive() do
        local target = GetNearestPlayerPed(GetEntityCoords(PlayerPedId()))
        local player = target
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
                RetargetSpawnedPed(ped, 1000)
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
