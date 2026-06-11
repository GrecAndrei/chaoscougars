function FX_PlayerPoof(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if GetEntityPlayerIsFreeAimingAt(playerPed) then
            local target = GetEntityPlayerIsFreeAimingAt(playerPed)
            if DoesEntityExist(target) and (IsEntityAPed(target) or IsEntityAVehicle(target)) and not IsEntityDead(target, false) then
                local pos = GetEntityCoords(target, false)
                SetEntityHealth(target, 0)
                SetEntityInvincible(target, false)
                AddExplosion(pos.x, pos.y, pos.z, 9, 100.0, true, false, 3.0, false)
            end
        end
        Citizen.Wait(0)
    end
end
