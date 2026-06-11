function FX_VehsCruiseControl(alive)
    local currentVel = -1.0
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            if IsVehicleOnAllWheels(veh) then
                local speed = GetEntitySpeed(veh)
                if speed > currentVel or speed < currentVel / 2 or speed < 1 then
                    currentVel = speed
                elseif speed < currentVel then
                    SetVehicleForwardSpeed(veh, currentVel)
                end
            else
                currentVel = -1.0
            end
        end
        Citizen.Wait(0)
    end
end
