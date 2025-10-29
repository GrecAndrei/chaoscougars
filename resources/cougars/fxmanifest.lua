fx_version 'cerulean'
game 'gta5'
this_is_a_map 'yes'

author 'Your Name'
description 'Cooperative Cougar Journey Mode with Chaos Mod Integration'
version '1.0.0'

-- Config
shared_script 'config.lua'

-- Server
server_scripts {
    'server/sv_main.lua',
    'server/sv_journey.lua',
    'server/sv_cougars.lua',
    'server/sv_chaos.lua',
    'server/sv_stats.lua',           -- ADD
    'server/sv_achievements.lua'     -- ADD
}

-- Client
client_scripts {
    'client/cl_cougars.lua',
    'client/cl_journey.lua',
    'client/cl_main.lua',
    'client/cl_hud.lua',
    'client/cl_chaos.lua',
    'client/cl_menu.lua',
    'client/cl_spawn.lua',
    'client/cl_stats.lua'            -- ADD
}

-- NUI
ui_page 'html/menu.html'

files {
    'html/index.html',
    'html/menu.html'  -- ADD THIS
}