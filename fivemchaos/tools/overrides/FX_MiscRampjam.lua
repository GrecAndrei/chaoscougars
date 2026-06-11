function FX_MiscRampjam(alive)
    while alive() do
        local playerPed = PlayerPedId()
        if not IsPedInAnyVehicle(playerPed, false) then
            local pos = GetEntityCoords(playerPed, false)
            local heading = GetEntityHeading(playerPed)
            local rampHash = GetHashKey("prop_mp_ramp_03")
            RequestModel(rampHash)
            while not HasModelLoaded(rampHash) do Citizen.Wait(0) end
            local ramp = CreateObject(rampHash, pos.x, pos.y + 3.0, pos.z, true, true, true)
            SetModelAsNoLongerNeeded(rampHash)
            SetEntityHeading(ramp, heading)
            FreezeEntityPosition(ramp, true)
            SetObjectAsNoLongerNeeded(ramp)
        end
        Citizen.Wait(500)
    end
end
