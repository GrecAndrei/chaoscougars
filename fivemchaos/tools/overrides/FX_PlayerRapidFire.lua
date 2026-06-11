function FX_PlayerRapidFire(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPlayerFreeAiming(PlayerId()) then
            local weaponHash = GetSelectedPedWeapon(playerPed)
            if weaponHash ~= GetHashKey("WEAPON_UNARMED") then
                local camCoords = GetGameplayCamCoord()
                local targPos = camCoords + vector3(
                    math.sin(GetGameplayCamRot(2).z * math.pi/180) * -1,
                    math.cos(GetGameplayCamRot(2).z * math.pi/180) * -1,
                    math.sin(GetGameplayCamRot(2).x * math.pi/180)
                ) * 500.0
                ShootSingleBulletBetweenCoords(camCoords.x, camCoords.y, camCoords.z,
                    targPos.x, targPos.y, targPos.z, 5, true, weaponHash, playerPed, true, false, 1.0)
            end
        end
        Citizen.Wait(0)
    end
end
