function FX_WorldSnow(alive)
    while alive() do
        -- Memory::SetSnow(true)
        SetWeatherTypeNow("XMAS")
        Citizen.Wait(500)
    end
    -- Memory::SetSnow(false)
    SetWeatherTypeNow("EXTRASUNNY")
end
