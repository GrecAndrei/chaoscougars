function FX_TpFake(alive)
    -- Hooks::EnableScriptThreadBlock
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)

    local fakeTpTypes = {
        { id = "tp_lsairport", coords = vector3(-1388.6, -3111.61, 13.94) },
        { id = "tp_mazebanktower", coords = vector3(-75.7, -818.62, 326.16) },
        { id = "tp_skyfall", coords = vector3(935.0, 3800.0, 2300.0) },
        { id = "player_tp_store" },
        { id = "tp_random" }
    }

    local chosen = fakeTpTypes[math.random(1, #fakeTpTypes)]
    -- CurrentEffect::OverrideEffectNameFromId

    DoScreenFadeOut(100)
    Citizen.Wait(100)
    if chosen.coords then
        SetEntityCoordsNoOffset(playerPed, chosen.coords.x, chosen.coords.y, chosen.coords.z, false, false, false)
    elseif chosen.id == "player_tp_store" then
        local stores = {
            vector3(372.29, 326.39, 103.57),
            vector3(-1487.29, -376.92, 40.16),
            vector3(810.94, -2157.19, 29.62),
            vector3(72.3, -1399.1, 28.4)
        }
        SetEntityCoordsNoOffset(playerPed, stores[math.random(1, #stores)].x, stores[math.random(1, #stores)].y, stores[math.random(1, #stores)].z, false, false, false)
    else
        local randX = (math.random() * 8000.0) - 4000.0
        local randY = (math.random() * 12000.0) - 4000.0
        SetEntityCoordsNoOffset(playerPed, randX, randY, 500.0, false, false, false)
    end
    Citizen.Wait(0)
    DoScreenFadeIn(200)

    Citizen.Wait(math.random(3500, 6000))

    DoScreenFadeOut(100)
    Citizen.Wait(100)
    SetEntityCoordsNoOffset(playerPed, playerPos.x, playerPos.y, playerPos.z, false, false, false)
    Citizen.Wait(0)
    DoScreenFadeIn(200)

    -- Hooks::DisableScriptThreadBlock
end
