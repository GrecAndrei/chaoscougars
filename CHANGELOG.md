# Changelog

## Unreleased — security + bug-fix audit (4 rounds)

### Round 4 (security hardening)
- `server/security.lua`: hardened `isAdmin` (type-check, `==` for ACE boolean
  return). Added `setMeta()` helper that type-validates every META key
  (`additionalEffects` clamped 0–16, `durationModifier`/`timerModifier`
  clamped 0.1–10, `votingMode` enum, bools coerced). Both
  `cc:meta_set` and `cc:meta_set_internal` go through it.
- `server/admin.lua`: ALL 6 admin endpoints (`cc:admin_start/stop/pause/
  effect/spawn_cougar/kill_cougars`) now gated on `chaoscougar.admin` ACE
  + 250 ms per-source debounce. `cougarType` (string) and `pos`
  (xyz numbers) type-validated.
- `server/state.lua`: `State.Broadcast` validates event is non-empty string;
  sizes payload to ≤32 KB and refuses oversized events.
- `server/voting.lua`: 750 ms per-player debounce; validates `src` is a
  real connected player; cleans `lastVoteAt` on drop.
- `server/director.lua`: `playerDropped` despawns cougars near the dropped
  player and rebroadcasts the count.
- `server/late_join.lua`: cougar snapshot capped to 32 entries; dropped
  per-cougar `pos` field to keep payload small.
- `client/effects_runner.lua`: `cc:trigger_effect` rejects non-string
  `id`/`fnName`. `cc:late_join_sync` validates snapshot is a table and each
  entry has string `id`/`fn`; switched late-join timer to `{gen,cancel}`
  table to match `cc:trigger_effect` semantics.
- `client/panel.lua`: `panel_effect` input type/length/control-char check
  before firing `cc:admin_effect`.
- `client/hud.lua`: `nuiReady` gate + 64-entry `pendingMessages` queue
  drains on NUI `ready` callback so first ~100 ms of state isn't dropped.
- `client/sync.lua`: 2 s loop scans nearby cougars and re-requests control
  if ownership has flipped to a different client.
- `resource_repl/server.lua`: dev endpoints (`/exec`, `/client_exec`,
  `/event`, `/client_event`, `/telemetry`) require `X-CC-Dev-Token` header
  matching `chaoscougar_dev_token` ConVar. `cc:force_effect` requires
  `chaoscougar.dev` ACE. Read-only `/status`, `/players`, `/log` remain
  open for debugging.

### Round 3 (HUD/registry correctness)
- `ui/app.js`: added `case 'vote'` handler (`showVote` with per-option
  number key + bar fill) and `case 'vote_end'` (`clearVote` with fade).
  `death` handler now shows `${player} KIA — ${N} left`.
  `effects_cleared` hides the timer-bar and clears the tick interval.
  `addEffect` overflow path removes the corresponding `Map` entry.
  `addEffect` retrigger updates `timeEl.textContent`.
- `client/hud.lua`: forwards `cc:vote_end` → `{type:'vote_end'}`.
- `server/voting.lua`: broadcasts `cc:vote_end` on threshold-hit
  (immediate panel hide) and on expiry when no votes remain.
- `shared/effects_registry.lua`: `GetRandom` returns `nil` instead of a
  violating random pool entry when all candidates are exhausted.
- `server/chaos.lua`: burst loop has `if not fx then break end` guard.

### Round 2 (registry + META security)
- `shared/effects_generated_registry.lua`: built `Effects._validFns` and
  `Effects._validSyncModes` whitelists; per-META `meta={[key,on,off]}`
  data for 11 META effects.
- `server/chaos.lua`: validates `fn`/`duration`/`seed` in `DispatchEffect`
  against the whitelist; server applies META state via `ApplyMetaChange`
  with per-id `metaResetGens`; cap concurrent effects at 8.
- `server/security.lua`: ACE check on `cc:meta_set_internal` via
  `isAdmin()`.
- `server/admin.lua`: `cc:admin_effect` validates fn against the
  whitelist.
- `server/state.lua`: `onResourceStop` resets `phase`/`meta`/director.
- `client/effects_runner.lua`: `onResourceStop` resets gravity,
  invincible, vehicle, timecycle, etc.
- `client/effects_meta.lua`: `MetaSetInternal` is a no-op.
- `client/effects_generated.lua`: inlined helper definitions
  (`CreateHostilePed`, `CreatePoolClonePed`, `CreatePoolCloneVehicle`,
  `GetCoordAround`, `allPossibleJumps`, `allPossibleStores`,
  `TV_PLAYLISTS`); fixed two registry fn names
  (`FX_Invertvelocity`→`FX_MiscInvertvelocity`,
  `FX_TpMazebanktower`→`FX_TpMazebank`).
- `client/sync.lua`: hard LSIA respawn gated on `MyState.phase`.
- Deleted: `shared/effects.lua`, `patch_cougar.py`.

### Round 1 (cougar ownership + lifecycle)
- `client/ownership.lua`: promoted `AIIsMine` to a global so
  `effects_spawn.lua` can use it.
- `client/spawner.lua`: unified `Cleanup` claiming first; removed 3 s
  wait; `FindGround` accepts z=0; swarm per-`AIIsMine`; splitter
  registers each generated cougar individually; ball gate requires both
  ent and ball to be owned.
- `client/effects_spawn.lua`: `RetargetSpawnedPed` balanced inc +
  `DeleteEntity` corpse cleanup.
- `client/effects_generated.lua`: inlined helper definitions.
- `client/effects_runner.lua`: generation-counter `SetTimeout` so a
  retriggered effect doesn't get killed by its previous trigger's
  timer; late-join handler takes the new `cougars` argument.
- `server/director.lua`: broadcasts `cc:cougar_count` on despawn.
- `server/late_join.lua`: cougar snapshot + `cc:cougar_count` to the
  late-joiner.
- `server/chaos.lua`: `cc:despawn_all_cougars` on stop.
- `server/admin.lua`: 4-arg broadcast.
- Deleted: `client/effects.lua` (982 lines of dead code).

---

## Earlier

- `525feb1` — full chaos-mod framework with working multiplayer sync,
  admin panel, and aggressive cougars.
- `3e8f762` — 50 new chaos effects across 7 categories.
