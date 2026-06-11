function FX_MetaTimerspeed2x(alive)
    TriggerServerEvent("cc:meta_set", "timerModifier", 2.0)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set", "timerModifier", 1.0)
end
