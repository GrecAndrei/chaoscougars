function FX_TimeX02(alive)
    while alive() do
        SetAudioFlag("AllowScriptedSpeechInSlowMo", true)
        SetAudioFlag("AllowAmbientSpeechInSlowMo", true)
        -- Hooks::SetAudioPitchFromSpeedMult(0.2)
        SetTimeScale(0.2)
        Citizen.Wait(0)
    end
    SetAudioFlag("AllowScriptedSpeechInSlowMo", false)
    SetAudioFlag("AllowAmbientSpeechInSlowMo", false)
    -- Hooks::ResetAudioPitch
    SetTimeScale(1.0)
end
