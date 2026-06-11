function FX_PlayerSuicide(alive)
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) and IsPedOnFoot(playerPed)
    and GetPedParachuteState(playerPed) == -1 then
        RequestAnimDict("mp_suicide")
        while not HasAnimDictLoaded("mp_suicide") do
            Citizen.Wait(0)
        end
        local pistolHash = GetHashKey("WEAPON_PISTOL")
        GiveWeaponToPed(playerPed, pistolHash, 1, true, true)
        TaskPlayAnim(playerPed, "mp_suicide", "pistol", 8.0, -1.0, 800, 1, 0.0, false, false, false)
        Citizen.Wait(750)
        SetPedShootsAtCoord(playerPed, 0.0, 0.0, 0.0, true)
        RemoveAnimDict("mp_suicide")
    end
    SetEntityHealth(playerPed, 0)
end
