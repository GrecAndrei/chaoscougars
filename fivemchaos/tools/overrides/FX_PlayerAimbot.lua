function FX_PlayerAimbot(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPlayerFreeAiming(PlayerId()) then
            local target = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if DoesEntityExist(target) and IsEntityAPed(target) and not IsPedAPlayer(target) and not IsEntityDead(target, false) then
                TaskShootAtEntity(playerPed, target, -1, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
            end
        end
        Citizen.Wait(0)
    end
end
