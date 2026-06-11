function FX_MiscFpsLimit(alive)
    local lagTimeDelay = 40
    while alive() do
        local lastUpdateTick = GetGameTimer()
        while lastUpdateTick > GetGameTimer() - lagTimeDelay do
        end
        Citizen.Wait(0)
    end
end
