function FX_MetaEffectDuration2x(alive)
    TriggerServerEvent("cc:meta_set", "durationModifier", 2.0)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set", "durationModifier", 1.0)
end
