function FX_MiscNewsTeam(alive)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed, false)
    local modelHash = GetHashKey("s_m_m_news_01")
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Citizen.Wait(0) end
    local newsGuy = CreatePed(26, modelHash, pos.x + 3.0, pos.y, pos.z, GetEntityHeading(playerPed), true, false)
    SetModelAsNoLongerNeeded(modelHash)
    GiveWeaponToPed(newsGuy, GetHashKey("WEAPON_MICROSMG"), 9999, true, true)
    SetPedCombatAttributes(newsGuy, 5, true)
    TaskCombatPed(newsGuy, playerPed, 0, 16)
end
