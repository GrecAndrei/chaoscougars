function FX_MiscMuffledAudio(alive)
    -- Hooks::SetAudioLPFCutoff not available
    while alive() do
        Citizen.Wait(1000)
    end
    -- Hooks::ResetAudioLPFCutoff not available
end
