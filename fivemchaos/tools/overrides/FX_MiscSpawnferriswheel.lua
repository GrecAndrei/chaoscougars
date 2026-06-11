function FX_MiscSpawnferriswheel(alive)
    local hash = GetHashKey("prop_ld_ferris_wheel")
    local playerPos = GetEntityCoords(PlayerPedId(), false)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
    end

    CreateObject(hash, playerPos.x, playerPos.y, playerPos.z, true, true, false)
    SetModelAsNoLongerNeeded(hash)
end
