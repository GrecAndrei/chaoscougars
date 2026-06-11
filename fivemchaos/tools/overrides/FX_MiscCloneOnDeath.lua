-- MANUAL OVERRIDE from MiscCloneOnDeath.cpp
function FX_MiscCloneOnDeath(alive)
    -- temporarilyInvincibleEntities: array of {entity=Entity, endInvincibilityTick=int}
    local temporarilyInvincibleEntities = {}
    local excludeEntities = {}
    -- OnStart: exclude currently dead entities
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not DoesEntityExist(ped) or IsEntityDead(ped, 0) then
            table.insert(excludeEntities, ped)
        end
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if not DoesEntityExist(veh) or IsEntityDead(veh, 0) then
            table.insert(excludeEntities, veh)
        end
    end
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and IsEntityDead(ped, 0)
            and (function() for _,_v in ipairs(excludeEntities) do if _v == ped then return false end end return true end)() then
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
        end
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and IsEntityDead(veh, 0)
            and (function() for _,_v in ipairs(excludeEntities) do if _v == veh then return false end end return true end)() then
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
        end
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
