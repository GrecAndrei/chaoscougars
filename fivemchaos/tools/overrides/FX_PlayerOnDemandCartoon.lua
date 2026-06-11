local TV_PLAYLISTS = {
    "PL_WEB_KFLF",
    "PL_WEB_RANGERS",
    "PL_WEB_PRB2",
    "PL_WEB_FOS",
    "PL_WEB_CAS",
    "PL_WEB_HOWITZER",
    "PL_WEB_RS",
    "PL_STD_CNT",
    "PL_STD_WZL",
    "PL_LO_CNT",
    "PL_LO_WZL",
    "PL_SP_WORKOUT",
    "PL_SP_INV",
    "PL_SP_INV_EXP",
    "PL_LO_RS",
    "PL_LO_RS_CUTSCENE",
    "PL_SP_PLSH1_INTRO",
    "PL_LES1_FAME_OR_SHAME",
    "PL_STD_WZL_FOS_EP2",
    "PL_MP_WEAZEL",
    "PL_MP_CCTV",
    "PL_CINEMA_CARTOON",
    "PL_CINEMA_ARTHOUSE",
    "PL_CINEMA_ACTION",
    "PL_CINEMA_MULTIPLAYER",
    "PL_CINEMA_MULTIPLAYER_NO_MELTDOWN"
}
local ms_PosX = 0.0
local ms_PosY = 0.0

function FX_PlayerOnDemandCartoon(alive)
    local playlist = TV_PLAYLISTS[math.random(1, #TV_PLAYLISTS)]
    SetTvChannelPlaylistAtHour(0, playlist, math.random(0, 23))
    SetTvAudioFrontend(true)
    SetTvVolume(1.0)
    AttachTvAudioToEntity(PlayerPedId())
    SetTvChannel(0)
    EnableMovieSubtitles(true)
    ms_PosX = (math.random() * 0.4) + 0.3
    ms_PosY = (math.random() * 0.4) + 0.3

    while alive() do
        SetScriptGfxDrawOrder(4)
        SetScriptGfxDrawBehindPausemenu(true)
        DrawTvChannel(ms_PosX, ms_PosY, 0.3, 0.3, 0.0, 255, 255, 255, 255)
        Citizen.Wait(0)
    end

    SetTvChannel(-1)
    SetTvChannelPlaylist(0, "", false)
    EnableMovieSubtitles(false)
end
