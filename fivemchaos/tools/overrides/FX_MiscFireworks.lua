function FX_MiscFireworks(alive)
    local lastFirework = 0
    SetClockTime(0, 0, 0)
    local weaponHash = GetHashKey("WEAPON_FIREWORK")
    for _, ped in ipairs(GetGamePool('CPed')) do
        if DoesEntityExist(ped) then
            GiveWeaponToPed(ped, weaponHash, 9999, true, true)
        end
    end
    while alive() do
        local currentTime = GetGameTimer()
        if currentTime - lastFirework > 500 then
            lastFirework = currentTime
            local pos = GetEntityCoords(PlayerPedId(), true)
            RequestNamedPtfxAsset("proj_indep_firework_v2")
            while not HasNamedPtfxAssetLoaded("proj_indep_firework_v2") do Citizen.Wait(0) end
            UseParticleFxAsset("proj_indep_firework_v2")
            StartParticleFxNonLoopedAtCoord("scr_indep_fireworks",
                pos.x + math.random(-30, 30), pos.y + math.random(-30, 30), pos.z + math.random(15, 35),
                0.0, 0.0, 0.0, 1.0, false, false, false)
        end
        Citizen.Wait(10)
    end
end
