function FX_NoRadar(alive)
    while alive() do
        DisplayRadar(false)
        DisableControlAction(0, 199, true)
        DisableControlAction(0, 200, true)
        Citizen.Wait(0)
    end
    DisplayRadar(true)
end
