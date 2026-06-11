function FX_PedsBusbois(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local busHash = GetHashKey("bus")
    local maxDistance = 120.0
    RequestModel(busHash)
    while not HasModelLoaded(busHash) do Citizen.Wait(0) end
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) then
            local pedPos = GetEntityCoords(ped, false)
            local dist = #(playerPos - pedPos)
            if dist <= maxDistance then
                local heading = GetEntityHeading(ped)
                local veh = CreateVehicle(busHash, pedPos.x, pedPos.y, pedPos.z, heading, true, false, false)
                SetVehicleEngineOn(veh, true, true, false)
                SetPedIntoVehicle(ped, veh, -1)
            end
        end
    end
    SetModelAsNoLongerNeeded(busHash)
end
