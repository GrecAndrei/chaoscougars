function FX_MetaReInvoke(alive)
    -- Approximation: trigger an extra effect via server
    TriggerServerEvent("cc:meta_set", "additionalEffects", 1)
    Citizen.Wait(100)
    TriggerServerEvent("cc:meta_set", "additionalEffects", 0)
end
