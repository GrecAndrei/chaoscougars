function FX_PedsReflectivedamage(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if HasEntityBeenDamagedByAnyPed(playerPed) then
            local attacker = GetPedSourceOfDeath(playerPed)
            if DoesEntityExist(attacker) and attacker ~= 0 then
                local dmg = GetEntityHealth(playerPed)
                SetEntityHealth(attacker, GetEntityHealth(attacker) - (GetEntityMaxHealth(playerPed) - dmg))
            end
            ClearEntityLastDamageEntity(playerPed)
        end
        Citizen.Wait(100)
    end
end
