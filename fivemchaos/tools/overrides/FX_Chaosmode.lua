function FX_Chaosmode(alive)
    TriggerServerEvent("cc:meta_set", "additionalEffects", 3)
    TriggerServerEvent("cc:meta_set", "timerModifier", 3.0)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set", "additionalEffects", 0)
    TriggerServerEvent("cc:meta_set", "timerModifier", 1.0)
end
