function FX_ScreenBright(alive)
    while alive() do
        SetTransitionTimecycleModifier("mp_x17dlc_int_02", 5.0)
        SetTimecycleModifierStrength(1.0)
        SetWeatherTypeNow("EXTRASUNNY")
        Citizen.Wait(250)
    end
    ClearTimecycleModifier()
    for _, veh in ipairs(GetGamePool("CVehicle")) do
        SetVehicleLights(veh, 0)
        SetVehicleLightMultiplier(veh, 1.0)
    end
end
