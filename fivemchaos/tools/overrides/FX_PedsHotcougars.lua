-- MANUAL OVERRIDE from PedsHotCougars.cpp
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
                    if IsPedInAnyVehicle(playerPed, true) then
                        TaskEnterVehicle(cougar, GetVehiclePedIsIn(playerPed, false), -1, -2, 2.0, 1, 0)
                    else
                        TaskCombatPed(cougar, playerPed, 0, 16)
                        SetBlockingOfNonTemporaryEvents(cougar, true)
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
            table.insert(cougarEnemies, ped)
        end
        Citizen.Wait(0)
    end
    -- OnStop cleanup
    RemoveNamedPtfxAsset("des_trailerpark")
    for _, ped in ipairs(cougarEnemies) do
        SetPedAsNoLongerNeeded(ped)
    end
end
