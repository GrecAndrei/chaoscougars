function FX_PlayervehTprandompeds(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            local seats = GetVehicleModelNumberOfSeats(GetEntityModel(veh))
            for i = 0, seats - 2 do
                if IsVehicleSeatFree(veh, i, false) then
                    local peds = {}
                    for _, ped in ipairs(GetGamePool('CPed')) do
                        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsPedInAnyVehicle(ped, false) then
                            table.insert(peds, ped)
                        end
                    end
                    if #peds > 0 then
                        local ped = peds[math.random(#peds)]
                        SetPedIntoVehicle(ped, veh, i)
                    end
                end
            end
        end
        Citizen.Wait(5000)
    end
end
