function FX_PlayerNosprint(alive)
    while alive() do
        DisableControlAction(0, 21, true)
        DisableControlAction(0, 22, true)
        Citizen.Wait(0)
    end
end
