function FX_MiscEsp(alive)
    local maxDistance = 75.0
    local thickness = 0.001
    local lineColor = {r = 255, g = 0, b = 0, a = 255}
    local boneIds = {0x0, 0x2e28, 0xe39f, 0xf9bb, 0x3779, 0xca72, 0x9000, 0xcc4d, 0xe0fd, 0x5c01, 0x60f0, 0x60f1, 0x60f2, 0xfcd9, 0xb1c5, 0xeeeb, 0x49d9, 0x29d2, 0x9d4d, 0x6e5c, 0xdead, 0x9995, 0x796e}
    local connections = {
        {0x0, 0xe0fd}, {0xe0fd, 0x5c01}, {0x5c01, 0x60f0}, {0x60f0, 0x60f1},
        {0x60f1, 0x60f2}, {0x60f2, 0x9995}, {0x9995, 0x796e},
        {0xe0fd, 0xfcd9}, {0xfcd9, 0xb1c5}, {0xb1c5, 0xeeeb}, {0xeeeb, 0x49d9},
        {0xe0fd, 0x29d2}, {0x29d2, 0x9d4d}, {0x9d4d, 0x6e5c}, {0x6e5c, 0xdead},
        {0x0, 0x2e28}, {0x2e28, 0xe39f}, {0xe39f, 0xf9bb}, {0xf9bb, 0x3779},
        {0x2e28, 0xca72}, {0xca72, 0x9000}, {0x9000, 0xcc4d},
    }
    local points = {}
    while alive() do
        local playerPed = PlayerPedId()
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and IsEntityOnScreen(ped) and not IsEntityDead(ped, false)
            and not IsPedAPlayer(ped) and #(GetEntityCoords(ped) - GetEntityCoords(playerPed)) < maxDistance then
                for i = 1, #boneIds do
                    points[i] = GetPedBoneCoords(ped, boneIds[i], 0.0, 0.0, 0.0)
                end
                for _, conn in ipairs(connections) do
                    if points[conn[1]] and points[conn[2]] then
                        DrawLine(
                            points[conn[1]].x, points[conn[1]].y, points[conn[1]].z,
                            points[conn[2]].x, points[conn[2]].y, points[conn[2]].z,
                            lineColor.r, lineColor.g, lineColor.b, lineColor.a
                        )
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end
