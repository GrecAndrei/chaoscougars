function FX_MiscSpinningProps(alive)
    local ROTATION_SPEED = (1.3 * 360.0) / 1000.0
    local lastTick = GetGameTimer()

    while alive() do
        local currentTick = GetGameTimer()
        local tickDelta = currentTick - lastTick
        lastTick = currentTick

        for _, prop in ipairs(GetGamePool('CObject')) do
            local rotation = GetEntityRotation(prop, 2)
            SetEntityRotation(prop, rotation.x, rotation.y, rotation.z + (ROTATION_SPEED * tickDelta), 2, true)
        end

        Citizen.Wait(0)
    end
end
