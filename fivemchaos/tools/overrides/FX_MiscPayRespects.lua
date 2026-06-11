function FX_MiscPayRespects(alive)
    while alive() do
        TaskPlayAnim(PlayerPedId(), "mp_player_int_upperfinger", "mp_player_int_finger_01", 8.0, -1.0, -1, 49, 0.0, false, false, false)
        Citizen.Wait(5000)
    end
end
