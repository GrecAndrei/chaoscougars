function FX_PlayerTpeverything(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsEntityAMissionEntity(ped) then
            SetEntityCoords(ped, playerPos.x + math.random(-3, 3), playerPos.y + math.random(-3, 3), playerPos.z, false, false, false, true)
        end
    end
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) and not IsPedInVehicle(playerPed, veh, false) and not IsEntityAMissionEntity(veh) then
            SetEntityCoords(veh, playerPos.x + math.random(-5, 5), playerPos.y + math.random(-5, 5), playerPos.z + 3.0, false, false, false, true)
        end
    end
end
