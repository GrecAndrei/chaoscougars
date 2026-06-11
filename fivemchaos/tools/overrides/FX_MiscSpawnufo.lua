function FX_MiscSpawnufo(alive)
    local hash = GetHashKey("p_spinning_anus_s")
    local playerPos = GetEntityCoords(PlayerPedId(), false)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
    end

    CreateObject(hash, playerPos.x, playerPos.y, playerPos.z, true, true, false)
    SetModelAsNoLongerNeeded(hash)
end
