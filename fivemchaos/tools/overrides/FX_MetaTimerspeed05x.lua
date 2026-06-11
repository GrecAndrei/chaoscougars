function FX_MetaTimerspeed05x(alive)
    TriggerServerEvent("cc:meta_set", "timerModifier", 0.5)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set", "timerModifier", 1.0)
end
