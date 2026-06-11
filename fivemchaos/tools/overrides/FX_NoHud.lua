function FX_NoHud(alive)
    while alive() do
        HideHudAndRadarThisFrame()
        DisableControlAction(0, 199, true)
        DisableControlAction(0, 200, true)
        Citizen.Wait(0)
    end
end
