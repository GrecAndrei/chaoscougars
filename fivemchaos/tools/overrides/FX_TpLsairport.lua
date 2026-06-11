function FX_TpLsairport(alive)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(50)
    Citizen.Wait(50)
    SetEntityCoordsNoOffset(playerPed, -1388.6, -3111.61, 13.94, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)
end
