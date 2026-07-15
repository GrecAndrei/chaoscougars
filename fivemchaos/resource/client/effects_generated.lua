--[[
    Helper functions used by FX_* effects below.
    These were originally emitted by tools/transpile_effects.py into a header
    file that was concatenated before the generated body. To make the resource
    self-contained (no build step required), the helpers are inlined here.
    Mirrors the definitions in tools/m3_output/header.lua.
]]

local _CHAOS_PED_MODELS = {
    "a_m_m_acult_01", "a_m_m_afriamer_01", "a_m_m_beach_02", "a_m_m_busicas_01",
    "a_m_m_farmer_01", "a_m_m_fatlatin_01", "a_m_m_hillbilly_02", "a_m_m_indian_01",
    "a_m_m_og_boss_01", "a_m_m_paparazzi_01", "a_m_m_rurmeth_01", "a_m_m_salton_04",
    "a_m_m_skater_01", "a_m_m_socenlat_01", "a_m_m_tourist_01", "a_m_o_acult_02",
    "a_m_o_beach_01", "a_m_o_salton_01", "a_m_y_acult_02", "a_m_y_beach_02",
    "a_m_y_beachvesp_02", "a_m_y_business_03", "a_m_y_cyclist_01", "a_m_y_eastsa_02",
    "a_m_y_genstreet_01", "a_m_y_genstreet_02", "a_m_y_hipster_01", "a_m_y_jetski_01",
    "a_m_y_mexthug_01", "a_m_y_motox_02", "a_m_y_musclbeac_01", "a_m_y_rurmeth_01",
    "a_m_y_salton_01", "a_m_y_skater_02", "a_m_y_stlat_01", "a_m_y_stwhi_02",
    "a_m_y_sunbathe_01", "a_m_y_surfer_01", "a_m_y_vindouche_01", "a_m_y_yoga_01",
    "a_f_m_beach_01", "a_f_m_fatcult_01", "a_f_m_salton_01", "a_f_m_skidrow_01",
    "a_f_m_tourist_01", "a_f_o_genstreet_01", "a_f_o_soucent_01", "a_f_y_beach_01",
    "a_f_y_hipster_01", "a_f_y_juggalo_01", "a_f_y_runner_01", "a_f_y_vinewood_04",
    "a_f_y_yoga_01", "s_m_m_autoshop_01", "s_m_m_bouncer_01", "s_m_m_chemsec_01",
    "s_m_m_ciasec_01", "s_m_m_dockwork_01", "s_m_m_highsec_01", "s_m_m_lifeinvad_01",
    "s_m_m_movprem_01", "s_m_m_pilot_02", "s_m_m_security_01", "s_m_m_ups_02",
    "s_m_y_airworker", "s_m_y_blackops_01", "s_m_y_construct_01", "s_m_y_fireman_01",
    "s_m_y_marine_01", "s_m_y_pilot_01", "s_m_y_prisoner_01",
}

local function _ChaosCreateRandomPed(x, y, z, heading)
    local modelName = _CHAOS_PED_MODELS[math.random(#_CHAOS_PED_MODELS)]
    local model = GetHashKey(modelName)
    RequestModel(model)
    local t = 20
    while not HasModelLoaded(model) and t > 0 do
        Citizen.Wait(50)
        t = t - 1
    end
    local ped = CreatePed(26, model, x, y, z, heading, true, false)
    SetModelAsNoLongerNeeded(model)
    return ped
end

local function _ChaosCreateHostilePed(model, weapon)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed, false)
    local ped = CreatePed(26, model, pos.x, pos.y, pos.z, GetEntityHeading(playerPed), true, false)
    if ped ~= 0 then
        SetPedAsEnemy(ped, true)
        if weapon and weapon ~= 0 then
            GiveWeaponToPed(ped, weapon, 9999, true, true)
        end
        SetPedCombatAttributes(ped, 5, true)
        SetPedCombatAttributes(ped, 46, true)
        local nearest = GetNearestPlayerPed(GetEntityCoords(ped)) or playerPed
        TaskCombatPed(ped, nearest, 0, 16)
        SetPedFiringPattern(ped, 0xC6EE6B4C)
    end
    return ped
end

-- 3-arg variant: spawn at a given position (used by FX_PedsHotcougars)
local function CreateHostilePed(model, weapon, pos)
    local ped = CreatePed(28, model, pos.x, pos.y, pos.z, math.random(0, 360) + 0.0, true, true)
    if ped ~= 0 then
        SetPedAsEnemy(ped, true)
        if weapon and weapon ~= 0 then
            GiveWeaponToPed(ped, weapon, 9999, true, true)
        end
        SetPedCombatAttributes(ped, 5, true)
        SetPedCombatAttributes(ped, 46, true)
        local nearest = GetNearestPlayerPed(GetEntityCoords(ped)) or PlayerPedId()
        TaskCombatPed(ped, nearest, 0, 16)
        SetPedFiringPattern(ped, 0xC6EE6B4C)
    end
    return ped
end

-- ===== Pool-clone helpers (used by FX_PedsCloneOnDeath) =====
-- Spawns a clone of a dead ped at the ped's position. Used by the
-- "clone on death" effect to replace a dead NPC/player with a clone.
local function CreatePoolClonePed(ped)
    if not ped or not DoesEntityExist(ped) then return 0 end
    local model = GetEntityModel(ped)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local clone = CreatePed(4, model, coords.x, coords.y, coords.z, heading, true, false)
    if clone ~= 0 then
        SetBlockingOfNonTemporaryEvents(clone, true)
        SetPedKeepTask(clone, true)
    end
    return clone
end

local function CreatePoolCloneVehicle(veh)
    if not veh or not DoesEntityExist(veh) then return 0 end
    local model = GetEntityModel(veh)
    local coords = GetEntityCoords(veh)
    local heading = GetEntityHeading(veh)
    local clone = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    if clone ~= 0 then
        SetVehicleOnGroundProperly(clone)
    end
    return clone
end

-- ===== Coord helper (used by orbital-cam and cougar-spawn effects) =====
-- Returns a vector3 around the entity at the given heading (degrees) and
-- distance. ground=true snaps to ground; use raw 0 otherwise.
local function GetCoordAround(entity, headingDeg, distance, zCorrection, ground)
    local pos = GetEntityCoords(entity)
    local rad = math.rad(headingDeg)
    local x = pos.x + math.cos(rad) * distance
    local y = pos.y + math.sin(rad) * distance
    local z = pos.z + (zCorrection or 0.0)
    if ground then
        local found, groundZ = GetGroundZFor_3dCoord(x, y, z + 50.0, false)
        if found then z = groundZ + 1.0 end
    end
    return vector3(x, y, z)
end

-- ===== Stunt-jump / store-teleport tables (used by FX_PlayerTpStunt, FX_PlayerTpStore) =====
-- A curated set of safe, well-known stunt-jump and 24/7-store teleport
-- locations. If empty, the effects that reference these no-op gracefully.
local allPossibleJumps = {
    vector3(  120.0,  1280.0,  95.0),  -- Vinewood sign approach
    vector3( -700.0, -1300.0,  20.0),  -- Airport ramp
    vector3(  -50.0,  1900.0, 200.0),  -- Grapeseed bridge
    vector3(  250.0,  -800.0,  85.0),  -- Eclipse towers
    vector3( -900.0,   600.0, 110.0),  -- Great Chaparral cliff
    vector3( 1500.0,  3700.0,  35.0),  -- Sandy Shores aqueduct
    vector3( 2000.0,  4500.0,  45.0),  -- Harmony billboard
    vector3( -500.0,  2800.0,  50.0),  -- Route 68 jump
}

local allPossibleStores = {
    vector3(  -50.0,  -1750.0,  29.0),  -- LTD Gasoline
    vector3(  255.0,   -45.0,  69.0),  -- Rob's Liquor
    vector3(-709.0,   -905.0,  19.0),  -- 24/7
    vector3( 373.0,   328.0,  103.0),  -- 24/7 Mirror Park
    vector3(-1222.0,  -906.0,  12.0),  -- 24/7 Inglewood
    vector3(-1487.0,  -375.0,  39.0),  -- LTD Richman Glen
    vector3(-2967.0,   391.0,  15.0),  -- LTD Banham Canyon
    vector3(  267.0,  -1261.0,  29.0),  -- Rob's Liquor Vespucci
    vector3(  1700.0,  4920.0,  42.0),  -- 24/7 Sandy Shores
    vector3( 1961.0,  3741.0,  32.0),  -- LTD Grapeseed
}

-- ===== TV playlist names (used by FX_PlayerOnDemandCartoon) =====
-- Standard GTA V TV channel playlist names. Random pick per effect run.
local TV_PLAYLISTS = {
    'PL_TV_STUDIO', 'PL_STD_W', 'PL_STD_CNT', 'PL_LO_CNT',
    'PL_LO_W', 'PL_SP_STUDIO', 'PL_MP_STUDIO', 'PL_SP_CNT',
    'PL_MP_CNT', 'PL_SP_W', 'PL_MP_W', 'PL_TNANAR',
}

-- sync_mode: META
function FX_MetaSpawnMultipleEffects(alive)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "additionalEffects", 2)
    while alive() do Citizen.Wait(250) end
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "additionalEffects", 0)
end

-- sync_mode: META
function FX_MetaEffectDuration05x(alive)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "durationModifier", 0.5)
    while alive() do Citizen.Wait(250) end
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "durationModifier", 1.0)
end

-- sync_mode: META
function FX_MetaEffectDuration2x(alive)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "durationModifier", 2.0)
    while alive() do Citizen.Wait(250) end
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "durationModifier", 1.0)
end

-- sync_mode: META
function FX_MetaHideChaosUi(alive)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "hideChaosUI", true)
    while alive() do Citizen.Wait(250) end
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "hideChaosUI", false)
end

-- sync_mode: META
function FX_MetaNochaos(alive)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "disableChaos", true)
    while alive() do Citizen.Wait(250) end
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "disableChaos", false)
end

-- sync_mode: META
function FX_MetaReInvoke(alive)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "additionalEffects", 1)
    Citizen.Wait(100)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "additionalEffects", 0)
end

-- sync_mode: META
function FX_MetaTimerspeed05x(alive)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "timerModifier", 0.5)
    while alive() do Citizen.Wait(250) end
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "timerModifier", 1.0)
end

-- sync_mode: META
function FX_MetaTimerspeed2x(alive)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "timerModifier", 2.0)
    while alive() do Citizen.Wait(250) end
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "timerModifier", 1.0)
end

-- sync_mode: META
function FX_MetaTimerspeed5x(alive)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "timerModifier", 5.0)
    while alive() do Citizen.Wait(250) end
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "timerModifier", 1.0)
end

-- sync_mode: META
function FX_MetaVotingmodeMajority(alive)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "votingMode", "majority")
    while alive() do Citizen.Wait(250) end
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "votingMode", "none")
end

-- sync_mode: META
function FX_MetaVotingmodeAntimajority(alive)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "votingMode", "antimajority")
    while alive() do Citizen.Wait(250) end
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "votingMode", "none")
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

-- sync_mode: LOCAL
function FX_Lowgravity(alive)
    while alive() do SetGravityLevel(1); Citizen.Wait(0) end
    SetGravityLevel(0)
end

-- sync_mode: LOCAL
function FX_Verylowgravity(alive)
    while alive() do SetGravityLevel(2); Citizen.Wait(0) end
    SetGravityLevel(0)
end

-- sync_mode: LOCAL
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

-- sync_mode: LOCAL
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

-- sync_mode: GLOBAL_OWNED
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

-- sync_mode: SPAWN_SINGLE
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

-- sync_mode: SPAWN_SINGLE
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

-- sync_mode: SPAWN_SINGLE
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
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "additionalEffects", 3)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "timerModifier", 3.0)
    while alive() do Citizen.Wait(250) end
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "additionalEffects", 0)
    -- server-applies-meta: TriggerServerEvent("cc:meta_set_internal", "timerModifier", 1.0)
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
-- sync_mode: GLOBAL_OWNED
function FX_PedsHandsUp(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        local pedType = GetPedType(ped)
        if pedType ~= 6 and pedType ~= 27 and not IsPedDeadOrDying(ped, true) and OwnershipGuard.IsOwner(ped) then
            TaskHandsUp(ped, 5000, 0, -1, true)
            SetPedDropsWeapon(ped)
        end
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsHeadless(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) then
                SetPedComponentVariation(ped, 0, 0, 0, 0)
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsHotcougars(alive)
    local cougarEnemies = {}
    local spawnTimer = -1
    local maxCougarsToSpawn = 5
    local lastTick = GetGameTimer()
    RequestNamedPtfxAsset("des_trailerpark")
    while not HasNamedPtfxAssetLoaded("des_trailerpark") do
        Citizen.Wait(0)
    end
    while alive() do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed, false)
        local current_time = GetGameTimer()
        if lastTick < current_time - 100 then
            lastTick = current_time
            for i = #cougarEnemies, 1, -1 do
                local cougar = cougarEnemies[i]
                local cougarPos = GetEntityCoords(cougar, false)
                if IsPedDeadOrDying(cougar, false) or IsPedInjured(cougar)
                or GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, cougarPos.x, cougarPos.y, cougarPos.z, false) > 100.0 then
                    SetEntityHealth(cougar, 0, 0)
                    UseParticleFxAsset("core")
                    StartParticleFxNonLoopedAtCoord("exp_air_molotov", cougarPos.x, cougarPos.y, cougarPos.z, 0, 0, 0, 3, false, false, false)
                    SetEntityAlpha(cougar, 0, true)
                    SetPedAsNoLongerNeeded(cougar)
                    DeletePed(cougar)
                    table.remove(cougarEnemies, i)
                else
                    local targetPed = GetNearestPlayerPed(cougarPos)
                    if targetPed then
                        if IsPedInAnyVehicle(targetPed, true) then
                            TaskEnterVehicle(cougar, GetVehiclePedIsIn(targetPed, false), -1, -2, 2.0, 1, 0)
                        else
                            TaskCombatPed(cougar, targetPed, 0, 16)
                            SetBlockingOfNonTemporaryEvents(cougar, true)
                        end
                    end
                end
            end
        end
        if #cougarEnemies < maxCougarsToSpawn and current_time > spawnTimer + 2000 then
            spawnTimer = current_time
            local spawnPos = GetCoordAround(playerPed, math.random() * 360.0, 10.0, 0.0, true)
            UseParticleFxAsset("core")
            StartParticleFxNonLoopedAtCoord("exp_air_molotov", spawnPos.x, spawnPos.y, spawnPos.z, 0, 0, 0, 2, true, true, true)
            Citizen.Wait(300)
            local ped = CreateHostilePed(GetHashKey("a_c_mtlion"), 0, spawnPos)
            SetPedCombatAttributes(ped, 1, true)
            SetPedCombatAttributes(ped, 3, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedFleeAttributes(ped, 2, true)
            UseParticleFxAsset("des_trailerpark")
            StartParticleFxLoopedOnEntity("ent_ray_trailerpark_fires", ped, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, false, false, false)
            RetargetSpawnedPed(ped, 5000)
            table.insert(cougarEnemies, ped)
        end
        Citizen.Wait(0)
    end
    RemoveNamedPtfxAsset("des_trailerpark")
    for _, ped in ipairs(cougarEnemies) do
        SetPedAsNoLongerNeeded(ped)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsIgnite(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) and math.random() < 0.02 then
                StartEntityFire(ped)
            end
        end)
        Citizen.Wait(100)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsDance(alive)
    local animDict = "missfbi3_sniping"
    local animName = "dance_m_default"
    local playerPed = PlayerPedId()
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            local rel = GetRelationshipBetweenPeds(playerPed, ped)
            if not IsEntityPlayingAnim(ped, animDict, animName, 3) and not IsPedAPlayer(ped)
                and (not IsEntityAMissionEntity(ped) or rel == 4 or rel == 5) then
                TaskPlayAnim(ped, animDict, animName, 4.0, -4.0, -1, 1, 0.0, false, false, false)
                SetPedKeepTask(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
            end
        end)
        Citizen.Wait(0)
    end
    RemoveAnimDict(animDict)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if IsEntityPlayingAnim(ped, animDict, animName, 3) then
            SetPedKeepTask(ped, false)
            SetBlockingOfNonTemporaryEvents(ped, false)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsIntorandomvehs(alive)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if not IsPedAPlayer(ped) and not IsPedInAnyVehicle(ped, false) then
            local nearbyVehs = {}
            OwnershipGuard.ForEachOwnedVehicle(function(veh)
                if IsVehicleSeatFree(veh, -1, false) then
                    table.insert(nearbyVehs, veh)
                end
            end)
            if #nearbyVehs > 0 then
                local veh = nearbyVehs[math.random(#nearbyVehs)]
                SetPedIntoVehicle(ped, veh, -1)
            end
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsInvincible(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) then
                SetEntityInvincible(ped, true)
            end
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedPed(function(ped)
        SetEntityInvincible(ped, false)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsGhost(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) then
                SetEntityAlpha(ped, 80, false)
            end
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedPed(function(ped)
        ResetEntityAlpha(ped)
    end)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsJamesbond(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local bondModel = GetHashKey("cs_milton")
    local vehModel = GetHashKey("JB700")
    local playerGroup = GetHashKey("PLAYER")
    local relationshipGroup = AddRelationshipGroup("_HOSTILE_BOND")
    SetRelationshipBetweenGroups(5, relationshipGroup, playerGroup)
    local heading = GetEntityHeading(IsPedInAnyVehicle(playerPed, false) and GetVehiclePedIsIn(playerPed, false) or playerPed)
    local xPos = math.sin(math.rad(360.0 - heading)) * 10.0
    local yPos = math.cos(math.rad(360.0 - heading)) * 10.0
    RequestModel(vehModel)
    while not HasModelLoaded(vehModel) do Citizen.Wait(0) end
    local veh = CreateVehicle(vehModel, playerPos.x - xPos, playerPos.y - yPos, playerPos.z, heading, true, false, false)
    SetVehicleEngineOn(veh, true, true, false)
    SetModelAsNoLongerNeeded(vehModel)
    local vel = GetEntityVelocity(playerPed)
    SetEntityVelocity(veh, vel.x, vel.y, vel.z)
    RequestModel(bondModel)
    while not HasModelLoaded(bondModel) do Citizen.Wait(0) end
    local bond = CreatePedInsideVehicle(veh, 4, bondModel, -1, true, false)
    SetModelAsNoLongerNeeded(bondModel)
    SetPedRelationshipGroupHash(bond, relationshipGroup)
    TaskSetBlockingOfNonTemporaryEvents(bond, true)
    SetPedHearingRange(bond, 9999.0)
    SetPedConfigFlag(bond, 281, true)
    SetPedCombatAttributes(bond, 5, true)
    SetPedCombatAttributes(bond, 46, true)
    SetPedSuffersCriticalHits(bond, false)
    GiveWeaponToPed(bond, GetHashKey("WEAPON_SWITCHBLADE"), 9999, true, true)
    GiveWeaponToPed(bond, GetHashKey("WEAPON_VINTAGEPISTOL"), 9999, true, true)
    GiveWeaponComponentToPed(bond, GetHashKey("WEAPON_VINTAGEPISTOL"), GetHashKey("COMPONENT_AT_PI_SUPP"))
    SetPedAccuracy(bond, 100)
    local targetPed = GetNearestPlayerPed(GetEntityCoords(bond))
    TaskCombatPed(bond, targetPed, 0, 16)
    RetargetSpawnedPed(bond, 5000)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsSlidy(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) then
                SetPedMoveRateOverride(ped, 100.0)
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsKillerclowns(alive)
    local function getRandomOffsetCoord(startCoord, minOffset, maxOffset)
        local coord = {x = startCoord.x, y = startCoord.y, z = startCoord.z}
        for i = 0, 9 do
            coord.x = startCoord.x + (math.random(0, 1) == 0 and math.random(minOffset, maxOffset) or -math.random(minOffset, maxOffset))
            coord.y = startCoord.y + (math.random(0, 1) == 0 and math.random(minOffset, maxOffset) or -math.random(minOffset, maxOffset))
            coord.z = startCoord.z
            local ok, gz = GetGroundZFor3dCoord(coord.x, coord.y, coord.z, 0.0, false, false)
            if ok then coord.z = gz; break end
        end
        return coord
    end
    local clownEnemies = {}
    local spawnTimer = -1
    local relationshipGroup
    local maxClownsToSpawn = 3
    local playerGroup = GetHashKey("PLAYER")
    relationshipGroup = AddRelationshipGroup("_HOSTILE_KILLER_CLOWNS")
    SetRelationshipBetweenGroups(5, relationshipGroup, playerGroup)
    SetRelationshipBetweenGroups(5, playerGroup, relationshipGroup)
    SetRelationshipBetweenGroups(0, relationshipGroup, relationshipGroup)
    RequestNamedPtfxAsset("scr_rcbarry2")
    while not HasNamedPtfxAssetLoaded("scr_rcbarry2") do
        Citizen.Wait(0)
    end
    while alive() do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed, false)
        local current_time = GetGameTimer()
        for i = #clownEnemies, 1, -1 do
            local clown = clownEnemies[i]
            local clownPos = GetEntityCoords(clown, false)
            if IsPedDeadOrDying(clown, false) or IsPedInjured(clown)
            or GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, clownPos.x, clownPos.y, clownPos.z, false) > 100.0 then
                SetEntityHealth(clown, 0, 0)
                UseParticleFxAsset("scr_rcbarry2")
                StartParticleFxNonLoopedAtCoord("scr_clown_death", clownPos.x, clownPos.y, clownPos.z, 0, 0, 0, 3, false, false, false)
                Citizen.Wait(300)
                SetEntityAlpha(clown, 0, true)
                SetPedAsNoLongerNeeded(clown)
                DeletePed(clown)
                table.remove(clownEnemies, i)
                Citizen.Wait(0)
            else
                local targetPed = GetNearestPlayerPed(clownPos)
                if targetPed then
                    TaskCombatPed(clown, targetPed, 0, 16)
                end
            end
        end
        if #clownEnemies < maxClownsToSpawn and current_time > spawnTimer + 2000 then
            spawnTimer = current_time
            local spawnPos = getRandomOffsetCoord(playerPos, 10, 25)
            UseParticleFxAsset("scr_rcbarry2")
            StartParticleFxNonLoopedAtCoord("scr_clown_appears", spawnPos.x, spawnPos.y, spawnPos.z, 0, 0, 0, 2, true, true, true)
            Citizen.Wait(300)
            local clownHash = GetHashKey("s_m_y_clown_01")
            local weaponHash = GetHashKey("WEAPON_MICROSMG")
            LoadModel(clownHash)
            local ped = CreatePed(-1, clownHash, spawnPos.x, spawnPos.y, spawnPos.z, 0, true, false)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedRelationshipGroupHash(ped, relationshipGroup)
            SetPedHearingRange(ped, 9999.0)
            GiveWeaponToPed(ped, weaponHash, 9999, true, true)
            SetPedAccuracy(ped, 20)
            local targetPed = GetNearestPlayerPed(spawnPos)
            TaskCombatPed(ped, targetPed, 0, 16)
            RetargetSpawnedPed(ped, 5000)
            table.insert(clownEnemies, ped)
        end
        Citizen.Wait(0)
    end
    RemoveNamedPtfxAsset("scr_rcbarry2")
    for _, ped in ipairs(clownEnemies) do
        SetPedAsNoLongerNeeded(ped)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsLaunchnearby(alive)
    local spacePeds = {}
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if not IsPedAPlayer(ped) then
            local vel = GetEntityVelocity(ped)
            ClearPedTasksImmediately(ped)
            SetPedToRagdoll(ped, 10000, 10000, 0, true, true, false)
            spacePeds[#spacePeds + 1] = { ped = ped, vel = vel }
        end
    end)
    Citizen.Wait(0)
    for _, entry in ipairs(spacePeds) do
        SetEntityVelocity(entry.ped, entry.vel.x, entry.vel.y, 100.0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsLoosetrigger(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) and GetSelectedPedWeapon(ped) ~= GetHashKey("WEAPON_UNARMED") then
                local pedPos = GetEntityCoords(ped)
                SetPedShootsAtCoord(ped, pedPos.x + math.random(-10, 10),
                    pedPos.y + math.random(-10, 10),
                    pedPos.z + math.random(-5, 5), true)
            end
        end)
        Citizen.Wait(500)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsMercenaries(alive)
    while alive() do
        local mercHash = GetHashKey("s_m_m_marine_01")
        local pedsToReplace = {}
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) and IsPedHuman(ped) then
                pedsToReplace[#pedsToReplace + 1] = {
                    ped = ped,
                    coords = GetEntityCoords(ped, false),
                    heading = GetEntityHeading(ped)
                }
            end
        end)
        for _, entry in ipairs(pedsToReplace) do
            DeletePed(entry.ped)
        end
        Citizen.Wait(0)
        RequestModel(mercHash)
        while not HasModelLoaded(mercHash) do Citizen.Wait(0) end
        for _, entry in ipairs(pedsToReplace) do
            local merc = CreatePed(26, mercHash, entry.coords.x, entry.coords.y, entry.coords.z, entry.heading, true, false)
            GiveWeaponToPed(merc, GetHashKey("WEAPON_CARBINERIFLE"), 9999, true, true)
            local targetPed = GetNearestPlayerPed(entry.coords)
            TaskCombatPed(merc, targetPed, 0, 16)
            RetargetSpawnedPed(merc, 5000)
        end
        SetModelAsNoLongerNeeded(mercHash)
        Citizen.Wait(10000)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsMindmg(alive)
    while alive() do
        SetAiMeleeWeaponDamageModifier(0.1)
        SetAiWeaponDamageModifier(0.1)
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), 0.1, true)
        SetPlayerWeaponDamageModifier(PlayerId(), 0.1)
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) then
                SetPedSuffersCriticalHits(ped, false)
                SetPedConfigFlag(ped, 281, true)
            end
        end)
        Citizen.Wait(0)
    end
    ResetAiMeleeWeaponDamageModifier()
    ResetAiWeaponDamageModifier()
    SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0, true)
    SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if not IsPedAPlayer(ped) then
            SetPedSuffersCriticalHits(ped, true)
            SetPedConfigFlag(ped, 281, false)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsMinions(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) then
                SetPedConfigFlag(ped, 223, true)
            end
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if DoesEntityExist(ped) then
            SetPedConfigFlag(ped, 223, false)
        end
    end)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsMowermates(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local mowerHash = GetHashKey("MOWER")
    RequestModel(mowerHash)
    while not HasModelLoaded(mowerHash) do Citizen.Wait(0) end
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) then
            local pedPos = GetEntityCoords(ped, false)
            local heading = GetEntityHeading(ped)
            local veh = CreateVehicle(mowerHash, pedPos.x, pedPos.y, pedPos.z, heading, true, false, false)
            SetVehicleEngineOn(veh, true, true, false)
            SetPedIntoVehicle(ped, veh, -1)
        end
    end)
    SetModelAsNoLongerNeeded(mowerHash)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsNailguns(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if IsPedShooting(ped) and not IsPedAPlayer(ped) then
                local pos = GetEntityCoords(ped, false)
                local fwd = GetEntityForwardVector(ped)
                local targPos = vector3(pos.x + fwd.x * 500.0, pos.y + fwd.y * 500.0, pos.z + fwd.z * 500.0)
                local ray = StartShapeTestRay(pos.x, pos.y, pos.z, targPos.x, targPos.y, targPos.z, 12, ped, 7)
                local _, hit, hitCoords, _, entityHit = GetShapeTestResult(ray)
                if hit and DoesEntityExist(entityHit) then
                    SetEntityCoords(ped, hitCoords.x, hitCoords.y, hitCoords.z, false, false, false, true)
                end
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsFlee(alive)
    local playerPed = PlayerPedId()
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if not IsPedAPlayer(ped) then
            local targetPed = GetNearestPlayerPed(GetEntityCoords(ped))
            if targetPed then
                TaskReactAndFleePed(ped, targetPed)
            end
            SetPedFleeAttributes(ped, 2, true)
        end
    end)
end

-- sync_mode: LOCAL
function FX_PlayerNoragdoll(alive)
    while alive() do
        SetPedCanRagdoll(PlayerPedId(), false)
        Citizen.Wait(0)
    end
    SetPedCanRagdoll(PlayerPedId(), true)
end

-- sync_mode: VISUAL
function FX_PedsNotMenendez(alive)
    local deadPeds = {}
    local lastTick = GetGameTimer()
    local speechHash = GetHashKey("BUDDY_DOWN")
    local voiceName = "s_m_y_blackops_01_white_mini_01"
    while alive() do
        local curTick = GetGameTimer()
        local newDead = false
        for _, ped in ipairs(GetGamePool('CPed')) do
            if not deadPeds[ped] and IsEntityDead(ped, false) then
                deadPeds[ped] = true
                newDead = true
            end
        end
        if newDead and curTick - lastTick >= 2000 then
            lastTick = curTick
            local playerPos = GetEntityCoords(PlayerPedId(), false)
            PlayAmbientSpeechAtCoords(speechHash, voiceName, playerPos.x, playerPos.y, playerPos.z, "SPEECH_PARAMS_FORCE_SHOUTED")
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsObliterate(alive)
    RequestNamedPtfxAsset("scr_xm_orbital")
    RequestNamedPtfxAsset("scr_xm_orbital_blast")
    while not HasNamedPtfxAssetLoaded("scr_xm_orbital") or not HasNamedPtfxAssetLoaded("scr_xm_orbital_blast") do
        Citizen.Wait(0)
    end
    local count = 5
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) and OwnershipGuard.IsOwner(ped) then
            local pos = GetEntityCoords(ped, false)
            UseParticleFxAsset("scr_xm_orbital")
            StartNetworkedParticleFxNonLoopedAtCoord("scr_xm_orbital_blast", pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
            PlaySoundFromCoord(-1, "DLC_XM_Explosions_Orbital_Cannon", pos.x, pos.y, pos.z, 0, true, 0, false)
            AddExplosion(pos.x, pos.y, pos.z, 9, 100.0, true, false, 3.0, false)
            SetEntityHealth(ped, 0, false)
            count = count - 1
            if count == 0 then
                count = 5
                Citizen.Wait(0)
            end
        end
    end
    RemoveNamedPtfxAsset("scr_xm_orbital")
    RemoveNamedPtfxAsset("scr_xm_orbital_blast")
end

-- sync_mode: LOCAL
function FX_PlayerOhko(alive)
    while alive() do
        SetPlayerMeleeWeaponDamageModifier(PlayerId(), 100.0)
        SetPlayerWeaponDamageModifier(PlayerId(), 100.0)
        Citizen.Wait(0)
    end
    SetPlayerMeleeWeaponDefenseModifier(PlayerId(), 1.0)
    SetPlayerWeaponDefenseModifier(PlayerId(), 1.0)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsPhones(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) and math.random() < 0.03 then
                TaskUseMobilePhone(ped, true)
            end
        end)
        Citizen.Wait(500)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsPropHunt(alive)
    while alive() do
        local pedsToConvert = {}
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) and math.random() < 0.01 then
                pedsToConvert[#pedsToConvert + 1] = ped
            end
        end)
        for _, ped in ipairs(pedsToConvert) do
            local props = {}
            OwnershipGuard.ForEachOwnedObject(function(obj)
                table.insert(props, obj)
            end)
            if #props > 0 then
                local prop = props[math.random(#props)]
                local model = GetEntityModel(prop)
                local coords = GetEntityCoords(ped, false)
                local heading = GetEntityHeading(ped)
                DeletePed(ped)
                Citizen.Wait(0)
                RequestModel(model)
                while not HasModelLoaded(model) do Citizen.Wait(0) end
                local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
                SetModelAsNoLongerNeeded(model)
                SetEntityHeading(obj, heading)
            end
        end
        Citizen.Wait(5000)
    end
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsSpawnQuarrelingCouple(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local relationshipGroup = AddRelationshipGroup("_HOSTILE_DEBRA")
    SetRelationshipBetweenGroups(5, relationshipGroup, GetHashKey("PLAYER"))
    local debraHash = GetHashKey("cs_debra")
    local floydHash = GetHashKey("cs_floyd")
    RequestModel(debraHash)
    while not HasModelLoaded(debraHash) do Citizen.Wait(0) end
    local debra = CreatePed(4, debraHash, playerPos.x + 1.0, playerPos.y, playerPos.z, heading, true, false)
    SetPedRelationshipGroupHash(debra, relationshipGroup)
    GiveWeaponToPed(debra, GetHashKey("WEAPON_PISTOL"), 9999, true, true)
    local targetDebra = GetNearestPlayerPed(playerPos)
    TaskCombatPed(debra, targetDebra, 0, 16)
    RetargetSpawnedPed(debra, 5000)
    SetModelAsNoLongerNeeded(debraHash)
    RequestModel(floydHash)
    while not HasModelLoaded(floydHash) do Citizen.Wait(0) end
    local floyd = CreatePed(4, floydHash, playerPos.x - 1.0, playerPos.y, playerPos.z, heading, true, false)
    SetPedRelationshipGroupHash(floyd, relationshipGroup)
    GiveWeaponToPed(floyd, GetHashKey("WEAPON_KNIFE"), 9999, true, true)
    local targetFloyd = GetNearestPlayerPed(playerPos)
    TaskCombatPed(floyd, targetFloyd, 0, 16)
    RetargetSpawnedPed(floyd, 5000)
    SetModelAsNoLongerNeeded(floydHash)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsRagdoll(alive)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        ClearPedTasksImmediately(ped)
        SetPedToRagdoll(ped, 10000, 10000, 0, true, true, false)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsSensitivetouch(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) and HasEntityBeenDamagedByAnyPed(ped) then
                SetEntityHealth(ped, 0)
                ClearEntityLastDamageEntity(ped)
            end
        end)
        Citizen.Wait(100)
    end
end

-- sync_mode: LOCAL
function FX_PedsReflectivedamage(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if HasEntityBeenDamagedByAnyPed(playerPed) then
            local attacker = GetPedSourceOfDeath(playerPed)
            if DoesEntityExist(attacker) and attacker ~= 0 then
                local dmg = GetEntityHealth(playerPed)
                SetEntityHealth(attacker, GetEntityHealth(attacker) - (GetEntityMaxHealth(playerPed) - dmg))
            end
            ClearEntityLastDamageEntity(playerPed)
        end
        Citizen.Wait(100)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsRevive(alive)
    local pedsToRevive = {}
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if IsEntityDead(ped, false) and not IsPedAPlayer(ped) then
            pedsToRevive[#pedsToRevive + 1] = {
                coords = GetEntityCoords(ped, false),
                heading = GetEntityHeading(ped),
                model = GetEntityModel(ped)
            }
            DeletePed(ped)
        end
    end)
    for _, entry in ipairs(pedsToRevive) do
        RequestModel(entry.model)
        while not HasModelLoaded(entry.model) do Citizen.Wait(0) end
        local newPed = CreatePed(26, entry.model, entry.coords.x, entry.coords.y, entry.coords.z, entry.heading, true, false)
        SetModelAsNoLongerNeeded(entry.model)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsRiot(alive)
    local groupHash
    groupHash = AddRelationshipGroup("_RIOT")
    local goneThroughPeds = {}
    while alive() do
        local riotGroupHash = GetHashKey("_RIOT")
        local playerGroupHash = GetHashKey("PLAYER")
        SetRelationshipBetweenGroups(5, riotGroupHash, riotGroupHash)
        SetRelationshipBetweenGroups(5, riotGroupHash, playerGroupHash)
        SetRelationshipBetweenGroups(5, playerGroupHash, riotGroupHash)
        SetPlayerWantedLevel(PlayerId(), 0, false)
        SetMaxWantedLevel(0)
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) then
                SetPedRelationshipGroupHash(ped, riotGroupHash)
                SetPedCombatAttributes(ped, 5, true)
                SetPedCombatAttributes(ped, 46, true)
                SetPedFiringPattern(ped, 0xC6EE6B4C)
                local found = false
                for _, v in ipairs(goneThroughPeds) do
                    if v == ped then found = true; break end
                end
                if not found then
                    table.insert(goneThroughPeds, ped)
                end
            end
        end)
        for i = #goneThroughPeds, 1, -1 do
            if not DoesEntityExist(goneThroughPeds[i]) then
                table.remove(goneThroughPeds, i)
            end
        end
        Citizen.Wait(0)
    end
    SetMaxWantedLevel(5)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsScooterbrothers(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local faggioHash = GetHashKey("FAGGIO")
    RequestModel(faggioHash)
    while not HasModelLoaded(faggioHash) do Citizen.Wait(0) end
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) then
            local pedPos = GetEntityCoords(ped, false)
            local heading = GetEntityHeading(ped)
            local veh = CreateVehicle(faggioHash, pedPos.x, pedPos.y, pedPos.z, heading, true, false, false)
            SetVehicleEngineOn(veh, true, true, false)
            SetPedIntoVehicle(ped, veh, -1)
        end
    end)
    SetModelAsNoLongerNeeded(faggioHash)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsSlipperyPeds(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) then
                SetPedMoveRateOverride(ped, 100.0)
                local vel = GetEntityVelocity(ped)
                SetEntityVelocity(ped, vel.x * 1.01, vel.y * 1.01, vel.z)
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsSmoketrails(alive)
    while alive() do
        UseParticleFxAsset("core")
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if not IsPedAPlayer(ped) then
                StartParticleFxLoopedOnEntity("ent_amb_cig_smoke", ped, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
            end
        end)
        Citizen.Wait(500)
    end
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsAngryalien(alive)
    local modelHash = GetHashKey("s_m_m_movalien_01")
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local group = AddRelationshipGroup("_HOSTILE_ALIEN")
    SetRelationshipBetweenGroups(5, group, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVMALE"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVFEMALE"))
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePed(4, modelHash, playerPos.x, playerPos.y, playerPos.z, 0.0, true, false)
    SetModelAsNoLongerNeeded(modelHash)
    SetPedRelationshipGroupHash(ped, group)
    SetPedHearingRange(ped, 9999.0)
    SetPedConfigFlag(ped, 281, true)
    SetPedComponentVariation(ped, 0, 0, 0, 0)
    SetPedComponentVariation(ped, 3, 0, 0, 0)
    SetPedComponentVariation(ped, 4, 0, 0, 0)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
    SetPedComponentVariation(ped, 6, 0, 0, 0)
    SetEntityHealth(ped, 500)
    SetPedArmour(ped, 500)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAttributes(ped, 0, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetRagdollBlockingFlags(ped, 5)
    SetPedSuffersCriticalHits(ped, false)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_RAYPISTOL"), 9999, true, true)
    local targetPed = GetNearestPlayerPed(playerPos)
    TaskCombatPed(ped, targetPed, 0, 16)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
    RetargetSpawnedPed(ped, 5000)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnAngryChimp(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local chimpHash = 2825402133
    local weaponHash = GetHashKey("WEAPON_STONE_HATCHET")
    local relationshipGroup = AddRelationshipGroup("_HOSTILE_CHIMP")
    SetRelationshipBetweenGroups(5, relationshipGroup, GetHashKey("PLAYER"))
    RequestModel(chimpHash)
    while not HasModelLoaded(chimpHash) do Citizen.Wait(0) end
    local ped = CreatePed(4, chimpHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(chimpHash)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedRelationshipGroupHash(ped, relationshipGroup)
    SetPedHearingRange(ped, 9999.0)
    SetPedConfigFlag(ped, 281, true)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedAccuracy(ped, 100)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
    SetPedSuffersCriticalHits(ped, false)
    GiveWeaponToPed(ped, weaponHash, 9999, true, true)
    local targetPed = GetNearestPlayerPed(playerPos)
    TaskCombatPed(ped, targetPed, 0, 16)
    RetargetSpawnedPed(ped, 5000)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnGrieferjesus(alive)
    local modelHash = -835930287
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local group = AddRelationshipGroup("_HOSTILE_JESUS")
    SetRelationshipBetweenGroups(5, group, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVMALE"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVFEMALE"))
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePed(4, modelHash, playerPos.x, playerPos.y, playerPos.z, 0.0, true, false)
    SetModelAsNoLongerNeeded(modelHash)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedRelationshipGroupHash(ped, group)
    SetPedHearingRange(ped, 9999.0)
    SetPedConfigFlag(ped, 281, true)
    SetEntityProofs(ped, false, true, true, false, false, false, false, false)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetRagdollBlockingFlags(ped, 5)
    SetPedSuffersCriticalHits(ped, false)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_RAILGUN"), 9999, true, true)
    local targetPed = GetNearestPlayerPed(playerPos)
    TaskCombatPed(ped, targetPed, 0, 16)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
    RetargetSpawnedPed(ped, 5000)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnGrieferjesus2(alive)
    local modelHash = -835930287
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local oppressorHash = GetHashKey("OPPRESSOR2")
    local group = AddRelationshipGroup("_HOSTILE_JESUS2")
    SetRelationshipBetweenGroups(5, group, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVMALE"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVFEMALE"))
    RequestModel(oppressorHash)
    while not HasModelLoaded(oppressorHash) do Citizen.Wait(0) end
    local heading = GetEntityHeading(IsPedInAnyVehicle(playerPed, false) and GetVehiclePedIsIn(playerPed, false) or playerPed)
    local veh = CreateVehicle(oppressorHash, playerPos.x, playerPos.y, playerPos.z, heading, true, false, false)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleModKit(veh, 0)
    for i = 0, 49 do
        local max = GetNumVehicleMods(veh, i)
        SetVehicleMod(veh, i, max > 0 and max - 1 or 0, false)
    end
    SetEntityProofs(veh, false, true, true, false, false, false, false, false)
    SetModelAsNoLongerNeeded(oppressorHash)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePedInsideVehicle(veh, 4, modelHash, -1, true, false)
    SetModelAsNoLongerNeeded(modelHash)
    SetPedRelationshipGroupHash(ped, group)
    SetPedHearingRange(ped, 9999.0)
    SetPedConfigFlag(ped, 281, true)
    SetPedCombatAttributes(ped, 3, false)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetEntityProofs(ped, false, true, true, false, false, false, false, false)
    SetPedCanBeKnockedOffVehicle(ped, 1)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetRagdollBlockingFlags(ped, 5)
    SetPedSuffersCriticalHits(ped, false)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_RAILGUN"), 9999, true, true)
    local targetPed = GetNearestPlayerPed(playerPos)
    TaskCombatPed(ped, targetPed, 0, 16)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
    RetargetSpawnedPed(ped, 5000)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsAngryjimmy(alive)
    local modelHash = 1459905209
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local group = AddRelationshipGroup("_HOSTILE_JIMMY")
    SetRelationshipBetweenGroups(5, group, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVMALE"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVFEMALE"))
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePed(4, modelHash, playerPos.x, playerPos.y, playerPos.z, 0.0, true, false)
    SetModelAsNoLongerNeeded(modelHash)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedRelationshipGroupHash(ped, group)
    SetPedHearingRange(ped, 9999.0)
    SetPedConfigFlag(ped, 281, true)
    SetEntityProofs(ped, false, true, true, false, false, false, false, false)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetRagdollBlockingFlags(ped, 5)
    SetPedSuffersCriticalHits(ped, false)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_COMBATMG"), 9999, true, true)
    local targetPed = GetNearestPlayerPed(playerPos)
    TaskCombatPed(ped, targetPed, 0, 16)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
    RetargetSpawnedPed(ped, 5000)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsSpawnballasquad(alive)
    local ballaNames = {-198252413, 588969535, 361513884, -1492432238, -1410400252, 599294057}
    local group = AddRelationshipGroup("_ENEMY_BALLAS")
    SetRelationshipBetweenGroups(5, group, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), group)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(
        IsPedInAnyVehicle(playerPed, false) and GetVehiclePedIsIn(playerPed, false) or playerPed
    )
    local vehHash = GetHashKey("Virgo2")
    RequestModel(vehHash)
    while not HasModelLoaded(vehHash) do Citizen.Wait(0) end
    local veh = CreateVehicle(vehHash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(vehHash)
    SetVehicleColours(veh, 148, 148)
    SetVehicleEngineOn(veh, true, true, false)
    for i = 0, 1 do
        local modelHash = ballaNames[math.random(#ballaNames)]
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
        local ped = CreatePed(4, modelHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
        SetModelAsNoLongerNeeded(modelHash)
        if i == 0 then
            SetPedIntoVehicle(ped, veh, -1)
        else
            SetPedIntoVehicle(ped, veh, 0)
        end
        SetPedCombatAttributes(ped, 3, false)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedRelationshipGroupHash(ped, group)
        SetPedHearingRange(ped, 9999.0)
        GiveWeaponToPed(ped, GetHashKey("WEAPON_MICROSMG"), 9999, true, true)
        SetPedAccuracy(ped, 50)
        local targetPed = GetNearestPlayerPed(playerPos)
        TaskCombatPed(ped, targetPed, 0, 16)
        RetargetSpawnedPed(ped, 5000)
    end
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsSpawnBiker(alive)
    local vehHash = GetHashKey("DAEMON")
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(
        IsPedInAnyVehicle(playerPed, false) and GetVehiclePedIsIn(playerPed, false) or playerPed
    )
    local xPos = math.sin((360 - heading) * math.pi / 180) * 10
    local yPos = math.cos((360 - heading) * math.pi / 180) * 10
    RequestModel(vehHash)
    while not HasModelLoaded(vehHash) do Citizen.Wait(0) end
    local veh = CreateVehicle(vehHash, playerPos.x - xPos, playerPos.y - yPos, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(vehHash)
    SetVehicleEngineOn(veh, true, true, false)
    local vel = GetEntityVelocity(playerPed)
    SetEntityVelocity(veh, vel.x, vel.y, vel.z)
    local ped = _ChaosCreateHostilePed(GetHashKey("G_M_Y_Lost_03"), GetHashKey("weapon_dbshotgun"))
    SetPedIntoVehicle(ped, veh, -1)
    RetargetSpawnedPed(ped, 5000)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnCompbrad(alive)
    local modelHash = GetHashKey("ig_brad")
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePed(4, modelHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(modelHash)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedSuffersCriticalHits(ped, false)
    SetPedHearingRange(ped, 9999.0)
    SetPedAsGroupMember(ped, GetPlayerGroup(PlayerId()))
    GiveWeaponToPed(ped, GetHashKey("WEAPON_MICROSMG"), 9999, true, true)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_RPG"), 9999, true, true)
    SetPedAccuracy(ped, 100)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnChimp(alive)
    local modelHash = GetHashKey("a_c_chimp")
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePed(28, modelHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(modelHash)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedSuffersCriticalHits(ped, false)
    SetPedHearingRange(ped, 9999.0)
    SetPedAsGroupMember(ped, GetPlayerGroup(PlayerId()))
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedAccuracy(ped, 100)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 9999, false, true)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_CARBINERIFLE"), 9999, false, true)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnChop(alive)
    local modelHash = GetHashKey("a_c_chop")
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePed(28, modelHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(modelHash)
    SetPedCombatAttributes(ped, 0, false)
    SetPedHearingRange(ped, 9999.0)
    SetPedRelationshipGroupHash(ped, GetHashKey("_COMPANION_CHOP"))
    SetPedAsGroupMember(ped, GetPlayerGroup(PlayerId()))
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnComprnd(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local ped = _ChaosCreateRandomPed(playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed))
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedSuffersCriticalHits(ped, false)
    SetPedHearingRange(ped, 9999.0)
    SetPedAsGroupMember(ped, GetPlayerGroup(PlayerId()))
    GiveWeaponToPed(ped, GetSelectedPedWeapon(playerPed), 9999, true, true)
    SetPedAccuracy(ped, 100)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsSpawndancingapes(alive)
    local group = AddRelationshipGroup("_DANCING__APES")
    SetRelationshipBetweenGroups(0, group, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), group)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local chimps = {GetHashKey("a_c_chimp"), GetHashKey("a_c_rhesus")}
    RequestAnimDict("missfbi3_sniping")
    for i = 0, 2 do
        local modelHash = chimps[math.random(2)]
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
        local ped = CreatePed(28, modelHash, playerPos.x, playerPos.y, playerPos.z, 0.0, true, false)
        SetModelAsNoLongerNeeded(modelHash)
        SetPedRelationshipGroupHash(ped, group)
        if IsPedInAnyVehicle(playerPed, false) then
            SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
        end
        SetPedCanRagdoll(ped, false)
        SetPedSuffersCriticalHits(ped, false)
        TaskPlayAnim(ped, "missfbi3_sniping", "dance_m_default", 4.0, -4.0, -1, 1, 0.0, false, false, false)
        SetPedConfigFlag(ped, 292, true)
        Citizen.Wait(0)
    end
    RemoveAnimDict("missfbi3_sniping")
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsSpawnfancats(alive)
    local modelHash = GetHashKey("a_c_cat_01")
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local relationshipGroup = AddRelationshipGroup("_FAN_CATS")
    SetRelationshipBetweenGroups(0, relationshipGroup, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), relationshipGroup)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    for i = 1, 3 do
        local ped = CreatePed(28, modelHash, playerPos.x, playerPos.y, playerPos.z, 0.0, true, false)
        SetPedRelationshipGroupHash(ped, relationshipGroup)
        SetPedAsGroupMember(ped, GetPlayerGroup(PlayerId()))
    end
    SetModelAsNoLongerNeeded(modelHash)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsSpawnrandomhostile(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local group = AddRelationshipGroup("_HOSTILE_RANDOM")
    SetRelationshipBetweenGroups(5, group, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVMALE"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVFEMALE"))
    local ped = _ChaosCreateRandomPed(playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed))
    SetPedRelationshipGroupHash(ped, group)
    SetPedHearingRange(ped, 9999.0)
    SetPedConfigFlag(ped, 281, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetRagdollBlockingFlags(ped, 5)
    SetPedSuffersCriticalHits(ped, false)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    GiveWeaponToPed(ped, GetSelectedPedWeapon(playerPed), 9999, true, true)
    SetPedAccuracy(ped, 100)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
    local targetPed = GetNearestPlayerPed(playerPos)
    TaskCombatPed(ped, targetPed, 0, 16)
    RetargetSpawnedPed(ped, 5000)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsSpawnimrage(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local group = AddRelationshipGroup("_IM_RAGE")
    SetRelationshipBetweenGroups(5, group, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVMALE"))
    SetRelationshipBetweenGroups(5, group, GetHashKey("CIVFEMALE"))
    local model = GetHashKey("u_m_y_imporage")
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end
    local ped = CreatePed(4, model, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(model)
    SetEntityHealth(ped, 1000)
    SetPedArmour(ped, 1000)
    SetPedRelationshipGroupHash(ped, group)
    SetPedHearingRange(ped, 9999.0)
    SetPedConfigFlag(ped, 281, true)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetRagdollBlockingFlags(ped, 5)
    SetPedSuffersCriticalHits(ped, false)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    local targetPed = GetNearestPlayerPed(playerPos)
    TaskCombatPed(ped, targetPed, 0, 16)
    SetPedFiringPattern(ped, 0xC6EE6B4C)
    RetargetSpawnedPed(ped, 5000)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsSpawnJuggernaut(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local modelHash = GetHashKey("u_m_y_juggernaut_01")
    local weaponHash = GetHashKey("WEAPON_MINIGUN")
    local relationshipGroup = AddRelationshipGroup("_HOSTILE_JUGGERNAUT")
    SetRelationshipBetweenGroups(5, relationshipGroup, GetHashKey("PLAYER"))
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePed(4, modelHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(modelHash)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedRelationshipGroupHash(ped, relationshipGroup)
    SetPedHearingRange(ped, 9999.0)
    SetPedConfigFlag(ped, 281, true)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedSuffersCriticalHits(ped, false)
    GiveWeaponToPed(ped, weaponHash, 9999, true, true)
    local targetPed = GetNearestPlayerPed(playerPos)
    TaskCombatPed(ped, targetPed, 0, 16)
    SetPedArmour(ped, 250)
    SetPedAccuracy(ped, 3)
    RetargetSpawnedPed(ped, 5000)
end
-- sync_mode: SPAWN_SINGLE
function FX_PedsRoasting(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local group = AddRelationshipGroup("_ROASTING_LAMAR")
    SetRelationshipBetweenGroups(0, group, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), group)
    local lamarModel = GetHashKey("ig_lamardavis")
    RequestModel(lamarModel)
    while not HasModelLoaded(lamarModel) do Citizen.Wait(0) end
    local lamarPed = CreatePed(4, lamarModel, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(lamarModel)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(lamarPed, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedRelationshipGroupHash(lamarPed, group)
    SetPedAsGroupMember(lamarPed, GetPlayerGroup(PlayerId()))
    SetEntityInvincible(lamarPed, true)
    Citizen.Wait(1500)
    Citizen.Wait(2500)
end

-- sync_mode: SPAWN_SINGLE
function FX_PedsSpawnSpaceRanger(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local modelHash = GetHashKey("u_m_y_rsranger_01")
    local weaponHash = GetHashKey("WEAPON_RAYCARBINE")
    local relationshipGroup = AddRelationshipGroup("_HOSTILE_SPACE_RANGER")
    SetRelationshipBetweenGroups(5, relationshipGroup, GetHashKey("PLAYER"))
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local ped = CreatePed(4, modelHash, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(modelHash)
    if IsPedInAnyVehicle(playerPed, false) then
        SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
    end
    SetPedRelationshipGroupHash(ped, relationshipGroup)
    SetPedHearingRange(ped, 9999.0)
    SetPedConfigFlag(ped, 281, true)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedSuffersCriticalHits(ped, false)
    GiveWeaponToPed(ped, weaponHash, 9999, true, true)
    local target = GetNearestPlayerPed(GetEntityCoords(ped))
    if target then
        TaskCombatPed(ped, target, 0, 16)
    end
    RetargetSpawnedPed(ped, 2000)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsSayhi(alive)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if DoesEntityExist(ped) then
            SetPedRelationshipGroupHash(ped, GetHashKey("PLAYER"))
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsInsult(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) then
                local target = GetNearestPlayerPed(GetEntityCoords(ped))
                if target then
                    TaskCombatPed(ped, target, 0, 16)
                end
            end
        end)
        Citizen.Wait(5000)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsKifflom(alive)
    local modelHash = GetHashKey("u_m_m_jesus_01")
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped, false)
            local heading = GetEntityHeading(ped)
            DeletePed(ped)
            Citizen.Wait(0)
            CreatePed(26, modelHash, coords.x, coords.y, coords.z, heading, true, false)
        end
    end)
    SetModelAsNoLongerNeeded(modelHash)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsStopStare(alive)
    local playerPed = PlayerPedId()
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if IsPedInAnyVehicle(ped, true) then
            local veh = GetVehiclePedIsIn(ped, true)
            TaskLeaveVehicle(ped, veh, 256)
            BringVehicleToHalt(veh, 0.1, 10, 0)
        end
        TaskTurnPedToFaceEntity(ped, playerPed, -1)
        TaskLookAtEntity(ped, playerPed, -1, 2048, 3)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsRemweps(alive)
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if DoesEntityExist(ped) then
            RemoveAllPedWeapons(ped, true)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsTankBois(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local tankHash = GetHashKey("rhino")
    local maxDistance = 120.0
    RequestModel(tankHash)
    while not HasModelLoaded(tankHash) do Citizen.Wait(0) end
    OwnershipGuard.ForEachOwnedPed(function(ped)
        if not IsPedDeadOrDying(ped, true) then
            local pedPos = GetEntityCoords(ped, false)
            local dist = #(playerPos - pedPos)
            if dist <= maxDistance then
                local heading = GetEntityHeading(ped)
                local veh = CreateVehicle(tankHash, pedPos.x, pedPos.y, pedPos.z, heading, true, false, false)
                SetVehicleEngineOn(veh, true, true, false)
                SetPedIntoVehicle(ped, veh, -1)
            end
        end
    end)
    SetModelAsNoLongerNeeded(tankHash)
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsToast(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) and math.random() < 0.01 then
                local pos = GetEntityCoords(ped, false)
                AddExplosion(pos.x, pos.y, pos.z, 9, 1.0, true, false, 1.0, false)
                SetEntityHealth(ped, 0)
            end
        end)
        Citizen.Wait(1000)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PedsPortalGun(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) and IsPedShooting(ped) then
                local pos = GetEntityCoords(ped, false)
                local fwd = GetEntityForwardVector(ped)
                local targPos = vector3(pos.x + fwd.x * 500.0, pos.y + fwd.y * 500.0, pos.z + fwd.z * 500.0)
                local ray = StartShapeTestRay(pos.x, pos.y, pos.z, targPos.x, targPos.y, targPos.z, 12, ped, 7)
                local _, hit, hitCoords, _, _ = GetShapeTestResult(ray)
                if hit then
                    SetEntityCoords(ped, hitCoords.x, hitCoords.y, hitCoords.z + 1.0, false, false, false, true)
                end
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayervehTprandompeds(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            local seats = GetVehicleModelNumberOfSeats(GetEntityModel(veh))
            local peds = {}
            OwnershipGuard.ForEachOwnedPed(function(ped)
                if not IsPedInAnyVehicle(ped, false) then
                    table.insert(peds, ped)
                end
            end)
            for i = 0, seats - 2 do
                if IsVehicleSeatFree(veh, i, false) then
                    if #peds > 0 then
                        local ped = table.remove(peds, math.random(#peds))
                        SetPedIntoVehicle(ped, veh, i)
                    end
                end
            end
        end
        Citizen.Wait(5000)
    end
end

-- sync_mode: SPAWN_SINGLE
function FX_Zombies(alive)
    local ms_Zombies = {}
    local MAX_ZOMBIES = 20
    local MODEL_HASH = -1404353274
    local zombieGroupHash = GetHashKey("_ZOMBIES")
    local playerGroupHash = GetHashKey("PLAYER")
    local civMaleGroupHash = GetHashKey("CIVMALE")
    local civFemaleGroupHash = GetHashKey("CIVFEMALE")
    local groupHash
    groupHash = AddRelationshipGroup("_ZOMBIES")
    SetRelationshipBetweenGroups(5, groupHash, playerGroupHash)
    SetRelationshipBetweenGroups(5, groupHash, civMaleGroupHash)
    SetRelationshipBetweenGroups(5, groupHash, civFemaleGroupHash)
    RequestModel(MODEL_HASH)
    while not HasModelLoaded(MODEL_HASH) do Citizen.Wait(0) end
    while alive() do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed, false)
        if #ms_Zombies <= MAX_ZOMBIES then
            local ok, spawnPos = GetNthClosestVehicleNode(playerPos.x, playerPos.y, playerPos.z, 10 + #ms_Zombies, 0, 0, 0)
            if ok and spawnPos and GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, spawnPos.x, spawnPos.y, spawnPos.z, false) < 300.0 then
                local zombie = CreatePed(26, MODEL_HASH, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, false)
                table.insert(ms_Zombies, zombie)
                SetPedRelationshipGroupHash(zombie, zombieGroupHash)
                SetPedCombatAttributes(zombie, 5, true)
                SetPedCombatAttributes(zombie, 46, true)
                DisablePedPainAudio(zombie, true)
                local target = GetNearestPlayerPed(GetEntityCoords(zombie))
                if target then
                    TaskCombatPed(zombie, target, 0, 16)
                end
                RetargetSpawnedPed(zombie, 2000)
            end
        end
        for i = #ms_Zombies, 1, -1 do
            local zombie = ms_Zombies[i]
            local keepAlive = false
            if DoesEntityExist(zombie) then
                local zombiePos = GetEntityCoords(zombie, false)
                if GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, zombiePos.x, zombiePos.y, zombiePos.z, false) < 300.0 then
                    local maxHealth = GetEntityMaxHealth(zombie)
                    if maxHealth > 0 then
                        if IsPedInjured(zombie) or IsPedRagdoll(zombie) then
                            AddExplosion(zombiePos.x, zombiePos.y, zombiePos.z, 4, 9999.0, true, false, 1.0, false)
                            SetEntityHealth(zombie, 0, false)
                            SetEntityMaxHealth(zombie, 0)
                        end
                        keepAlive = true
                    end
                end
                if not keepAlive then
                    SetPedAsNoLongerNeeded(zombie)
                end
            end
            if not keepAlive then
                table.remove(ms_Zombies, i)
            end
        end
        Citizen.Wait(0)
    end
    SetModelAsNoLongerNeeded(MODEL_HASH)
    for _, ped in ipairs(ms_Zombies) do
        if DoesEntityExist(ped) then
            SetPedAsNoLongerNeeded(ped)
        end
    end
end

-- sync_mode: LOCAL
function FX_PlayerAfk(alive)
    while alive() do
        SetControlNormal(0, 1, 1.0)
        Citizen.Wait(0)
    end
    EnableControlAction(0, 1, true)
end

-- sync_mode: LOCAL
function FX_PlayerAimbot(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPlayerFreeAiming(PlayerId()) then
            local target = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if DoesEntityExist(target) and IsEntityAPed(target) and not IsPedAPlayer(target) and not IsEntityDead(target, false) then
                TaskShootAtEntity(playerPed, target, -1, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerBreak(alive)
    while alive() do
        SetVehicleCheatPowerIncrease(PlayerPedId(), 2.0)
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerBees(alive)
    while alive() do
        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed, false)
        UseParticleFxAsset("core")
        StartParticleFxLoopedOnEntity("ent_sht_pest_cont", playerPed, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
        if math.random() < 0.1 then
            SetEntityHealth(playerPed, GetEntityHealth(playerPed) - 1)
        end
        Citizen.Wait(100)
    end
end

-- sync_mode: LOCAL
function FX_PlayerBlimpStrats(alive)
    local blimpHash = GetHashKey("blimp")
    RequestModel(blimpHash)
    while not HasModelLoaded(blimpHash) do
        Citizen.Wait(0)
    end
    local playerPed = PlayerPedId()
    SetEntityInvincible(playerPed, true)
    local veh = CreateVehicle(blimpHash, -370.49, 1029.085, 345.09, 53.824, true, false)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
    SetVehicleForwardSpeed(veh, 45.0)
    TaskLeaveVehicle(playerPed, veh, 4160)
    SetModelAsNoLongerNeeded(blimpHash)
    local waited = 0
    while not IsPedGettingUp(playerPed) and waited < 100 do
        Citizen.Wait(100)
        waited = waited + 1
    end
    SetEntityInvincible(playerPed, false)
    RequestCutscene("fbi_1_int", 8)
    while not HasCutsceneLoaded() do
        Citizen.Wait(0)
    end
    RegisterEntityForCutscene(playerPed, "MICHAEL", 0, 0, 64)
    StartCutscene(0)
    Citizen.Wait(6500)
    StopCutsceneImmediately()
    RemoveCutscene()
    local daveHash = GetHashKey("ig_davenorton")
    RequestModel(daveHash)
    while not HasModelLoaded(daveHash) do
        Citizen.Wait(0)
    end
    local pedDave = CreatePed(4, daveHash, -442.2, 1059.25, 326.66, 180.6, true, false)
    SetModelAsNoLongerNeeded(daveHash)
    TaskPlayAnim(pedDave, "missfbi1leadinout", "fbi_1_int_leadin_loop_daven", 8.0, 1.0, -1, 1, 0.0, false, false, false)
    SetPedKeepTask(pedDave, true)
    SetPedAsNoLongerNeeded(pedDave)
    SetVehicleAsNoLongerNeeded(veh)
end

-- sync_mode: LOCAL
function FX_PlayerClone(alive)
    local playerPed = PlayerPedId()
    local model = GetEntityModel(playerPed)
    local coords = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end
    local clone = CreatePed(GetPedType(playerPed), model, coords.x + 1.0, coords.y, coords.z, heading, true, false)
    ClonePedToTarget(playerPed, clone)
    SetModelAsNoLongerNeeded(model)
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayerCopyforce(alive)
    while alive() do
        local playerPed = PlayerPedId()
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        if playerVeh ~= 0 then
            local vel = GetEntityVelocity(playerVeh)
            OwnershipGuard.ForEachOwnedVehicle(function(veh)
                if DoesEntityExist(veh) and veh ~= playerVeh then
                    ApplyForceToEntityCenterOfMass(veh, 1, vel.x * 5.0, vel.y * 5.0, vel.z, true, false, true, true)
                end
            end)
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerDeadEye(alive)
    local didSelect = false
    local isBlocked = false
    while alive() do
        local player = PlayerPedId()
        local weaponHash = GetSelectedPedWeapon(player, true)
        if weaponHash ~= 0 and not isBlocked then
            local tgi = GetWeapontypeGroup(weaponHash)
            if tgi ~= -764164997 and tgi ~= -1207784977 and weaponHash ~= 1122106729 and weaponHash ~= 3059529913 then
                if IsControlPressed(0, 25) then
                    SetTimeScale(0.2)
                    DisableControlAction(0, 24, true)
                    DisableControlAction(2, 257, true)
                    if IsDisabledControlPressed(0, 24) or IsDisabledControlPressed(2, 257) then
                        if not didSelect then
                            local camCoords = GetGameplayCamCoord()
                            local camDir = GetGameplayCamRot(2)
                            local targPos = camCoords + (
                                vector3(math.sin(camDir.z * math.pi/180) * -1, math.cos(camDir.z * math.pi/180) * -1, math.sin(camDir.x * math.pi/180))
                                * 10000.0
                            )
                            local ray = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, targPos.x, targPos.y, targPos.z, 12, player, 7)
                            local _, hit, hitCoords, _, entityHandle = GetShapeTestResult(ray)
                            if hit and IsEntityAPed(entityHandle) then
                                local boneIds = {0x0, 0x2e28, 0xe39f, 0xf9bb, 0x3779, 0xca72, 0x9000, 0xcc4d, 0xe0fd, 0x5c01, 0x60f0, 0x60f1, 0x60f2, 0xfcd9, 0xb1c5, 0xeeeb, 0x49d9, 0x29d2, 0x9d4d, 0x6e5c, 0xdead, 0x9995, 0x796e}
                                local bestBone = boneIds[1]
                                local bestDist = 99999.0
                                for _, bid in ipairs(boneIds) do
                                    local bc = GetPedBoneCoords(entityHandle, bid, 0.0, 0.0, 0.0)
                                    local dist = #(hitCoords - bc)
                                    if dist < bestDist then
                                        bestDist = dist
                                        bestBone = bid
                                    end
                                end
                                didSelect = true
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
    SetTimeScale(1.0)
end

-- sync_mode: LOCAL
function FX_PlayerDrunk(alive)
    RequestAnimSet("move_m@drunk@verydrunk")
    while alive() do
        SetPedMovementClipset(PlayerPedId(), "move_m@drunk@verydrunk", 1.0)
        ShakeGameplayCam("DRUNK_SHAKE", 1.0)
        SetPedIsDrunk(PlayerPedId(), true)
        Citizen.Wait(100)
    end
    ResetPedMovementClipset(PlayerPedId(), 0.0)
    StopGameplayCamShaking(true)
end

-- sync_mode: LOCAL
function FX_PlayerFakedeath(alive)
    local playerPed = PlayerPedId()
    local currentMode = 0
    local lastModeTime = 0
    local nextModeTime = 0
    RequestScriptAudioBank("OFFMISSION_WASTED", false, -1)
    -- This effect is timed by effects_runner. Honour its cancellation so a
    -- fake death cannot leave the player invincible after the effect expires.
    while alive() and currentMode < 4 do
        Citizen.Wait(0)
        if currentMode > 1 then
            HideHudAndRadarThisFrame()
        end
        local curTime = GetGameTimer()
        if curTime - lastModeTime <= nextModeTime then
            -- still waiting, skip rest
        elseif currentMode == 0 then
            nextModeTime = 1000
            lastModeTime = curTime
            currentMode = 1
        elseif currentMode == 1 then
            SetPlayerInvincible(PlayerId(), true)
            if math.random(0, 1) == 0 then
                if not IsPedInAnyVehicle(playerPed, false) then
                    if IsPedOnFoot(playerPed) and GetPedParachuteState(playerPed) == -1 then
                        RequestAnimDict("mp_suicide")
                        while alive() and not HasAnimDictLoaded("mp_suicide") do Citizen.Wait(0) end
                        GiveWeaponToPed(playerPed, GetHashKey("WEAPON_PISTOL"), 1, true, true)
                        TaskPlayAnim(playerPed, "mp_suicide", "pistol", 8.0, -1.0, 1150, 1, 0.0, false, false, false)
                        nextModeTime = 750
                    end
                elseif IsPedInAnyVehicle(playerPed, false) then
                    local veh = GetVehiclePedIsIn(playerPed, false)
                    local detonateTimer = 5000
                    local beepTimer = 5000
                    local lastTimestamp = GetGameTimer()
                    local exploding = true
                    while alive() and DoesEntityExist(veh) and exploding do
                        Citizen.Wait(0)
                        local curTimestamp = GetGameTimer()
                        detonateTimer = detonateTimer - (curTimestamp - lastTimestamp)
                        lastTimestamp = curTimestamp
                        if detonateTimer < beepTimer then
                            beepTimer = beepTimer * 0.8
                            PlaySoundFromEntity(-1, "Beep_Red", veh, "DLC_HEIST_HACKING_SNAKE_SOUNDS", true, false)
                        end
                        if detonateTimer <= 0 then
                            exploding = false
                            ExplodeVehicle(veh, true, false)
                        end
                        if not IsPedInVehicle(playerPed, veh, false) then
                            exploding = false
                        end
                    end
                    nextModeTime = 2000
                end
            end
            if nextModeTime == 999999 then
                nextModeTime = 2000
            end
            currentMode = 2
            lastModeTime = GetGameTimer()
        elseif currentMode == 2 then
            SetPlayerInvincible(PlayerId(), true)
            PlaySoundFrontend(-1, "Bed", "WastedSounds", true)
            nextModeTime = 5000
            lastModeTime = curTime
            currentMode = 3
        elseif currentMode == 3 then
            SetPlayerInvincible(PlayerId(), true)
            nextModeTime = 1500
            lastModeTime = curTime
            currentMode = 4
        end
    end
    SetPlayerInvincible(PlayerId(), false)
    ClearPedTasksImmediately(playerPed)
    SetEntityHealth(playerPed, 200)
    ReleaseNamedScriptAudioBank("OFFMISSION_WASTED")
end

-- sync_mode: VISUAL
function FX_PlayerFlingPlayer(alive)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed, false)
    AddExplosion(pos.x, pos.y, pos.z - 1.0, 9, 100.0, true, false, 10.0, false)
    SetEntityInvincible(playerPed, true)
    Citizen.Wait(100)
    SetEntityInvincible(playerPed, false)
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayerForcefield(alive)
    while alive() do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed, false)
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and veh ~= playerVeh then
                local pos = GetEntityCoords(veh, false)
                local dist = #(pos - playerPos)
                if dist < 15.0 and dist > 0.0 then
                    local dir = (pos - playerPos) / dist
                    ApplyForceToEntityCenterOfMass(veh, 1, dir.x * 50.0, dir.y * 50.0, 5.0, true, false, true, true)
                end
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayerGravSphere(alive)
    while alive() do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed, false)
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if DoesEntityExist(ped) then
                local pos = GetEntityCoords(ped, false)
                local dist = #(pos - playerPos)
                if dist < 20.0 and dist > 0.0 then
                    local dir = (playerPos - pos) / dist
                    local strength = (20.0 - dist) / 20.0 * 10.0
                    SetPedToRagdoll(ped, 100, 100, 0, false, false, false)
                    ApplyForceToEntityCenterOfMass(ped, 1, dir.x * strength, dir.y * strength, dir.z * strength + 2.0, true, false, true, true)
                end
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerGta2(alive)
    while alive() do
        SetTimeScale(0.5)
        Citizen.Wait(0)
    end
    SetTimeScale(1.0)
end

-- sync_mode: LOCAL
function FX_PlayerHacking(alive)
    local scaleform = RequestScaleformMovieInteractive("Hacking_PC")
    while not HasScaleformMovieLoaded(scaleform) do Citizen.Wait(0) end
    BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND")
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(scaleform, "SET_ROULETTE_WORD")
    PushScaleformMovieMethodParameterString("CHAOS")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(scaleform, "RUN_PROGRAM")
    ScaleformMovieMethodAddParamInt(1)
    EndScaleformMovieMethod()
    SetPlayerControl(PlayerId(), false, 0)
    local hackingState = true
    while alive() and hackingState do
        Citizen.Wait(0)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
        if IsControlJustPressed(2, 201) then
            BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT_SELECT")
            local selectReturn = EndScaleformMovieMethodReturnValue()
            Citizen.Wait(50)
            if selectReturn > 0 and IsScaleformMovieMethodReturnValueReady(selectReturn) then
                local result = GetScaleformMovieMethodReturnValueInt(selectReturn)
                if result == 1 then
                    hackingState = false
                end
            end
        end
    end
    SetScaleformMovieAsNoLongerNeeded(scaleform)
    SetPlayerControl(PlayerId(), true, 0)
end

-- sync_mode: LOCAL
function FX_PlayerGravity(alive)
    local playerPed = PlayerPedId()
    while alive() do
        SetEntityHasGravity(playerPed, false)
        local vel = GetEntityVelocity(playerPed)
        SetEntityVelocity(playerPed, vel.x, vel.y, vel.z - 5.0)
        Citizen.Wait(0)
    end
    SetEntityHasGravity(playerPed, true)
end

-- sync_mode: LOCAL
function FX_PlayerHeavyrecoil(alive)
    local verticalRecoil = 1.0
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedShooting(playerPed) then
            local weaponHash = GetSelectedPedWeapon(playerPed)
            if weaponHash ~= 0 and GetWeaponDamageType(weaponHash) == 3 then
                local horizontalRecoil = (math.random(-100, 100)) / 10.0
                for i = 1, 10 do
                    SetGameplayCamRelativePitch(GetGameplayCamRelativePitch() + (verticalRecoil / 10.0), 1.0)
                    SetGameplayCamRelativeHeading(GetGameplayCamRelativeHeading() + (horizontalRecoil / 10.0))
                    Citizen.Wait(0)
                end
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerHeal(alive)
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
    SetPedArmour(playerPed, 100)
    AddArmourToPed(playerPed, 100)
end

-- sync_mode: LOCAL
function FX_PlayerIgnite(alive)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        SetVehicleEngineHealth(playerVeh, -1.0)
        SetVehiclePetrolTankHealth(playerVeh, -1.0)
        SetVehicleBodyHealth(playerVeh, -1.0)
    else
        StartEntityFire(playerPed)
        Citizen.Wait(5000)
        StopEntityFire(playerPed)
    end
end

-- sync_mode: LOCAL
function FX_PlayerIllegalinnocence(alive)
    ClearPlayerWantedLevel(PlayerId())
    while alive() do
        SetMaxWantedLevel(0)
        Citizen.Wait(0)
    end
    SetMaxWantedLevel(5)
end

-- sync_mode: LOCAL
function FX_PlayerTired(alive)
    while alive() do
        Citizen.Wait(1000)
        SetPedToRagdoll(PlayerPedId(), 1500, 1500, 0, true, true, false)
    end
end

-- sync_mode: LOCAL
function FX_PlayerInvincible(alive)
    while alive() do
        SetPlayerInvincible(PlayerId(), true)
        Citizen.Wait(0)
    end
    SetPlayerInvincible(PlayerId(), false)
end

-- sync_mode: LOCAL
function FX_PlayerJumpJump(alive)
    while alive() do
        SetSuperJumpThisFrame(PlayerId())
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerKeeprunning(alive)
    while alive() do
        SimulatePlayerInputGait(PlayerId(), 5.0, 100, 1.0, true, false)
        SetControlNormal(0, 32, 1.0)
        SetControlNormal(0, 71, 1.0)
        SetControlNormal(0, 77, 1.0)
        SetControlNormal(0, 87, 1.0)
        SetControlNormal(0, 129, 1.0)
        SetControlNormal(0, 136, 1.0)
        SetControlNormal(0, 150, 1.0)
        SetControlNormal(0, 232, 1.0)
        SetControlNormal(0, 280, 1.0)
        DisableControlAction(0, 72, true)
        DisableControlAction(0, 76, true)
        DisableControlAction(0, 88, true)
        DisableControlAction(0, 138, true)
        DisableControlAction(0, 139, true)
        DisableControlAction(0, 152, true)
        DisableControlAction(0, 153, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 44, true)
        DisableControlAction(0, 50, true)
        DisableControlAction(0, 68, true)
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerKickflip(alive)
    local playerPed = PlayerPedId()
    local entityToFlip
    if IsPedInAnyVehicle(playerPed, false) then
        entityToFlip = GetVehiclePedIsIn(playerPed, false)
    else
        entityToFlip = playerPed
        SetPedToRagdoll(playerPed, 200, 0, 0, true, true, false)
    end
    ApplyForceToEntity(entityToFlip, 1, 0.0, 0.0, 10.0, 2.0, 0.0, 0.0, 0.0, 1, true, true, true, false, true)
end

-- sync_mode: LOCAL
function FX_PlayerLaggyCamera(alive)
    while alive() do
        ShakeGameplayCam("HAND_SHAKE", 1.5)
        Citizen.Wait(0)
    end
    StopGameplayCamShaking(true)
end

-- sync_mode: LOCAL
function FX_PlayerUpupaway(alive)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        local playerVel = GetEntityVelocity(playerVeh)
        SetEntityVelocity(playerVeh, playerVel.x, playerVel.y, 100.0)
    else
        local playerVel = GetEntityVelocity(playerPed)
        SetPedToRagdoll(playerPed, 10000, 10000, 0, true, true, false)
        Citizen.Wait(0)
        SetEntityVelocity(playerPed, playerVel.x, playerVel.y, 100.0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerLockcamera(alive)
    local playerPed = PlayerPedId()
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local pos = GetEntityCoords(playerPed, false)
    SetCamCoord(cam, pos.x, pos.y, pos.z)
    SetCamRot(cam, GetGameplayCamRot(2).x, GetGameplayCamRot(2).y, GetGameplayCamRot(2).z, 2)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 0, true, true)
    while alive() do
        SetCamCoord(cam, GetEntityCoords(playerPed).x, GetEntityCoords(playerPed).y, GetEntityCoords(playerPed).z)
        Citizen.Wait(0)
    end
    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(cam, true)
end

-- sync_mode: LOCAL
function FX_PlayerMovementx5(alive)
    while alive() do
        SetPedMoveRateOverride(PlayerPedId(), 5.0)
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerMovementx10(alive)
    while alive() do
        SetPedMoveRateOverride(PlayerPedId(), 10.0)
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerMovementx05(alive)
    while alive() do
        SetPedMoveRateOverride(PlayerPedId(), 0.5)
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerNoRandomMovement(alive)
    while alive() do
        SetPedRandomComponentVariation(PlayerPedId(), false)
        SetPedRandomProps(PlayerPedId(), false)
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerNospecial(alive)
    while alive() do
        SpecialAbilityDepleteMeter(PlayerId(), true, 0)
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerNosprint(alive)
    while alive() do
        DisableControlAction(0, 21, true)
        DisableControlAction(0, 22, true)
        Citizen.Wait(0)
    end
end

local lastPlayerKills = 0

-- sync_mode: LOCAL
function FX_PlayerPacifist(alive)
    lastPlayerKills = -1
    while alive() do
        local playerPed = PlayerPedId()
        local allPlayerKills = 0
        local statHashes = {
            GetHashKey("SP0_KILLS"),
            GetHashKey("SP1_KILLS"),
            GetHashKey("SP2_KILLS")
        }
        for _, hash in ipairs(statHashes) do
            local curKills = GetStatInt(hash, -1)
            if curKills then
                allPlayerKills = allPlayerKills + curKills
            end
        end
        if lastPlayerKills >= 0 and allPlayerKills > lastPlayerKills then
            StartEntityFire(playerPed)
            SetEntityHealth(playerPed, 0, 0)
        end
        lastPlayerKills = allPlayerKills
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_PlayerPoof(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if GetEntityPlayerIsFreeAimingAt(playerPed) then
            local target = GetEntityPlayerIsFreeAimingAt(playerPed)
            if DoesEntityExist(target) and (IsEntityAPed(target) or IsEntityAVehicle(target)) and not IsEntityDead(target, false) then
                local pos = GetEntityCoords(target, false)
                SetEntityHealth(target, 0)
                SetEntityInvincible(target, false)
                AddExplosion(pos.x, pos.y, pos.z, 9, 100.0, true, false, 3.0, false)
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_Poorboi(alive)
    StatSetInt(GetHashKey("SP0_TOTAL_CASH"), 0, true)
    StatSetInt(GetHashKey("SP1_TOTAL_CASH"), 0, true)
    StatSetInt(GetHashKey("SP2_TOTAL_CASH"), 0, true)
    SetPedMoney(PlayerPedId(), 0)
end

-- sync_mode: LOCAL
function FX_PlayerRagdoll(alive)
    local playerPed = PlayerPedId()
    ClearPedTasksImmediately(playerPed)
    SetPedToRagdoll(playerPed, 10000, 10000, 0, true, true, false)
end
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
    -- Do not outlive the dispatcher timer. The old infinite loop kept the
    -- player invincible forever when the effect was cancelled or restarted.
    while alive() and launchTimer > 0 do
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
    SetEntityInvincible(playerPed, false)
    SetPlayerInvincible(PlayerId(), false)
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
    local zoomCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    RenderScriptCams(true, true, 10, true, true)

    while alive() do
        local curTick = GetGameTimer()
        local camZoom = math.sin(curTick * 0.0015) * 30.0 + 70.0
        SetCamActive(zoomCamera, true)
        local coord = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        SetCamParams(zoomCamera, coord.x, coord.y, coord.z, rot.x, rot.y, rot.z, camZoom, 0, 1, 1, 2)
        Citizen.Wait(0)
    end

    SetCamActive(zoomCamera, false)
    RenderScriptCams(false, true, 700, true, true)
    DestroyCam(zoomCamera, true)
end

-- sync_mode: VISUAL
function FX_PlayerBinoculars(alive)
    local fovCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
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
    local flippedCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
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
    local fovCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
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
-- sync_mode: VISUAL
function FX_PlayerSpinCamera(alive)
    local camRot = 0.0
    local camRotRate = 5.0
    local spinningCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    RenderScriptCams(true, true, 10, true, true)

    while alive() do
        camRot = camRot + camRotRate
        SetCamActive(spinningCamera, true)
        local coord = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        local fov = GetGameplayCamFov()
        SetCamParams(spinningCamera, coord.x, coord.y, coord.z, rot.x, camRot, rot.z, fov, 0, 1, 1, 2)
        Citizen.Wait(0)
    end

    SetCamActive(spinningCamera, false)
    RenderScriptCams(false, true, 700, true, true)
    DestroyCam(spinningCamera, true)
end

-- sync_mode: VISUAL
function FX_ScreenMexico(alive)
    while alive() do
        SetTransitionTimecycleModifier("trevorspliff", 5.0)
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenBright(alive)
    while alive() do
        SetTransitionTimecycleModifier("mp_x17dlc_int_02", 5.0)
        SetTimecycleModifierStrength(1.0)
        SetWeatherTypeNow("EXTRASUNNY")
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetVehicleLights(veh, 0)
        SetVehicleLightMultiplier(veh, 1.0)
    end)
end

-- sync_mode: VISUAL
function FX_ScreenFog(alive)
    while alive() do
        SetTransitionTimecycleModifier("prologue_ending_fog", 5.0)
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenLowrenderdist(alive)
    while alive() do
        SetTransitionTimecycleModifier("Mp_apart_mid", 5.0)
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenLsd(alive)
    while alive() do
        SetTimecycleModifier("drug_drive_blend01")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenFullbright(alive)
    SetClockTime(0, 0, 0)
    while alive() do
        SetTransitionTimecycleModifier("int_lesters", 5.0)
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenBubblevision(alive)
    while alive() do
        SetTransitionTimecycleModifier("ufo_deathray", 5.0)
        SetTimecycleModifierStrength(1.0)
        SetAudioSpecialEffectMode(1)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenLsnoire(alive)
    while alive() do
        SetTimecycleModifier("NG_filmic01")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenNeedglasses(alive)
    while alive() do
        SetTransitionTimecycleModifier("hud_def_blur", 5.0)
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_TimecycleFuzzy(alive)
    while alive() do
        SetTransitionTimecycleModifier("Broken_camera_fuzz", 5.0)
        SetTimecycleModifierStrength(0.5)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_TimecycleDarkworld(alive)
    while alive() do
        SetArtificialLightsState(true)
        SetTransitionTimecycleModifier("dlc_island_vault", 5.0)
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    SetArtificialLightsState(false)
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenArc(alive)
    while alive() do
        SetTimecycleModifier("trevorspliff")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenColorfulworld(alive)
    while alive() do
        SetTimecycleModifier("ufo_deathray")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenDimwarp(alive)
    while alive() do
        SetTimecycleModifier("hud_def_blur")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenFckautorotate(alive)
    while alive() do
        SetTimecycleModifier("Tunnel")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenFoldedscreen(alive)
    while alive() do
        SetTimecycleModifier("Tunnel")
        SetTimecycleModifierStrength(0.8)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenFourthdimension(alive)
    while alive() do
        SetTimecycleModifier("phone_cam8")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenHueshift(alive)
    while alive() do
        SetTimecycleModifier("phone_cam8")
        SetTimecycleModifierStrength(0.7)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenInvertedcolors(alive)
    while alive() do
        SetTimecycleModifier("ArenaEMP")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenLocalcoop(alive)
    while alive() do
        SetTimecycleModifier("yell_tunnel_nodirect")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenMirrored(alive)
    while alive() do
        SetTimecycleModifier("hud_def_blur")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenRgbland(alive)
    while alive() do
        SetTimecycleModifier("ufo_deathray")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenScreenfreakout(alive)
    while alive() do
        SetTimecycleModifier("trevorspliff")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenScreenpotato(alive)
    while alive() do
        SetTimecycleModifier("Mp_apart_mid")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenShatteredscreen(alive)
    while alive() do
        SetTimecycleModifier("Broken_camera_fuzz")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenSwappedcolors(alive)
    while alive() do
        SetTimecycleModifier("ArenaEMP")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenTextureless(alive)
    while alive() do
        SetTimecycleModifier("int_lesters")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenTnpanel(alive)
    while alive() do
        SetTimecycleModifier("Tunnel")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_ScreenWarpedcam(alive)
    while alive() do
        SetTimecycleModifier("Tunnel")
        SetTimecycleModifierStrength(1.0)
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
end

-- sync_mode: VISUAL
function FX_TimeMorning(alive)
    while alive() do
        NetworkOverrideClockTime(8, 0, 0)
        Citizen.Wait(1000)
    end
    NetworkClearClockTimeOverride()
end

-- sync_mode: VISUAL
function FX_TimeDay(alive)
    while alive() do
        NetworkOverrideClockTime(12, 0, 0)
        Citizen.Wait(1000)
    end
    NetworkClearClockTimeOverride()
end

-- sync_mode: VISUAL
function FX_TimeEvening(alive)
    while alive() do
        NetworkOverrideClockTime(18, 0, 0)
        Citizen.Wait(1000)
    end
    NetworkClearClockTimeOverride()
end

-- sync_mode: VISUAL
function FX_TimeNight(alive)
    while alive() do
        NetworkOverrideClockTime(0, 0, 0)
        Citizen.Wait(1000)
    end
    NetworkClearClockTimeOverride()
end

-- sync_mode: VISUAL
function FX_TimeQuickday(alive)
    while alive() do
        AddToClockTime(0, 1, 0)
        Citizen.Wait(0)
    end
end

-- sync_mode: VISUAL
function FX_TimeLocalTime(alive)
    while alive() do
        NetworkOverrideClockTime(GetClockHours(), GetClockMinutes(), GetClockSeconds())
        Citizen.Wait(1000)
    end
    NetworkClearClockTimeOverride()
end

-- sync_mode: LOCAL
function FX_TimeX02(alive)
    while alive() do
        SetAudioFlag("AllowScriptedSpeechInSlowMo", true)
        SetAudioFlag("AllowAmbientSpeechInSlowMo", true)
        SetTimeScale(0.2)
        Citizen.Wait(0)
    end
    SetAudioFlag("AllowScriptedSpeechInSlowMo", false)
    SetAudioFlag("AllowAmbientSpeechInSlowMo", false)
    SetTimeScale(1.0)
end

-- sync_mode: LOCAL
function FX_TimeX05(alive)
    while alive() do
        SetAudioFlag("AllowScriptedSpeechInSlowMo", true)
        SetAudioFlag("AllowAmbientSpeechInSlowMo", true)
        SetTimeScale(0.5)
        Citizen.Wait(0)
    end
    SetAudioFlag("AllowScriptedSpeechInSlowMo", false)
    SetAudioFlag("AllowAmbientSpeechInSlowMo", false)
    SetTimeScale(1.0)
end

-- sync_mode: LOCAL
function FX_TimeSuperhot(alive)
    local lastCheck = 0
    while alive() do
        local currentTime = GetGameTimer()
        if currentTime - lastCheck > 100 then
            lastCheck = currentTime
            local playerPed = PlayerPedId()
            local gameSpeed = 1.0
            if not IsPedGettingIntoAVehicle(playerPed) and not IsPedClimbing(playerPed)
               and not IsPedDiving(playerPed) and not IsPedJumpingOutOfVehicle(playerPed)
               and not IsPedRagdoll(playerPed) and not IsPedGettingUp(playerPed) then
                local speed = GetEntitySpeed(playerPed)
                gameSpeed = math.max(math.min(speed, 4.0) / 4.0, 0.2)
            end
            SetTimeScale(gameSpeed)
        end
        Citizen.Wait(0)
    end
    SetTimeScale(1.0)
end

-- sync_mode: GLOBAL_OWNED
function FX_Veh30mphlimit(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and not IsPedAPlayer(GetPedInVehicleSeat(veh, -1, false)) then
                SetEntityMaxSpeed(veh, 13.41)
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsHonkconstant(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                SetHornPermanentlyOn(veh, true)
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsUpupaway(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        local vel = GetEntityVelocity(veh)
        SetEntityVelocity(veh, vel.x, vel.y, 100.0)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsBeyblade(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and IsVehicleSeatFree(veh, -1, false) then
                ApplyForceToEntity(veh, 3, 100.0, 0.0, 0.0, 0.0, 4.0, 0.0, 0, true, true, true, true, true)
                ApplyForceToEntity(veh, 3, -100.0, 0.0, 0.0, 0.0, -4.0, 0.0, 0, true, true, true, true, true)
                SetEntityInvincible(veh, true)
            end
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetEntityInvincible(veh, false)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehBoostbrake(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                local speed = GetEntitySpeed(veh)
                if speed > 1.0 and GetEntityHeightAboveGround(veh) <= 2.0 then
                    SetVehicleForwardSpeed(veh, speed * -1.5)
                end
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehBouncy(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and HasEntityCollidedWithAnything(veh) then
                local vel = GetEntityVelocity(veh)
                local factor = (vel.x < 10 and vel.y < 10 and vel.z < 10) and 300.0 or 60.0
                ApplyForceToEntity(veh, 0, vel.x * -factor, vel.y * -factor, vel.z * -factor, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehBrakeboost(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                local vehClass = GetVehicleClass(veh)
                if vehClass ~= 15 and vehClass ~= 16 then
                    ApplyForceToEntity(veh, 0, 0.0, 50.0, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
                end
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayervehBreakdoors(alive)
    local count = 10
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        for i = 0, 5 do
            SetVehicleDoorBroken(veh, i, false)
            count = count - 1
            if count == 0 then
                count = 10
                Citizen.Wait(0)
            end
        end
    end)
end

-- sync_mode: LOCAL
function FX_PlayerForcedcinematiccam(alive)
    while alive() do
        SetPlayerCanDoDriveBy(PlayerId(), false)
        SetCinematicModeActive(true)
        DisableControlAction(0, 80, true)
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            DisableControlAction(0, 27, true)
            DisableControlAction(0, 0, true)
        end
        Citizen.Wait(0)
    end
    SetCinematicModeActive(false)
    SetPlayerCanDoDriveBy(PlayerId(), true)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsRed(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            ToggleVehicleMod(veh, 20, true)
            SetVehicleTyreSmokeColor(veh, 255, 0, 0)
            SetVehicleCustomPrimaryColour(veh, 255, 0, 0)
            SetVehicleCustomSecondaryColour(veh, 255, 0, 0)
            SetVehicleEnveffScale(veh, 0.0)
            SetVehicleDirtLevel(veh, 0.0)
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsBlue(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            ToggleVehicleMod(veh, 20, true)
            SetVehicleTyreSmokeColor(veh, 0, 0, 255)
            SetVehicleCustomPrimaryColour(veh, 0, 0, 255)
            SetVehicleCustomSecondaryColour(veh, 0, 0, 255)
            SetVehicleEnveffScale(veh, 0.0)
            SetVehicleDirtLevel(veh, 0.0)
        end)
        Citizen.Wait(0)
    end
end
-- sync_mode: GLOBAL_OWNED
function FX_VehsGreen(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            ToggleVehicleMod(veh, 20, true)
            SetVehicleTyreSmokeColor(veh, 0, 255, 0)
            SetVehicleCustomPrimaryColour(veh, 0, 255, 0)
            SetVehicleCustomSecondaryColour(veh, 0, 255, 0)
            SetVehicleEnveffScale(veh, 0.0)
            SetVehicleDirtLevel(veh, 0.0)
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsChrome(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            ToggleVehicleMod(veh, 20, true)
            SetVehicleTyreSmokeColor(veh, 219, 226, 233)
            ClearVehicleCustomPrimaryColour(veh)
            ClearVehicleCustomSecondaryColour(veh)
            SetVehicleColours(veh, 120, 120)
            SetVehicleEnveffScale(veh, 0.0)
            SetVehicleDirtLevel(veh, 0.0)
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsPink(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) then
            SetVehicleCustomPrimaryColour(veh, 255, 105, 180)
            SetVehicleCustomSecondaryColour(veh, 255, 105, 180)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsRainbow(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                SetVehicleCustomPrimaryColour(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
                SetVehicleCustomSecondaryColour(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
            end
        end)
        Citizen.Wait(500)
    end
end

-- sync_mode: LOCAL
function FX_VehsCruiseControl(alive)
    local currentVel = -1.0
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            if IsVehicleOnAllWheels(veh) then
                local speed = GetEntitySpeed(veh)
                if speed > currentVel or speed < currentVel / 2 or speed < 1 then
                    currentVel = speed
                elseif speed < currentVel then
                    SetVehicleForwardSpeed(veh, currentVel)
                end
            else
                currentVel = -1.0
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsCrumble(alive)
    while alive() do
        local vehs = {}
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            table.insert(vehs, veh)
        end)
        if #vehs > 0 then
            local veh = vehs[math.random(#vehs)]
            SetVehicleDamage(veh,
                (-1.0 + math.random() * 2.0),
                (-1.0 + math.random() * 2.0),
                (-1.0 + math.random() * 2.0),
                (1000.0 + math.random() * 9000.0),
                (100.0 + math.random() * 900.0),
                true)
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: LOCAL
function FX_VehsDetachWheel(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    local wheelBones = {
        "wheel_lf", "wheel_rf", "wheel_lm", "wheel_rm",
        "wheel_lr", "wheel_rr", "wheel_lm1", "wheel_rm1",
    }
    local wheels = {}
    for _, boneName in ipairs(wheelBones) do
        local idx = GetEntityBoneIndexByName(veh, boneName)
        if idx ~= -1 then
            table.insert(wheels, idx)
        end
    end
    if #wheels > 0 then
        local pick = wheels[math.random(#wheels)]
        for i = 0, 7 do
            SetVehicleTyreBurst(veh, i, true, 1000.0)
        end
    end
end

-- sync_mode: LOCAL
function FX_VehsDisassemble(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    for i = 0, 49 do
        SetVehicleDoorBroken(veh, i, true)
    end
    for i = 0, 7 do
        SetVehicleTyreBurst(veh, i, true, 1000.0)
    end
    SetVehicleEngineHealth(veh, -4000.0)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsX2engine(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            ModifyVehicleTopSpeed(veh, 2.0)
            SetVehicleCheatPowerIncrease(veh, 2.0)
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        ModifyVehicleTopSpeed(veh, 1.0)
        SetVehicleCheatPowerIncrease(veh, 1.0)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsX10engine(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            ModifyVehicleTopSpeed(veh, 10.0)
            SetVehicleCheatPowerIncrease(veh, 10.0)
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        ModifyVehicleTopSpeed(veh, 1.0)
        SetVehicleCheatPowerIncrease(veh, 1.0)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsX05engine(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            ModifyVehicleTopSpeed(veh, 0.5)
            SetVehicleCheatPowerIncrease(veh, 0.5)
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        ModifyVehicleTopSpeed(veh, 1.0)
        SetVehicleCheatPowerIncrease(veh, 1.0)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsExplode(alive)
    local playerVeh = GetVehiclePedIsIn(PlayerPedId(), false)
    local count = 3
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if veh ~= playerVeh then
            ExplodeVehicle(veh, true, false)
            count = count - 1
            if count == 0 then
                count = 3
                Citizen.Wait(0)
            end
        end
    end)
end

-- sync_mode: LOCAL
function FX_VehsFlyingcars(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            local vehClass = GetVehicleClass(veh)
            if vehClass ~= 15 and vehClass ~= 16 then
                local speed = GetEntitySpeed(veh)
                if speed > 5.0 then
                    local fwd = GetEntityForwardVector(veh)
                    local deltaSpeed = 10.0 * GetFrameTime()
                    local vel = GetEntityVelocity(veh)
                    DisableControlAction(0, 68, true)
                    DisableControlAction(0, 69, true)
                    if IsControlPressed(0, 71) then
                        vel = vector3(fwd.x * (speed + deltaSpeed), fwd.y * (speed + deltaSpeed), vel.z)
                    end
                    SetEntityVelocity(veh, vel.x, vel.y, vel.z)
                    local rot = GetEntityRotation(veh, 2)
                    local deltaAngle = 80.0 * GetFrameTime()
                    if IsControlPressed(0, 63) then rot = vector3(rot.x, rot.y, rot.z + deltaAngle) end
                    if IsControlPressed(0, 64) then rot = vector3(rot.x, rot.y, rot.z - deltaAngle) end
                    if IsControlPressed(0, 108) then rot = vector3(rot.x, rot.y - deltaAngle, rot.z) end
                    if IsControlPressed(0, 109) then rot = vector3(rot.x, rot.y + deltaAngle, rot.z) end
                    if IsControlPressed(0, 111) then rot = vector3(rot.x - deltaAngle, rot.y, rot.z) end
                    if IsControlPressed(0, 112) then rot = vector3(rot.x + deltaAngle, rot.y, rot.z) end
                    SetEntityRotation(veh, rot.x, rot.y, rot.z, 2, true)
                end
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_TrafficFullaccel(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                local driver = GetPedInVehicleSeat(veh, -1, false)
                if driver ~= 0 and not IsPedAPlayer(driver) then
                    SetVehicleForwardSpeed(veh, GetVehicleModelEstimatedMaxSpeed(GetEntityModel(veh)) * 2.0)
                end
            end
        end)
        Citizen.Wait(250)
    end
end

-- MANUAL OVERRIDE from VehsGTAOTraffic.cpp
-- sync_mode: GLOBAL_OWNED
function FX_TrafficGtao(alive)
    local goneThrough = {}
    while alive() do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed, false)
        OwnershipGuard.ForEachOwnedPed(function(ped)
            if IsPedInAnyVehicle(ped, false)
            and GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1, 0) == ped
            and (function() for _,_v in ipairs(goneThrough) do if _v == ped then return false end end return true end)() then
                local veh = GetVehiclePedIsIn(ped, false)
                SetBlockingOfNonTemporaryEvents(ped, true)
                TaskVehicleMissionPedTarget(ped, veh, playerPed, 13, 9999.0, 4176732, 0.0, 0.0, false)
                table.insert(goneThrough, ped)
            end
        end)
        for i = #goneThrough, 1, -1 do
            if not DoesEntityExist(goneThrough[i]) then
                table.remove(goneThrough, i)
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsHonkboost(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and IsHornActive(veh) then
                ApplyForceToEntity(veh, 0, 0.0, 50.0, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsInvincible(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                SetEntityInvincible(veh, true)
            end
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetEntityInvincible(veh, false)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsGhost(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                SetEntityAlpha(veh, 80, false)
            end
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        ResetEntityAlpha(veh)
    end)
end

-- sync_mode: LOCAL
function FX_VehJesustakethewheel(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, true)
    local heading = GetEntityHeading(playerPed)
    local vehHash = GetHashKey("PANTO")
    RequestModel(vehHash)
    while not HasModelLoaded(vehHash) do Citizen.Wait(0) end
    local veh = CreateVehicle(vehHash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(vehHash)
    SetVehicleColours(veh, 135, 135)
    SetPedIntoVehicle(playerPed, veh, -1)
    local jesusHash = -835930287
    local group = AddRelationshipGroup("_WHEEL_JESUS")
    SetRelationshipBetweenGroups(0, group, GetHashKey("PLAYER"))
    RequestModel(jesusHash)
    while not HasModelLoaded(jesusHash) do Citizen.Wait(0) end
    local jesus = CreatePedInsideVehicle(veh, 4, jesusHash, -1, true, false)
    SetModelAsNoLongerNeeded(jesusHash)
    SetPedRelationshipGroupHash(jesus, group)
    SetEntityProofs(jesus, true, false, false, false, false, false, false, false)
    SetPedIntoVehicle(playerPed, veh, -2)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsJumpy(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and math.random() < 0.1 and not IsEntityInAir(veh) then
                ApplyForceToEntity(veh, 1, 0.0, 0.0, 10.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end)
        Citizen.Wait(100)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayervehKillengine(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) then
            SetVehicleEngineHealth(veh, 0.0)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsLockdoors(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) then
            SetVehicleDoorsLocked(veh, 2)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsNogravity(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                SetVehicleGravity(veh, false)
            end
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetVehicleGravity(veh, true)
    end)
end

-- sync_mode: VISUAL
function FX_Notraffic(alive)
    while alive() do
        SetAmbientVehicleRangeMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetVehicleDensityMultiplierThisFrame(0.0)
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsOhko(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and HasEntityCollidedWithAnything(veh) and GetEntitySpeed(veh) > 5.0 then
                ExplodeVehicle(veh, true, false)
            end
        end)
        Citizen.Wait(500)
    end
end

-- sync_mode: LOCAL
function FX_PlayervehDespawn(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    Citizen.Wait(0)
    SetEntityAsMissionEntity(veh, true, true)
    DeleteVehicle(veh)
end

-- sync_mode: LOCAL
function FX_PlayervehExplode(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    local lastTimestamp = GetGameTimer()
    local detonateTimer = 5000
    local beepTimer = 5000
    while DoesEntityExist(veh) and alive() do
        Citizen.Wait(0)
        local curTimestamp = GetGameTimer()
        detonateTimer = detonateTimer - (curTimestamp - lastTimestamp)
        lastTimestamp = curTimestamp
        if detonateTimer < beepTimer then
            beepTimer = beepTimer * 0.8
            PlaySoundFromEntity(-1, "Beep_Red", veh, "DLC_HEIST_HACKING_SNAKE_SOUNDS", true, false)
        end
        if detonateTimer <= 0 then
            ExplodeVehicle(veh, true, false)
            break
        end
        if not IsPedInVehicle(playerPed, veh, false) then break end
    end
end

-- sync_mode: LOCAL
function FX_PlayervehLock(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            SetVehicleDoorsLocked(veh, 4)
        end
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetVehicleDoorsLocked(veh, 1)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayervehPoptires(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        for i = 0, 47 do
            SetVehicleTyresCanBurst(veh, true)
            SetVehicleTyreBurst(veh, i, true, 1000.0)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehPoptire(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            for i = 0, 47 do
                if math.random(0, 1) == 1 then
                    SetVehicleTyresCanBurst(veh, true)
                    SetVehicleTyreBurst(veh, i, true, 1000.0)
                else
                    SetVehicleTyreFixed(veh, i)
                end
            end
        end)
        Citizen.Wait(1750)
    end
end

-- sync_mode: SPAWN_SINGLE
function FX_VehsPropModels(alive)
    while alive() do
        local models = {}
        OwnershipGuard.ForEachOwnedObject(function(prop)
            if DoesEntityExist(prop) then
                local model = GetEntityModel(prop)
                local min, max = GetModelDimensions(model)
                local size = #(max - min)
                if size > 0.75 and size < 6.0 then
                    models[#models + 1] = model
                end
            end
        end)
        if #models > 0 then
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed, false)
            local pick = models[math.random(#models)]
            RequestModel(pick)
            while not HasModelLoaded(pick) do Citizen.Wait(0) end
            local obj = CreateObject(pick, playerPos.x + math.random(-10, 10), playerPos.y + math.random(-10, 10), playerPos.z + 10.0, true, true, false)
            SetModelAsNoLongerNeeded(pick)
            SetObjectAsNoLongerNeeded(obj)
        end
        Citizen.Wait(1000)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehRandtraffic(alive)
    while alive() do
        local toRespawn = {}
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) and GetVehicleWindowTint(veh) ~= 3 then
                table.insert(toRespawn, veh)
            end
        end)
        for _, veh in ipairs(toRespawn) do
            local model = GetEntityModel(veh)
            local coords = GetEntityCoords(veh, false)
            local heading = GetEntityHeading(veh)
            SetEntityAsMissionEntity(veh, true, true)
            DeleteVehicle(veh)
            Citizen.Wait(0)
            RequestModel(model)
            while not HasModelLoaded(model) do Citizen.Wait(0) end
            local newVeh = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
            SetModelAsNoLongerNeeded(model)
            SetVehicleWindowTint(newVeh, 3)
            local driver = GetPedInVehicleSeat(newVeh, -1, false)
            if driver ~= 0 and DoesEntityExist(driver) and not IsPedAPlayer(driver) then
                TaskVehicleDriveWander(driver, newVeh, 40.0, 786603)
            end
        end
        Citizen.Wait(0)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_PlayervehRepair(alive)
    local count = 5
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetVehicleFixed(veh)
        SetVehicleDirtLevel(veh, 0.0)
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehiclePetrolTankHealth(veh, 1000.0)
        SetVehicleBodyHealth(veh, 1000.0)
        SetVehicleUndriveable(veh, false)
        SetVehicleOnGroundProperly(veh, 5.0)
        count = count - 1
        if count == 0 then
            count = 5
            Citizen.Wait(0)
        end
    end)
end

-- sync_mode: LOCAL
function FX_MiscReplacevehicle(alive)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local veh = GetVehiclePedIsIn(playerPed, false)
        local model = GetEntityModel(veh)
        local coords = GetEntityCoords(veh, false)
        local heading = GetEntityHeading(veh)
        SetEntityAsMissionEntity(veh, true, true)
        DeleteVehicle(veh)
        Citizen.Wait(0)
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(0) end
        local newVeh = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
        SetModelAsNoLongerNeeded(model)
        SetPedIntoVehicle(playerPed, newVeh, -1)
    else
        local coords = GetEntityCoords(playerPed, false)
        local heading = GetEntityHeading(playerPed)
        RequestModel(GetHashKey("buffalo"))
        while not HasModelLoaded(GetHashKey("buffalo")) do Citizen.Wait(0) end
        local veh = CreateVehicle(GetHashKey("buffalo"), coords.x, coords.y + 5.0, coords.z, heading, true, false)
        SetModelAsNoLongerNeeded(GetHashKey("buffalo"))
        SetPedIntoVehicle(playerPed, veh, -1)
    end
end

-- sync_mode: LOCAL
function FX_VehRepossession(alive)
    local playerPed = PlayerPedId()

    if IsPedInAnyVehicle(playerPed, false) then
        local modelHash = GetHashKey("franklin")
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Citizen.Wait(0) end

        local relationshipGroup
        AddRelationshipGroup("_WHEEL_FRANKLIN", relationshipGroup)
        SetRelationshipBetweenGroups(0, relationshipGroup, GetHashKey("PLAYER"))

        local veh = GetVehiclePedIsIn(playerPed, false)
        SetPedIntoVehicle(playerPed, veh, -2)

        local franklinDrive = CreatePedInsideVehicle(veh, 4, modelHash, -1, true, false)
        SetModelAsNoLongerNeeded(modelHash)
        SetPedRelationshipGroupHash(franklinDrive, relationshipGroup)
        SetEntityProofs(franklinDrive, true, false, false, false, false, false, false, false)

        TaskVehicleDriveToCoordLongrange(franklinDrive, veh, -52, -1106.88, 26, 9999.0, 262668, 0.0)
        SetPedKeepTask(franklinDrive, true)
        SetBlockingOfNonTemporaryEvents(franklinDrive, true)
    else
        local playerPos = GetEntityCoords(playerPed, false)
        local heading = GetEntityHeading(playerPed)

        local carModel = GetHashKey("BJXL")
        RequestModel(carModel)
        while not HasModelLoaded(carModel) do Citizen.Wait(0) end
        local veh = CreateVehicle(carModel, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
        SetModelAsNoLongerNeeded(carModel)
        SetVehicleColours(veh, 88, 0)
        SetVehicleEngineOn(veh, true, true, false)

        local modelHash = GetHashKey("franklin")
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Citizen.Wait(0) end

        local relationshipGroup
        AddRelationshipGroup("_WHEEL_FRANKLIN", relationshipGroup)
        SetRelationshipBetweenGroups(0, relationshipGroup, GetHashKey("PLAYER"))
        SetPedIntoVehicle(playerPed, veh, -2)

        local franklinDrive = CreatePedInsideVehicle(veh, 4, modelHash, -1, true, false)
        SetModelAsNoLongerNeeded(modelHash)
        SetPedRelationshipGroupHash(franklinDrive, relationshipGroup)
        SetEntityProofs(franklinDrive, true, false, false, false, false, false, false, false)

        TaskVehicleDriveToCoordLongrange(franklinDrive, veh, -52, -1106.88, 26, 9999.0, 262668, 0.0)
        SetPedKeepTask(franklinDrive, true)
        SetBlockingOfNonTemporaryEvents(franklinDrive, true)
    end
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsRotall(alive)
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        if DoesEntityExist(veh) then
            local vel = GetEntityVelocity(veh)
            local rot = GetEntityRotation(veh, 2)
            if math.random(0, 1) == 0 then
                SetEntityRotation(veh, rot.x + 180.0, rot.y, rot.z, 2, true)
            else
                SetEntityRotation(veh, rot.x, rot.y + 180.0, rot.z, 2, true)
            end
            SetEntityVelocity(veh, vel.x, vel.y, vel.z)
        end
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsSlippery(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            if DoesEntityExist(veh) then
                SetVehicleReduceGrip(veh, true)
            end
        end)
        Citizen.Wait(0)
    end
    OwnershipGuard.ForEachOwnedVehicle(function(veh)
        SetVehicleReduceGrip(veh, false)
    end)
end

-- sync_mode: GLOBAL_OWNED
function FX_VehsSpamdoors(alive)
    while alive() do
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            for i = 0, 5 do
                SetVehicleDoorOpen(veh, i, false, false)
                SetVehicleDoorCanBreak(veh, i, false)
            end
        end)
        Citizen.Wait(500)
        OwnershipGuard.ForEachOwnedVehicle(function(veh)
            SetVehicleDoorsShut(veh, false)
        end)
        Citizen.Wait(500)
    end
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnRhino(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("rhino")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnAdder(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("adder")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnDump(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("dump")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnMonster(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("monster")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnBmx(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("bmx")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnTug(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("tug")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnCargo(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("cargoplane")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnBus(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("bus")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnBlimp(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("blimp")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnBuzzard(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("buzzard")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnFaggio(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("faggio")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end

-- sync_mode: SPAWN_SINGLE
function FX_SpawnRuiner3(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local heading = GetEntityHeading(playerPed)
    local hash = GetHashKey("ruiner3")
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(0) end
    local veh = CreateVehicle(hash, playerPos.x, playerPos.y, playerPos.z, heading, true, true)
    SetModelAsNoLongerNeeded(hash)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
end
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
    while alive() do
        SetWeatherTypeNowPersist("EXTRASUNNY")
        Citizen.Wait(1000)
    end
    ClearWeatherTypePersist()
end

-- sync_mode: VISUAL
function FX_WeatherStormy(alive)
    while alive() do
        SetWeatherTypeNowPersist("THUNDER")
        Citizen.Wait(1000)
    end
    ClearWeatherTypePersist()
end

-- sync_mode: VISUAL
function FX_WeatherFoggy(alive)
    while alive() do
        SetWeatherTypeNowPersist("FOGGY")
        Citizen.Wait(1000)
    end
    ClearWeatherTypePersist()
end

-- sync_mode: VISUAL
function FX_WeatherNeutral(alive)
    while alive() do
        SetWeatherTypeNowPersist("NEUTRAL")
        Citizen.Wait(1000)
    end
    ClearWeatherTypePersist()
end

-- sync_mode: VISUAL
function FX_WeatherSnowy(alive)
    while alive() do
        SetWeatherTypeNowPersist("XMAS")
        Citizen.Wait(1000)
    end
    ClearWeatherTypePersist()
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
        SetWeatherTypeNowPersist("XMAS")
        Citizen.Wait(1000)
    end
    ClearWeatherTypePersist()
end

