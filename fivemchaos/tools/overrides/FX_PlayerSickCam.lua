function FX_PlayerSickCam(alive)
    local sickCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    RenderScriptCams(true, true, 10, 1, 1, 1)
    local camZoom = 80.0
    local camZoomRate = 0.4
    local camRotX = 0.0
    local camRotXRate = 0.4
    local camRotY = 0.0
    local camRotYRate = 0.6
    while alive() do
        camZoom = camZoom + camZoomRate
        if camZoom > 120 or camZoom < 40 then camZoomRate = -camZoomRate end
        camRotX = camRotX + camRotXRate
        if camRotX > 10 or camRotX < -10 then camRotXRate = -camRotXRate end
        camRotY = camRotY + camRotYRate
        if camRotY > 15 or camRotY < -15 then camRotYRate = -camRotYRate end
        SetCamParams(sickCamera, GetEntityCoords(PlayerPedId()).x, GetEntityCoords(PlayerPedId()).y,
            GetEntityCoords(PlayerPedId()).z, camRotX, camRotY, GetEntityHeading(PlayerPedId()), camZoom, 0, 0, 1, 2)
        SetCamActive(sickCamera, true)
        Citizen.Wait(0)
    end
    SetCamActive(sickCamera, false)
    RenderScriptCams(false, true, 700, 1, 1, 1)
    DestroyCam(sickCamera, true)
end
