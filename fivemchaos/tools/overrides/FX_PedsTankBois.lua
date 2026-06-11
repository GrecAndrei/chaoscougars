function FX_PedsTankBois(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local tankHash = GetHashKey("rhino")
    local maxDistance = 120.0
    RequestModel(tankHash)
    while not HasModelLoaded(tankHash) do Citizen.Wait(0) end
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) then
            local pedPos = GetEntityCoords(ped, false)
            local dist = #(playerPos - pedPos)
            if dist <= maxDistance then
                local heading = GetEntityHeading(ped)
                local veh = CreateVehicle(tankHash, pedPos.x, pedPos.y, pedPos.z, heading, true, false, false)
                SetVehicleEngineOn(veh, true, true, false)
                SetPedIntoVehicle(ped, veh, -1)
            end
        end
    end
    SetModelAsNoLongerNeeded(tankHash)
end
