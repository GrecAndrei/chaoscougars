function FX_TpMission(alive)
    local playerPed = PlayerPedId()
    local blips = {}
    for _, blip in ipairs({GetFirstBlipInfoId(1)}) do
        -- mission blips
    end
    local x = math.random(-500, 500) + 0.0
    local y = math.random(-500, 500) + 0.0
    local _, z = GetGroundZFor3dCoord(x, y, 500.0, 0.0, false, false)
    SetEntityCoords(playerPed, x, y, z + 5.0, false, false, false, true)
end
