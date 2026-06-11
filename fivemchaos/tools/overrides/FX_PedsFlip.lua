function FX_PedsFlip(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedInAnyVehicle(ped, false) then
            local rot = GetEntityRotation(ped, 2)
            SetEntityRotation(ped, rot.x + 180.0, rot.y, rot.z, 2, true)
        end
    end
end
