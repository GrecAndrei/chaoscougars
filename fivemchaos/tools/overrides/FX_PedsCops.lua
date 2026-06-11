function FX_PedsCops(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                SetPedAsCop(ped, true)
            end
        end
        Citizen.Wait(0)
    end
end
