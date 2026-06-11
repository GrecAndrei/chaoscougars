function FX_PlayerAfk(alive)
    while alive() do
        SetControlNormal(0, 1, 1.0)
        Citizen.Wait(0)
    end
    EnableControlAction(0, 1, true)
end
