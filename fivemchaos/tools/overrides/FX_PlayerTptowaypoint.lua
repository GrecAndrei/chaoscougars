function FX_PlayerTptowaypoint(alive)
    local waypoint = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypoint) then
        local coords = GetBlipInfoIdCoord(waypoint)
        local _, z = GetGroundZFor3dCoord(coords.x, coords.y, 500.0, 0.0, false, false)
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, z + 5.0, false, false, false, true)
    end
end
