function FX_PedsRemweps(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            RemoveAllPedWeapons(ped, true)
        end
    end
end
