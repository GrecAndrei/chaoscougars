Config = {}

-- Journey Settings
Config.MaxTeamDeaths = 2
Config.MaxDeathsPerPlayer = 1
Config.RubberBandRadius = 600.0 -- meters
Config.PositionUpdateRate = 100 -- ms

-- Cougar Settings
Config.MaxAliveCougars = 100  -- Increase from 25 to 100
Config.SpawnDistance = {min = 50, max = 100} -- meters from team center
Config.SpawnInterval = 8 -- seconds
Config.DespawnDistance = 300  -- Changed from 200 to 300
Config.MaxCougarLifetime = 300 -- 5 minutes max per cougar

Config.DebugDefaults = {
    enabled = false,
    godMode = false,
    infiniteDeaths = false
}

-- Cougar Type Spawn Weights (must sum to 1.0)
Config.CougarTypes = {
    normal = {
        weight = 0.40,
        model = 'a_c_mtlion',
        health = 150,
        damage = 20,
        visualObject = nil
    },
    
    shooter = {
        weight = 0.20,
        model = 'a_c_mtlion',
        health = 120,
        damage = 15,
        weapon = 'WEAPON_PISTOL',
        accuracy = 40,
        shootRate = 300,
        visualObject = nil
    },
    
    blueBall = {
        weight = 0.15,
        model = 'a_c_mtlion',
        health = 100,
        damage = 15,
        visualObject = 'p_ld_soc_ball_01', -- ACTUAL soccer ball that works
        knockback = {x = 0, y = 0, z = 12.0}
    },
    
    purpleBall = {
        weight = 0.05,
        model = 'a_c_mtlion',
        health = 100,
        damage = 15,
        visualObject = 'prop_bowling_ball', -- Bowling ball
        knockback = {x = 0, y = 0, z = 28.0}
    },
    
    barrier = {
        weight = 0.05,
        model = 'a_c_mtlion',
        health = 100,
        damage = 10,
        visualObject = 'prop_mp_cone_01', -- Traffic cone
        invertVelocity = true
    },
    
    health = {
        weight = 0.05,
        model = 'a_c_mtlion',
        health = 80,
        damage = 10,
        visualObject = 'prop_ld_health_pack',
        dropOnDeath = {type = 'health', amount = 50}
    },
    
    armor = {
        weight = 0.05,
        model = 'a_c_mtlion',
        health = 80,
        damage = 10,
        visualObject = 'prop_armour_pickup',
        dropOnDeath = {type = 'armor', amount = 50}
    },
    
    ammo = {
        weight = 0.03,
        model = 'a_c_mtlion',
        health = 80,
        damage = 10,
        visualObject = 'prop_box_ammo03a',
        dropOnDeath = {type = 'ammo', amount = 100}
    },
    
    jesus = {
        weight = 0.01,
        model = 'a_c_mtlion',
        health = 500,
        damage = 25,
        visualObject = 'prop_big_bag_01',
        isTank = true
    },
    
    beeper = {
        weight = 0.01,
        model = 'a_c_mtlion',
        health = 50,
        damage = 100,
        visualObject = 'prop_bomb_01', -- ACTUAL bomb prop
        explodeOnContact = true
    }
}

-- Difficulty Scaling (distance in km)
Config.DifficultyScaling = {
    {distance = 0, multiplier = 1.0},
    {distance = 2, multiplier = 1.3},
    {distance = 5, multiplier = 1.6},
    {distance = 8, multiplier = 2.0}
}

-- Cropduster Event
Config.CropDusterInterval = 300 -- seconds (5 mins)
Config.CropDusterCougarCount = 8

-- ====================================
-- CLIENT-SPECIFIC CONFIG
-- ====================================
if IsDuplicityVersion() == false then
    Config.ChaosPort = 8080  -- ⚠️ CHANGE THIS PER PLAYER
    Config.ChaosDebug = true
    Config.ChaosConnectionTestInterval = 10000
    
    print('^2[Cougar Journey] Client config loaded - Chaos port: ' .. Config.ChaosPort .. '^7')
end
