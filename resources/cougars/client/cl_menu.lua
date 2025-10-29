local menuOpen = false

Citizen.CreateThread(function()
    while true do
        Wait(0)
        
        if IsControlJustPressed(0, 167) then -- F6
            menuOpen = not menuOpen
            
            if menuOpen then
                -- OPEN
                SetNuiFocus(true, true)
                SetNuiFocusKeepInput(true) -- Keep input for NUI
                SendNUIMessage({action = 'toggle', show = true})
                print('^2[Menu] OPENED^7')
            else
                -- CLOSE
                SetNuiFocus(false, false) -- BOTH must be false
                SetNuiFocusKeepInput(false) -- Release input
                SendNUIMessage({action = 'toggle', show = false})
                print('^2[Menu] CLOSED^7')
            end
        end
        
        -- ESC to close when open
        if menuOpen and IsControlJustPressed(0, 322) then -- ESC
            menuOpen = false
            SetNuiFocus(false, false) -- BOTH false
            SetNuiFocusKeepInput(false) -- Release input
            SendNUIMessage({action = 'toggle', show = false})
            print('^2[Menu] ESC close^7')
        end
    end
end)

-- NUI Callbacks
RegisterNUICallback('start', function(data, cb)
    print('^2[Menu] START^7')
    TriggerServerEvent('cougar:menuAction', 'start')
    cb('ok')
end)

RegisterNUICallback('stop', function(data, cb)
    print('^2[Menu] STOP^7')
    TriggerServerEvent('cougar:menuAction', 'stop')
    cb('ok')
end)

RegisterNUICallback('spawn', function(data, cb)
    print('^2[Menu] SPAWN^7')
    TriggerServerEvent('cougar:menuAction', 'spawn')
    cb('ok')
end)

RegisterNUICallback('chaos', function(data, cb)
    print('^2[Menu] CHAOS^7')
    TriggerServerEvent('cougar:menuAction', 'chaos')
    cb('ok')
end)

-- Force close on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SetNuiFocus(false, false)
    end
end)

-- Add this new callback
RegisterNUICallback('spawnType', function(data, cb)
    print('^2[Menu] Spawn type: ' .. data.type .. '^7')
    TriggerServerEvent('cougar:spawnSpecificType', data.type)
    cb('ok')
end)

RegisterNUICallback('cropduster', function(data, cb)
    print('^2[Menu] CROPDUSTER^7')
    TriggerServerEvent('cougar:menuAction', 'cropduster')
    cb('ok')
end)

print('^2[Menu] Loaded - F6 or ESC^7')

RegisterNUICallback('spawnCar', function(data, cb)
    print('^2[Menu] SPAWN CAR^7')
    TriggerEvent('cougar:spawnDebugCar')
    cb('ok')
end)

RegisterNUICallback('heal', function(data, cb)
    print('^2[Menu] HEAL^7')
    local playerPed = PlayerPedId()
    SetEntityHealth(playerPed, 200)
    SetPedArmour(playerPed, 100)
    cb('ok')
end)

RegisterNUICallback('clearCougars', function(data, cb)
    print('^2[Menu] CLEAR COUGARS^7')
    for netId, data in pairs(localCougars) do
        if DoesEntityExist(data.entity) then
            DeleteEntity(data.entity)
        end
        if data.attachedObj and DoesEntityExist(data.attachedObj) then
            DeleteEntity(data.attachedObj)
        end
    end
    localCougars = {}
    cb('ok')
end)