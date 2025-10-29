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
                                if not data.lastEffect or currentTime > data.lastEffect + 2000 then
                                    print('^3>>> BLUE BALL LAUNCHING <<<^7')
                                    
                                    -- Ragdoll first
                                    SetPedToRagdoll(playerPed, 1500, 1500, 0, false, false, false)
                                    
                                    Wait(100)
                                    
                                    -- CRITICAL: Apply velocity directly
                                    local vel = GetEntityVelocity(playerPed)
                                    SetEntityVelocity(playerPed, vel.x, vel.y, vel.z + 15.0)
                                    
                                    PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true)
                                    
                                    data.lastEffect = currentTime
                                end
                            end
                            
                            -- PURPLE BALL
                            if data.type == 'purpleBall' then
                                if not data.lastEffect or currentTime > data.lastEffect + 3000 then
                                    print('^5>>> PURPLE BALL MEGA LAUNCHING <<<^7')
                                    
                                    SetPedToRagdoll(playerPed, 3000, 3000, 0, false, false, false)
                                    
                                    Wait(100)
                                    
                                    local vel = GetEntityVelocity(playerPed)
                                    SetEntityVelocity(playerPed, vel.x, vel.y, vel.z + 35.0)
                                    
                                    StartScreenEffect("RaceTurbo", 2000, false)
                                    PlaySoundFrontend(-1, "FLIGHT_TURBULENCE_MASTER", "HUD_AWARDS", true)
                                    
                                    data.lastEffect = currentTime
                                end
                            end
                            
                            -- BARRIER
                            if data.type == 'barrier' then
                                if not data.lastEffect or currentTime > data.lastEffect + 1500 then
                                    print('^6>>> BARRIER REVERSING <<<^7')
                                    
                                    local vel = GetEntityVelocity(playerPed)
                                    
                                    SetPedToRagdoll(playerPed, 1000, 1000, 0, false, false, false)
                                    
                                    Wait(50)
                                    
                                    -- Reverse velocity
                                    SetEntityVelocity(playerPed, -vel.x * 2.5, -vel.y * 2.5, 5.0)
                                    
                                    PlaySoundFrontend(-1, "CHECKPOINT_UNDER_THE_BRIDGE", "HUD_MINI_GAME_SOUNDSET", true)
                                    
                                    data.lastEffect = currentTime
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
                                
                                DeleteEntity(data.entity)
                                if data.attachedObj and DoesEntityExist(data.attachedObj) then
                                    DeleteEntity(data.attachedObj)
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