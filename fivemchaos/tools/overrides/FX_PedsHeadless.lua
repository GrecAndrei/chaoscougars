function FX_PedsHeadless(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                SetPedComponentVariation(ped, 0, 0, 0, 0)
            end
        end
        Citizen.Wait(0)
    end
end
