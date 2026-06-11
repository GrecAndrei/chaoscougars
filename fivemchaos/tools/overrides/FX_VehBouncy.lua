function FX_VehBouncy(alive)
    while alive() do
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and HasEntityCollidedWithAnything(veh) then
                local vel = GetEntityVelocity(veh)
                local factor = (vel.x < 10 and vel.y < 10 and vel.z < 10) and 300.0 or 60.0
                ApplyForceToEntity(veh, 0, vel.x * -factor, vel.y * -factor, vel.z * -factor, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end
        Citizen.Wait(0)
    end
end
