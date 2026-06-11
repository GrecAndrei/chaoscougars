function FX_Insanegravity(alive)
    while alive() do SetGravityLevel(3); Citizen.Wait(0) end
    SetGravityLevel(0)
end
