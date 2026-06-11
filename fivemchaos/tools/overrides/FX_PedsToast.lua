function FX_PedsToast(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and math.random() < 0.01 then
                local pos = GetEntityCoords(ped, false)
                AddExplosion(pos.x, pos.y, pos.z, 9, 1.0, true, false, 1.0, false)
                SetEntityHealth(ped, 0)
            end
        end
        Citizen.Wait(1000)
    end
end
