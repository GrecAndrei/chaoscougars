function FX_PedsGunsmoke(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and IsPedShooting(ped) and not IsPedAPlayer(ped) then
                UseParticleFxAsset("core")
                local pos = GetEntityCoords(ped, false)
                StartParticleFxNonLoopedAtCoord("exp_grd_flare", pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 0.5, false, false, false)
            end
        end
        Citizen.Wait(0)
    end
end
