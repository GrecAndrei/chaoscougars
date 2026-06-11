function FX_PlayerSimeonsays(alive)
    local actions = {
        {name = "Jump", control = 22},
        {name = "Aim", control = 25},
        {name = "Attack", control = 24},
        {name = "Sprint", control = 21},
        {name = "Duck", control = 36},
        {name = "Reload", control = 45},
    }
    local action = actions[math.random(#actions)]
    local opposite = math.random(0, 1) == 1
    local displayName = (opposite and "DON'T " or "") .. action.name .. "!"
    local lastTime = 0
    local waitTime = 2000
    local dead = false
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(displayName)
    EndTextCommandThefeedPostTicker(false, false)
    while alive() do
        local playerPed = PlayerPedId()
        if IsPedDeadOrDying(playerPed, true) then
            if not dead then
                dead = true
                BeginTextCommandThefeedPost("STRING")
                AddTextComponentSubstringPlayerName("FAILED: You died!")
                EndTextCommandThefeedPostTicker(true, true)
            end
            Citizen.Wait(100)
        else
            local curTime = GetGameTimer()
            if curTime - lastTime > waitTime then
                BeginTextCommandThefeedPost("STRING")
                AddTextComponentSubstringPlayerName("FAILED: Time's up!")
                EndTextCommandThefeedPostTicker(true, true)
                SetEntityHealth(playerPed, 0)
                break
            end
            if IsControlJustPressed(0, action.control) then
                if not opposite then
                    BeginTextCommandThefeedPost("STRING")
                    AddTextComponentSubstringPlayerName("PASSED: Good job!")
                    EndTextCommandThefeedPostTicker(false, false)
                    break
                else
                    BeginTextCommandThefeedPost("STRING")
                    AddTextComponentSubstringPlayerName("FAILED: I said DON'T " .. action.name .. "!")
                    EndTextCommandThefeedPostTicker(true, true)
                    SetEntityHealth(playerPed, 0)
                    break
                end
            end
        end
        Citizen.Wait(0)
    end
end
