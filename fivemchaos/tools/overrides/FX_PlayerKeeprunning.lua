function FX_PlayerKeeprunning(alive)
    while alive() do
        SimulatePlayerInputGait(PlayerId(), 5.0, 100, 1.0, true, false)

        SetControlNormal(0, 32, 1.0)
        SetControlNormal(0, 71, 1.0)
        SetControlNormal(0, 77, 1.0)
        SetControlNormal(0, 87, 1.0)
        SetControlNormal(0, 129, 1.0)
        SetControlNormal(0, 136, 1.0)
        SetControlNormal(0, 150, 1.0)
        SetControlNormal(0, 232, 1.0)
        SetControlNormal(0, 280, 1.0)

        DisableControlAction(0, 72, true)
        DisableControlAction(0, 76, true)
        DisableControlAction(0, 88, true)
        DisableControlAction(0, 138, true)
        DisableControlAction(0, 139, true)
        DisableControlAction(0, 152, true)
        DisableControlAction(0, 153, true)

        DisableControlAction(0, 25, true)
        DisableControlAction(0, 44, true)
        DisableControlAction(0, 50, true)
        DisableControlAction(0, 68, true)

        Citizen.Wait(0)
    end
end
