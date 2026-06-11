local lastPlayerKills = 0

function FX_PlayerPacifist(alive)
    lastPlayerKills = -1
    while alive() do
        local playerPed = PlayerPedId()
        local allPlayerKills = 0

        local statHashes = {
            GetHashKey("SP0_KILLS"),
            GetHashKey("SP1_KILLS"),
            GetHashKey("SP2_KILLS")
        }

        for _, hash in ipairs(statHashes) do
            local curKills = GetStatInt(hash, -1)
            if curKills then
                allPlayerKills = allPlayerKills + curKills
            end
        end

        if lastPlayerKills >= 0 and allPlayerKills > lastPlayerKills then
            StartEntityFire(playerPed)
            SetEntityHealth(playerPed, 0, 0)
        end
        lastPlayerKills = allPlayerKills
        Citizen.Wait(0)
    end
end
