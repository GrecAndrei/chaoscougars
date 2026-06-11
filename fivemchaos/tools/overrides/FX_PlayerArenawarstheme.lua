function FX_PlayerArenawarstheme(alive)
    TriggerMusicEvent("AW_LOBBY_MUSIC_START")
    while alive() do
        Citizen.Wait(1000)
    end
    TriggerMusicEvent("MP_MC_CMH_IAA_FINALE_START")
end
