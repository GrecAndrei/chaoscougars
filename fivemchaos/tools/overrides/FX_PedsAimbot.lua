function FX_PedsAimbot(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if not IsPedAPlayer(ped) then
                SetPedAccuracy(ped, 100)
                SetPedFiringPattern(ped, 0xC6EE6B4C)
            end
        end
        Citizen.Wait(0)
    end
end
