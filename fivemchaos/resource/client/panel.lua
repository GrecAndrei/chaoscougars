local panelOpen = false

local function TogglePanel()
    panelOpen = not panelOpen
    SetNuiFocus(panelOpen, panelOpen)
    SendNUIMessage({type = 'panel_toggle', open = panelOpen})
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 166) then -- F5
            TogglePanel()
        end
    end
end)

RegisterNUICallback('panel_toggle', function(data, cb)
    panelOpen = data.open and true or false
    SetNuiFocus(panelOpen, panelOpen)
    cb({})
end)

RegisterNUICallback('panel_action', function(data, cb)
    local action = data.action
    if action == 'start' then
        TriggerServerEvent('cc:admin_start')
    elseif action == 'stop' then
        TriggerServerEvent('cc:admin_stop')
    elseif action == 'pause' then
        TriggerServerEvent('cc:admin_pause', true)
    elseif action == 'resume' then
        TriggerServerEvent('cc:admin_pause', false)
    elseif action == 'spawn_cougar' then
        local pos = GetEntityCoords(PlayerPedId())
        local ahead = GetEntityForwardVector(PlayerPedId())
        TriggerServerEvent('cc:admin_spawn_cougar', 'fence', pos + ahead * 30.0)
    elseif action == 'spawn_swarm' then
        local pos = GetEntityCoords(PlayerPedId())
        local ahead = GetEntityForwardVector(PlayerPedId())
        TriggerServerEvent('cc:admin_spawn_cougar', 'swarm', pos + ahead * 30.0)
    elseif action == 'spawn_bomber' then
        local pos = GetEntityCoords(PlayerPedId())
        local ahead = GetEntityForwardVector(PlayerPedId())
        TriggerServerEvent('cc:admin_spawn_cougar', 'bomber', pos + ahead * 30.0)
    elseif action == 'kill_cougars' then
        TriggerServerEvent('cc:admin_kill_cougars')
    end
    cb({})
end)

RegisterNUICallback('panel_effect', function(data, cb)
    if data.id then
        TriggerServerEvent('cc:admin_effect', data.id)
    end
    cb({})
end)

RegisterNUICallback('ready', function(_, cb)
    cb({})
end)
