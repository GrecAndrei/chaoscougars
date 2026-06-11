function FX_PedsPhones(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and math.random() < 0.03 then
                TaskUseMobilePhone(ped, true)
            end
        end
        Citizen.Wait(500)
    end
end
