OwnershipGuard = {}

function OwnershipGuard.IsOwner(entity)
    if not DoesEntityExist(entity) then return false end
    if not NetworkGetEntityIsNetworked(entity) then
        return true
    end
    return NetworkGetEntityOwner(entity) == PlayerId()
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
