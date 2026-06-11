function FX_PedsRevive(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and IsEntityDead(ped, false) and not IsPedAPlayer(ped) then
            local coords = GetEntityCoords(ped, false)
            local heading = GetEntityHeading(ped)
            local model = GetEntityModel(ped)
            DeletePed(ped)
            RequestModel(model)
            while not HasModelLoaded(model) do Citizen.Wait(0) end
            local newPed = CreatePed(26, model, coords.x, coords.y, coords.z, heading, true, false)
            SetModelAsNoLongerNeeded(model)
        end
    end
end
