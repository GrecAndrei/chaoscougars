function FX_ScreenRealfp(alive)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    AttachCamToEntity(cam, PlayerPedId(), 0.0, 0.0, 0.65, true)
    SetCamFov(cam, 90.0)
    RenderScriptCams(true, true, 500, true, true)
    SetCamActive(cam, true)
    while alive() do
        Citizen.Wait(0)
    end
    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(cam, true)
end
