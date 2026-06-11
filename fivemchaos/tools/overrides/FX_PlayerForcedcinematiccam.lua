function FX_PlayerForcedcinematiccam(alive)
    while alive() do
        SetPlayerCanDoDriveBy(PlayerId(), false)
        SetCinematicModeActive(true)
        DisableControlAction(0, 80, true)
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            DisableControlAction(0, 27, true)
            DisableControlAction(0, 0, true)
        end
        Citizen.Wait(0)
    end
    SetCinematicModeActive(false)
    SetPlayerCanDoDriveBy(PlayerId(), true)
end
