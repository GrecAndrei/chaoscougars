function FX_PedsInsult(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                TaskCombatPed(ped, PlayerPedId(), 0, 16)
            end
        end
        Citizen.Wait(5000)
    end
end
