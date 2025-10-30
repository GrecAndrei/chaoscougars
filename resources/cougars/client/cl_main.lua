
journeyActive = false

local lastDeathState = false
local defaultMeleeDefense = 1.0
local journeyDefenseModifier = 0.3
local invulnDurationMs = 4000
local journeyRunMultiplier = 1.1
local animalWeaponHash = GetHashKey('WEAPON_ANIMAL')
local animalDamageScale = 0.3
local defaultAnimalDamageScale = 1.0

local lastRecordedHealth = nil
local debugState = Config.DebugDefaults or {enabled = false, godMode = false, infiniteDeaths = false}

local function applyJourneyLoadout()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    SetPedMaxHealth(ped, 200)
    SetEntityHealth(ped, 200)
    SetPedArmour(ped, 100)
    RestorePlayerStamina(PlayerId(), 1.0)
    SetRunSprintMultiplierForPlayer(PlayerId(), journeyRunMultiplier)
    SetSwimMultiplierForPlayer(PlayerId(), journeyRunMultiplier)

    local weapon = GetHashKey('WEAPON_APPISTOL')
    GiveWeaponToPed(ped, weapon, 40, false, true)
    SetCurrentPedWeapon(ped, weapon, true)
    lastRecordedHealth = GetEntityHealth(ped)
end

RegisterNetEvent('cougar:journeyStarted')
AddEventHandler('cougar:journeyStarted', function()
    journeyActive = true
    TriggerEvent('cougar:startMission')

    local playerId = PlayerId()
    SetPlayerMeleeWeaponDefenseModifier(playerId, journeyDefenseModifier)
    if animalWeaponHash ~= 0 then
        SetWeaponDamageModifier(animalWeaponHash, animalDamageScale)
    end

    local ped = PlayerPedId()
    if DoesEntityExist(ped) then
        applyJourneyLoadout()
        SetEntityInvincible(ped, true)
        if not (debugState.enabled and debugState.godMode) then
            Citizen.SetTimeout(invulnDurationMs, function()
                if journeyActive and not (debugState.enabled and debugState.godMode) then
                    SetEntityInvincible(ped, false)
                end
            end)
        end
    end
    lastRecordedHealth = GetEntityHealth(PlayerPedId())
end)

RegisterNetEvent('cougar:journeyStopped')
AddEventHandler('cougar:journeyStopped', function()
    journeyActive = false
    TriggerEvent('cougar:stopMission')
    lastDeathState = false
    local ped = PlayerPedId()
    if DoesEntityExist(ped) and not (debugState.enabled and debugState.godMode) then
        SetEntityInvincible(ped, false)
    end

    local playerId = PlayerId()
    SetPlayerMeleeWeaponDefenseModifier(playerId, defaultMeleeDefense)
    SetRunSprintMultiplierForPlayer(playerId, 1.0)
    SetSwimMultiplierForPlayer(playerId, 1.0)
    if animalWeaponHash ~= 0 then
        SetWeaponDamageModifier(animalWeaponHash, defaultAnimalDamageScale)
    end
    lastRecordedHealth = nil
end)

RegisterNetEvent('cougar:setPlayerSkills')
AddEventHandler('cougar:setPlayerSkills', function()
    applyJourneyLoadout()
end)

RegisterNetEvent('cougar:debugState')
AddEventHandler('cougar:debugState', function(state)
    debugState = state or debugState
    local ped = PlayerPedId()
    if DoesEntityExist(ped) then
        lastRecordedHealth = GetEntityHealth(ped)
    end
    if journeyActive then
        if debugState.enabled and debugState.godMode then
            SetEntityInvincible(ped, true)
        elseif not IsEntityDead(ped) then
            SetEntityInvincible(ped, false)
        end
    else
        if not (debugState.enabled and debugState.godMode) then
            SetEntityInvincible(ped, false)
        end
    end
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        local playerId = PlayerId()
        SetPlayerMeleeWeaponDefenseModifier(playerId, defaultMeleeDefense)
        SetRunSprintMultiplierForPlayer(playerId, 1.0)
        SetSwimMultiplierForPlayer(playerId, 1.0)
        if animalWeaponHash ~= 0 then
            SetWeaponDamageModifier(animalWeaponHash, defaultAnimalDamageScale)
        end
        local ped = PlayerPedId()
        if DoesEntityExist(ped) then
            if not (debugState.enabled and debugState.godMode) then
                SetEntityInvincible(ped, false)
            end
        end
    end
end)

Citizen.CreateThread(function()
    local updateInterval = Config and Config.PositionUpdateRate or 200

    while true do
        Wait(updateInterval)

        if journeyActive then
            local ped = PlayerPedId()

            if DoesEntityExist(ped) then
                local coords = GetEntityCoords(ped)
                TriggerServerEvent('cougar:updatePosition', {x = coords.x, y = coords.y, z = coords.z})

                local isDead = IsEntityDead(ped)
                local health = math.floor(GetEntityHealth(ped))

                if lastRecordedHealth and health < lastRecordedHealth then
                    local delta = lastRecordedHealth - health
                    if delta > 0 then
                        local retention = animalDamageScale
                        local targetHealth = math.floor(lastRecordedHealth - delta * retention)
                        if targetHealth < 1 then targetHealth = 1 end

                        if isDead then
                            local coords = GetEntityCoords(ped)
                            local heading = GetEntityHeading(ped)
                            NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z + 0.5, heading, true, false)
                            SetEntityHealth(ped, targetHealth)
                            ClearPedTasksImmediately(ped)
                            ClearPedSecondaryTask(ped)
                            SetEntityInvincible(ped, debugState.enabled and debugState.godMode or false)
                            isDead = false
                        else
                            SetEntityHealth(ped, targetHealth)
                        end
                        health = targetHealth
                    end
                end

                lastRecordedHealth = health

                TriggerServerEvent('cougar:updatePlayerStatus', health, isDead)

                if isDead and not lastDeathState then
                    TriggerServerEvent('cougar:playerDied')
                end

                lastDeathState = isDead
            end
        end
    end
end)

RegisterCommand('startjourney', function()
    TriggerEvent('cougar:startMission')
    print("^2[JOURNEY] Mission started - Continuous spawning enabled")
end)

RegisterCommand('stopjourney', function()
    TriggerEvent('cougar:stopMission')
    print("^1[JOURNEY] Mission stopped - All cougars cleaned up")
end)
