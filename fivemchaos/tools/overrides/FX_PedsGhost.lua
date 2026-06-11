function FX_PedsGhost(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                SetEntityAlpha(ped, 80, false)
            end
        end
        Citizen.Wait(0)
    end
    for _, ped in ipairs(GetGamePool('CPed')) do
        ResetEntityAlpha(ped)
    end
end
