function FX_PlayerHacking(alive)
    local scaleform = RequestScaleformMovieInteractive("Hacking_PC")
    while not HasScaleformMovieLoaded(scaleform) do Citizen.Wait(0) end
    BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND")
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(scaleform, "SET_ROULETTE_WORD")
    PushScaleformMovieMethodParameterString("CHAOS")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(scaleform, "RUN_PROGRAM")
    ScaleformMovieMethodAddParamInt(1)
    EndScaleformMovieMethod()
    SetPlayerControl(PlayerId(), false, 0)
    local hackingState = true
    while alive() and hackingState do
        Citizen.Wait(0)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
        if IsControlJustPressed(2, 201) then
            BeginScaleformMovieMethod(scaleform, "SET_INPUT_EVENT_SELECT")
            local selectReturn = EndScaleformMovieMethodReturnValue()
            Citizen.Wait(50)
            if selectReturn > 0 and IsScaleformMovieMethodReturnValueReady(selectReturn) then
                local result = GetScaleformMovieMethodReturnValueInt(selectReturn)
                if result == 1 then
                    hackingState = false
                end
            end
        end
    end
    SetScaleformMovieAsNoLongerNeeded(scaleform)
    SetPlayerControl(PlayerId(), true, 0)
end
