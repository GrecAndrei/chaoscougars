function FX_MiscVehicleRain(alive)
    local lastTick = 0
    -- Memory::GetAllVehModels not available, using a popular vehicle list
    local vehModels = {
        GetHashKey("adder"),
        GetHashKey("t20"),
        GetHashKey("zentorno"),
        GetHashKey("infernus"),
        GetHashKey("turismor"),
        GetHashKey("cheetah"),
        GetHashKey("entityxf"),
        GetHashKey("vacca"),
        GetHashKey("banshee"),
        GetHashKey("comet2"),
        GetHashKey("feltzer2"),
        GetHashKey("ninef"),
        GetHashKey("sultan"),
        GetHashKey("penumbra"),
        GetHashKey("seminole")
    }

    for _, model in ipairs(vehModels) do
        RequestModel(model)
    end

    while alive() do
        local curTick = GetGameTimer()
        if curTick > lastTick + 500 then
            lastTick = curTick

            local playerPos = GetEntityCoords(PlayerPedId(), false)
            local spawnPos = vector3(
                playerPos.x + math.random(-100, 100),
                playerPos.y + math.random(-100, 100),
                playerPos.z + math.random(25, 50)
            )

            local model = vehModels[math.random(1, #vehModels)]
            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end

            local veh = CreateVehicle(model, spawnPos.x, spawnPos.y, spawnPos.z, GetEntityHeading(PlayerPedId()), true, true)
            SetVehicleModKit(veh, 0)
            SetVehicleWheelType(veh, math.random(0, 12))

            for i = 0, 49 do
                local maxMod = GetNumVehicleMods(veh, i)
                SetVehicleMod(veh, i, maxMod > 0 and math.random(0, maxMod - 1) or 0, math.random(0, 1) == 1)
                ToggleVehicleMod(veh, i, math.random(0, 1) == 1)
            end

            SetVehicleTyresCanBurst(veh, math.random(0, 1) == 1)
            SetVehicleWindowTint(veh, math.random(0, 6))
        end
        Citizen.Wait(0)
    end

    for _, model in ipairs(vehModels) do
        SetModelAsNoLongerNeeded(model)
    end
end
