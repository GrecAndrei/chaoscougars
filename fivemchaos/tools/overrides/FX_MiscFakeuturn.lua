function FX_MiscFakeuturn(alive)
    -- CurrentEffect::OverrideEffectNameFromId("misc_uturn") - not available, will display as Fake U-Turn

    local function DoUTurn()
        local entities = {}
        for _, ped in ipairs(GetGamePool('CPed')) do
            table.insert(entities, ped)
        end
        for _, veh in ipairs(GetGamePool('CVehicle')) do
            table.insert(entities, veh)
        end
        for _, prop in ipairs(GetGamePool('CObject')) do
            table.insert(entities, prop)
        end

        local camHeading = GetGameplayCamRelativeHeading()

        for _, ent in ipairs(entities) do
            local rot = GetEntityRotation(ent, 2)
            local vel = GetEntityVelocity(ent)
            SetEntityRotation(ent, -rot.x, -rot.y, rot.z + 180.0, 2, true)
            SetEntityVelocity(ent, -vel.x, -vel.y, -vel.z)
        end

        SetGameplayCamRelativeHeading(camHeading)
    end

    DoUTurn()
    Citizen.Wait(math.random(6000, 9000))
    DoUTurn()
end
