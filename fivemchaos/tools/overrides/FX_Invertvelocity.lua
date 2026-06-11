function FX_MiscInvertvelocity(alive)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(veh) and not IsPedAPlayer(GetPedInVehicleSeat(veh, -1, false)) then
            local vel = GetEntityVelocity(veh)
            SetEntityVelocity(veh, -vel.x, -vel.y, -vel.z)
        end
    end
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            SetPedToRagdoll(ped, 1000, 1000, 0, true, true, false)
            local vel = GetEntityVelocity(ped)
            SetEntityVelocity(ped, -vel.x, -vel.y, -vel.z)
        end
    end
end
