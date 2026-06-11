-- MANUAL OVERRIDE from PedsFrozen.cpp
function FX_PedsFrozen(alive)
    local lastTick = GetGameTimer()
    local wentThroughPeds = {}
    while alive() do
        local curTick = GetGameTimer()
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed, false)
        if lastTick < curTick - 1000 then
            lastTick = curTick
            for _, ped in ipairs(GetGamePool('CPed')) do
                if not IsPedAPlayer(ped) then
                    local pedPos = GetEntityCoords(ped, false)
                    if GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, pedPos.x, pedPos.y, pedPos.z, false) < 50.0 then
                        SetPedConfigFlag(ped, 292, true)
                        table.insert(wentThroughPeds, ped)
                    end
                end
            end
            for i = #wentThroughPeds, 1, -1 do
                local ped = wentThroughPeds[i]
                local pedPos = GetEntityCoords(ped, false)
                local pedExists = DoesEntityExist(ped)
                if not pedExists or GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, pedPos.x, pedPos.y, pedPos.z, false) > 50.0 then
                    if pedExists then
                        SetPedConfigFlag(ped, 292, false)
                    end
                    table.remove(wentThroughPeds, i)
                end
            end
            SetPedConfigFlag(PlayerPedId(), 292, false)
        end
        Citizen.Wait(0)
    end
    -- OnStop cleanup
    for _, ped in ipairs(GetGamePool('CPed')) do
        SetPedConfigFlag(ped, 292, false)
    end
end
