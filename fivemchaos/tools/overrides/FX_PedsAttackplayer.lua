function FX_PedsAttackplayer(alive)
    while alive() do
        local playerPed = PlayerPedId()
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsEntityDead(ped, false) then
                TaskCombatPed(ped, playerPed, 0, 16)
            end
        end
        Citizen.Wait(1000)
    end
end
