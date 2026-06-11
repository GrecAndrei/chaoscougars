-- sync_mode: LOCAL
function FX_PlayerRagdollondmg(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if HasEntityBeenDamagedByAnyPed(playerPed) or HasEntityBeenDamagedByAnyVehicle(playerPed) then
            ClearEntityLastDamageEntity(playerPed)
            SetPedToRagdoll(playerPed, 750, 750, 0, true, true, false)
        end
        Citizen.Wait(100)
    end
end

-- sync_mode: LOCAL
function FX_PlayerRandclothes(alive)
    local playerPed = PlayerPedId()
    for i = 0, 11 do
        local drawableAmount = GetNumberOfPedDrawableVariations(playerPed, i)
        local drawable = drawableAmount > 0 and math.random(0, drawableAmount - 1) or 0
        local textureAmount = GetNumberOfPedTextureVariations(playerPed, i, drawable)
        local texture = textureAmount > 0 and math.random(0, textureAmount - 1) or 0
        SetPedComponentVariation(playerPed, i, drawable, texture, math.random(0, 3))
    end
end

-- sync_mode: LOCAL
function FX_PlayerTpStunt(alive)
    local playerPed = PlayerPedId()
    local loc = allPossibleJumps[math.random(1, #allPossibleJumps)]

    DoScreenFadeOut(50)
    Citizen.Wait(50)
    SetEntityCoordsNoOffset(playerPed, loc.x, loc.y, loc.z, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)

    local veh
    if not IsPedInAnyVehicle(playerPed, false) then
        local batiHash = GetHashKey("bati")
        RequestModel(batiHash)
        while not HasModelLoaded(batiHash) do
            Citizen.Wait(0)
        end
        local pos = GetEntityCoords(playerPed, false)
        local heading = GetEntityHeading(playerPed)
        veh = CreateVehicle(batiHash, pos.x, pos.y, pos.z, heading, true, false)
        SetModelAsNoLongerNeeded(batiHash)
        SetPedIntoVehicle(playerPed, veh, -1)
    else
        veh = GetVehiclePedIsIn(playerPed, false)
    end

    SetEntityVelocity(veh, 0.0, 0.0, 0.0)
    SetEntityRotation(veh, 0.0, 0.0, loc.rotation, 2, true)
    SetVehicleForwardSpeed(veh, loc.speed)
end

-- sync_mode: LOCAL
function FX_VehRandomseat(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    local maxSeats = GetVehicleModelNumberOfSeats(GetEntityModel(playerVeh))
    local seats = {}
    for i = -1, maxSeats - 2 do
        if IsVehicleSeatFree(playerVeh, i, false) then
            table.insert(seats, i)
        end
    end
    if #seats > 0 then
        SetPedIntoVehicle(playerPed, playerVeh, seats[math.random(#seats)])
    end
end

-- sync_mode: LOCAL
function FX_PlayerRapidFire(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPlayerFreeAiming(PlayerId()) then
            local weaponHash = GetSelectedPedWeapon(playerPed)
            if weaponHash ~= GetHashKey("WEAPON_UNARMED") then
                local camCoords = GetGameplayCamCoord()
                local targPos = camCoords + vector3(
                    math.sin(GetGameplayCamRot(2).z * math.pi/180) * -1,
                    math.cos(GetGameplayCamRot(2).z * math.pi/180) * -1,
                    math.sin(GetGameplayCamRot(2).x * math.pi/180)
                ) * 500.0
                ShootSingleBulletBetweenCoords(camCoords.x, camCoords.y, camCoords.z,
                    targPos.x, targPos.y, targPos.z, 5, true, weaponHash, playerPed, true, false, 1.0)
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerRocket(alive)
    local playerPed = PlayerPedId()
    local parachuteHash = GetHashKey("GADGET_PARACHUTE")
    ClearPedTasksImmediately(playerPed)
    SetPedToRagdoll(playerPed, 10000, 10000, 0, true, true, false)
    GiveWeaponToPed(playerPed, parachuteHash, 1, true, false)
    local lastTimestamp = GetGameTimer()
    local launchTimer = 5000
    local beepTimer = 5000
    while true do
        SetEntityInvincible(playerPed, true)
        local curTimestamp = GetGameTimer()
        launchTimer = launchTimer - (curTimestamp - lastTimestamp)
        lastTimestamp = curTimestamp
        if launchTimer < beepTimer then
            beepTimer = beepTimer * 0.8
            UseParticleFxAsset("core")
            PlaySoundFromEntity(-1, "Beep_Red", playerPed, "DLC_HEIST_HACKING_SNAKE_SOUNDS", true, false)
            StartParticleFxLoopedOnEntity("exp_air_molotov", playerPed, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, false, false, false)
            SetEntityVelocity(playerPed, 0.0, 0.0, 5.0)
            if launchTimer <= 0 then
                SetEntityHealth(playerPed, 0)
                AddExplosion(
                    GetEntityCoords(playerPed).x, GetEntityCoords(playerPed).y, GetEntityCoords(playerPed).z,
                    9, 100.0, true, false, 3.0, false
                )
                break
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerTpclosestveh(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    local closestVeh = 0
    local closestDist = 9999.0
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) and veh ~= playerVeh then
            local vehPos = GetEntityCoords(veh, false)
            local dist = #(vehPos - playerPos)
            if dist < closestDist then
                closestVeh = veh
                closestDist = dist
            end
        end
    end)
    if closestVeh ~= 0 and IsVehicleSeatFree(closestVeh, -1, false) then
        SetPedIntoVehicle(playerPed, closestVeh, -1)
    end
end

-- sync_mode: LOCAL
function FX_PlayerSetintorandveh(alive)
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    local vehs = {}
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) and veh ~= playerVeh and IsVehicleSeatFree(veh, -1, false) then
            table.insert(vehs, veh)
        end
    end)
    if #vehs > 0 then
        SetPedIntoVehicle(playerPed, vehs[math.random(#vehs)], -1)
    end
end

-- sync_mode: LOCAL
function FX_PlayerSimeonsays(alive)
    local actions = {
        {name = "Jump", control = 22},
        {name = "Aim", control = 25},
        {name = "Attack", control = 24},
        {name = "Sprint", control = 21},
        {name = "Duck", control = 36},
        {name = "Reload", control = 45},
    }
    local action = actions[math.random(#actions)]
    local opposite = math.random(0, 1) == 1
    local displayName = (opposite and "DON'T " or "") .. action.name .. "!"
    local lastTime = 0
    local waitTime = 2000
    local dead = false
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(displayName)
    EndTextCommandThefeedPostTicker(false, false)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedDeadOrDying(playerPed, true) then
            if not dead then
                dead = true
                BeginTextCommandThefeedPost("STRING")
                AddTextComponentSubstringPlayerName("FAILED: You died!")
                EndTextCommandThefeedPostTicker(true, true)
            end
            Citizen.Wait(100)
        else
            local curTime = GetGameTimer()
            if curTime - lastTime > waitTime then
                BeginTextCommandThefeedPost("STRING")
                AddTextComponentSubstringPlayerName("FAILED: Time's up!")
                EndTextCommandThefeedPostTicker(true, true)
                SetEntityHealth(playerPed, 0)
                break
            end
            if IsControlJustPressed(0, action.control) then
                if not opposite then
                    BeginTextCommandThefeedPost("STRING")
                    AddTextComponentSubstringPlayerName("PASSED: Good job!")
                    EndTextCommandThefeedPostTicker(false, false)
                    break
                else
                    BeginTextCommandThefeedPost("STRING")
                    AddTextComponentSubstringPlayerName("FAILED: I said DON'T " .. action.name .. "!")
                    EndTextCommandThefeedPostTicker(true, true)
                    SetEntityHealth(playerPed, 0)
                    break
                end
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerSuicide(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) and IsPedOnFoot(playerPed)
    and GetPedParachuteState(playerPed) == -1 then
        RequestAnimDict("mp_suicide")
        while not HasAnimDictLoaded("mp_suicide") do
            Citizen.Wait(0)
        end
        local pistolHash = GetHashKey("WEAPON_PISTOL")
        GiveWeaponToPed(playerPed, pistolHash, 1, true, true)
        TaskPlayAnim(playerPed, "mp_suicide", "pistol", 8.0, -1.0, 800, 1, 0.0, false, false, false)
        Citizen.Wait(750)
        SetPedShootsAtCoord(playerPed, 0.0, 0.0, 0.0, true)
        RemoveAnimDict("mp_suicide")
    end
    SetEntityHealth(playerPed, 0)
end

-- sync_mode: LOCAL
function FX_PlayerSuperrun(alive)
    local playerId = PlayerId()
    while alive() do
        SetRunSprintMultiplierForPlayer(playerId, 1.49)
        SetSuperJumpThisFrame(playerId)
        Citizen.Wait(0)
    end
    SetRunSprintMultiplierForPlayer(playerId, 1.0)
end

-- sync_mode: LOCAL
function FX_TpLsairport(alive)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(50)
    Citizen.Wait(50)
    SetEntityCoordsNoOffset(playerPed, -1388.6, -3111.61, 13.94, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)
end

-- sync_mode: LOCAL
function FX_TpMazebank(alive)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(50)
    Citizen.Wait(50)
    SetEntityCoordsNoOffset(playerPed, -75.7, -818.62, 326.16, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)
end

-- sync_mode: LOCAL
function FX_TpFortzancudo(alive)
    SetEntityCoords(PlayerPedId(), -2050.0, 3200.0, 35.0, false, false, false, true)
end

-- sync_mode: LOCAL
function FX_TpMountchilliad(alive)
    SetEntityCoords(PlayerPedId(), 450.0, 5600.0, 800.0, false, false, false, true)
end

-- sync_mode: LOCAL
function FX_TpSkyfall(alive)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(100)
    Citizen.Wait(100)
    SetEntityCoordsNoOffset(playerPed, 935.0, 3800.0, 2300.0, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)
end

-- sync_mode: LOCAL
function FX_PlayerTptowaypoint(alive)
    local waypoint = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypoint) then
        local coords = GetBlipInfoIdCoord(waypoint)
        local _, z = GetGroundZFor3dCoord(coords.x, coords.y, 500.0, 0.0, false, false)
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, z + 5.0, false, false, false, true)
    end
end

-- sync_mode: LOCAL
function FX_PlayerTptowaypointopposite(alive)
    local waypoint = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypoint) then
        local coords = GetBlipInfoIdCoord(waypoint)
        local playerPos = GetEntityCoords(PlayerPedId(), false)
        local opposite = vector3(
            playerPos.x + (playerPos.x - coords.x),
            playerPos.y + (playerPos.y - coords.y),
            coords.z
        )
        local _, z = GetGroundZFor3dCoord(opposite.x, opposite.y, 500.0, 0.0, false, false)
        SetEntityCoords(PlayerPedId(), opposite.x, opposite.y, z + 5.0, false, false, false, true)
    end
end

-- sync_mode: LOCAL
function FX_PlayerTpfront(alive)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped, false)
    local heading = GetEntityHeading(ped)
    local x = coords.x + math.sin(math.rad(heading)) * -50
    local y = coords.y + math.cos(math.rad(heading)) * -50
    local _, z = GetGroundZFor3dCoord(x, y, 500.0, 0.0, false, false)
    SetEntityCoords(ped, x, y, z + 5.0, false, false, false, true)
end

-- sync_mode: LOCAL
function FX_TpRandom(alive)
    local x = math.random(-3000, 3000) + 0.0
    local y = math.random(-3000, 3000) + 0.0
    local _, z = GetGroundZFor3dCoord(x, y, 500.0, 0.0, false, false)
    SetEntityCoords(PlayerPedId(), x, y, z + 5.0, false, false, false, true)
end

-- sync_mode: LOCAL
function FX_TpMission(alive)
    local playerPed = PlayerPedId()
    local blips = {}
    for _, blip in ipairs({GetFirstBlipInfoId(1)}) do
        -- mission blips
    end
    local x = math.random(-500, 500) + 0.0
    local y = math.random(-500, 500) + 0.0
    local _, z = GetGroundZFor3dCoord(x, y, 500.0, 0.0, false, false)
    SetEntityCoords(playerPed, x, y, z + 5.0, false, false, false, true)
end

-- sync_mode: LOCAL
function FX_TpFake(alive)
    -- Hooks::EnableScriptThreadBlock
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)

    local fakeTpTypes = {
        { id = "tp_lsairport", coords = vector3(-1388.6, -3111.61, 13.94) },
        { id = "tp_mazebanktower", coords = vector3(-75.7, -818.62, 326.16) },
        { id = "tp_skyfall", coords = vector3(935.0, 3800.0, 2300.0) },
        { id = "player_tp_store" },
        { id = "tp_random" }
    }

    local chosen = fakeTpTypes[math.random(1, #fakeTpTypes)]
    -- CurrentEffect::OverrideEffectNameFromId

    DoScreenFadeOut(100)
    Citizen.Wait(100)
    if chosen.coords then
        SetEntityCoordsNoOffset(playerPed, chosen.coords.x, chosen.coords.y, chosen.coords.z, false, false, false)
    elseif chosen.id == "player_tp_store" then
        local stores = {
            vector3(372.29, 326.39, 103.57),
            vector3(-1487.29, -376.92, 40.16),
            vector3(810.94, -2157.19, 29.62),
            vector3(72.3, -1399.1, 28.4)
        }
        SetEntityCoordsNoOffset(playerPed, stores[math.random(1, #stores)].x, stores[math.random(1, #stores)].y, stores[math.random(1, #stores)].z, false, false, false)
    else
        local randX = (math.random() * 8000.0) - 4000.0
        local randY = (math.random() * 12000.0) - 4000.0
        SetEntityCoordsNoOffset(playerPed, randX, randY, 500.0, false, false, false)
    end
    Citizen.Wait(0)
    DoScreenFadeIn(200)

    Citizen.Wait(math.random(3500, 6000))

    DoScreenFadeOut(100)
    Citizen.Wait(100)
    SetEntityCoordsNoOffset(playerPed, playerPos.x, playerPos.y, playerPos.z, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)

    -- Hooks::DisableScriptThreadBlock
end

-- sync_mode: LOCAL
function FX_TpFakex2(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)

    DoScreenFadeOut(100)
    Citizen.Wait(100)
    SetEntityCoordsNoOffset(playerPed, 935.0, 3800.0, 2300.0, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)

    Citizen.Wait(math.random(3500, 6000))

    -- Now fake-teleport back to a different fake destination
    local fakeDest = vector3(-75.7, -818.62, 326.16)
    DoScreenFadeOut(100)
    Citizen.Wait(100)
    SetEntityCoordsNoOffset(playerPed, fakeDest.x, fakeDest.y, fakeDest.z, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)

    -- CurrentEffect::OverrideEffectNameFromId
    Citizen.Wait(math.random(3500, 6000))

    DoScreenFadeOut(100)
    Citizen.Wait(100)
    SetEntityCoordsNoOffset(playerPed, playerPos.x, playerPos.y, playerPos.z, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayerTpeverything(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if DoesEntityExist(ped) then
            SetEntityCoords(ped, playerPos.x + math.random(-3, 3), playerPos.y + math.random(-3, 3), playerPos.z, false, false, false, true)
        end
    end)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) and not IsPedInVehicle(playerPed, veh, false) then
            SetEntityCoords(veh, playerPos.x + math.random(-5, 5), playerPos.y + math.random(-5, 5), playerPos.z + 3.0, false, false, false, true)
        end
    end)
end

-- sync_mode: LOCAL
function FX_PlayerTpToEverything(alive)
    while alive() do
        local allEntities = {}
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) then
                table.insert(allEntities, ped)
            end
        end)
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                table.insert(allEntities, veh)
            end
        end)
        if #allEntities > 0 then
            local target = allEntities[math.random(#allEntities)]
            local coords = GetEntityCoords(target, false)
            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z + 2.0, false, false, false, true)
        end
        Citizen.Wait(3000)
    end
end

-- sync_mode: LOCAL
function FX_PlayerTpStore(alive)
    local playerPed = PlayerPedId()
    local loc = allPossibleStores[math.random(1, #allPossibleStores)]
    DoScreenFadeOut(50)
    Citizen.Wait(50)
    SetEntityCoordsNoOffset(playerPed, loc.x, loc.y, loc.z, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)
end

-- sync_mode: LOCAL
function FX_PlayerVr(alive)
    local playerPed = PlayerPedId()
    local heading = GetEntityHeading(playerPed)
    local coords = GetEntityCoords(playerPed, true)
    local rot = GetEntityRotation(playerPed, 0)
    local pedType = GetPedType(playerPed)
    local model = GetEntityModel(playerPed)
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end
    local clone = CreatePed(pedType, model, coords.x, coords.y, coords.z, heading, true, false)
    ClonePedToTarget(playerPed, clone)
    local _, groundZ = GetGroundZFor3dCoord(coords.x, coords.y, coords.z, 0.0, false, false)
    local cloneVeh = nil
    if IsPedInAnyVehicle(playerPed, false) then
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        local vehModel = GetEntityModel(playerVeh)
        RequestModel(vehModel)
        while not HasModelLoaded(vehModel) do Citizen.Wait(0) end
        local vehCoords = GetEntityCoords(playerVeh, false)
        cloneVeh = CreateVehicle(vehModel, vehCoords.x, vehCoords.y, vehCoords.z + 1.0, GetEntityHeading(playerVeh), true, false)
        SetPedIntoVehicle(clone, cloneVeh, -1)
        SetVehicleEngineOn(cloneVeh, GetIsVehicleEngineRunning(playerVeh), true, false)
        SetVehicleForwardSpeed(cloneVeh, GetEntitySpeed(playerVeh))
        local vel = GetEntityVelocity(playerVeh)
        SetEntityVelocity(cloneVeh, vel.x, vel.y, vel.z)
        SetModelAsNoLongerNeeded(vehModel)
    end
    SetModelAsNoLongerNeeded(model)
    while alive() do
        local targetHeading = GetEntityHeading(playerPed)
        heading = heading + (targetHeading - heading) * 0.15
        SetEntityHeading(clone, heading)
        local targCoords = GetEntityCoords(playerPed, true)
        local _, gz = GetGroundZFor3dCoord(targCoords.x, targCoords.y, targCoords.z, 0.0, false, false)
        coords = vector3(
            coords.x + (targCoords.x - coords.x) * 0.15,
            coords.y + (targCoords.y - coords.y) * 0.15,
            coords.z + (groundZ - coords.z) * 0.15
        )
        SetEntityCoords(clone, coords.x, coords.y, coords.z, true, false, false, true)
        Citizen.Wait(0)
    end
    if DoesEntityExist(clone) then DeleteEntity(clone) end
    if cloneVeh and DoesEntityExist(cloneVeh) then DeleteVehicle(cloneVeh) end
end

-- sync_mode: LOCAL
function FX_PlayerWalkonwater(alive)
    local waterObj = 0
    local displayHash = GetHashKey("prop_huge_display_01")
    while alive() do
        local playerPed = PlayerPedId()
        local playerCoord = GetEntityCoords(playerPed, true)
        RequestModel(displayHash)
        while not HasModelLoaded(displayHash) do Citizen.Wait(0) end
        if not DoesEntityExist(waterObj) then
            waterObj = CreateObject(displayHash, playerCoord.x, playerCoord.y, playerCoord.z - 0.5, true, true, true)
            SetEntityRotation(waterObj, 90.0, 0.0, 0.0, 2, true)
            FreezeEntityPosition(waterObj, true)
            SetEntityVisible(waterObj, false, false)
        else
            SetEntityCoords(waterObj, playerCoord.x, playerCoord.y, playerCoord.z - 0.5, true, false, false, true)
        end
        SetModelAsNoLongerNeeded(displayHash)
        Citizen.Wait(0)
    end
    if DoesEntityExist(waterObj) then DeleteObject(waterObj) end
end

-- sync_mode: LOCAL
function FX_Player5stars(alive)
    SetPlayerWantedLevel(PlayerId(), 5, false)
    SetPlayerWantedLevelNow(PlayerId(), false)
end

-- sync_mode: LOCAL
function FX_PlayerPlus2stars(alive)
    local player = PlayerId()
    local wantedLevel = GetPlayerWantedLevel(player)
    SetPlayerWantedLevel(player, wantedLevel + 2, false)
    SetPlayerWantedLevelNow(player, false)
end

-- sync_mode: LOCAL
function FX_PlayerNeverwanted(alive)
    while alive() do
        SetPlayerWantedLevel(PlayerId(), 0, false)
        SetPlayerWantedLevelNow(PlayerId(), true)
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_Player3stars(alive)
    SetPlayerWantedLevel(PlayerId(), 3, false)
    SetPlayerWantedLevelNow(PlayerId(), false)
end

-- sync_mode: LOCAL
function FX_Player1star(alive)
    SetPlayerWantedLevel(PlayerId(), 1, false)
    SetPlayerWantedLevelNow(PlayerId(), false)
end

-- sync_mode: VISUAL
function FX_PlayerFakestars(alive)
    SetFakeWantedLevel(5)
    Citizen.Wait(5000)
    SetFakeWantedLevel(0)
end

-- sync_mode: LOCAL
function FX_PlayerAllweps(alive)
    local ped = PlayerPedId()
    local weapons = {
        GetHashKey("WEAPON_PISTOL"), GetHashKey("WEAPON_SMG"), GetHashKey("WEAPON_ASSAULTRIFLE"),
        GetHashKey("WEAPON_PUMPSHOTGUN"), GetHashKey("WEAPON_SNIPERRIFLE"), GetHashKey("WEAPON_RPG"),
        GetHashKey("WEAPON_GRENADE"), GetHashKey("WEAPON_MOLOTOV"), GetHashKey("WEAPON_MINIGUN"),
        GetHashKey("WEAPON_COMBATMG"), GetHashKey("WEAPON_STICKYBOMB"), GetHashKey("WEAPON_RAILGUN"),
    }
    for _, weapon in ipairs(weapons) do
        GiveWeaponToPed(ped, weapon, 999, false, false)
    end
end

-- sync_mode: VISUAL
function FX_PlayerZoomzoomCam(alive)
    zoomCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    RenderScriptCams(true, true, 10, true, true)

    while alive() do
        local curTick = GetGameTimer()
        camZoom = math.sin(curTick * camZoomRate) * zoomMultiplier + zoomMidpoint
        SetCamActive(zoomCamera, true)
        local coord = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        SetCamParams(zoomCamera, coord.x, coord.y, coord.z, rot.x, rot.y, rot.z, camZoom, 0, 1, 1, 2)
        Citizen.Wait(0)
    end

    SetCamActive(zoomCamera, false)
    RenderScriptCams(false, true, 700, true, true)
    DestroyCam(zoomCamera, true)
    zoomCamera = 0
end

-- sync_mode: VISUAL
function FX_PlayerBinoculars(alive)
    fovCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    RenderScriptCams(true, true, 700, true, true)

    while alive() do
        SetCamActive(fovCamera, true)
        local coord = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        SetCamParams(fovCamera, coord.x, coord.y, coord.z, rot.x, rot.y, rot.z, 10.0, 0, 1, 1, 2)
        Citizen.Wait(0)
    end

    SetCamActive(fovCamera, false)
    RenderScriptCams(false, true, 700, true, true)
    DestroyCam(fovCamera, true)
    fovCamera = 0
end

-- sync_mode: VISUAL
function FX_ScreenBouncyradar(alive)
    while alive() do
        ShakeGameplayCam("HAND_SHAKE", 0.5)
        Citizen.Wait(0)
    end
    StopGameplayCamShaking(true)
end

-- sync_mode: VISUAL
function FX_MiscDvdscreensaver(alive)
    while alive() do
        SetTimecycleModifier("scanline_cam_cheap")
        SetTimecycleModifierStrength(0.5)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_PlayerFlipCamera(alive)
    flippedCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    RenderScriptCams(true, true, 700, true, true)

    while alive() do
        SetCamActive(flippedCamera, true)
        local coord = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        local fov = GetGameplayCamFov()
        SetCamParams(flippedCamera, coord.x, coord.y, coord.z, rot.x, 180.0, rot.z, fov, 700, 0, 0, 2)
        Citizen.Wait(0)
    end

    SetCamActive(flippedCamera, false)
    RenderScriptCams(false, true, 700, true, true)
    DestroyCam(flippedCamera, true)
    flippedCamera = 0
end

-- sync_mode: VISUAL
function FX_MiscFlipUi(alive)
    while alive() do
        SetTimecycleModifier("CAMERA_BW")
        SetTimecycleModifierStrength(0.5)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_PlayerHeatvision(alive)
    while alive() do
        SetSeethrough(true)
        Citizen.Wait(0)
    end
    SetSeethrough(false)
end

-- sync_mode: VISUAL
function FX_ScreenMaximap(alive)
    while alive() do
        -- Memory::MultiplyRadarSize(5.4, 0.1)
        Citizen.Wait(100)
    end
    -- Memory::ResetRadar
end

-- sync_mode: VISUAL
function FX_PlayerNightvision(alive)
    while alive() do
        SetNightvision(true)
        Citizen.Wait(0)
    end
    SetNightvision(false)
end

-- sync_mode: VISUAL
function FX_NoHud(alive)
    while alive() do
        HideHudAndRadarThisFrame()
        DisableControlAction(0, 199, true)
        DisableControlAction(0, 200, true)
        Citizen.Wait(0)
    end
end

-- sync_mode: VISUAL
function FX_NoRadar(alive)
    while alive() do
        DisplayRadar(false)
        DisableControlAction(0, 199, true)
        DisableControlAction(0, 200, true)
        Citizen.Wait(0)
    end
    DisplayRadar(true)
end

-- sync_mode: VISUAL
function FX_PlayerOnDemandCartoon(alive)
    local playlist = TV_PLAYLISTS[math.random(1, #TV_PLAYLISTS)]
    SetTvChannelPlaylistAtHour(0, playlist, math.random(0, 23))
    SetTvAudioFrontend(true)
    SetTvVolume(1.0)
    AttachTvAudioToEntity(PlayerPedId())
    SetTvChannel(0)
    EnableMovieSubtitles(true)
    ms_PosX = (math.random() * 0.4) + 0.3
    ms_PosY = (math.random() * 0.4) + 0.3

    while alive() do
        SetScriptGfxDrawOrder(4)
        SetScriptGfxDrawBehindPausemenu(true)
        DrawTvChannel(ms_PosX, ms_PosY, 0.3, 0.3, 0.0, 255, 255, 255, 255)
        Citizen.Wait(0)
    end

    SetTvChannel(-1)
    SetTvChannelPlaylist(0, "", false)
    EnableMovieSubtitles(false)
end

-- sync_mode: VISUAL
function FX_PlayerQuakeFov(alive)
    fovCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    RenderScriptCams(true, true, 700, true, true)

    while alive() do
        SetCamActive(fovCamera, true)
        local coord = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        SetCamParams(fovCamera, coord.x, coord.y, coord.z, rot.x, rot.y, rot.z, 120.0, 0, 1, 1, 2)
        Citizen.Wait(0)
    end

    SetCamActive(fovCamera, false)
    RenderScriptCams(false, true, 700, true, true)
    DestroyCam(fovCamera, true)
    fovCamera = 0
end

-- sync_mode: VISUAL
function FX_ScreenRealfp(alive)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    AttachCamToEntity(cam, PlayerPedId(), 0.0, 0.0, 0.65, true)
    SetCamFov(cam, 90.0)
    RenderScriptCams(true, true, 500, true, true)
    SetCamActive(cam, true)
    while alive() do
        Citizen.Wait(0)
    end
    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(cam, true)
end

-- sync_mode: VISUAL
function FX_PlayerSickCam(alive)
    local sickCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    RenderScriptCams(true, true, 10, 1, 1, 1)
    local camZoom = 80.0
    local camZoomRate = 0.4
    local camRotX = 0.0
    local camRotXRate = 0.4
    local camRotY = 0.0
    local camRotYRate = 0.6
    while alive() do
        camZoom = camZoom + camZoomRate
        if camZoom > 120 or camZoom < 40 then camZoomRate = -camZoomRate end
        camRotX = camRotX + camRotXRate
        if camRotX > 10 or camRotX < -10 then camRotXRate = -camRotXRate end
        camRotY = camRotY + camRotYRate
        if camRotY > 15 or camRotY < -15 then camRotYRate = -camRotYRate end
        SetCamParams(sickCamera, GetEntityCoords(PlayerPedId()).x, GetEntityCoords(PlayerPedId()).y,
            GetEntityCoords(PlayerPedId()).z, camRotX, camRotY, GetEntityHeading(PlayerPedId()), camZoom, 0, 0, 1, 2)
        SetCamActive(sickCamera, true)
        Citizen.Wait(0)
    end
    SetCamActive(sickCamera, false)
    RenderScriptCams(false, true, 700, 1, 1, 1)
    DestroyCam(sickCamera, true)
end
