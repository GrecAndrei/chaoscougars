function FX_MetaEffectDuration05x(alive)
    TriggerServerEvent("cc:meta_set", "durationModifier", 0.5)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set", "durationModifier", 1.0)
end
