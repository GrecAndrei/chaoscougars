function FX_MiscNosky(alive)
    while alive() do
        -- Memory::SetSkyDisabled not available
        SetCloudHatTransition("altostratus", 0.0)
        Citizen.Wait(0)
    end
    SetCloudHatTransition("Clear", 1.0)
end
