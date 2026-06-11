local fovCamera = 0

function FX_PlayerBinoculars(alive)
    fovCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    RenderScriptCams(true, true, 700, true, true)

    while alive() do
        SetCamActive(fovCamera, true)
        local coord = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        SetCamParams(fovCamera, coord.x, coord.y, coord.z, rot.x, rot.y, rot.z, 10.0, 0, 1, 1, 2)
        Citizen.Wait(0)
    end

    SetCamActive(fovCamera, false)
    RenderScriptCams(false, true, 700, true, true)
    DestroyCam(fovCamera, true)
    fovCamera = 0
end
