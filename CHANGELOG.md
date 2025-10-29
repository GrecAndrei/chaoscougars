# Changelog

## Unreleased

- Added server-side spawn controller so a single authoritative client handles cougar creation and confirmations.
- Reworked client cougar logic to acknowledge server spawns, register network ids, and report deaths for stats.
- Synced Chaos Mod triggers between HUD and HTTP bridge; clients now validate Chaos Mod status before responding.
- Expanded HUD to show teammate vitals without duplicating the local player and moved stats overlay to `Z`.
- Normalised player tracking across server scripts, fixing nil `NetToEntity` crashes and duplicate roster entries.
- Locked journey start/finish to deterministic spawn & destination points to avoid unpredictable teleports.
