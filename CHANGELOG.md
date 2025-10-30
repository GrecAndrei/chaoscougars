# Changelog

## Unreleased

- Fixed cropduster spawns by loading models server-side with native calls.
- Added per-player elimination with spectator mode, one-life limit, and reduced melee damage.
- Implemented debug mode toggles (god mode, unlimited deaths) accessible via the F6 menu and synced to all clients.
- Reworked special cougar abilities and props to trigger once, detach visibly, and clean up their entities.
- Added server-side spawn controller so a single authoritative client handles cougar creation and confirmations.
- Reworked client cougar logic to acknowledge server spawns, register network ids, and report deaths for stats.
- Synced Chaos Mod triggers between HUD and HTTP bridge; clients now validate Chaos Mod status before responding.
- Expanded HUD to show teammate vitals without duplicating the local player and moved stats overlay to `Z`.
- Normalised player tracking across server scripts, fixing nil `NetToEntity` crashes and duplicate roster entries.
- Locked journey start/finish to deterministic spawn & destination points to avoid unpredictable teleports.
- Hardened respawn flow by forcing local resurrection, clearing freeze states, and restoring loadouts with spawn invulnerability.
- Scaled down animal bite damage globally during journeys via `WEAPON_ANIMAL` modifiers to keep cougars lethal but survivable.
- Added client-side health scaler that resurrects the player if a cougar bite would be fatal, preserving the 70% damage reduction guarantee.
- Reattached ability props for all clients on replicated cougars so visual cues stay in sync with their abilities.
