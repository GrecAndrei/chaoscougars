function FX_PedsIntorandomvehs(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsPedInAnyVehicle(ped, false) then
            local nearbyVehs = {}
            for _, veh in ipairs(GetGamePool('CVehicle')) do
                if DoesEntityExist(veh) and IsVehicleSeatFree(veh, -1, false) then
                    table.insert(nearbyVehs, veh)
                end
            end
            if #nearbyVehs > 0 then
                local veh = nearbyVehs[math.random(#nearbyVehs)]
                SetPedIntoVehicle(ped, veh, -1)
            end
        end
    end
end
