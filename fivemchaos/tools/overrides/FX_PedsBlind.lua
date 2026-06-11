function FX_PedsBlind(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) then
            ClearPedTasks(ped)
            SetBlockingOfNonTemporaryEvents(ped, true)
        end
    end
    while alive() do
        SetEveryoneIgnorePlayer(PlayerId(), true)
        for _, ped in ipairs(GetGamePool('CPed')) do
            if not IsPedAPlayer(ped) then
                SetPedSeeingRange(ped, 0.0)
                SetPedHearingRange(ped, 0.0)
                SetBlockingOfNonTemporaryEvents(ped, true)
                SetPedShootRate(ped, 0)
                SetPedFiringPattern(ped, -490063247)
            end
        end
        Citizen.Wait(0)
    end
    SetEveryoneIgnorePlayer(PlayerId(), false)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) then
            SetPedSeeingRange(ped, 9999.0)
            SetPedHearingRange(ped, 9999.0)
            SetBlockingOfNonTemporaryEvents(ped, false)
            SetPedShootRate(ped, 100)
            SetPedFiringPattern(ped, -957453492)
        end
    end
end
