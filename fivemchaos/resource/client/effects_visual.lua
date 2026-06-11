-- sync_mode: VISUAL — client-only visual/audio, safe on all clients

function FX_FlipScreen(alive)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    RenderScriptCams(true, true, 500, true, true)
    while alive() do
        local pos = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        SetCamCoord(cam, pos.x, pos.y, pos.z)
        SetCamRot(cam, rot.x, rot.y, rot.z + 180.0, 2)
        SetCamFov(cam, GetGameplayCamFov())
        Citizen.Wait(0)
    end
    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(cam, false)
end

function FX_QuakeFOV(alive)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    RenderScriptCams(true, true, 300, true, true)
    while alive() do
        local pos = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        SetCamCoord(cam, pos.x, pos.y, pos.z)
        SetCamRot(cam, rot.x, rot.y, rot.z, 2)
        SetCamFov(cam, 120.0)
        Citizen.Wait(0)
    end
    RenderScriptCams(false, true, 300, true, true)
    DestroyCam(cam, false)
end

function FX_NightVision(alive)
    SetNightvision(true)
    while alive() do Citizen.Wait(500) end
    SetNightvision(false)
end

function FX_HeatVision(alive)
    SetSeethrough(true)
    while alive() do Citizen.Wait(500) end
    SetSeethrough(false)
end

function FX_LSD(alive)
    SetTimecycleModifier('drugslean')
    SetTimecycleModifierStrength(1.5)
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_Noir(alive)
    SetTimecycleModifier('NG_filmic01')
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_DeepFried(alive)
    SetTimecycleModifier('spectator5')
    SetTimecycleModifierStrength(2.0)
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_NoHUD(alive)
    while alive() do HideHudAndRadarThisFrame(); Citizen.Wait(0) end
end

function FX_FogScreen(alive)
    SetTimecycleModifier('FogGreenLight')
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_ExtremeBright(alive)
    SetTimecycleModifier('WhiteOut')
    SetTimecycleModifierStrength(1.0)
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_ExtremeDark(alive)
    SetArtificialLightsState(true)
    while alive() do Citizen.Wait(500) end
    SetArtificialLightsState(false)
end

-- === WEATHER ===

function FX_Storm(alive)
    SetWeatherTypeNowPersist('THUNDER')
    while alive() do Citizen.Wait(1000) end
    ClearWeatherTypePersist()
end

function FX_Fog(alive)
    SetWeatherTypeNowPersist('FOGGY')
    while alive() do Citizen.Wait(1000) end
    ClearWeatherTypePersist()
end

function FX_Snow(alive)
    SetWeatherTypeNowPersist('XMAS')
    while alive() do Citizen.Wait(1000) end
    ClearWeatherTypePersist()
end

function FX_DiscoWeather(alive)
    local weathers = {'EXTRASUNNY', 'THUNDER', 'FOGGY', 'XMAS', 'OVERCAST', 'RAIN', 'CLEARING'}
    while alive() do
        SetWeatherTypeNow(weathers[math.random(#weathers)])
        Citizen.Wait(500)
    end
    ClearWeatherTypePersist()
end

-- === METEOR / AIRSTRIKE (visual explosions, safe on all) ===

function FX_MeteorRain(alive)
    while alive() do
        local pos = GetEntityCoords(PlayerPedId())
        local x = pos.x + math.random(-80, 80)
        local y = pos.y + math.random(-80, 80)
        AddExplosion(x, y, pos.z + math.random(30, 60), 28, 8.0, true, false, 1.0)
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.3)
        Citizen.Wait(math.random(150, 500))
    end
    StopGameplayCamShaking(true)
end

function FX_Airstrike()
    local pos = GetEntityCoords(PlayerPedId())
    for i = 1, 8 do
        SetTimeout(i * 400, function()
            local x = pos.x + math.random(-25, 25)
            local y = pos.y + math.random(-25, 25)
            AddExplosion(x, y, pos.z + 1.0, 4, 12.0, true, false, 1.0)
        end)
    end
end

-- === NEW: SCREEN/VISUAL ===

function FX_Greyscale(alive)
    SetTimecycleModifier('spectator8')
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_WavyVision(alive)
    SetTimecycleModifier('drug_wobbly')
    SetTimecycleModifierStrength(1.5)
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_FishEye(alive)
    SetTimecycleModifier('Barry_Stoned')
    SetTimecycleModifierStrength(1.0)
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_Bloom(alive)
    SetTimecycleModifier('Bloom')
    SetTimecycleModifierStrength(2.0)
    while alive() do Citizen.Wait(500) end
    ClearTimecycleModifier()
end

function FX_TunnelVision(alive)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    RenderScriptCams(true, true, 300, true, true)
    while alive() do
        local pos = GetGameplayCamCoord()
        local rot = GetGameplayCamRot(2)
        SetCamCoord(cam, pos.x, pos.y, pos.z)
        SetCamRot(cam, rot.x, rot.y, rot.z, 2)
        SetCamFov(cam, 25.0)
        Citizen.Wait(0)
    end
    RenderScriptCams(false, true, 300, true, true)
    DestroyCam(cam, false)
end

-- === NEW: TIME/WEATHER ===

function FX_Midnight(alive)
    SetClockTime(0, 0, 0)
    NetworkOverrideClockTime(0, 0, 0)
    while alive() do Citizen.Wait(500) end
    NetworkClearClockTimeOverride()
end

function FX_HighNoon(alive)
    SetClockTime(12, 0, 0)
    NetworkOverrideClockTime(12, 0, 0)
    while alive() do Citizen.Wait(500) end
    NetworkClearClockTimeOverride()
end

function FX_Smog(alive)
    SetWeatherTypeNowPersist('SMOG')
    while alive() do Citizen.Wait(1000) end
    ClearWeatherTypePersist()
end

function FX_RainStorm(alive)
    SetWeatherTypeNowPersist('RAIN')
    while alive() do Citizen.Wait(1000) end
    ClearWeatherTypePersist()
end

-- === NEW: GRAVITY PULSE (visual sync, but it's gravity) ===

function FX_GravityPulse(alive)
    local levels = {0, 1, 2, 3}
    while alive() do
        SetGravityLevel(levels[math.random(#levels)])
        Citizen.Wait(2500)
    end
    SetGravityLevel(0)
end
