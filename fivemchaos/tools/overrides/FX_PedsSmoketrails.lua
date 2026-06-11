function FX_PedsSmoketrails(alive)
    while alive() do
        UseParticleFxAsset("core")
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                StartParticleFxLoopedOnEntity("ent_amb_cig_smoke", ped, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
            end
        end
        Citizen.Wait(500)
    end
end
