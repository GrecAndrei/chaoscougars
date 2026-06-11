function FX_MetaVotingmodeAntimajority(alive)
    TriggerServerEvent("cc:meta_set", "votingMode", "antimajority")
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set", "votingMode", "none")
end
