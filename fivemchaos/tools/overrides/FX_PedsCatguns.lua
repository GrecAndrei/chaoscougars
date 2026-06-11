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
