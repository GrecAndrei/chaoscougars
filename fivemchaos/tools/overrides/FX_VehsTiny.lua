function FX_VehsTiny(alive)
    local vehicleDefaultSizes = {}
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) then
                local vehModel = GetEntityModel(veh)
                if not IsThisModelABike(vehModel) and not IsThisModelABicycle(vehModel) then
                    local rightVector, forwardVector, upVector, position = GetEntityMatrix(veh)
                    local size = vector3(#rightVector, #forwardVector, #upVector)
                    if not vehicleDefaultSizes[veh] then
                        vehicleDefaultSizes[veh] = size
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end
