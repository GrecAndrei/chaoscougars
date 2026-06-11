function FX_PedsSpawndancingapes(alive)
    local group = AddRelationshipGroup("_DANCING__APES")
    SetRelationshipBetweenGroups(0, group, GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), group)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local chimps = {GetHashKey("a_c_chimp"), GetHashKey("a_c_rhesus")}
    RequestAnimDict("missfbi3_sniping")
    for i = 0, 2 do
        local modelHash = chimps[math.random(2)]
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
        local ped = CreatePed(28, modelHash, playerPos.x, playerPos.y, playerPos.z, 0.0, true, false)
        SetModelAsNoLongerNeeded(modelHash)
        SetPedRelationshipGroupHash(ped, group)
        if IsPedInAnyVehicle(playerPed, false) then
            SetPedIntoVehicle(ped, GetVehiclePedIsIn(playerPed, false), -2)
        end
        SetPedCanRagdoll(ped, false)
        SetPedSuffersCriticalHits(ped, false)
        TaskPlayAnim(ped, "missfbi3_sniping", "dance_m_default", 4.0, -4.0, -1, 1, 0.0, false, false, false)
        SetPedConfigFlag(ped, 292, true)
        Citizen.Wait(0)
    end
    RemoveAnimDict("missfbi3_sniping")
end
