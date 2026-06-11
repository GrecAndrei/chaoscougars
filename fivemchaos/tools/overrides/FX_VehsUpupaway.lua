function FX_VehsUpupaway(alive)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        local vel = GetEntityVelocity(veh)
        SetEntityVelocity(veh, vel.x, vel.y, 100.0)
    end
end
