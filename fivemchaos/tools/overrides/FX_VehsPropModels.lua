function FX_VehsPropModels(alive)
    while alive() do
        local models = {}
        for _, prop in ipairs(GetGamePool('CObject')) do
            if DoesEntityExist(prop) then
                local model = GetEntityModel(prop)
                local min, max = GetModelDimensions(model)
                local size = #(max - min)
                if size > 0.75 and size < 6.0 then
                    models[#models + 1] = model
                end
            end
        end
        if #models > 0 then
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed, false)
            local pick = models[math.random(#models)]
            RequestModel(pick)
            while not HasModelLoaded(pick) do Citizen.Wait(0) end
            local obj = CreateObject(pick, playerPos.x + math.random(-10, 10), playerPos.y + math.random(-10, 10), playerPos.z + 10.0, true, true, false)
            SetModelAsNoLongerNeeded(pick)
            SetObjectAsNoLongerNeeded(obj)
        end
        Citizen.Wait(1000)
    end
end
