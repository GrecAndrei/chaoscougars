function FX_PedsNotMenendez(alive)
    local deadPeds = {}
    local lastTick = GetGameTimer()
    local speechHash = GetHashKey("BUDDY_DOWN")
    local voiceName = "s_m_y_blackops_01_white_mini_01"
    while alive() do
        local curTick = GetGameTimer()
        local newDead = false
        for _, ped in ipairs(GetGamePool('CPed')) do
            if not deadPeds[ped] and IsEntityDead(ped, false) then
                deadPeds[ped] = true
                newDead = true
            end
        end
        if newDead and curTick - lastTick >= 2000 then
            lastTick = curTick
            local playerPos = GetEntityCoords(PlayerPedId(), false)
            PlayAmbientSpeechAtCoords(speechHash, voiceName, playerPos.x, playerPos.y, playerPos.z, "SPEECH_PARAMS_FORCE_SHOUTED")
        end
        Citizen.Wait(0)
    end
end
