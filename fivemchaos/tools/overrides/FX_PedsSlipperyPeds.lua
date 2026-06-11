function FX_PedsSlipperyPeds(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                SetPedMoveRateOverride(ped, 100.0)
                local vel = GetEntityVelocity(ped)
                SetEntityVelocity(ped, vel.x * 1.01, vel.y * 1.01, vel.z)
            end
        end
        Citizen.Wait(0)
    end
end
