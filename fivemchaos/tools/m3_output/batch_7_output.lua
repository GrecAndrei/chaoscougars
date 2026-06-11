-- sync_mode: SPAWN_SINGLE
function FX_SpawnRandom(alive)
    local spawns = {
        {model = "adder", name = "Adder"},
        {model = "zentorno", name = "Zentorno"},
        {model = "t20", name = "T20"},
        {model = "akuma", name = "Akuma"},
        {model = "buzzard", name = "Buzzard"},
        {model = "hydra", name = "Hydra"},
        {model = "insurgent", name = "Insurgent"},
        {model = "kuruma", name = "Kuruma"},
    }
    local pick = spawns[math.random(#spawns)]
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey(pick.model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x + 5.0, playerPos.y, playerPos.z, heading, true, false)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnBaletrailer(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("baletrailer")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnRomero(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("romero")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_VehsSpawnWizardBroom(alive)
    local player = PlayerPedId()
    local oppressorHash = GetHashKey("oppressor2")
    local broomHash = GetHashKey("prop_tool_broom")

    RequestModel(oppressorHash)
    RequestModel(broomHash)
    while not HasModelLoaded(oppressorHash) or not HasModelLoaded(broomHash) do Citizen.Wait(0) end

    local playerPos = GetOffsetFromEntityInWorldCoords(player, 0, 1, 0)

    local veh = CreateVehicle(oppressorHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(player), true, true)
    SetModelAsNoLongerNeeded(oppressorHash)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleModKit(veh, 0)
    for i = 0, 49 do
        local max = GetNumVehicleMods(veh, i)
        SetVehicleMod(veh, i, max > 0 and max - 1 or 0, false)
    end
    SetEntityAlpha(veh, 0, false)
    SetEntityVisible(veh, false, false)

    local broom = CreateObject(broomHash, playerPos.x, playerPos.y + 2, playerPos.z, true, false, false)
    SetModelAsNoLongerNeeded(broomHash)
    AttachEntityToEntity(broom, veh, 0, 0, 0, 0.3, -80.0, 0, 0, true, false, false, false, 0, true)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnBluesultan(alive)
    local playerPed = PlayerPedId()
    local playerHeading = GetEntityHeading(playerPed)

    local heading
    if IsPedInAnyVehicle(playerPed, false) then
        heading = GetEntityHeading(GetVehiclePedIsIn(playerPed, false))
    else
        heading = playerHeading
    end

    local playerPos = GetEntityCoords(playerPed, false)

    local sultanHash = GetHashKey("sultanrs")
    RequestModel(sultanHash)
    while not HasModelLoaded(sultanHash) do Citizen.Wait(0) end

    local veh = CreateVehicle(sultanHash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(sultanHash)
    SetVehicleColours(veh, 64, 64)
    SetVehicleEngineOn(veh, true, true, false)

    local playerGroup = GetHashKey("PLAYER")

    local relationshipGroup
    AddRelationshipGroup("_HOSTILE_IESULTAN", relationshipGroup)
    SetRelationshipBetweenGroups(5, relationshipGroup, playerGroup)
    SetRelationshipBetweenGroups(5, playerGroup, relationshipGroup)
    SetRelationshipBetweenGroups(0, relationshipGroup, relationshipGroup)

    local pedModel = GetHashKey("g_m_m_armboss_01")
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do Citizen.Wait(0) end

    local weaponHash = GetHashKey("WEAPON_MICROSMG")

    local ped = CreatePedInsideVehicle(veh, 4, pedModel, -1, true, false)
    SetPedCombatAttributes(ped, 3, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedRelationshipGroupHash(ped, relationshipGroup)
    SetPedHearingRange(ped, 9999.0)
    GiveWeaponToPed(ped, weaponHash, 9999, true, true)
    SetPedAccuracy(ped, 50)
    TaskCombatPed(ped, GetNearestPlayerPed(GetEntityCoords(ped)), 0, 16)
    RetargetSpawnedPed(ped, 2000)

    Citizen.Wait(0)

    ped = CreatePedInsideVehicle(veh, 4, pedModel, 0, true, false)
    SetModelAsNoLongerNeeded(pedModel)
    SetPedCombatAttributes(ped, 3, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedRelationshipGroupHash(ped, relationshipGroup)
    SetPedHearingRange(ped, 9999.0)
    GiveWeaponToPed(ped, weaponHash, 9999, true, true)
    SetPedAccuracy(ped, 50)
    TaskCombatPed(ped, GetNearestPlayerPed(GetEntityCoords(ped)), 0, 16)
    RetargetSpawnedPed(ped, 2000)
end

-- sync_mode: LOCAL
function FX_VehSpeedGoal(alive)
    local ms_Overlay = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
    while not HasScaleformMovieLoaded(ms_Overlay) do Citizen.Wait(0) end
    local ms_EnteredVehicle = false
    local ms_LastVeh = 0
    local ms_TimeReserve = 10000
    local ms_LastTick = 0
    while alive() do
        local playerPed = PlayerPedId()
        local veh = GetVehiclePedIsIn(playerPed, false)
        if ms_LastVeh ~= 0 and (veh ~= ms_LastVeh or not IsPedInAnyVehicle(playerPed, false)) then
            ExplodeVehicle(ms_LastVeh, true, false)
            ms_TimeReserve = 10000
        end
        ms_LastVeh = veh
        local currentTick = GetGameTimer()
        if currentTick - ms_LastTick > 100 then
            ms_LastTick = currentTick
            local speed = GetEntitySpeed(veh)
            if speed > 20.0 and ms_TimeReserve > 0 then
                ms_TimeReserve = ms_TimeReserve - 100
            end
            if ms_TimeReserve <= 0 and veh ~= 0 then
                ExplodeVehicle(veh, true, false)
            end
        end
        Citizen.Wait(0)
    end
    SetScaleformMovieAsNoLongerNeeded(ms_Overlay)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsTiny(alive)
    local vehicleDefaultSizes = {}
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                local vehModel = GetEntityModel(veh)
                if not IsThisModelABike(vehModel) and not IsThisModelABicycle(vehModel) then
                    local rightVector, forwardVector, upVector, position = GetEntityMatrix(veh)
                    local size = vector3(#rightVector, #forwardVector, #upVector)
                    if not vehicleDefaultSizes[veh] then
                        vehicleDefaultSizes[veh] = size
                    end
                end
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsPoptiresconstant(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            for i = 0, 7 do
                SetVehicleTyresCanBurst(veh, true)
                SetVehicleTyreBurst(veh, i, true, 1000.0)
            end
        end)
        Citizen.Wait(400)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        for i = 0, 7 do
            SetVehicleTyreFixed(veh, i)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsAlarmloop(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                SetVehicleAlarm(veh, true)
                StartVehicleAlarm(veh)
            end
        end)
        Citizen.Wait(2000)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetVehicleAlarm(veh, false)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayervehMaxupgrades(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) then
            SetVehicleModKit(veh, 0)
            for i = 0, 49 do
                local max = GetNumVehicleMods(veh, i)
                if max > 0 then
                    SetVehicleMod(veh, i, max - 1, true)
                    ToggleVehicleMod(veh, i, true)
                end
            end
            SetVehicleTyresCanBurst(veh, false)
            SetVehicleWindowTint(veh, 1)
            SetVehicleCustomPrimaryColour(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
            SetVehicleCustomSecondaryColour(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
            for i = 0, 3 do
                SetVehicleNeonLightEnabled(veh, i, true)
            end
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayervehRandupgrades(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) then
            SetVehicleModKit(veh, 0)
            for i = 0, 49 do
                local max = GetNumVehicleMods(veh, i)
                if max > 0 then
                    SetVehicleMod(veh, i, math.random(0, max - 1), true)
                end
            end
        end
    end)
end

-- sync_mode: LOCAL
function FX_VehWeapons(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) and IsControlPressed(0, 69) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            local pos = GetEntityCoords(veh, false)
            local weaponHash = GetHashKey("WEAPON_AIRSTRIKE_ROCKET")
            if not HasWeaponAssetLoaded(weaponHash) then
                RequestWeaponAsset(weaponHash, 31, 0)
                while not HasWeaponAssetLoaded(weaponHash) do Citizen.Wait(0) end
            end
            local fwd = GetEntityForwardVector(veh)
            local targ = vector3(pos.x + fwd.x * 100.0, pos.y + fwd.y * 100.0, pos.z - 1.0)
            ShootSingleBulletBetweenCoords(pos.x, pos.y, pos.z + 0.35, targ.x, targ.y, targ.z, 500, true, weaponHash, playerPed, true, false, 1.0)
        end
        Citizen.Wait(1000)
    end
end

-- sync_mode: VISUAL
function FX_WeatherExtrasunny(alive)
    SetWeatherTypeNow("EXTRASUNNY")
end

-- sync_mode: VISUAL
function FX_WeatherStormy(alive)
    SetWeatherTypeNow("THUNDER")
end

-- sync_mode: VISUAL
function FX_WeatherFoggy(alive)
    SetWeatherTypeNow("FOGGY")
end

-- sync_mode: VISUAL
function FX_WeatherNeutral(alive)
    SetWeatherTypeNow("NEUTRAL")
end

-- sync_mode: VISUAL
function FX_WeatherSnowy(alive)
    SetWeatherTypeNow("XMAS")
end

-- sync_mode: VISUAL
function FX_WeatherRandomizer(alive)
    local weathers = {"CLEAR", "EXTRASUNNY", "CLOUDS", "OVERCAST", "RAIN", "THUNDER", "SMOG", "FOGGY", "XMAS", "SNOWLIGHT"}
    while alive() do
        SetWeatherTypeNowPersist(weathers[math.random(#weathers)])
        Citizen.Wait(3000)
    end
    ClearWeatherTypePersist()
end

-- sync_mode: VISUAL
function FX_WorldSnow(alive)
    while alive() do
        SetWeatherTypeNow("XMAS")
        Citizen.Wait(500)
    end
    SetWeatherTypeNow("EXTRASUNNY")
end
