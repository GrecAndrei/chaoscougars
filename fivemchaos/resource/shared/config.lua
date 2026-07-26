Config = {}

-- Route
Config.Start = vector3(-1388.6, -3111.61, 13.94)
Config.Finish = vector3(-106.29, 6349.32, 31.49)
Config.WinRadius = 50.0

-- Players
Config.MinPlayers = 1
Config.MaxPlayers = 4
Config.MinSurvivors = 1
Config.StartVehicle = 'kuruma2'

-- Co-op / pack play. A dead survivor stays down long enough for the squad to
-- reach them; grouping up also grants small, periodic recovery instead of a
-- permanent stat buff.
Config.ReviveDistance = 7.0
Config.ReviveHoldMs = 2500
Config.ReviveWindowSec = 35
Config.ReviveInvulnMs = 4000
Config.PackRadius = 40.0
Config.PackSurgeIntervalMs = 3000
Config.PackEngineRepair = 18.0
Config.PackHealthRestore = 4

-- Chaos timing (gets faster as you progress)
Config.ChaosIntervalBase = 20       -- seconds at start
Config.ChaosIntervalMin = 8         -- minimum at end
Config.EffectDuration = 45
Config.ShortDuration = 20

-- Director
Config.SpawnAheadBase = 60.0        -- meters ahead at start
Config.SpawnAheadMin = 25.0         -- gets closer as difficulty ramps
Config.SpawnLateral = 25.0
Config.MaxCougarsBase = 12
Config.MaxCougarsMax = 24
Config.SpawnCooldownBase = 4
Config.SpawnCooldownMin = 2
Config.CougarDespawnDist = 250.0

-- Difficulty ramp (0.0 at start, 1.0 at finish)
-- All "Base -> Min/Max" values interpolate based on progress
Config.DifficultyExponent = 1.5     -- curve (>1 = backloaded)

-- Voting
Config.PauseThreshold = 2
Config.VoteWindowSec = 5

-- Squad effect voting: when the chaos timer expires with 2+ players, the
-- squad picks between 3 candidate effects instead of the server rolling in
-- private. META effect votingMode='chaos' forces this on even when false.
Config.VoteEffects = true
Config.VoteEffectWindowSec = 8

-- Banned vehicle classes
Config.BannedClasses = {
    [14] = true,
    [15] = true,
    [16] = true,
}

Config.Debug = false
