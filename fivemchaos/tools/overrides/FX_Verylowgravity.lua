function FX_Verylowgravity(alive)
    while alive() do SetGravityLevel(2); Citizen.Wait(0) end
    SetGravityLevel(0)
end
