function FX_PedsExplosive(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if not IsPedAPlayer(ped) then
                local maxHealth = GetEntityMaxHealth(ped)
                if maxHealth > 0 and (IsPedInjured(ped) or IsPedRagdoll(ped)) then
                    local pedPos = GetEntityCoords(ped, false)
                    AddExplosion(pedPos.x, pedPos.y, pedPos.z, 4, 9999.0, true, false, 1.0, false)
                    SetEntityHealth(ped, 0, false)
                    SetEntityMaxHealth(ped, 0)
                end
            end
        end
        Citizen.Wait(0)
    end
end
