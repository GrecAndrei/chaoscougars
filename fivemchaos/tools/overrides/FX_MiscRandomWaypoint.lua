function FX_MiscRandomWaypoint(alive)
    local x = math.random(-4000, 4000) + 0.0
    local y = math.random(-4000, 4000) + 0.0
    SetNewWaypoint(x, y)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName("New waypoint set!")
    EndTextCommandThefeedPostTicker(false, false)
end
