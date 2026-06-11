function FX_MiscRemoveWater(alive)
    while alive() do
        SetDeepOceanScaler(0.0)
        Citizen.Wait(0)
    end
    SetDeepOceanScaler(1.0)
end
