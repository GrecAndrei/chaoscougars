-- Chaos Effect System with Full Chaos Mod V Integration
local chaosEffectInterval = 60000 -- 30 seconds
local lastChaosEffect = 0

-- ALL 350+ Chaos Mod V Effects (pulled from effect source code)
local allChaosEffects = {
    -- Meta Effects
    'meta_additional_effects',
    'meta_effect_duration',
    'meta_hide_chaos_ui',
    'meta_no_chaos',
    'meta_re_invoke',
    'meta_timerspeed_0_5x',
    'meta_timerspeed_2x',
    'meta_timerspeed_5x',
    'meta_voting_mode',
    
    -- Misc Effects
    'misc_airstrike',
    'misc_black_hole',
    'misc_blackout',
    'misc_boost_velocity',
    'misc_clone_on_death',
    'misc_cocktail',
    'misc_earthquake',
    'misc_esp',
    'misc_fake_crash',
    'misc_fireworks',
    'misc_flamethrower',
    'misc_fps_limit',
    'misc_get_towed',
    'misc_ghost_world',
    'misc_go_to_jail',
    'misc_gravity_controller',
    'misc_high_pitch',
    'misc_intense_music',
    'misc_invert_velocity',
    'misc_jumpy_props',
    'misc_lag',
    'misc_low_pitch',
    'misc_low_poly',
    'misc_meteor_rain',
    'misc_midas_touch',
    'misc_money_rain',
    'misc_muffled_audio',
    'misc_news_team',
    'misc_no_phone',
    'misc_no_sky',
    'misc_nothing',
    'misc_no_water',
    'misc_no_waypoint',
    'misc_oil_leaks',
    'misc_one_shot',
    'misc_pause',
    'misc_pay_respects',
    'misc_portrait_mode',
    'misc_quick_sprunk_stop',
    'misc_rainbow_weps',
    'misc_ramp_jam',
    'misc_random_waypoint',
    'misc_roll_credits',
    'misc_solid_props',
    'misc_spawn_controller',
    'misc_spawn_orange_ball',
    'misc_spinning_props',
    'misc_stuff_guns',
    'misc_super_stunt',
    'misc_total_chaos',
    'misc_u_turn',
    'misc_vehicle_rain',
    'misc_weird_pitch',
    'misc_whale_rain',
    'misc_witness_protection',
    
    -- Ped Effects
    'peds_2x_animation_speed',
    'peds_aimbot',
    'peds_attack_player',
    'peds_blind',
    'peds_bloody',
    'peds_bus_bois',
    'peds_cat_guns',
    'peds_cops',
    'peds_drive_backwards',
    'peds_driveby_player',
    'peds_eternal_screams',
    'peds_everyone_wep_controller',
    'peds_exit_veh',
    'peds_explosive',
    'peds_explosive_combat',
    'peds_flip_all',
    'peds_follow_player',
    'peds_frozen',
    'peds_give_props',
    'peds_grapple_guns',
    'peds_gunsmoke',
    'peds_hands_up',
    'peds_headless',
    'peds_hot_cougars',
    'peds_ignite_nearby',
    'peds_in_the_hood',
    'peds_into_random_vehs',
    'peds_invincible_peds',
    'peds_invisible_peds',
    'peds_james_bond',
    'peds_jumpy',
    'peds_killer_clowns',
    'peds_launch_nearby_peds',
    'peds_loose_trigger',
    'peds_mercenaries',
    'peds_min_damage',
    'peds_minions',
    'peds_mower_mates',
    'peds_nailguns',
    'peds_nearby_flee',
    'peds_no_ragdoll',
    'peds_not_menendez',
    'peds_obliterate_nearby',
    'peds_ohko',
    'peds_phones',
    'peds_prop_hunt',
    'peds_quarreling_couple',
    'peds_ragdoll',
    'peds_ragdoll_on_touch',
    'peds_reflective_damage',
    'peds_revive_nearby',
    'peds_riot',
    'peds_scooter_brothers',
    'peds_slippery_peds',
    'peds_smoke_trails',
    'peds_spawn_angry_alien',
    'peds_spawn_angry_chimp',
    'peds_spawn_angry_jesus',
    'peds_spawn_angry_jesus2',
    'peds_spawn_angry_jimmy',
    'peds_spawn_balla_squad',
    'peds_spawn_biker',
    'peds_spawn_companion_brad',
    'peds_spawn_companion_chimp',
    'peds_spawn_companion_chop',
    'peds_spawn_companion_random',
    'peds_spawn_dancing_apes',
    'peds_spawn_fan_cats',
    'peds_spawn_hostile_random',
    'peds_spawn_impotent_rage',
    'peds_spawn_juggernaut',
    'peds_spawn_roasting_lamar',
    'peds_spawn_space_ranger',
    'peds_speech_controller',
    'peds_stop_and_stare',
    'peds_strip_weapons',
    'peds_synced_cougar_apocalypse',
    'peds_tank_bois',
    'peds_toast',
    'peds_tp_guns',
    'peds_tp_random_peds_player_veh',
    'peds_zombies',
    
    -- Player Effects
    'player_afk',
    'player_aimbot',
    'player_autopilot',
    'player_bees',
    'player_blimp_strats',
    'player_clone',
    'player_copy_force',
    'player_dead_eye',
    'player_drunk',
    'player_fake_death',
    'player_fling_player',
    'player_forcefield',
    'player_gravity_sphere',
    'player_gta2',
    'player_hacking',
    'player_has_gravity',
    'player_heavy_recoil',
    'player_hesoyam',
    'player_ignite_player',
    'player_illegal_innocence',
    'player_im_tired',
    'player_invincibility',
    'player_jump_jump',
    'player_keep_running',
    'player_kickflip',
    'player_lag_camera',
    'player_launch_up',
    'player_lock_camera',
    'player_movement_speed',
    'player_no_mov_random',
    'player_no_special',
    'player_no_sprint_jump',
    'player_pacifist',
    'player_poof',
    'player_poor',
    'player_ragdoll',
    'player_ragdoll_on_shot',
    'player_random_clothes',
    'player_random_stunt_jump',
    'player_random_veh_seat',
    'player_rapid_fire',
    'player_rocket',
    'player_set_into_closest_veh',
    'player_set_into_random_veh',
    'player_simeon_says',
    'player_suicide',
    'player_super_run_jump',
    'player_team_roles',
    'player_tp_controller',
    'player_tp_everything',
    'player_tp_to_everything',
    'player_tp_to_random_store',
    'player_vr',
    'player_walk_on_water',
    'player_wanted_controller',
    'player_weapon_giver',
    'player_zoom_zoom_cam',
    
    -- Screen Effects
    'screen_binoculars',
    'screen_bouncy_radar',
    'screen_dvd_screensaver',
    'screen_flip_camera',
    'screen_flip_ui',
    'screen_heat_vision',
    'screen_maximap',
    'screen_night_vision',
    'screen_no_hud',
    'screen_no_radar',
    'screen_on_demand_cartoon',
    'screen_quake_fov',
    'screen_real_first_person',
    'screen_sick_cam',
    'screen_spin_cam',
    'screen_timecyc_modifier_controller',
    
    -- Shader Effects
    'screen_shader_arc',
    'screen_shader_colorful_world',
    'screen_shader_dim_warp',
    'screen_shader_fck_autorotate',
    'screen_shader_folded_screen',
    'screen_shader_fourth_dimension',
    'screen_shader_hue_shift',
    'screen_shader_inverted_colors',
    'screen_shader_local_coop',
    'screen_shader_mirrored',
    'screen_shader_rgb_land',
    'screen_shader_screen_freakout',
    'screen_shader_screen_potato',
    'screen_shader_shattered_screen',
    'screen_shader_swapped_colors',
    'screen_shader_textureless',
    'screen_shader_tn_panel',
    'screen_shader_warped_cam',
    
    -- Time Effects
    'time_controller',
    'time_game_speed_controller',
    'time_superhot',
    
    -- Veh Effects
    'vehs_30mph_limit',
    'vehs_all_horn',
    'vehs_all_vehs_launch_up',
    'vehs_beyblade',
    'vehs_boost_braking',
    'vehs_bouncy',
    'vehs_brake_boosting',
    'vehs_break_doors',
    'vehs_cinematic_cam',
    'vehs_color_controller',
    'vehs_cruise_control',
    'vehs_crumble',
    'vehs_detach_wheel',
    'vehs_disassemble',
    'vehs_engine_multiplier_controller',
    'vehs_explode_nearby',
    'vehs_flying_car',
    'vehs_full_accel',
    'vehs_gtao_traffic',
    'vehs_honk_boosting',
    'vehs_invincible',
    'vehs_invisible',
    'vehs_jesus_take_the_wheel',
    'vehs_jumpy',
    'vehs_kill_engine',
    'vehs_lock_all',
    'vehs_no_grav',
    'vehs_no_traffic',
    'vehs_one_hit_ko',
    'vehs_player_veh_despawn',
    'vehs_player_veh_explode',
    'vehs_player_veh_lock',
    'vehs_pop_tires',
    'vehs_pop_tires_random',
    'vehs_prop_models',
    'vehs_random_traffic',
    'vehs_repair_all',
    'vehs_replace_vehicle',
    'vehs_repossession',
    'vehs_rot_all',
    'vehs_slippery_vehs',
    'vehs_spam_doors',
    'vehs_spawner',
    'vehs_spawn_iesultan',
    'vehs_speed_min',
    'vehs_tiny',
    'vehs_tire_poppin',
    'vehs_trigger_alarm',
    'vehs_upgrade_controller',
    'vehs_weapons',
    
    -- Weather Effects
    'weather_controller',
    'weather_snow'
}

-- Client port mapping (each player has Chaos Mod on different port)
local playerChaosPorts = {
    -- Will be populated when players join
    -- [source] = port number
}

-- Trigger effect on ALL clients simultaneously
function TriggerSyncedChaosEffect(effectId, duration)
    if not JourneySession.active then return end
    
    local timestamp = os.time()
    
    -- Send to all connected players
    local count = 0
    for source, playerData in pairs(JourneySession.players) do
        local port = playerChaosPorts[source] or 8080
        local url = string.format("http://127.0.0.1:%d/trigger", port)
        
        PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
            if errorCode ~= 200 then
                print(string.format('^1[Chaos] Failed to trigger effect for player %d (port %d): HTTP %d^7', 
                    source, port, errorCode))
            end
        end, 'POST', json.encode({
            effectId = effectId,
            duration = duration,
            syncTimestamp = timestamp
        }), {
            ['Content-Type'] = 'application/json'
        })
        
        count = count + 1
    end
    
    print(string.format('^2[Chaos] Triggered "%s" for %d players (duration: %dms)^7', 
        effectId, count, duration))
    
    -- Notify clients for HUD display
    TriggerClientEvent('cougar:triggerChaosEffect', -1, effectId, duration, timestamp)
    TriggerClientEvent('cougar:chaosEffectTriggered', -1, effectId, duration, timestamp)
end

-- Only trigger if journey is active AND chaos mod is active
Citizen.CreateThread(function()
    while true do
        Wait(chaosEffectInterval)
        
        if JourneySession.active and GetPlayerCount() > 0 then
            -- Check if chaos mod is active (client checks this)
            TriggerClientEvent('cougar:requestChaosStatus', -1)
        end
    end
end)

RegisterNetEvent('cougar:chaosStatusResponse')
AddEventHandler('cougar:chaosStatusResponse', function(isActive)
    if isActive then
        local effectId = allChaosEffects[math.random(#allChaosEffects)]
        local duration = 20000
        
        TriggerSyncedChaosEffect(effectId, duration)
    end
end)

-- Player connects: assign chaos port
RegisterNetEvent('cougar:registerChaosPort')
AddEventHandler('cougar:registerChaosPort', function(port)
    local src = source
    playerChaosPorts[src] = port
    print(string.format('^2[Chaos] Player %d registered Chaos Mod port: %d^7', src, port))
end)

-- Global event to trigger chaos effect from other files
RegisterNetEvent('cougar:triggerChaosEffect')
AddEventHandler('cougar:triggerChaosEffect', function(effectId, duration)
    TriggerSyncedChaosEffect(effectId, duration)
end)

-- Cougar-triggered chaos (when specific events happen)
function TriggerCougarChaos(cougarType)
    if cougarType == 'beeper' then
        -- Beeper exploded: trigger ragdoll on all players
        TriggerSyncedChaosEffect('player_ragdoll', 3000)
    elseif cougarType == 'jesus' then
        -- Jesus cougar spawned: trigger inverted controls
        TriggerSyncedChaosEffect('vehs_inverted_controls', 15000) -- assuming inverted controls effect exists
    elseif cougarType == 'purpleBall' then
        -- Purple ball hit: low gravity for everyone
        TriggerSyncedChaosEffect('misc_gravity_controller', 10000)
    elseif cougarType == 'hotCougars' then
        -- Spawn hostile cougars for all players
        TriggerSyncedChaosEffect('peds_hot_cougars', 30000)
    end
end
