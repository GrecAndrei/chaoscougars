function FX_PedsMercenaries(alive)
    while alive() do
        local mercHash = GetHashKey("s_m_m_marine_01")
        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and IsPedHuman(ped) then
                local coords = GetEntityCoords(ped, false)
                local heading = GetEntityHeading(ped)
                DeletePed(ped)
                Citizen.Wait(0)
                RequestModel(mercHash)
                while not HasModelLoaded(mercHash) do Citizen.Wait(0) end
                local merc = CreatePed(26, mercHash, coords.x, coords.y, coords.z, heading, true, false)
                SetModelAsNoLongerNeeded(mercHash)
                GiveWeaponToPed(merc, GetHashKey("WEAPON_CARBINERIFLE"), 9999, true, true)
                TaskCombatPed(merc, PlayerPedId(), 0, 16)
            end
        end
        Citizen.Wait(10000)
    end
end
