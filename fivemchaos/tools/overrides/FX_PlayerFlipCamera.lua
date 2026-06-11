local flippedCamera = 0

function FX_PlayerFlipCamera(alive)
    flippedCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    RenderScriptCams(true, true, 700, true, true)

    while alive() do
        SetCamActive(flippedCamera, true)
        local coord = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        local fov = GetGameplayCamFov()
        SetCamParams(flippedCamera, coord.x, coord.y, coord.z, rot.x, 180.0, rot.z, fov, 700, 0, 0, 2)
        Citizen.Wait(0)
    end

    SetCamActive(flippedCamera, false)
    RenderScriptCams(false, true, 700, true, true)
    DestroyCam(flippedCamera, true)
    flippedCamera = 0
end
