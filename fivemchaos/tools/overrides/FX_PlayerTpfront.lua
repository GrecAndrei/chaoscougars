function FX_PlayerTpfront(alive)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped, false)
    local heading = GetEntityHeading(ped)
    local x = coords.x + math.sin(math.rad(heading)) * -50
    local y = coords.y + math.cos(math.rad(heading)) * -50
    local _, z = GetGroundZFor3dCoord(x, y, 500.0, 0.0, false, false)
    SetEntityCoords(ped, x, y, z + 5.0, false, false, false, true)
end
