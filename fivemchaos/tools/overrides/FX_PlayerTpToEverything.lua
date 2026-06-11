function FX_PlayerTpToEverything(alive)
    while alive() do
        local allEntities = {}
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                table.insert(allEntities, ped)
            end
        end
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) then
                table.insert(allEntities, veh)
            end
        end
        if #allEntities > 0 then
            local target = allEntities[math.random(#allEntities)]
            local coords = GetEntityCoords(target, false)
            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z + 2.0, false, false, false, true)
        end
        Citizen.Wait(3000)
    end
end
