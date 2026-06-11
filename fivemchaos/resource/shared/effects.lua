--[[
    Effect registry.
    Fields:
      id       - unique key
      name     - display name (shown on HUD)
      fn       - client function name in client/effects.lua
      short    - uses ShortDuration instead of EffectDuration
      instant  - fire-and-forget, no duration
      weight   - selection weight (default 10, higher = more common)
      incompatible - list of effect ids that can't run simultaneously
]]

Effects = {}

Effects.Pool = {
    -- === GRAVITY ===
    {id='low_gravity',       name='Low Gravity',              fn='FX_LowGravity'},
    {id='very_low_gravity',  name='Very Low Gravity',         fn='FX_VeryLowGravity'},
    {id='high_gravity',      name='Insane Gravity',           fn='FX_HighGravity'},
    {id='moon_gravity',      name='Moon Physics',             fn='FX_MoonGravity'},

    -- === VEHICLE ===
    {id='slippery_cars',     name='Slippery Vehicles',        fn='FX_SlipperyCars'},
    {id='bouncy_cars',       name='Bouncy Vehicles',          fn='FX_BouncyCars'},
    {id='turbo_cars',        name='2x Engine Power',          fn='FX_TurboCars'},
    {id='slow_cars',         name='0.5x Engine Power',        fn='FX_SlowCars'},
    {id='turbo_10x',         name='10x Engine Power',         fn='FX_Turbo10x',          short=true},
    {id='honk_boost',        name='Honk Boost',              fn='FX_HonkBoost'},
    {id='brake_boost',       name='Brake Boost',             fn='FX_BrakeBoost'},
    {id='flying_cars',       name='Flying Cars',             fn='FX_FlyingCars'},
    {id='flip_cars',         name='Flip All Vehicles',        fn='FX_FlipCars',           instant=true},
    {id='launch_cars',       name='Launch Vehicles Up',       fn='FX_LaunchCars',         instant=true},
    {id='pop_tires',         name='Pop All Tires',            fn='FX_PopTires',           instant=true},
    {id='explode_on_impact', name='Vehicles Explode On Hit',  fn='FX_ExplodeOnImpact',    short=true},
    {id='beyblade',          name='Beyblades',               fn='FX_Beyblade',           short=true},
    {id='cruise_control',    name='Cruise Control',           fn='FX_CruiseControl'},
    {id='no_steering',       name='No Steering',             fn='FX_NoSteering',         short=true},
    {id='invincible_cars',   name='Invincible Vehicles',      fn='FX_InvincibleCars'},
    {id='lock_doors',        name='Lock All Doors',           fn='FX_LockDoors',          instant=true},
    {id='full_accel',        name='Full Throttle',            fn='FX_FullAccel',          short=true},
    {id='speed_limit',       name='30 MPH Limit',            fn='FX_SpeedLimit'},

    -- === PLAYER ===
    {id='super_jump',        name='Super Jump',              fn='FX_SuperJump'},
    {id='super_speed',       name='Super Speed',             fn='FX_SuperSpeed'},
    {id='drunk',             name='Drunk',                   fn='FX_Drunk'},
    {id='ragdoll',           name='Ragdoll!',                fn='FX_Ragdoll',            instant=true},
    {id='ignite_player',     name='Spontaneous Combustion',   fn='FX_IgnitePlayer',       instant=true},
    {id='launch_player',     name='Launch Player Up',         fn='FX_LaunchPlayer',       instant=true},
    {id='give_weapon',       name='Random Weapon',            fn='FX_GiveWeapon',         instant=true},
    {id='no_sprint',         name='No Sprint',               fn='FX_NoSprint'},
    {id='forcefield',        name='Forcefield',              fn='FX_Forcefield',         short=true},
    {id='invincible',        name='Invincibility',           fn='FX_Invincible',         short=true},
    {id='bees',              name='BEES!',                   fn='FX_Bees'},
    {id='keep_running',      name='Keep Running',            fn='FX_KeepRunning',        short=true},
    {id='heavy_recoil',      name='Heavy Recoil',            fn='FX_HeavyRecoil'},
    {id='rapid_fire',        name='Rapid Fire',              fn='FX_RapidFire'},
    {id='one_hit_ko',        name='One Hit KO',              fn='FX_OneHitKO',           short=true},
    {id='clone_player',      name='Clone Player',            fn='FX_ClonePlayer',        instant=true},
    {id='jesus_wheel',       name='Jesus Take The Wheel',     fn='FX_JesusTakeTheWheel',  instant=true},
    {id='cant_move_forward', name="Can't Move Forward",      fn='FX_CantMoveForward',    short=true},

    -- === PEDS ===
    {id='ped_riot',          name='Peds Riot',               fn='FX_PedRiot'},
    {id='ped_attack',        name='Peds Attack You',          fn='FX_PedAttack'},
    {id='ped_flee',          name='Everyone Flees',           fn='FX_PedFlee',            instant=true},
    {id='ped_explode',       name='Explosive Pedestrians',    fn='FX_PedExplode'},
    {id='ped_weapons',       name='Arm All Peds',            fn='FX_PedWeapons',         instant=true},
    {id='ped_rockets',       name='Rocket Launcher Peds',     fn='FX_PedRockets',         instant=true},
    {id='ped_ragdoll',       name='Ragdoll Everyone',        fn='FX_PedRagdoll',         instant=true},
    {id='spawn_killerclowns',name='Killer Clowns',           fn='FX_SpawnKillerClowns',  instant=true},
    {id='spawn_juggernaut',  name='Spawn Juggernaut',        fn='FX_SpawnJuggernaut',    instant=true},
    {id='spawn_angry_jesus', name='Spawn Angry Jesus',        fn='FX_SpawnAngryJesus',    instant=true},

    -- === SCREEN ===
    {id='flip_screen',       name='Australia Mode',           fn='FX_FlipScreen'},
    {id='quake_fov',         name='Quake FOV',               fn='FX_QuakeFOV'},
    {id='night_vision',      name='Night Vision',            fn='FX_NightVision'},
    {id='heat_vision',       name='Thermal Vision',          fn='FX_HeatVision'},
    {id='lsd',               name='LSD',                     fn='FX_LSD'},
    {id='noir',              name='Noir',                    fn='FX_Noir'},
    {id='deepfried',         name='Deep Fried',              fn='FX_DeepFried'},
    {id='no_hud',            name='No HUD',                  fn='FX_NoHUD'},
    {id='fog_screen',        name='Foggy',                   fn='FX_FogScreen'},
    {id='extreme_bright',    name='Flashbang',               fn='FX_ExtremeBright',      short=true},
    {id='extreme_dark',      name='Blackout',                fn='FX_ExtremeDark',        short=true},

    -- === WEATHER ===
    {id='storm',             name='Thunderstorm',            fn='FX_Storm'},
    {id='fog',               name='Dense Fog',               fn='FX_Fog'},
    {id='snow',              name='Snow',                    fn='FX_Snow'},
    {id='disco_weather',     name='Disco Weather',           fn='FX_DiscoWeather',       short=true},

    -- === TIME ===
    {id='slow_mo',           name='0.3x Speed',              fn='FX_SlowMo',             short=true},
    {id='fast_mo',           name='2x Speed',                fn='FX_FastMo'},
    {id='very_fast',         name='5x Speed',                fn='FX_VeryFast',           short=true},

    -- === MISC MAYHEM ===
    {id='earthquake',        name='Earthquake',              fn='FX_Earthquake',         short=true},
    {id='meteor_rain',       name='Meteor Shower',           fn='FX_MeteorRain',         short=true},
    {id='black_hole',        name='Black Hole',              fn='FX_BlackHole',          short=true},
    {id='airstrike',         name='Airstrike',              fn='FX_Airstrike',          instant=true},
    {id='invert_velocity',   name='Reverse!',                fn='FX_InvertVelocity',     instant=true},
    {id='boost_velocity',    name='Speed Boost',             fn='FX_BoostVelocity',      instant=true},
    {id='uturn',             name='U-Turn',                  fn='FX_UTurn',              instant=true},
    {id='money_rain',        name='Money Rain',              fn='FX_MoneyRain',          instant=true},
    {id='oil_leaks',         name='Oil Leaks',               fn='FX_OilLeaks'},
    {id='jumpy_props',       name='Jumpy Props',             fn='FX_JumpyProps',         short=true},
    {id='ghost_world',       name='Ghost World',             fn='FX_GhostWorld',         short=true},

    -- === WANTED ===
    {id='wanted_3',          name='3 Star Wanted',           fn='FX_Wanted3',            instant=true},
    {id='wanted_5',          name='5 Star Wanted',           fn='FX_Wanted5',            instant=true},
    {id='clear_wanted',      name='Clear Wanted',            fn='FX_ClearWanted',        instant=true},
    {id='never_wanted',      name='Never Wanted',            fn='FX_NeverWanted',        short=true},
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
