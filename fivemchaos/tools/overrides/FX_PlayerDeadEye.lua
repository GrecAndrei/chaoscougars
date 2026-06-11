function FX_PlayerDeadEye(alive)
    local didSelect = false
    local isBlocked = false
    while alive() do
        local player = PlayerPedId()
        local weaponHash = GetSelectedPedWeapon(player, true)
        if weaponHash ~= 0 and not isBlocked then
            local tgi = GetWeapontypeGroup(weaponHash)
            if tgi ~= -764164997 and tgi ~= -1207784977 and weaponHash ~= 1122106729 and weaponHash ~= 3059529913 then
                if IsControlPressed(0, 25) then
                    SetTimeScale(0.2)
                    DisableControlAction(0, 24, true)
                    DisableControlAction(2, 257, true)
                    if IsDisabledControlPressed(0, 24) or IsDisabledControlPressed(2, 257) then
                        if not didSelect then
                            local camCoords = GetGameplayCamCoord()
                            local camDir = GetGameplayCamRot(2)
                            local targPos = camCoords + (
                                vector3(math.sin(camDir.z * math.pi/180) * -1, math.cos(camDir.z * math.pi/180) * -1, math.sin(camDir.x * math.pi/180))
                                * 10000.0
                            )
                            local ray = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, targPos.x, targPos.y, targPos.z, 12, player, 7)
                            local _, hit, hitCoords, _, entityHandle = GetShapeTestResult(ray)
                            if hit and IsEntityAPed(entityHandle) then
                                local boneIds = {0x0, 0x2e28, 0xe39f, 0xf9bb, 0x3779, 0xca72, 0x9000, 0xcc4d, 0xe0fd, 0x5c01, 0x60f0, 0x60f1, 0x60f2, 0xfcd9, 0xb1c5, 0xeeeb, 0x49d9, 0x29d2, 0x9d4d, 0x6e5c, 0xdead, 0x9995, 0x796e}
                                local bestBone = boneIds[1]
                                local bestDist = 99999.0
                                for _, bid in ipairs(boneIds) do
                                    local bc = GetPedBoneCoords(entityHandle, bid, 0.0, 0.0, 0.0)
                                    local dist = #(hitCoords - bc)
                                    if dist < bestDist then
                                        bestDist = dist
                                        bestBone = bid
                                    end
                                end
                                didSelect = true
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
    SetTimeScale(1.0)
end
