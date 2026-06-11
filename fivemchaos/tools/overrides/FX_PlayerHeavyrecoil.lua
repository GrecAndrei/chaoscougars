function FX_PlayerHeavyrecoil(alive)
    local verticalRecoil = 1.0
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedShooting(playerPed) then
            local weaponHash = GetSelectedPedWeapon(playerPed)
            if weaponHash ~= 0 and GetWeaponDamageType(weaponHash) == 3 then
                local horizontalRecoil = (math.random(-100, 100)) / 10.0
                for i = 1, 10 do
                    SetGameplayCamRelativePitch(GetGameplayCamRelativePitch() + (verticalRecoil / 10.0), 1.0)
                    SetGameplayCamRelativeHeading(GetGameplayCamRelativeHeading() + (horizontalRecoil / 10.0))
                    Citizen.Wait(0)
                end
            end
        end
        Citizen.Wait(0)
    end
end
