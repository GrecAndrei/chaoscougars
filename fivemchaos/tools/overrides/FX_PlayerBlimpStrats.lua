function FX_PlayerBlimpStrats(alive)
    -- Hooks::EnableScriptThreadBlock
    local blimpHash = GetHashKey("blimp")

    RequestModel(blimpHash)
    while not HasModelLoaded(blimpHash) do
        Citizen.Wait(0)
    end

    local playerPed = PlayerPedId()
    SetEntityInvincible(playerPed, true)

    local veh = CreateVehicle(blimpHash, -370.49, 1029.085, 345.09, 53.824, true, false)
    SetVehicleEngineOn(veh, true, true, false)
    SetPedIntoVehicle(playerPed, veh, -1)
    SetVehicleForwardSpeed(veh, 45.0)
    TaskLeaveVehicle(playerPed, veh, 4160)
    SetModelAsNoLongerNeeded(blimpHash)

    local waited = 0
    while not IsPedGettingUp(playerPed) and waited < 100 do
        Citizen.Wait(100)
        waited = waited + 1
    end
    SetEntityInvincible(playerPed, false)

    RequestCutscene("fbi_1_int", 8)
    while not HasCutsceneLoaded() do
        Citizen.Wait(0)
    end
    RegisterEntityForCutscene(playerPed, "MICHAEL", 0, 0, 64)
    StartCutscene(0)
    Citizen.Wait(6500)
    StopCutsceneImmediately()
    RemoveCutscene()

    local daveHash = GetHashKey("ig_davenorton")
    RequestModel(daveHash)
    while not HasModelLoaded(daveHash) do
        Citizen.Wait(0)
    end
    local pedDave = CreatePed(4, daveHash, -442.2, 1059.25, 326.66, 180.6, true, false)
    SetModelAsNoLongerNeeded(daveHash)
    TaskPlayAnim(pedDave, "missfbi1leadinout", "fbi_1_int_leadin_loop_daven", 8.0, 1.0, -1, 1, 0.0, false, false, false)
    SetPedKeepTask(pedDave, true)
    SetPedAsNoLongerNeeded(pedDave)
    SetVehicleAsNoLongerNeeded(veh)

    -- Hooks::DisableScriptThreadBlock
end
