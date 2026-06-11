function FX_MiscHighpitch(alive)
    local targetPitch = 750.0 + math.random() * (2000.0 - 750.0)
    while alive() do
        -- Hooks::SetAudioPitch not available
        Citizen.Wait(0)
    end
    -- Hooks::ResetAudioPitch not available
end
