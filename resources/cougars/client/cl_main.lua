
journeyActive = false

local lastDeathState = false
local defaultMeleeDefense = 1.0
local journeyDefenseModifier = 0.3
local invulnDurationMs = 4000
local journeyRunMultiplier = 1.1

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
    GiveWeaponToPed(ped, weapon, 500, false, true)
    SetCurrentPedWeapon(ped, weapon, true)
    SetPedInfiniteAmmo(ped, true, weapon)
end

RegisterNetEvent('cougar:journeyStarted')
AddEventHandler('cougar:journeyStarted', function()
    journeyActive = true
    TriggerEvent('cougar:startMission')

    local playerId = PlayerId()
    SetPlayerMeleeWeaponDefenseModifier(playerId, journeyDefenseModifier)

    local ped = PlayerPedId()
    if DoesEntityExist(ped) then
        applyJourneyLoadout()
        SetEntityInvincible(ped, true)
        Citizen.SetTimeout(invulnDurationMs, function()
            if journeyActive then
                SetEntityInvincible(ped, false)
            end
        end)
    end
end)

RegisterNetEvent('cougar:journeyStopped')
AddEventHandler('cougar:journeyStopped', function()
    journeyActive = false
    TriggerEvent('cougar:stopMission')
    lastDeathState = false
    local ped = PlayerPedId()
    if DoesEntityExist(ped) then
        SetEntityInvincible(ped, false)
    end

    local playerId = PlayerId()
    SetPlayerMeleeWeaponDefenseModifier(playerId, defaultMeleeDefense)
    SetRunSprintMultiplierForPlayer(playerId, 1.0)
    SetSwimMultiplierForPlayer(playerId, 1.0)
end)

RegisterNetEvent('cougar:setPlayerSkills')
AddEventHandler('cougar:setPlayerSkills', function()
    applyJourneyLoadout()
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        local playerId = PlayerId()
        SetPlayerMeleeWeaponDefenseModifier(playerId, defaultMeleeDefense)
        SetRunSprintMultiplierForPlayer(playerId, 1.0)
        SetSwimMultiplierForPlayer(playerId, 1.0)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) then
            SetEntityInvincible(ped, false)
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
