fx_version 'cerulean'
game 'gta5'

author 'ChaosCougar'
description 'Chaos Run: LSIA to Paleto Bay — heat-paced chaos, cougar director, squad voting, 4-player co-op'
version '0.5.0'

shared_scripts {
    'shared/enums.lua',
    'shared/config.lua',
    'shared/effects_registry.lua',
    'shared/effects_generated_registry.lua',
    'shared/effects_tuning.lua',
}

server_scripts {
    'server/state.lua',
    'server/security.lua',
    'server/late_join.lua',
    'server/heat.lua',
    'server/director.lua',
    'server/chaos.lua',
    'server/effect_vote.lua',
    'server/lobby.lua',
    'server/admin.lua',
    'server/voting.lua',
    'server/records.lua',
    'server/exports_api.lua',
}

server_exports {
    'GetState',
    'GetActiveEffects',
    'GetDirectorSnapshot',
    'GetEffectById',
    'DispatchEffectById',
}

client_scripts {
    'client/ownership.lua',
    'client/effects_runner.lua',
    'client/sync.lua',
    'client/vote.lua',
    'client/spawner.lua',
    'client/panel.lua',
    'client/effects_local.lua',
    'client/effects_global.lua',
    'client/effects_visual.lua',
    'client/effects_spawn.lua',
    'client/effects_meta.lua',
    'client/effects_generated.lua',
    'client/hud.lua',
}

client_event 'cc:trigger_effect'
client_event 'cc:late_join_sync'
client_event 'cc:clear_effects'
client_event 'cc:spawn_cougar'
client_event 'cc:despawn_cougar'
client_event 'cc:despawn_all_cougars'
client_event 'cc:cougar_count'
client_event 'cc:vote_end'
client_event 'cc:state'
client_event 'cc:mission_start'
client_event 'cc:mission_end'
client_event 'cc:chaos_tick'
client_event 'cc:vote_update'
client_event 'cc:player_died'
client_event 'cc:player_downed'
client_event 'cc:player_revived'
client_event 'cc:revived'
client_event 'cc:pack_surge'
client_event 'cc:difficulty'
client_event 'cc:meta_ui'
client_event 'cc:act'
client_event 'cc:bleedout'
client_event 'cc:ready_count'
client_event 'cc:effect_vote'
client_event 'cc:effect_vote_update'
client_event 'cc:records'
client_event 'cc:new_record'

server_event 'cc:join'
server_event 'cc:pos'
server_event 'cc:died'
server_event 'cc:reached_finish'
server_event 'cc:respawned'
server_event 'cc:revive'
server_event 'cc:vote_pause'
server_event 'cc:cougar_spawned'
server_event 'cc:cougar_dead'
server_event 'cc:cougar_pos'
server_event 'cc:spawn_load_inc'
server_event 'cc:spawn_load_dec'
server_event 'cc:meta_set'
server_event 'cc:meta_set_internal'
server_event 'cc:admin_start'
server_event 'cc:admin_stop'
server_event 'cc:admin_pause'
server_event 'cc:admin_effect'
server_event 'cc:admin_spawn_cougar'
server_event 'cc:admin_kill_cougars'
server_event 'cc:ready'
server_event 'cc:effect_vote_cast'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/app.js',
}
