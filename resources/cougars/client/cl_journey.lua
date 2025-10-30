-- COUGAR SPECIAL EFFECTS - USING PROPER COLLISION DETECTION
Citizen.CreateThread(function()
    print('^2[Effects] Starting with proper collision detection^7')
    
    while true do
        Wait(50) -- Check 20 times per second
        
        if journeyActive and localCougars then
            local playerPed = PlayerPedId()
            
            -- Only on foot
            if not IsPedInAnyVehicle(playerPed, false) then
                local currentTime = GetGameTimer()
                
                for netId, data in pairs(localCougars) do
                    if data.entity and DoesEntityExist(data.entity) then
                        
                        -- USE PROPER COLLISION DETECTION
                        local isTouching = IsEntityTouchingEntity(playerPed, data.entity)
                        
                        if isTouching then
                            print('^3[Collision] Player touching ' .. data.type .. ' cougar!^7')
                            
                            -- BLUE BALL
                            if data.type == 'blueBall' then
                                if not data.abilityUsed then
                                    data.abilityUsed = true
                                    print('^3>>> BLUE BALL LAUNCHING <<<^7')
                                    SetPedToRagdoll(playerPed, 1500, 1500, 0, false, false, false)
                                    PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true)
                                    SetEntityVelocity(playerPed, 0.0, 0.0, 15.0)

                                    if data.prop and DoesEntityExist(data.prop) then
                                        local coords = GetEntityCoords(data.prop)
                                        PlaySoundFromCoord(-1, "GOLF_BALL_TIMER", coords.x, coords.y, coords.z, nil, false, 0, false)
                                        AddExplosion(coords.x, coords.y, coords.z, 2, 0.0, false, true, 0.0)
                                        DeleteEntity(data.prop)
                                        data.prop = nil
                                    end

                                    TriggerServerEvent('cougar:died', netId, data.type)
                                    if data.entity and DoesEntityExist(data.entity) then
                                        DeleteEntity(data.entity)
                                    end
                                    localCougars[netId] = nil
                                end
                            end

                            if data.type == 'purpleBall' then
                                if not data.abilityUsed then
                                    data.abilityUsed = true
                                    print('^5>>> PURPLE BALL MEGA LAUNCHING <<<^7')
                                    SetPedToRagdoll(playerPed, 3000, 3000, 0, false, false, false)
                                    StartScreenEffect("RaceTurbo", 2000, false)
                                    PlaySoundFrontend(-1, "FLIGHT_TURBULENCE_MASTER", "HUD_AWARDS", true)
                                    SetEntityVelocity(playerPed, 0.0, 0.0, 35.0)

                                    if data.prop and DoesEntityExist(data.prop) then
                                        local coords = GetEntityCoords(data.prop)
                                        AddExplosion(coords.x, coords.y, coords.z, 2, 0.0, false, true, 0.0)
                                        DeleteEntity(data.prop)
                                        data.prop = nil
                                    end

                                    TriggerServerEvent('cougar:died', netId, data.type)
                                    if data.entity and DoesEntityExist(data.entity) then
                                        DeleteEntity(data.entity)
                                    end
                                    localCougars[netId] = nil
                                end
                            end

                            if data.type == 'barrier' then
                                if not data.abilityUsed then
                                    data.abilityUsed = true
                                    print('^6>>> BARRIER REVERSING <<<^7')
                                    local vel = GetEntityVelocity(playerPed)
                                    SetPedToRagdoll(playerPed, 1000, 1000, 0, false, false, false)
                                    Wait(50)
                                    SetEntityVelocity(playerPed, -vel.x * 2.5, -vel.y * 2.5, 5.0)
                                    PlaySoundFrontend(-1, "CHECKPOINT_UNDER_THE_BRIDGE", "HUD_MINI_GAME_SOUNDSET", true)

                                    if data.prop and DoesEntityExist(data.prop) then
                                        local coords = GetEntityCoords(data.prop)
                                        AddExplosion(coords.x, coords.y, coords.z, 2, 0.0, false, true, 0.0)
                                        DeleteEntity(data.prop)
                                        data.prop = nil
                                    end

                                    TriggerServerEvent('cougar:died', netId, data.type)
                                    if data.entity and DoesEntityExist(data.entity) then
                                        DeleteEntity(data.entity)
                                    end
                                    localCougars[netId] = nil
                                end
                            end
                            
                            -- BEEPER
                            if data.type == 'beeper' and not data.hasExploded then
                                print('^1>>> BEEPER EXPLODING <<<^7')
                                
                                local coords = GetEntityCoords(data.entity)
                                
                                AddExplosion(coords.x, coords.y, coords.z, 2, 200.0, true, false, 10.0)
                                
                                SetPedToRagdoll(playerPed, 2000, 2000, 0, false, false, false)
                                
                                Wait(50)
                                
                                local vel = GetEntityVelocity(playerPed)
                                SetEntityVelocity(playerPed, vel.x, vel.y, vel.z + 20.0)
                                
                                TriggerServerEvent('cougar:beeperExplode', netId)
                                if data.prop and DoesEntityExist(data.prop) then
                                    DetachEntity(data.prop, true, true)
                                    data.prop = nil
                                end
                                if DoesEntityExist(data.entity) then
                                    DeleteEntity(data.entity)
                                end
                                data.hasExploded = true
                                localCougars[netId] = nil
                            end
                        end
                    end
                end
            end
        end
    end
end)

print('^2[Effects] Collision-based effects loaded^7')
RegisterNetEvent('cougar:gameOver')
AddEventHandler('cougar:gameOver', function(reason)
    NetworkEndSpectatorMode()
    FreezeEntityPosition(PlayerPedId(), false)
end)
