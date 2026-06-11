function FX_MiscLowpitch(alive)
    local targetPitch = -900.0 + math.random() * (-300.0 - (-900.0))
    while alive() do
        -- Hooks::SetAudioPitch not available
        Citizen.Wait(0)
    end
    -- Hooks::ResetAudioPitch not available
end
