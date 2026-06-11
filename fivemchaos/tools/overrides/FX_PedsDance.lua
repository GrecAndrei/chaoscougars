function FX_PedsDance(alive)
    local animDict = "missfbi3_sniping"
    local animName = "dance_m_default"
    local playerPed = PlayerPedId()
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Citizen.Wait(0) end
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            local rel = GetRelationshipBetweenPeds(playerPed, ped)
            if not IsEntityPlayingAnim(ped, animDict, animName, 3) and not IsPedAPlayer(ped)
                and (not IsEntityAMissionEntity(ped) or rel == 4 or rel == 5) then
                TaskPlayAnim(ped, animDict, animName, 4.0, -4.0, -1, 1, 0.0, false, false, false)
                SetPedKeepTask(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
            end
        end
        Citizen.Wait(0)
    end
    RemoveAnimDict(animDict)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if IsEntityPlayingAnim(ped, animDict, animName, 3) then
            SetPedKeepTask(ped, false)
            SetBlockingOfNonTemporaryEvents(ped, false)
        end
    end
end
