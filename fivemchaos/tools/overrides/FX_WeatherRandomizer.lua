function FX_WeatherRandomizer(alive)
    local weathers = {"CLEAR", "EXTRASUNNY", "CLOUDS", "OVERCAST", "RAIN", "THUNDER", "SMOG", "FOGGY", "XMAS", "SNOWLIGHT"}
    while alive() do
        SetWeatherTypeNowPersist(weathers[math.random(#weathers)])
        Citizen.Wait(3000)
    end
    ClearWeatherTypePersist()
end
