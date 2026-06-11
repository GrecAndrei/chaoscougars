function FX_MetaVotingmodeMajority(alive)
    TriggerServerEvent("cc:meta_set", "votingMode", "majority")
    while alive() do Citizen.Wait(250) end
    TriggerServerEvent("cc:meta_set", "votingMode", "none")
end
