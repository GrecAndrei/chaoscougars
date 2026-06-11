function FX_PedsIgnite(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and math.random() < 0.02 then
                StartEntityFire(ped)
            end
        end
        Citizen.Wait(100)
    end
end
