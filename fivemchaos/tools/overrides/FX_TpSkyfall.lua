function FX_TpSkyfall(alive)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(100)
    Citizen.Wait(100)
    SetEntityCoordsNoOffset(playerPed, 935.0, 3800.0, 2300.0, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)
end
