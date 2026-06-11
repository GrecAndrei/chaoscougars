local spinningCamera = 0
local camRot = 0.0
local camRotRate = 1.2

function FX_PlayerSpinCamera(alive)
    spinningCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    RenderScriptCams(true, true, 10, true, true)

    while alive() do
        camRot = camRot + camRotRate
        SetCamActive(spinningCamera, true)
        local coord = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        local fov = GetGameplayCamFov()
        SetCamParams(spinningCamera, coord.x, coord.y, coord.z, rot.x, camRot, rot.z, fov, 0, 1, 1, 2)
        Citizen.Wait(0)
    end

    SetCamActive(spinningCamera, false)
    RenderScriptCams(false, true, 700, true, true)
    DestroyCam(spinningCamera, true)
    spinningCamera = 0
end
