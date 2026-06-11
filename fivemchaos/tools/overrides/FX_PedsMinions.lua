function FX_PedsMinions(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                SetPedConfigFlag(ped, 223, true)
            end
        end
        Citizen.Wait(0)
    end
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) then
            SetPedConfigFlag(ped, 223, false)
        end
    end
end
