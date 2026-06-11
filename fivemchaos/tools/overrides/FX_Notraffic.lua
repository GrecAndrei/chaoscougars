function FX_Notraffic(alive)
    while alive() do
        SetAmbientVehicleRangeMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetVehicleDensityMultiplierThisFrame(0.0)
        Citizen.Wait(0)
    end
end
