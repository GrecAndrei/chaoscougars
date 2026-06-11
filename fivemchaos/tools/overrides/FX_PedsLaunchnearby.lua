function FX_PedsLaunchnearby(alive)
    local spacePeds = {}
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) then
            local vel = GetEntityVelocity(ped)
            ClearPedTasksImmediately(ped)
            SetPedToRagdoll(ped, 10000, 10000, 0, true, true, false)
            spacePeds[#spacePeds + 1] = { ped = ped, vel = vel }
        end
    end
    Citizen.Wait(0)
    for _, entry in ipairs(spacePeds) do
        SetEntityVelocity(entry.ped, entry.vel.x, entry.vel.y, 100.0)
    end
end
