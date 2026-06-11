function FX_PlayerLockcamera(alive)
    local playerPed = PlayerPedId()
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local pos = GetEntityCoords(playerPed, false)
    SetCamCoord(cam, pos.x, pos.y, pos.z)
    SetCamRot(cam, GetGameplayCamRot(2).x, GetGameplayCamRot(2).y, GetGameplayCamRot(2).z, 2)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 0, true, true)
    while alive() do
        SetCamCoord(cam, GetEntityCoords(playerPed).x, GetEntityCoords(playerPed).y, GetEntityCoords(playerPed).z)
        Citizen.Wait(0)
    end
    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(cam, true)
end
