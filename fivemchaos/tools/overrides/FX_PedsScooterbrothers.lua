function FX_PedsScooterbrothers(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local faggioHash = GetHashKey("FAGGIO")
    RequestModel(faggioHash)
    while not HasModelLoaded(faggioHash) do Citizen.Wait(0) end
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, true) then
            local pedPos = GetEntityCoords(ped, false)
            local heading = GetEntityHeading(ped)
            local veh = CreateVehicle(faggioHash, pedPos.x, pedPos.y, pedPos.z, heading, true, false, false)
            SetVehicleEngineOn(veh, true, true, false)
            SetPedIntoVehicle(ped, veh, -1)
        end
    end
    SetModelAsNoLongerNeeded(faggioHash)
end
