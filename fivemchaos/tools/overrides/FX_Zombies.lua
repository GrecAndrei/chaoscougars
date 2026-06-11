-- MANUAL OVERRIDE from PedsZombies.cpp
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
    while alive() do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed, false)
        if #ms_Zombies <= MAX_ZOMBIES then
            local ok, spawnPos = GetNthClosestVehicleNode(playerPos.x, playerPos.y, playerPos.z, 10 + #ms_Zombies, 0, 0, 0)
            if ok and spawnPos and GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, spawnPos.x, spawnPos.y, spawnPos.z, false) < 300.0 then
                LoadModel(MODEL_HASH)
                local zombie = CreatePed(26, MODEL_HASH, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, false)
                table.insert(ms_Zombies, zombie)
                SetPedRelationshipGroupHash(zombie, zombieGroupHash)
                SetPedCombatAttributes(zombie, 5, true)
                SetPedCombatAttributes(zombie, 46, true)
                DisablePedPainAudio(zombie, true)
                TaskCombatPed(zombie, playerPed, 0, 16)
                SetModelAsNoLongerNeeded(MODEL_HASH)
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
    -- OnStop cleanup
    for _, ped in ipairs(ms_Zombies) do
        if DoesEntityExist(ped) then
            SetPedAsNoLongerNeeded(ped)
        end
    end
end
