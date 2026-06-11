function FX_MiscUturn(alive)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) and not IsPedAPlayer(GetPedInVehicleSeat(veh, -1, false)) then
            local heading = GetEntityHeading(veh)
            SetEntityHeading(veh, heading + 180.0)
            local vel = GetEntityVelocity(veh)
            SetEntityVelocity(veh, -vel.x, -vel.y, vel.z)
        end
    end
end
