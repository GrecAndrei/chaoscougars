function FX_PlayerPlus2stars(alive)
    local player = PlayerId()
    local wantedLevel = GetPlayerWantedLevel(player)
    SetPlayerWantedLevel(player, wantedLevel + 2, false)
    SetPlayerWantedLevelNow(player, false)
end
