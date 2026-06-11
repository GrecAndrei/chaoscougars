function FX_TimeX05(alive)
    while alive() do
        SetAudioFlag("AllowScriptedSpeechInSlowMo", true)
        SetAudioFlag("AllowAmbientSpeechInSlowMo", true)
        -- Hooks::SetAudioPitchFromSpeedMult(0.5)
        SetTimeScale(0.5)
        Citizen.Wait(0)
    end
    SetAudioFlag("AllowScriptedSpeechInSlowMo", false)
    SetAudioFlag("AllowAmbientSpeechInSlowMo", false)
    -- Hooks::ResetAudioPitch
    SetTimeScale(1.0)
end
