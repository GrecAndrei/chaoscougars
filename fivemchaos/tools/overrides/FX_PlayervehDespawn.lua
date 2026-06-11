function FX_PlayervehDespawn(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local veh = GetVehiclePedIsIn(playerPed, false)
    Citizen.Wait(0)
    SetEntityAsMissionEntity(veh, true, true)
    DeleteVehicle(veh)
end
