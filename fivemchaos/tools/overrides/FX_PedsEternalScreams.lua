function FX_PedsEternalScreams(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and IsEntityDead(ped, false) then
                PlayPain(ped, 7, 0, 0)
            end
        end
        Citizen.Wait(100)
    end
end
