function FX_MiscStuffguns(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
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
                    if thing and DoesEntityExist(thing) then
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
        Citizen.Wait(0)
    end
end
