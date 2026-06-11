-- MANUAL OVERRIDE from PedsKillerClowns.cpp
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
            TaskCombatPed(ped, playerPed, 0, 16)
            table.insert(clownEnemies, ped)
        end
        Citizen.Wait(0)
    end
    -- OnStop cleanup
    RemoveNamedPtfxAsset("scr_rcbarry2")
    for _, ped in ipairs(clownEnemies) do
        SetPedAsNoLongerNeeded(ped)
    end
end
