function FX_PedsKifflom(alive)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            local modelHash = GetHashKey("u_m_m_jesus_01")
            local coords = GetEntityCoords(ped, false)
            local heading = GetEntityHeading(ped)
            DeletePed(ped)
            Citizen.Wait(0)
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
            CreatePed(26, modelHash, coords.x, coords.y, coords.z, heading, true, false)
            SetModelAsNoLongerNeeded(modelHash)
        end
    end
end
