-- Chaos Effect Integration - Client Side

-- Send port to NUI on load
Citizen.CreateThread(function()
    Wait(2000) -- Wait for NUI to load
    
    -- Configure NUI with client port
    SendNUIMessage({
        action = 'setPort',
        port = Config.ChaosPort
    })
    
    -- Enable debug if configured
    if Config.ChaosDebug then
        SendNUIMessage({
            action = 'setDebug',
            enabled = true
        })
    end
    
    print('^2[Chaos] NUI configured with port ' .. Config.ChaosPort .. '^7')
    
    -- Register chaos port with server
    TriggerServerEvent('cougar:registerChaosPort', Config.ChaosPort)
end)

-- NUI Response Handler
RegisterNUICallback('chaosResponse', function(data, cb)
    if data.success then
        chaosModActive = true
        if Config.ChaosDebug then
            print('^2[Chaos] Effect triggered: ' .. data.effectId .. '^7')
        end
    else
        print('^1[Chaos] Effect failed: ' .. data.effectId .. ' - ' .. tostring(data.error) .. '^7')
    end
    
    cb('ok')
end)

-- Server tells client to trigger effect
RegisterNetEvent('cougar:triggerChaosEffect')
AddEventHandler('cougar:triggerChaosEffect', function(effectId, duration, timestamp)
    -- Send to NUI for HTTP request
    SendNUIMessage({
        action = 'triggerEffect',
        effectId = effectId,
        duration = duration,
        timestamp = timestamp
    })
    
    -- Display notification
    local effectName = effectId:gsub('_', ' '):gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper()..rest:lower()
    end)
    
    SetNotificationTextEntry('STRING')
    AddTextComponentString('~p~[CHAOS] ' .. effectName)
    DrawNotification(false, true)
end)

-- Connection test command
RegisterCommand('testchaos', function()
    SendNUIMessage({
        action = 'testConnection'
    })
end, false)

-- Toggle debug command
RegisterCommand('chaosdebug', function()
    Config.ChaosDebug = not Config.ChaosDebug
    
    SendNUIMessage({
        action = 'setDebug',
        enabled = Config.ChaosDebug
    })
    
    print('^2[Chaos] Debug mode: ' .. tostring(Config.ChaosDebug) .. '^7')
end, false)

print('^2[Cougar Journey] Chaos integration loaded^7')

local chaosModActive = false
local pendingChaosStatus = false

-- Listen for Ctrl+L toggle (Chaos Mod default toggle key)
Citizen.CreateThread(function()
    while true do
        Wait(0)
        
        -- Ctrl+L pressed
        if IsControlPressed(0, 36) and IsControlJustPressed(0, 182) then  -- Ctrl + L
            print('^3[Chaos] Detected Chaos Mod toggle (Ctrl+L)^7')
            
            -- TODO: Sync toggle state
        end
    end
end)

-- Check Chaos Mod status
function GetChaosModStatus()
    -- Send request to NUI which handles HTTP
    SendNUIMessage({
        action = 'getStatus'
    })
end

-- Toggle Chaos Mod remotely
RegisterCommand('togglechaos', function()
    -- Send toggle request to NUI
    SendNUIMessage({
        action = 'toggleChaos'
    })
end, false)

-- Handle response from NUI about status
RegisterNUICallback('chaosStatusResponse', function(data, cb)
    print('^3Chaos Mod Active: ' .. tostring(data.chaos_mod_active) .. '^7')
    if data.current_effect then
        print('^3Current Effect: ' .. data.current_effect .. '^7')
    end
    if data.time_remaining then
        print('^3Time Remaining: ' .. data.time_remaining .. '^7')
    end
    chaosModActive = data.chaos_mod_active == true
    if pendingChaosStatus then
        TriggerServerEvent('cougar:chaosStatusResponse', chaosModActive)
        pendingChaosStatus = false
    end
    
    cb('ok')
end)

-- Handle response from NUI about toggle
RegisterNUICallback('chaosToggleResponse', function(data, cb)
    if data.success then
        TriggerEvent('chat:addMessage', {args = {data.message}})
    end
    cb('ok')
end)

-- Respond to chaos status requests
RegisterNetEvent('cougar:requestChaosStatus')
AddEventHandler('cougar:requestChaosStatus', function()
    pendingChaosStatus = true
    GetChaosModStatus()
    Citizen.SetTimeout(2500, function()
        if pendingChaosStatus then
            TriggerServerEvent('cougar:chaosStatusResponse', chaosModActive)
            pendingChaosStatus = false
        end
    end)
end)
