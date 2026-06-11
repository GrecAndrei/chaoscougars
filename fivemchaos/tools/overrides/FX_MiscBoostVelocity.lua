function FX_MiscBoostVelocity(alive)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) and not IsPedAPlayer(GetPedInVehicleSeat(veh, -1, false)) then
            local vel = GetEntityVelocity(veh)
            SetEntityVelocity(veh, vel.x * 3.0, vel.y * 3.0, vel.z * 3.0)
        end
    end
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            local vel = GetEntityVelocity(ped)
            SetEntityVelocity(ped, vel.x * 3.0, vel.y * 3.0, vel.z * 3.0)
        end
    end
end
