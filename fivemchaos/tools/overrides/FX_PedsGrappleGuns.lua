function FX_PedsGrappleGuns(alive)
    while alive() do
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and IsPedShooting(ped) and not IsPedAPlayer(ped) then
                local target = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if DoesEntityExist(target) then
                    local pedPos = GetEntityCoords(ped, false)
                    local targPos = GetEntityCoords(target, false)
                    local dir = (pedPos - targPos) / #(pedPos - targPos)
                    ApplyForceToEntityCenterOfMass(target, 1, dir.x * 50.0, dir.y * 50.0, 20.0, true, false, true, true)
                end
            end
        end
        Citizen.Wait(0)
    end
end
