function FX_PedsInvincible(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                SetEntityInvincible(ped, true)
            end
        end
        Citizen.Wait(0)
    end
    for _, ped in ipairs(GetGamePool('CPed')) do
        SetEntityInvincible(ped, false)
    end
end
