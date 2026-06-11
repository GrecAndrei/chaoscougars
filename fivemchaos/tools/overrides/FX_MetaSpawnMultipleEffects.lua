function FX_MetaSpawnMultipleEffects(alive)
    TriggerServerEvent("cc:meta_set", "additionalEffects", 2)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set", "additionalEffects", 0)
end
