function FX_TpFakex2(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)

    DoScreenFadeOut(100)
    Citizen.Wait(100)
    SetEntityCoordsNoOffset(playerPed, 935.0, 3800.0, 2300.0, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)

    Citizen.Wait(math.random(3500, 6000))

    -- Now fake-teleport back to a different fake destination
    local fakeDest = vector3(-75.7, -818.62, 326.16)
    DoScreenFadeOut(100)
    Citizen.Wait(100)
    SetEntityCoordsNoOffset(playerPed, fakeDest.x, fakeDest.y, fakeDest.z, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)

    -- CurrentEffect::OverrideEffectNameFromId
    Citizen.Wait(math.random(3500, 6000))

    DoScreenFadeOut(100)
    Citizen.Wait(100)
    SetEntityCoordsNoOffset(playerPed, playerPos.x, playerPos.y, playerPos.z, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)
end
