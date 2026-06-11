function FX_MetaNochaos(alive)
    TriggerServerEvent("cc:meta_set", "disableChaos", true)
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set", "disableChaos", false)
end
