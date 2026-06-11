-- MANUAL OVERRIDE from MiscBlackHole.cpp
function FX_WorldBlackhole(alive)
    local ms_BlackHolePos = GetEntityCoords(PlayerPedId(), false)
    ms_BlackHolePos = vector3(
        ms_BlackHolePos.x + math.random(-1000, 1000),
        ms_BlackHolePos.y + math.random(-1000, 1000),
        ms_BlackHolePos.z + math.random(400, 800)
    )
    local ms_CurRadius = 0.0
    while alive() do
        -- XInput::SetAllControllersRumble not available in FiveM
        if ms_CurRadius < 200.0 then
            ms_CurRadius = ms_CurRadius + 0.2 + GetFrameTime()
        end
        DrawSphere(ms_BlackHolePos.x, ms_BlackHolePos.y, ms_BlackHolePos.z, ms_CurRadius, 0, 0, 0, 1.0)
        ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 0.1 * ms_CurRadius / 200.0)
        local entities = {}
        for _, ped in ipairs(GetGamePool('CPed')) do table.insert(entities, ped) end
        for _, veh in ipairs(GetGamePool('CVehicle')) do table.insert(entities, veh) end
        for _, prop in ipairs(GetGamePool('CObject')) do table.insert(entities, prop) end
        local playerVeh = GetVehiclePedIsIn(PlayerPedId(), false)
        for _, entity in ipairs(entities) do
            if not DoesEntityExist(entity) then goto _continue_ end
            local pos = GetEntityCoords(entity, false)
            if (entity ~= playerVeh and not IsEntityAMissionEntity(entity))
            or GetEntityHeightAboveGround(entity) > 2.0 then
                local vel = GetEntityVelocity(entity)
                local newVel = vector3(
                    (ms_BlackHolePos.x - pos.x) - (2.0 * vel.x),
                    (ms_BlackHolePos.y - pos.y) - (2.0 * vel.y),
                    (ms_BlackHolePos.z - pos.z) - (2.0 * vel.z)
                )
                ApplyForceToEntityCenterOfMass(entity, 0, newVel.x, newVel.y, newVel.z, true, false, true, true)
            end
            local dist = #(pos - ms_BlackHolePos)
            if dist < ms_CurRadius then
                if IsEntityAPed(entity) then
                    SetEntityHealth(entity, 0, 0)
                elseif IsEntityAVehicle(entity) then
                    ExplodeVehicle(entity, true, false)
                end
                if not IsEntityAMissionEntity(entity) then
                    DeleteEntity(entity)
                end
            end
            ::_continue_::
        end
        Citizen.Wait(0)
    end
end
