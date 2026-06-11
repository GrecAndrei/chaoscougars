-- MANUAL OVERRIDE from PedsRiot.cpp
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
        for _, ped in ipairs(GetGamePool('CPed')) do
            if not IsPedAPlayer(ped) then
                SetPedRelationshipGroupHash(ped, riotGroupHash)
                SetPedCombatAttributes(ped, 5, true)
                SetPedCombatAttributes(ped, 46, true)
                SetPedFiringPattern(ped, 0xC6EE6B4C)
                if (function() for _,_v in ipairs(goneThroughPeds) do if _v == ped then return false end end return true end)() then
                    -- Memory::GetAllWeapons() not available, skip weapon assignment
                    table.insert(goneThroughPeds, ped)
                end
            end
        end
        for i = #goneThroughPeds, 1, -1 do
            if not DoesEntityExist(goneThroughPeds[i]) then
                table.remove(goneThroughPeds, i)
            end
        end
        Citizen.Wait(0)
    end
    -- OnStop cleanup
    SetMaxWantedLevel(5)
end
