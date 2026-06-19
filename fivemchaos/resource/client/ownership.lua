OwnershipGuard = {}

function OwnershipGuard.IsOwner(entity)
    if not DoesEntityExist(entity) then return false end
    if not NetworkGetEntityIsNetworked(entity) then
        return true
    end
    return NetworkGetEntityOwner(entity) == PlayerId()
end

-- True if THIS client currently drives the AI for this entity. Unlike
-- OwnershipGuard.IsOwner (a one-shot check), this actively reclaims control
-- and waits up to 1s when the engine hands ownership to someone else. This
-- is the universal gate replacing the old "OwnershipGuard.IsOwner(ped)"
-- checks for cougar / spawned-ped AI threads in both spawner.lua and
-- effects_spawn.lua.
function AIIsMine(ent)
    if not DoesEntityExist(ent) or IsEntityDead(ent) then return false end
    if NetworkHasControlOfEntity(ent) then return true end
    NetworkRequestControlOfEntity(ent)
    local t = 0
    while not NetworkHasControlOfEntity(ent) and t < 20 do
        Citizen.Wait(50)
        t = t + 1
    end
    return NetworkHasControlOfEntity(ent)
end

function OwnershipGuard.ForEachOwnedVehicle(fn)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if OwnershipGuard.IsOwner(veh) then
            fn(veh)
        end
    end
end

function OwnershipGuard.ForEachOwnedPed(fn)
    local myPed = PlayerPedId()
    for _, ped in ipairs(GetGamePool('CPed')) do
        if ped ~= myPed and OwnershipGuard.IsOwner(ped) then
            fn(ped)
        end
    end
end

function OwnershipGuard.ForEachOwnedObject(fn)
    for _, obj in ipairs(GetGamePool('CObject')) do
        if OwnershipGuard.IsOwner(obj) then
            fn(obj)
        end
    end
end

function GetNearestPlayerPed(pos)
    local best, bestDist = nil, 999999.0
    for _, playerId in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(playerId)
        if ped and DoesEntityExist(ped) and not IsEntityDead(ped) then
            local d = #(GetEntityCoords(ped) - pos)
            if d < bestDist then
                best = ped
                bestDist = d
            end
        end
    end
    return best
end

function GetAllPlayerPeds()
    local peds = {}
    for _, playerId in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(playerId)
        if ped and DoesEntityExist(ped) and not IsEntityDead(ped) then
            peds[#peds + 1] = ped
        end
    end
    return peds
end
