function FX_MiscReplacevehicle(alive)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local veh = GetVehiclePedIsIn(playerPed, false)
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
        SetPedIntoVehicle(playerPed, newVeh, -1)
    else
        local coords = GetEntityCoords(playerPed, false)
        local heading = GetEntityHeading(playerPed)
        RequestModel(GetHashKey("buffalo"))
        while not HasModelLoaded(GetHashKey("buffalo")) do Citizen.Wait(0) end
        local veh = CreateVehicle(GetHashKey("buffalo"), coords.x, coords.y + 5.0, coords.z, heading, true, false)
        SetModelAsNoLongerNeeded(GetHashKey("buffalo"))
        SetPedIntoVehicle(playerPed, veh, -1)
    end
end
