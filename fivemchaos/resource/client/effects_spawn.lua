-- sync_mode: SPAWN_SINGLE — server picks ONE executor, these only run on that client

function FX_SpawnKillerClowns()
    local pos = GetEntityCoords(PlayerPedId())
    local hash = `s_m_y_clown_01`
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(10) end
    for i = 1, 4 do
        local x = pos.x + math.random(-15, 15)
        local y = pos.y + math.random(-15, 15)
        local p = CreatePed(4, hash, x, y, pos.z, math.random(0, 360) + 0.0, true, true)
        GiveWeaponToPed(p, `WEAPON_MACHETE`, 1, false, true)
        local target = GetNearestPlayerPed(GetEntityCoords(p)) or PlayerPedId()
        TaskCombatPed(p, target, 0, 16)
        SetPedFleeAttributes(p, 0, false)
        SetBlockingOfNonTemporaryEvents(p, true)
        RetargetSpawnedPed(p, 5000)
    end
    SetModelAsNoLongerNeeded(hash)
    TriggerServerEvent('cc:spawn_load_inc')
end

function FX_SpawnJuggernaut()
    local pos = GetEntityCoords(PlayerPedId())
    local hash = `u_m_y_juggernaut_01`
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(10) end
    local p = CreatePed(4, hash, pos.x + 10, pos.y + 10, pos.z, 0.0, true, true)
    SetEntityHealth(p, 2000)
    SetPedArmour(p, 500)
    GiveWeaponToPed(p, `WEAPON_MINIGUN`, 9999, false, true)
    local target = GetNearestPlayerPed(GetEntityCoords(p)) or PlayerPedId()
    TaskCombatPed(p, target, 0, 16)
    SetPedFleeAttributes(p, 0, false)
    SetBlockingOfNonTemporaryEvents(p, true)
    SetModelAsNoLongerNeeded(hash)
    RetargetSpawnedPed(p, 4000)
    TriggerServerEvent('cc:spawn_load_inc')
end

function FX_SpawnAngryJesus()
    local pos = GetEntityCoords(PlayerPedId())
    local hash = `u_m_y_jesus01`
    RequestModel(hash)
    while not HasModelLoaded(hash) do Citizen.Wait(10) end
    local p = CreatePed(4, hash, pos.x + 8, pos.y, pos.z, 0.0, true, true)
    SetEntityHealth(p, 500)
    GiveWeaponToPed(p, `WEAPON_RAILGUN`, 50, false, true)
    local target = GetNearestPlayerPed(GetEntityCoords(p)) or PlayerPedId()
    TaskCombatPed(p, target, 0, 16)
    SetPedFleeAttributes(p, 0, false)
    SetBlockingOfNonTemporaryEvents(p, true)
    SetPedAccuracy(p, 70)
    SetModelAsNoLongerNeeded(hash)
    RetargetSpawnedPed(p, 4000)
    TriggerServerEvent('cc:spawn_load_inc')
end

-- Retarget loop for spawned hostile peds
function RetargetSpawnedPed(ped, intervalMs)
    intervalMs = intervalMs or 5000
    Citizen.CreateThread(function()
        while DoesEntityExist(ped) and not IsEntityDead(ped) do
            if OwnershipGuard.IsOwner(ped) then
                local nearest = GetNearestPlayerPed(GetEntityCoords(ped))
                if nearest and nearest ~= 0 then
                    TaskCombatPed(ped, nearest, 0, 16)
                end
            end
            Citizen.Wait(intervalMs)
        end
        TriggerServerEvent('cc:spawn_load_dec')
    end)
end

-- === NEW: SPAWN SINGLE ===

function FX_SpawnAlien()
    local pos = GetEntityCoords(PlayerPedId())
    local hash = `s_m_m_movalien_01`
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do Citizen.Wait(10); timeout = timeout + 1 end
    if not HasModelLoaded(hash) then return end

    local p = CreatePed(4, hash, pos.x + 8, pos.y, pos.z, 0.0, true, true)
    if p ~= 0 then
        SetEntityHealth(p, 1000)
        SetPedArmour(p, 500)
        GiveWeaponToPed(p, `WEAPON_RAILGUN`, 30, false, true)
        local target = GetNearestPlayerPed(GetEntityCoords(p)) or PlayerPedId()
        TaskCombatPed(p, target, 0, 16)
        SetPedFleeAttributes(p, 0, false)
        SetBlockingOfNonTemporaryEvents(p, true)
        SetPedAccuracy(p, 80)
        RetargetSpawnedPed(p, 4000)
    end
    SetModelAsNoLongerNeeded(hash)
    TriggerServerEvent('cc:spawn_load_inc')
end

function FX_SpawnBigfoot()
    local pos = GetEntityCoords(PlayerPedId())
    local hash = `a_c_bear`
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do Citizen.Wait(10); timeout = timeout + 1 end
    if not HasModelLoaded(hash) then return end

    local p = CreatePed(28, hash, pos.x + 5, pos.y, pos.z, 0.0, true, true)
    if p ~= 0 then
        SetEntityHealth(p, 800)
        SetPedArmour(p, 300)
        GiveWeaponToPed(p, `WEAPON_KNIFE`, 1, false, true)
        local target = GetNearestPlayerPed(GetEntityCoords(p)) or PlayerPedId()
        TaskCombatPed(p, target, 0, 16)
        SetPedFleeAttributes(p, 0, false)
        SetBlockingOfNonTemporaryEvents(p, true)
        RetargetSpawnedPed(p, 4000)
    end
    SetModelAsNoLongerNeeded(hash)
    TriggerServerEvent('cc:spawn_load_inc')
end

function FX_SpawnZombieHorde()
    local pos = GetEntityCoords(PlayerPedId())
    local hash = `u_m_y_zombie_01`
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do Citizen.Wait(10); timeout = timeout + 1 end
    if not HasModelLoaded(hash) then return end

    for i = 1, 8 do
        local x = pos.x + math.random(-20, 20)
        local y = pos.y + math.random(-20, 20)
        local p = CreatePed(4, hash, x, y, pos.z, math.random(0, 360) + 0.0, true, true)
        if p ~= 0 then
            GiveWeaponToPed(p, `WEAPON_BAT`, 1, false, true)
            local target = GetNearestPlayerPed(GetEntityCoords(p)) or PlayerPedId()
            TaskCombatPed(p, target, 0, 16)
            SetPedFleeAttributes(p, 0, false)
            SetBlockingOfNonTemporaryEvents(p, true)
            RetargetSpawnedPed(p, 5000)
        end
    end
    SetModelAsNoLongerNeeded(hash)
    TriggerServerEvent('cc:spawn_load_inc')
end
