function FX_MetaHideChaosUi(alive)
    TriggerServerEvent("cc:meta_set", "hideChaosUI", true)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set", "hideChaosUI", false)
end
