function FX_PedsSayhi(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            SetPedRelationshipGroupHash(ped, GetHashKey("PLAYER"))
        end
    end
end
