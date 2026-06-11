function FX_VehsFlyingcars(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local veh = GetVehiclePedIsIn(playerPed, false)
            local vehClass = GetVehicleClass(veh)
            if vehClass ~= 15 and vehClass ~= 16 then
                local speed = GetEntitySpeed(veh)
                if speed > 5.0 then
                    local fwd = GetEntityForwardVector(veh)
                    local deltaSpeed = 10.0 * GetFrameTime()
                    local vel = GetEntityVelocity(veh)
                    DisableControlAction(0, 68, true)
                    DisableControlAction(0, 69, true)
                    if IsControlPressed(0, 71) then
                        vel = vector3(fwd.x * (speed + deltaSpeed), fwd.y * (speed + deltaSpeed), vel.z)
                    end
                    SetEntityVelocity(veh, vel.x, vel.y, vel.z)
                    local rot = GetEntityRotation(veh, 2)
                    local deltaAngle = 80.0 * GetFrameTime()
                    if IsControlPressed(0, 63) then rot = vector3(rot.x, rot.y, rot.z + deltaAngle) end
                    if IsControlPressed(0, 64) then rot = vector3(rot.x, rot.y, rot.z - deltaAngle) end
                    if IsControlPressed(0, 108) then rot = vector3(rot.x, rot.y - deltaAngle, rot.z) end
                    if IsControlPressed(0, 109) then rot = vector3(rot.x, rot.y + deltaAngle, rot.z) end
                    if IsControlPressed(0, 111) then rot = vector3(rot.x - deltaAngle, rot.y, rot.z) end
                    if IsControlPressed(0, 112) then rot = vector3(rot.x + deltaAngle, rot.y, rot.z) end
                    SetEntityRotation(veh, rot.x, rot.y, rot.z, 2, true)
                end
            end
        end
        Citizen.Wait(0)
    end
end
