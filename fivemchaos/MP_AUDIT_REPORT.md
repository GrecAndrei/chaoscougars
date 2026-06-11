# Multiplayer Safety Audit Report - Branch mp-audit-m3

Audited: `effects_generated.lua`, `effects_local.lua`, `effects_global.lua`, `effects_visual.lua`, `effects_spawn.lua`, `effects_meta.lua`, `effects_registry.lua`, `effects_generated_registry.lua`

---

## 1. WRONG sync_mode CLASSIFICATION (Registry vs Implementation)

Effects whose registry sync_mode does not match their actual behavior.

| # | Effect ID | Registry Mode | Correct Mode | Severity | Reason |
|---|-----------|---------------|--------------|----------|--------|
| 1 | `misc_earthquake` | VISUAL | GLOBAL_OWNED | HIGH | Applies force to owned vehicles via OwnershipGuard |
| 2 | `cocktail_shaker` | VISUAL | GLOBAL_OWNED | HIGH | Applies force to owned objects/vehicles via OwnershipGuard |
| 3 | `misc_flamethrower` | VISUAL | GLOBAL_OWNED | MED | Iterates owned peds for particle effects on weapons |
| 4 | `lowgravity` | VISUAL | LOCAL | MED | SetGravityLevel affects local physics |
| 5 | `verylowgravity` | VISUAL | LOCAL | MED | SetGravityLevel affects local physics |
| 6 | `insanegravity` | VISUAL | LOCAL | MED | SetGravityLevel affects local physics |
| 7 | `invertgravity` | VISUAL | GLOBAL_OWNED | HIGH | SetGravityLevel + ForEachOwnedPed force application |
| 8 | `misc_sideways_gravity` | VISUAL | GLOBAL_OWNED | HIGH | SetGravityLevel + ForEachOwnedPed force application |
| 9 | `time_lag` | VISUAL | GLOBAL_OWNED | HIGH | Teleports owned vehicles/peds to saved positions |
| 10 | `misc_ghost_world` | VISUAL | GLOBAL_OWNED | HIGH | Sets alpha and disables collision on owned peds |
| 11 | `misc_midas` | GLOBAL_OWNED | LOCAL | LOW | Primarily affects player vehicle, uses OwnershipGuard for touch detection only |
| 12 | `chaosmode` | VISUAL | META | HIGH | Triggers server meta events |
| 13 | `notraffic` | GLOBAL_OWNED | VISUAL | LOW | Only uses density multiplier natives (visual/local) |
| 14 | `misc_boost_velocity` | LOCAL | GLOBAL_OWNED | HIGH | Uses OwnershipGuard to modify all owned entities |
| 15 | `misc_clone_on_death` | LOCAL | GLOBAL_OWNED | HIGH | Uses OwnershipGuard to iterate and clone dead entities |
| 16 | `veh_bouncy` | LOCAL | GLOBAL_OWNED | HIGH | Uses OwnershipGuard to apply forces to all owned vehicles |
| 17 | `vehs_flyingcars` | GLOBAL_OWNED | LOCAL | MED | Only affects player's own vehicle via PlayerPedId() |
| 18 | `veh_30mphlimit` | LOCAL | GLOBAL_OWNED | HIGH | Uses OwnershipGuard to limit all owned vehicles |
| 19 | `peds_obliterate` | VISUAL | GLOBAL_OWNED | HIGH | Kills owned peds with explosions via OwnershipGuard |
| 20 | `misc_quick_sprunk_stop` | VISUAL | LOCAL | MED | Uses SetTimeScale which is a local gamespeed effect |
| 21 | `peds_roasting` | GLOBAL_OWNED | SPAWN_SINGLE | MED | Spawns a ped (Lamar) |
| 22 | `player_forcefield` | LOCAL | GLOBAL_OWNED | HIGH | Uses OwnershipGuard to push owned vehicles |
| 23 | `player_grav_sphere` | LOCAL | GLOBAL_OWNED | HIGH | Uses OwnershipGuard to ragdoll/push owned peds |
| 24 | `player_copyforce` | LOCAL | GLOBAL_OWNED | HIGH | Uses OwnershipGuard to apply velocity to owned vehicles |
| 25 | `player_famous` | LOCAL | GLOBAL_OWNED | MED | Uses OwnershipGuard to task owned peds |
| 26 | `peds_mindmg` | GLOBAL_OWNED | LOCAL | LOW | Primarily sets local player damage modifiers |
| 27 | `peds_reflectivedamage` | GLOBAL_OWNED | LOCAL | LOW | Only checks local player ped damage |
| 28 | `vehs_detach_wheel` | GLOBAL_OWNED | LOCAL | MED | Only affects player's current vehicle |
| 29 | `veh_boostbrake` | LOCAL | GLOBAL_OWNED | HIGH | Uses OwnershipGuard on all owned vehicles |
| 30 | `veh_brakeboost` | LOCAL | GLOBAL_OWNED | HIGH | Uses OwnershipGuard on all owned vehicles |
| 31 | `vehs_cruise_control` | GLOBAL_OWNED | LOCAL | MED | Only affects player's own vehicle |
| 32 | `peds_tank_bois` | SPAWN_SINGLE | GLOBAL_OWNED | MED | Uses OwnershipGuard to iterate owned peds |
| 33 | `misc_news_team` | VISUAL | SPAWN_SINGLE | HIGH | Spawns hostile ped |
| 34 | `player_fling_player` | VISUAL | LOCAL | MED | Creates explosion at player position, sets invincibility |
| 35 | `veh_poptire` | LOCAL | GLOBAL_OWNED | HIGH | Uses OwnershipGuard on all owned vehicles |

---

## 2. OWNERSHIP VIOLATIONS (GetGamePool without guard)

| # | Effect ID | Function | Severity | Issue |
|---|-----------|----------|----------|-------|
| 1 | `peds_busbois` | FX_PedsBusbois | MED | Iterates GetGamePool('CPed') and creates vehicles/sets peds into them without OwnershipGuard. SPAWN_SINGLE mitigates (single executor) but could still conflict with other clients' ped ownership. |
| 2 | `peds_catguns` | FX_PedsCatguns | MED | Iterates GetGamePool('CPed') checking IsPedShooting on all peds. SPAWN_SINGLE mitigates. |
| 3 | `peds_give_props` | FX_PedsGiveProps | MED | Iterates GetGamePool('CPed') and attaches objects to ALL peds without ownership check. Should use OwnershipGuard. |

---

## 3. CROSS-PLAYER ENTITY MODIFICATION

| # | Effect ID | Function | Severity | Issue |
|---|-----------|----------|----------|-------|
| 1 | `peds_grapple_guns` | FX_PedsGrappleGuns | HIGH | Applies `ApplyForceToEntityCenterOfMass` to `target` from `GetNearestPlayerPed()`. This force is applied to another player's ped without ownership check. Will cause physics fights. |

---

## 4. META DUPLICATION RISK

| # | Effect ID | Function | Severity | Issue |
|---|-----------|----------|----------|-------|
| 1 | All META effects | FX_MetaSpawnMultipleEffects, etc. | LOW | META effects call TriggerServerEvent from client. If the chaos runner dispatches META effects to all clients simultaneously (not just one), server state would be set N times. Presumed safe if server only dispatches META to one client, but should verify server-side `cc:meta_set_internal` is idempotent. |

---

## 5. SPAWN EFFECTS WITHOUT NETWORKING

Most SPAWN_SINGLE effects use `CreatePed(..., true, ...)` or `CreateVehicle(..., true, ...)` where the last `true` enables networking. This is correct. No issues found.

---

## FIXES APPLIED (HIGH severity)

1. Fixed `FX_PedsGrappleGuns` to not apply force to player peds (only owned objects/vehicles)
2. Fixed 21 sync_mode misclassifications in `effects_generated_registry.lua`
3. Fixed `FX_PedsGiveProps` to use OwnershipGuard instead of raw GetGamePool

---
