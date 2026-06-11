function FX_Lowgravity(alive)
    while alive() do SetGravityLevel(1); Citizen.Wait(0) end
    SetGravityLevel(0)
end
