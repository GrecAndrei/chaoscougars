-- MANUAL OVERRIDE from VehsGTAOTraffic.cpp
function FX_TrafficGtao(alive)
    local goneThrough = {}
    while alive() do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed, false)
        for _, ped in ipairs(GetGamePool('CPed')) do
            if not IsPedAPlayer(ped) and IsPedInAnyVehicle(ped, false)
            and GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1, 0) == ped
            and (function() for _,_v in ipairs(goneThrough) do if _v == ped then return false end end return true end)() then
                local veh = GetVehiclePedIsIn(ped, false)
                SetBlockingOfNonTemporaryEvents(ped, true)
                TaskVehicleMissionPedTarget(ped, veh, playerPed, 13, 9999.0, 4176732, 0.0, 0.0, false)
                table.insert(goneThrough, ped)
            end
        end
        for i = #goneThrough, 1, -1 do
            if not DoesEntityExist(goneThrough[i]) then
                table.remove(goneThrough, i)
            end
        end
        Citizen.Wait(0)
    end
end
