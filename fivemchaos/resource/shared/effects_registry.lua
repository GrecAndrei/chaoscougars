Effects = {}

Effects.Pool = {
    -- === GRAVITY (LOCAL) ===
    {id='low_gravity',       name='Low Gravity',              fn='FX_LowGravity',         sync_mode=SyncMode.LOCAL},
    {id='very_low_gravity',  name='Very Low Gravity',         fn='FX_VeryLowGravity',     sync_mode=SyncMode.LOCAL},
    {id='high_gravity',      name='Insane Gravity',           fn='FX_HighGravity',        sync_mode=SyncMode.LOCAL},
    {id='moon_gravity',      name='Moon Physics',             fn='FX_MoonGravity',        sync_mode=SyncMode.LOCAL},

    -- === VEHICLE LOCAL ===
    {id='slippery_cars',     name='Slippery Vehicles',        fn='FX_SlipperyCars',       sync_mode=SyncMode.LOCAL},
    {id='turbo_cars',        name='2x Engine Power',          fn='FX_TurboCars',          sync_mode=SyncMode.LOCAL},
    {id='slow_cars',         name='0.5x Engine Power',        fn='FX_SlowCars',           sync_mode=SyncMode.LOCAL},
    {id='turbo_10x',         name='10x Engine Power',         fn='FX_Turbo10x',           sync_mode=SyncMode.LOCAL, short=true},
    {id='honk_boost',        name='Honk Boost',              fn='FX_HonkBoost',          sync_mode=SyncMode.LOCAL},
    {id='brake_boost',       name='Brake Boost',             fn='FX_BrakeBoost',         sync_mode=SyncMode.LOCAL},
    {id='flying_cars',       name='Flying Cars',             fn='FX_FlyingCars',         sync_mode=SyncMode.LOCAL},
    {id='cruise_control',    name='Cruise Control',           fn='FX_CruiseControl',      sync_mode=SyncMode.LOCAL},
    {id='no_steering',       name='No Steering',             fn='FX_NoSteering',         sync_mode=SyncMode.LOCAL, short=true},
    {id='invincible_cars',   name='Invincible Vehicles',      fn='FX_InvincibleCars',     sync_mode=SyncMode.LOCAL},
    {id='full_accel',        name='Full Throttle',            fn='FX_FullAccel',          sync_mode=SyncMode.LOCAL, short=true},
    {id='speed_limit',       name='30 MPH Limit',            fn='FX_SpeedLimit',         sync_mode=SyncMode.LOCAL},
    {id='explode_on_impact', name='Vehicles Explode On Hit',  fn='FX_ExplodeOnImpact',    sync_mode=SyncMode.LOCAL, short=true},

    -- === VEHICLE GLOBAL ===
    {id='bouncy_cars',       name='Bouncy Vehicles',          fn='FX_BouncyCars',         sync_mode=SyncMode.GLOBAL_OWNED},
    {id='flip_cars',         name='Flip All Vehicles',        fn='FX_FlipCars',           sync_mode=SyncMode.GLOBAL_OWNED, instant=true},
    {id='launch_cars',       name='Launch Vehicles Up',       fn='FX_LaunchCars',         sync_mode=SyncMode.GLOBAL_OWNED, instant=true},
    {id='pop_tires',         name='Pop All Tires',            fn='FX_PopTires',           sync_mode=SyncMode.GLOBAL_OWNED, instant=true},
    {id='beyblade',          name='Beyblades',               fn='FX_Beyblade',           sync_mode=SyncMode.GLOBAL_OWNED, short=true},
    {id='lock_doors',        name='Lock All Doors',           fn='FX_LockDoors',          sync_mode=SyncMode.GLOBAL_OWNED, instant=true},

    -- === PLAYER (LOCAL) ===
    {id='super_jump',        name='Super Jump',              fn='FX_SuperJump',          sync_mode=SyncMode.LOCAL},
    {id='super_speed',       name='Super Speed',             fn='FX_SuperSpeed',         sync_mode=SyncMode.LOCAL},
    {id='drunk',             name='Drunk',                   fn='FX_Drunk',              sync_mode=SyncMode.LOCAL},
    {id='ragdoll',           name='Ragdoll!',                fn='FX_Ragdoll',            sync_mode=SyncMode.LOCAL, instant=true},
    {id='ignite_player',     name='Spontaneous Combustion',   fn='FX_IgnitePlayer',       sync_mode=SyncMode.LOCAL, instant=true},
    {id='launch_player',     name='Launch Player Up',         fn='FX_LaunchPlayer',       sync_mode=SyncMode.LOCAL, instant=true},
    {id='give_weapon',       name='Random Weapon',            fn='FX_GiveWeapon',         sync_mode=SyncMode.LOCAL, instant=true},
    {id='no_sprint',         name='No Sprint',               fn='FX_NoSprint',           sync_mode=SyncMode.LOCAL},
    {id='invincible',        name='Invincibility',           fn='FX_Invincible',         sync_mode=SyncMode.LOCAL, short=true},
    {id='bees',              name='BEES!',                   fn='FX_Bees',               sync_mode=SyncMode.LOCAL},
    {id='keep_running',      name='Keep Running',            fn='FX_KeepRunning',        sync_mode=SyncMode.LOCAL, short=true},
    {id='heavy_recoil',      name='Heavy Recoil',            fn='FX_HeavyRecoil',        sync_mode=SyncMode.LOCAL},
    {id='rapid_fire',        name='Rapid Fire',              fn='FX_RapidFire',          sync_mode=SyncMode.LOCAL},
    {id='one_hit_ko',        name='One Hit KO',              fn='FX_OneHitKO',           sync_mode=SyncMode.LOCAL, short=true},
    {id='clone_player',      name='Clone Player',            fn='FX_ClonePlayer',        sync_mode=SyncMode.LOCAL, instant=true},
    {id='jesus_wheel',       name='Jesus Take The Wheel',     fn='FX_JesusTakeTheWheel',  sync_mode=SyncMode.LOCAL, instant=true},
    {id='cant_move_forward', name="Can't Move Forward",      fn='FX_CantMoveForward',    sync_mode=SyncMode.LOCAL, short=true},

    -- === PEDS (GLOBAL_OWNED) ===
    {id='ped_riot',          name='Peds Riot',               fn='FX_PedRiot',            sync_mode=SyncMode.GLOBAL_OWNED},
    {id='ped_attack',        name='Peds Attack You',          fn='FX_PedAttack',          sync_mode=SyncMode.GLOBAL_OWNED},
    {id='ped_flee',          name='Everyone Flees',           fn='FX_PedFlee',            sync_mode=SyncMode.GLOBAL_OWNED, instant=true},
    {id='ped_explode',       name='Explosive Pedestrians',    fn='FX_PedExplode',         sync_mode=SyncMode.GLOBAL_OWNED},
    {id='ped_weapons',       name='Arm All Peds',            fn='FX_PedWeapons',         sync_mode=SyncMode.GLOBAL_OWNED, instant=true},
    {id='ped_rockets',       name='Rocket Launcher Peds',     fn='FX_PedRockets',         sync_mode=SyncMode.GLOBAL_OWNED, instant=true},
    {id='ped_ragdoll',       name='Ragdoll Everyone',        fn='FX_PedRagdoll',         sync_mode=SyncMode.GLOBAL_OWNED, instant=true},

    -- === SPAWN SINGLE ===
    {id='spawn_killerclowns',name='Killer Clowns',           fn='FX_SpawnKillerClowns',  sync_mode=SyncMode.SPAWN_SINGLE, instant=true},
    {id='spawn_juggernaut',  name='Spawn Juggernaut',        fn='FX_SpawnJuggernaut',    sync_mode=SyncMode.SPAWN_SINGLE, instant=true},
    {id='spawn_angry_jesus', name='Spawn Angry Jesus',        fn='FX_SpawnAngryJesus',    sync_mode=SyncMode.SPAWN_SINGLE, instant=true},

    -- === SCREEN (VISUAL) ===
    {id='flip_screen',       name='Australia Mode',           fn='FX_FlipScreen',         sync_mode=SyncMode.VISUAL},
    {id='quake_fov',         name='Quake FOV',               fn='FX_QuakeFOV',           sync_mode=SyncMode.VISUAL},
    {id='night_vision',      name='Night Vision',            fn='FX_NightVision',        sync_mode=SyncMode.VISUAL},
    {id='heat_vision',       name='Thermal Vision',          fn='FX_HeatVision',         sync_mode=SyncMode.VISUAL},
    {id='lsd',               name='LSD',                     fn='FX_LSD',                sync_mode=SyncMode.VISUAL},
    {id='noir',              name='Noir',                    fn='FX_Noir',               sync_mode=SyncMode.VISUAL},
    {id='deepfried',         name='Deep Fried',              fn='FX_DeepFried',          sync_mode=SyncMode.VISUAL},
    {id='no_hud',            name='No HUD',                  fn='FX_NoHUD',              sync_mode=SyncMode.VISUAL},
    {id='fog_screen',        name='Foggy',                   fn='FX_FogScreen',          sync_mode=SyncMode.VISUAL},
    {id='extreme_bright',    name='Flashbang',               fn='FX_ExtremeBright',      sync_mode=SyncMode.VISUAL, short=true},
    {id='extreme_dark',      name='Blackout',                fn='FX_ExtremeDark',        sync_mode=SyncMode.VISUAL, short=true},

    -- === WEATHER (VISUAL) ===
    {id='storm',             name='Thunderstorm',            fn='FX_Storm',              sync_mode=SyncMode.VISUAL},
    {id='fog',               name='Dense Fog',               fn='FX_Fog',                sync_mode=SyncMode.VISUAL},
    {id='snow',              name='Snow',                    fn='FX_Snow',               sync_mode=SyncMode.VISUAL},
    {id='disco_weather',     name='Disco Weather',           fn='FX_DiscoWeather',       sync_mode=SyncMode.VISUAL, short=true},

    -- === TIME (LOCAL) ===
    {id='slow_mo',           name='0.3x Speed',              fn='FX_SlowMo',             sync_mode=SyncMode.LOCAL, short=true},
    {id='fast_mo',           name='2x Speed',                fn='FX_FastMo',             sync_mode=SyncMode.LOCAL},
    {id='very_fast',         name='5x Speed',                fn='FX_VeryFast',           sync_mode=SyncMode.LOCAL, short=true},

    -- === MISC MAYHEM ===
    {id='earthquake',        name='Earthquake',              fn='FX_Earthquake',         sync_mode=SyncMode.GLOBAL_OWNED, short=true},
    {id='meteor_rain',       name='Meteor Shower',           fn='FX_MeteorRain',         sync_mode=SyncMode.VISUAL, short=true},
    {id='black_hole',        name='Black Hole',              fn='FX_BlackHole',          sync_mode=SyncMode.GLOBAL_OWNED, short=true},
    {id='airstrike',         name='Airstrike',              fn='FX_Airstrike',          sync_mode=SyncMode.VISUAL, instant=true},
    {id='invert_velocity',   name='Reverse!',                fn='FX_InvertVelocity',     sync_mode=SyncMode.LOCAL, instant=true},
    {id='boost_velocity',    name='Speed Boost',             fn='FX_BoostVelocity',      sync_mode=SyncMode.LOCAL, instant=true},
    {id='uturn',             name='U-Turn',                  fn='FX_UTurn',              sync_mode=SyncMode.LOCAL, instant=true},
    {id='money_rain',        name='Money Rain',              fn='FX_MoneyRain',          sync_mode=SyncMode.LOCAL, instant=true},
    {id='oil_leaks',         name='Oil Leaks',               fn='FX_OilLeaks',           sync_mode=SyncMode.LOCAL},
    {id='jumpy_props',       name='Jumpy Props',             fn='FX_JumpyProps',         sync_mode=SyncMode.GLOBAL_OWNED, short=true},
    {id='ghost_world',       name='Ghost World',             fn='FX_GhostWorld',         sync_mode=SyncMode.GLOBAL_OWNED, short=true},
    {id='forcefield',        name='Forcefield',              fn='FX_Forcefield',         sync_mode=SyncMode.GLOBAL_OWNED, short=true},

    -- === WANTED (LOCAL) ===
    {id='wanted_3',          name='3 Star Wanted',           fn='FX_Wanted3',            sync_mode=SyncMode.LOCAL, instant=true},
    {id='wanted_5',          name='5 Star Wanted',           fn='FX_Wanted5',            sync_mode=SyncMode.LOCAL, instant=true},
    {id='clear_wanted',      name='Clear Wanted',            fn='FX_ClearWanted',        sync_mode=SyncMode.LOCAL, instant=true},
    {id='never_wanted',      name='Never Wanted',            fn='FX_NeverWanted',        sync_mode=SyncMode.LOCAL, short=true},

    -- === META ===
    {id='meta_spawn_multiple',  name='Combo Time',            fn='FX_MetaSpawnMultiple',   sync_mode=SyncMode.META},
    {id='meta_duration_05x',    name='0.5x Duration',         fn='FX_MetaDuration05x',     sync_mode=SyncMode.META},
    {id='meta_duration_2x',     name='2x Duration',           fn='FX_MetaDuration2x',      sync_mode=SyncMode.META},
    {id='meta_timer_05x',       name='0.5x Timer Speed',      fn='FX_MetaTimerspeed05x',   sync_mode=SyncMode.META},
    {id='meta_timer_2x',        name='2x Timer Speed',        fn='FX_MetaTimerspeed2x',    sync_mode=SyncMode.META},
    {id='meta_timer_5x',        name='5x Timer Speed',        fn='FX_MetaTimerspeed5x',    sync_mode=SyncMode.META},
    {id='meta_no_chaos',        name='No Chaos',              fn='FX_MetaNoChaos',         sync_mode=SyncMode.META, short=true},
    {id='meta_hide_ui',         name='Hide Chaos UI',         fn='FX_MetaHideUI',          sync_mode=SyncMode.META},

    -- === NEW: VEHICLE LOCAL ===
    {id='auto_drive',        name='Auto Drive',                fn='FX_AutoDrive',        sync_mode=SyncMode.LOCAL, short=true},
    {id='reverse_only',      name='Reverse Only',              fn='FX_ReverseOnly',      sync_mode=SyncMode.LOCAL, short=true},
    {id='hover_mode',        name='Hover Mode',                fn='FX_HoverMode',        sync_mode=SyncMode.LOCAL},
    {id='sticky_tires',      name='Sticky Tires',              fn='FX_StickyTires',      sync_mode=SyncMode.LOCAL},
    {id='popcorn_engine',    name='Popcorn Engine',            fn='FX_PopcornEngine',    sync_mode=SyncMode.LOCAL, short=true},
    {id='reverse_camera',    name='Reverse Camera',            fn='FX_ReverseCamera',    sync_mode=SyncMode.LOCAL, short=true},
    {id='underwater_car',    name='Submarine',                 fn='FX_UnderwaterCar',    sync_mode=SyncMode.LOCAL},
    {id='ice_cam',           name='Jello Cam',                 fn='FX_IceCam',           sync_mode=SyncMode.LOCAL, short=true},
    {id='rocket_seat',       name='Rocket Seat',               fn='FX_RocketSeat',       sync_mode=SyncMode.LOCAL},
    {id='tow_along',         name='Tow Mode',                  fn='FX_TowAlong',         sync_mode=SyncMode.LOCAL},

    -- === NEW: VEHICLE GLOBAL ===
    {id='all_honk',          name='Honk-a-thon',               fn='FX_AllHonk',          sync_mode=SyncMode.GLOBAL_OWNED, short=true},
    {id='invisible_cars',    name='Invisible Cars',            fn='FX_InvisibleCars',    sync_mode=SyncMode.GLOBAL_OWNED, short=true},
    {id='tractor_beam',      name='Tractor Beam',              fn='FX_TractorBeam',      sync_mode=SyncMode.GLOBAL_OWNED, short=true},
    {id='cars_to_player',    name='Cars Converge',             fn='FX_CarsToPlayer',     sync_mode=SyncMode.GLOBAL_OWNED, short=true},

    -- === NEW: PLAYER LOCAL ===
    {id='huge_player',       name='Giant Mode',                fn='FX_HugePlayer',       sync_mode=SyncMode.LOCAL, short=true},
    {id='tiny_player',       name='Tiny Mode',                 fn='FX_TinyPlayer',       sync_mode=SyncMode.LOCAL, short=true},
    {id='mario_voice',       name='Mario Voice',               fn='FX_MarioVoice',       sync_mode=SyncMode.LOCAL, short=true},
    {id='whisper_voice',     name='Whisper Voice',             fn='FX_WhisperVoice',     sync_mode=SyncMode.LOCAL, short=true},
    {id='invisible_player',  name='Invisible Player',          fn='FX_InvisiblePlayer',  sync_mode=SyncMode.LOCAL, short=true},
    {id='pacifist',          name='Pacifist',                  fn='FX_Pacifist',         sync_mode=SyncMode.LOCAL, short=true},
    {id='confused_controls', name='Confused Controls',         fn='FX_ConfusedControls', sync_mode=SyncMode.LOCAL, short=true},
    {id='heavy_player',      name='Heavy Player',              fn='FX_HeavyPlayer',      sync_mode=SyncMode.LOCAL},
    {id='explosive_melee',   name='Explosive Fists',           fn='FX_ExplosiveMelee',   sync_mode=SyncMode.LOCAL},
    {id='ice_skates',        name='Ice Skates',                fn='FX_IceSkates',        sync_mode=SyncMode.LOCAL, short=true},

    -- === NEW: PEDS GLOBAL ===
    {id='peds_zombies',      name='Zombie Peds',               fn='FX_PedsZombies',      sync_mode=SyncMode.GLOBAL_OWNED, instant=true},
    {id='peds_wave',         name='Peds Wave Hello',           fn='FX_PedsWave',         sync_mode=SyncMode.GLOBAL_OWNED, short=true},
    {id='peds_sit',          name='Peds Sit Down',             fn='FX_PedsSit',          sync_mode=SyncMode.GLOBAL_OWNED, short=true},
    {id='peds_levitate',     name='Peds Levitate',             fn='FX_PedsLevitate',     sync_mode=SyncMode.GLOBAL_OWNED, short=true},
    {id='peds_dance',        name='Peds Dance',                fn='FX_PedsDance',        sync_mode=SyncMode.GLOBAL_OWNED, short=true},

    -- === NEW: SCREEN/VISUAL ===
    {id='greyscale',         name='Greyscale',                 fn='FX_Greyscale',        sync_mode=SyncMode.VISUAL},
    {id='wavy_vision',       name='Wavy Vision',               fn='FX_WavyVision',       sync_mode=SyncMode.VISUAL},
    {id='fish_eye',          name='Fish Eye',                  fn='FX_FishEye',          sync_mode=SyncMode.VISUAL},
    {id='bloom',             name='Heavy Bloom',               fn='FX_Bloom',            sync_mode=SyncMode.VISUAL},
    {id='tunnel_vision',     name='Tunnel Vision',             fn='FX_TunnelVision',     sync_mode=SyncMode.VISUAL, short=true},

    -- === NEW: TIME/WEATHER ===
    {id='midnight',          name='Midnight',                  fn='FX_Midnight',         sync_mode=SyncMode.VISUAL},
    {id='high_noon',         name='High Noon',                 fn='FX_HighNoon',         sync_mode=SyncMode.VISUAL},
    {id='smog',              name='Smog',                      fn='FX_Smog',             sync_mode=SyncMode.VISUAL},
    {id='rain_storm',        name='Rainstorm',                 fn='FX_RainStorm',        sync_mode=SyncMode.VISUAL},
    {id='reverse_time',      name='Time Reverses',             fn='FX_ReverseTime',      sync_mode=SyncMode.LOCAL, short=true},

    -- === NEW: MISC WORLD ===
    {id='lava_ground',       name='Lava Ground',               fn='FX_LavaGround',       sync_mode=SyncMode.GLOBAL_OWNED, short=true},
    {id='shrink_ray',        name='Shrink Ray',                fn='FX_ShrinkRay',        sync_mode=SyncMode.GLOBAL_OWNED, instant=true},
    {id='grow_ray',          name='Grow Ray',                  fn='FX_GrowRay',          sync_mode=SyncMode.GLOBAL_OWNED, instant=true},
    {id='gravity_pulse',     name='Gravity Pulse',             fn='FX_GravityPulse',     sync_mode=SyncMode.VISUAL, short=true},
    {id='color_swap',        name='Color Swap',                fn='FX_ColorSwap',        sync_mode=SyncMode.GLOBAL_OWNED, instant=true},

    -- === NEW: SPAWN SINGLE ===
    {id='spawn_alien',       name='Spawn Alien',               fn='FX_SpawnAlien',       sync_mode=SyncMode.SPAWN_SINGLE, instant=true},
    {id='spawn_bigfoot',     name='Spawn Bigfoot',             fn='FX_SpawnBigfoot',     sync_mode=SyncMode.SPAWN_SINGLE, instant=true},
    {id='spawn_zombie_horde',name='Spawn Zombie Horde',        fn='FX_SpawnZombieHorde', sync_mode=SyncMode.SPAWN_SINGLE, instant=true},

    -- === NEW: META ===
    {id='meta_super_chaos',     name='Super Chaos',            fn='FX_MetaSuperChaos',     sync_mode=SyncMode.META, short=true},
    {id='meta_extreme_duration',name='3x Duration',            fn='FX_MetaExtremeDuration',sync_mode=SyncMode.META, short=true},
    {id='meta_chaos_ramp',      name='Chaos Ramp',             fn='FX_MetaChaosRamp',      sync_mode=SyncMode.META},
}

-- Build lookup
Effects._byId = {}
for _, fx in ipairs(Effects.Pool) do
    Effects._byId[fx.id] = fx
end

function Effects.GetRandom(usedRecently, activeIds)
    usedRecently = usedRecently or {}
    activeIds = activeIds or {}

    local candidates = {}
    for _, fx in ipairs(Effects.Pool) do
        if not usedRecently[fx.id] and not activeIds[fx.id] then
            local dominated = false
            if fx.incompatible then
                for _, inc in ipairs(fx.incompatible) do
                    if activeIds[inc] then dominated = true; break end
                end
            end
            if not dominated then
                local w = fx.weight or 10
                for i = 1, w do
                    candidates[#candidates + 1] = fx
                end
            end
        end
    end

    if #candidates == 0 then
        return Effects.Pool[math.random(#Effects.Pool)]
    end
    return candidates[math.random(#candidates)]
end

function Effects.FindById(id)
    return Effects._byId[id]
end
