function FX_VehRandomseat(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then return end
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    local maxSeats = GetVehicleModelNumberOfSeats(GetEntityModel(playerVeh))
    local seats = {}
    for i = -1, maxSeats - 2 do
        if IsVehicleSeatFree(playerVeh, i, false) then
            table.insert(seats, i)
        end
    end
    if #seats > 0 then
        SetPedIntoVehicle(playerPed, playerVeh, seats[math.random(#seats)])
    end
end
