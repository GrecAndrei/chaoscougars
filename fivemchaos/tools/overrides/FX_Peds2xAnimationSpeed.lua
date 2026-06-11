function FX_Peds2xAnimationSpeed(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                SetPedMoveRateOverride(ped, 2.0)
            end
        end
        Citizen.Wait(0)
    end
end
