function FX_PedsPortalGun(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and IsPedShooting(ped) then
                local pos = GetEntityCoords(ped, false)
                local fwd = GetEntityForwardVector(ped)
                local targPos = vector3(pos.x + fwd.x * 500.0, pos.y + fwd.y * 500.0, pos.z + fwd.z * 500.0)
                local ray = StartShapeTestRay(pos.x, pos.y, pos.z, targPos.x, targPos.y, targPos.z, 12, ped, 7)
                local _, hit, hitCoords, _, _ = GetShapeTestResult(ray)
                if hit then
                    SetEntityCoords(ped, hitCoords.x, hitCoords.y, hitCoords.z + 1.0, false, false, false, true)
                end
            end
        end
        Citizen.Wait(0)
    end
end
