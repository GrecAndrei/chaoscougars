function FX_PlayerFamous(alive)
    while alive() do
        SetEveryoneIgnorePlayer(PlayerId(), false)
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                TaskLookAtEntity(ped, PlayerPedId(), -1, 2048, 3)
            end
        end
        Citizen.Wait(0)
    end
end
