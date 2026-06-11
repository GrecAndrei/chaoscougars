function FX_PedsObliterate(alive)
    RequestNamedPtfxAsset("scr_xm_orbital")
    RequestNamedPtfxAsset("scr_xm_orbital_blast")
    while not HasNamedPtfxAssetLoaded("scr_xm_orbital") or not HasNamedPtfxAssetLoaded("scr_xm_orbital_blast") do
        Citizen.Wait(0)
    end
    local count = 5
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) then
            local pos = GetEntityCoords(ped, false)
            UseParticleFxAsset("scr_xm_orbital")
            StartNetworkedParticleFxNonLoopedAtCoord("scr_xm_orbital_blast", pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
            PlaySoundFromCoord(-1, "DLC_XM_Explosions_Orbital_Cannon", pos.x, pos.y, pos.z, 0, true, 0, false)
            AddExplosion(pos.x, pos.y, pos.z, 9, 100.0, true, false, 3.0, false)
            SetEntityHealth(ped, 0, false)
            count = count - 1
            if count == 0 then
                count = 5
                Citizen.Wait(0)
            end
        end
    end
    RemoveNamedPtfxAsset("scr_xm_orbital")
    RemoveNamedPtfxAsset("scr_xm_orbital_blast")
end
