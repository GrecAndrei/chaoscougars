function FX_VehSpeedGoal(alive)
    local ms_Overlay = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
    while not HasScaleformMovieLoaded(ms_Overlay) do Citizen.Wait(0) end
    local ms_EnteredVehicle = false
    local ms_LastVeh = 0
    local ms_TimeReserve = 10000
    local ms_LastTick = 0
    while alive() do
        local playerPed = PlayerPedId()
        local veh = GetVehiclePedIsIn(playerPed, false)
        if ms_LastVeh ~= 0 and (veh ~= ms_LastVeh or not IsPedInAnyVehicle(playerPed, false)) then
            ExplodeVehicle(ms_LastVeh, true, false)
            ms_TimeReserve = 10000
        end
        ms_LastVeh = veh
        local currentTick = GetGameTimer()
        if currentTick - ms_LastTick > 100 then
            ms_LastTick = currentTick
            local speed = GetEntitySpeed(veh)
            if speed > 20.0 and ms_TimeReserve > 0 then
                ms_TimeReserve = ms_TimeReserve - 100
            end
            if ms_TimeReserve <= 0 and veh ~= 0 then
                ExplodeVehicle(veh, true, false)
            end
        end
        Citizen.Wait(0)
    end
    SetScaleformMovieAsNoLongerNeeded(ms_Overlay)
end
