function FX_PlayerGravSphere(alive)
    while alive() do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed, false)
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and ped ~= playerPed and not IsPedAPlayer(ped) then
                local pos = GetEntityCoords(ped, false)
                local dist = #(pos - playerPos)
                if dist < 20.0 then
                    local dir = (playerPos - pos) / dist
                    local strength = (20.0 - dist) / 20.0 * 10.0
                    SetPedToRagdoll(ped, 100, 100, 0, false, false, false)
                    ApplyForceToEntityCenterOfMass(ped, 1, dir.x * strength, dir.y * strength, dir.z * strength + 2.0, true, false, true, true)
                end
            end
        end
        Citizen.Wait(0)
    end
end
