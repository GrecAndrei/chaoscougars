function FX_MiscRandomgravity(alive)
    while alive() do
        local g = math.random(1, 3)
        SetGravityLevel(g)
        Citizen.Wait(3000)
    end
    SetGravityLevel(0)
end
