function FX_VehRandtraffic(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and GetVehicleWindowTint(veh) ~= 3 then
                local model = GetEntityModel(veh)
                local coords = GetEntityCoords(veh, false)
                local heading = GetEntityHeading(veh)
                SetEntityAsMissionEntity(veh, true, true)
                DeleteVehicle(veh)
                Citizen.Wait(0)
                RequestModel(model)
                while not HasModelLoaded(model) do Citizen.Wait(0) end
                local newVeh = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
                SetModelAsNoLongerNeeded(model)
                SetVehicleWindowTint(newVeh, 3)
                local driver = GetPedInVehicleSeat(newVeh, -1, false)
                if driver ~= 0 and DoesEntityExist(driver) and not IsPedAPlayer(driver) then
                    TaskVehicleDriveWander(driver, newVeh, 40.0, 786603)
                end
            end
        end
        Citizen.Wait(0)
    end
end
