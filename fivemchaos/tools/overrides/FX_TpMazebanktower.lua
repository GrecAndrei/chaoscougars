function FX_TpMazebank(alive)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(50)
    Citizen.Wait(50)
    SetEntityCoordsNoOffset(playerPed, -75.7, -818.62, 326.16, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)
end
