function FX_PlayerTptowaypointopposite(alive)
    local waypoint = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypoint) then
        local coords = GetBlipInfoIdCoord(waypoint)
        local playerPos = GetEntityCoords(PlayerPedId(), false)
        local opposite = vector3(
            playerPos.x + (playerPos.x - coords.x),
            playerPos.y + (playerPos.y - coords.y),
            coords.z
        )
        local _, z = GetGroundZFor3dCoord(opposite.x, opposite.y, 500.0, 0.0, false, false)
        SetEntityCoords(PlayerPedId(), opposite.x, opposite.y, z + 5.0, false, false, false, true)
    end
end
