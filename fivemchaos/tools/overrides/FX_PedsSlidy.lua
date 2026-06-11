function FX_PedsSlidy(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                SetPedMoveRateOverride(ped, 100.0)
            end
        end
        Citizen.Wait(0)
    end
end
