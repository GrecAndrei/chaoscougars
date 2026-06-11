function FX_TpRandom(alive)
    local x = math.random(-3000, 3000) + 0.0
    local y = math.random(-3000, 3000) + 0.0
    local _, z = GetGroundZFor3dCoord(x, y, 500.0, 0.0, false, false)
    SetEntityCoords(PlayerPedId(), x, y, z + 5.0, false, false, false, true)
end
