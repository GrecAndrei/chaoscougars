function FX_MiscMidas(alive)
    local model = GetHashKey("prop_money_bag_01")
    RequestModel(model)

    while alive() do
        local playerPed = PlayerPedId()
        local cE = playerPed

        if IsPedInAnyVehicle(playerPed, false) then
            cE = GetVehiclePedIsIn(playerPed, false)
            ToggleVehicleMod(cE, 20, true)
            SetVehicleTyreSmokeColor(cE, 255, 215, 0)
            ClearVehicleCustomPrimaryColour(cE)
            ClearVehicleCustomSecondaryColour(cE)
            SetVehicleColours(cE, 158, 158)
            SetVehicleExtraColours(cE, 160, 158)
            SetVehicleEnveffScale(cE, 0.0)
            SetVehicleDirtLevel(cE, 0.0)
        end

        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if IsEntityTouchingEntity(cE, veh) then
                ToggleVehicleMod(veh, 20, true)
                SetVehicleTyreSmokeColor(veh, 255, 215, 0)
                ClearVehicleCustomPrimaryColour(veh)
                ClearVehicleCustomSecondaryColour(veh)
                SetVehicleColours(veh, 158, 158)
                SetVehicleExtraColours(veh, 160, 158)
                SetVehicleEnveffScale(veh, 0.0)
                SetVehicleDirtLevel(veh, 0.0)
            end
        end

        for _, ped in ipairs(GetGamePool('CPed')) do
            if not IsPedAPlayer(ped) then
                if not IsEntityAMissionEntity(ped) or IsCutscenePlaying() then
                    if IsEntityTouchingEntity(cE, ped) then
                        local pos = GetEntityCoords(ped, false)
                        CreateAmbientPickup(GetHashKey("PICKUP_MONEY_SECURITY_CASE"), pos.x, pos.y, pos.z, 0, 1000, model, false, true)
                        SetEntityCoords(ped, 0.0, 0.0, 0.0, false, false, false, false)
                        SetPedAsNoLongerNeeded(ped)
                        DeletePed(ped)
                    end
                end
            end
        end

        for _, prop in ipairs(GetGamePool('CObject')) do
            if IsEntityTouchingEntity(cE, prop) and not IsPedClimbing(cE) then
                if not IsEntityAMissionEntity(prop) or IsCutscenePlaying() then
                    if not GetEntityAttachedTo(prop) then
                        local pos = GetEntityCoords(prop, false)
                        CreateAmbientPickup(GetHashKey("PICKUP_MONEY_SECURITY_CASE"), pos.x, pos.y, pos.z, 0, 1000, model, false, true)
                        SetEntityCoords(prop, 0.0, 0.0, 0.0, false, false, false, false)
                        SetEntityAsNoLongerNeeded(prop)
                        DeleteEntity(prop)
                    end
                end
            end
        end

        if IsPedArmed(playerPed, 7) then
            local weaponHash = GetCurrentPedWeapon(playerPed, true)
            SetPedWeaponTintIndex(playerPed, weaponHash, 2)
        end

        Citizen.Wait(0)
    end

    SetModelAsNoLongerNeeded(model)
end
