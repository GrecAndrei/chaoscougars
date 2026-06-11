function FX_MiscSuperstunt(alive)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed, false)
    local rampPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)

    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    if not IsPedInVehicle(playerPed, playerVeh, true) then
        local vehModel = GetHashKey("adder")
        RequestModel(vehModel)
        while not HasModelLoaded(vehModel) do
            Citizen.Wait(0)
        end
        playerVeh = CreateVehicle(vehModel, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(playerPed), true, true)
        SetModelAsNoLongerNeeded(vehModel)
        SetPedIntoVehicle(playerPed, playerVeh, -1)
    end

    local rampModel = GetHashKey("prop_mp_ramp_03")
    RequestModel(rampModel)
    while not HasModelLoaded(rampModel) do
        Citizen.Wait(0)
    end

    local ramp = CreateObject(rampModel, rampPos.x, rampPos.y, rampPos.z, true, false, false)
    SetModelAsNoLongerNeeded(rampModel)
    PlaceObjectOnGroundProperly(ramp)

    rampPos = GetEntityCoords(ramp, false)
    SetEntityCoords(ramp, rampPos.x, rampPos.y, rampPos.z - 0.3, true, true, true, false)
    SetEntityRotation(ramp, GetEntityPitch(playerVeh), -GetEntityRoll(playerVeh), GetEntityHeading(playerVeh), 0, true)

    local forward = GetEntityForwardVector(playerVeh)
    SetEntityVelocity(playerVeh, forward.x * 7000.0, forward.y * 7000.0, forward.z * 7000.0)

    SetEntityInvincible(playerPed, true)
    SetEntityInvincible(playerVeh, true)
    Citizen.Wait(500)
    SetEntityInvincible(playerPed, false)
    SetEntityInvincible(playerVeh, false)
end
