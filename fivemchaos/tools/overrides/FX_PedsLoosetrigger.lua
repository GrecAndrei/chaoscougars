function FX_PedsLoosetrigger(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and GetSelectedPedWeapon(ped) ~= GetHashKey("WEAPON_UNARMED") then
                SetPedShootsAtCoord(ped, GetEntityCoords(ped).x + math.random(-10, 10),
                    GetEntityCoords(ped).y + math.random(-10, 10),
                    GetEntityCoords(ped).z + math.random(-5, 5), true)
            end
        end
        Citizen.Wait(500)
    end
end
