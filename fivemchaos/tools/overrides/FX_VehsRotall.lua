function FX_VehsRotall(alive)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) then
            local vel = GetEntityVelocity(veh)
            local rot = GetEntityRotation(veh, 2)
            if math.random(0, 1) == 0 then
                SetEntityRotation(veh, rot.x + 180.0, rot.y, rot.z, 2, true)
            else
                SetEntityRotation(veh, rot.x, rot.y + 180.0, rot.z, 2, true)
            end
            SetEntityVelocity(veh, vel.x, vel.y, vel.z)
        end
    end
end
