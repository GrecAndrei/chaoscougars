-- MANUAL OVERRIDE from MiscFlamethrower.cpp
function FX_MiscFlamethrower(alive)
    local MAX_DURATION_BETWEEN_SHOTS = 10
    local MAX_DURATION_ANIMATION = 150
    -- animationHandleByPed: map ped -> {FxHandle=int, FullDuration=float, DurationSinceLastShot=float}
    local animationHandleByPed = {}
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
        Citizen.Wait(0)
    end
    while alive() do
        local firingPeds = {}
        for _, ped in ipairs(GetGamePool('CPed')) do
            if IsPedShooting(ped) then
                local weapon = GetSelectedPedWeapon(ped)
                if GetWeaponDamageType(weapon) == 3 then
                    table.insert(firingPeds, ped)
                end
            end
        end
        -- Remove not needed peds and cancel animations
        local delayRemovePeds = 25
        for ped, animInfo in pairs(animationHandleByPed) do
            if not DoesEntityExist(ped) or animInfo.FxHandle <= 0
            or animInfo.FullDuration > MAX_DURATION_ANIMATION
            or ((not IsPedShooting(ped) and IsPedWeaponReadyToShoot(ped))
                and animInfo.DurationSinceLastShot > MAX_DURATION_BETWEEN_SHOTS) then
                StopParticleFxLooped(animInfo.FxHandle, false)
                animationHandleByPed[ped] = nil
            else
                animInfo.FullDuration = animInfo.FullDuration + 1.0
                animInfo.DurationSinceLastShot = animInfo.DurationSinceLastShot + 1.0
            end
            delayRemovePeds = delayRemovePeds - 1
            if delayRemovePeds == 0 then
                delayRemovePeds = 25
                Citizen.Wait(0)
            end
        end
        -- Check for needed animation starts
        local delayAnimationStart = 25
        for _, ped in ipairs(firingPeds) do
            if animationHandleByPed[ped] == nil then
                UseParticleFxAsset("core")
                local weapon = GetCurrentPedWeaponEntityIndex(ped, 0)
                local handle = StartParticleFxLoopedOnEntity("ent_sht_flame", weapon, 1, 0, 0, 90, 0, 90, 2, false, false, false)
                animationHandleByPed[ped] = {FxHandle = handle, FullDuration = 0, DurationSinceLastShot = 0}
            else
                animationHandleByPed[ped].DurationSinceLastShot = 0
            end
            delayAnimationStart = delayAnimationStart - 1
            if delayAnimationStart == 0 then
                delayAnimationStart = 25
                Citizen.Wait(0)
            end
        end
        Citizen.Wait(0)
    end
    -- OnStop cleanup
    RemoveNamedPtfxAsset("core")
end
