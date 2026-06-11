function FX_MiscEarthquake(alive)
    while alive() do
        ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 0.35)
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(veh) and math.random() < 0.08 then
                ApplyForceToEntity(veh, 1, math.random(-5, 5), math.random(-5, 5), 10.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
            end
        end
        Citizen.Wait(150)
    end
    StopGameplayCamShaking(true)
end
