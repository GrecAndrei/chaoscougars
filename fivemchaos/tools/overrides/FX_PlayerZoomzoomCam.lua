local zoomCamera = 0
local camZoom = 80.0
local camZoomRate = 0.15
local minZoom = 10.0
local maxZoom = 120.0
local zoomMidpoint = (maxZoom - minZoom) / 2.0 + minZoom
local zoomMultiplier = maxZoom - zoomMidpoint

function FX_PlayerZoomzoomCam(alive)
    zoomCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    RenderScriptCams(true, true, 10, true, true)

    while alive() do
        local curTick = GetGameTimer()
        camZoom = math.sin(curTick * camZoomRate) * zoomMultiplier + zoomMidpoint
        SetCamActive(zoomCamera, true)
        local coord = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        SetCamParams(zoomCamera, coord.x, coord.y, coord.z, rot.x, rot.y, rot.z, camZoom, 0, 1, 1, 2)
        Citizen.Wait(0)
    end

    SetCamActive(zoomCamera, false)
    RenderScriptCams(false, true, 700, true, true)
    DestroyCam(zoomCamera, true)
    zoomCamera = 0
end
