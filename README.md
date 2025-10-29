# Cougar Journey (FiveM)

Cooperative survival experience for GTA V / FiveM that marries relentless cougar assaults with Chaos Mod V mayhem.  
This repository bundles the FiveM resource (`resources/cougars`) and the customised Chaos Mod V fork used to synchronise global chaos effects across players.

## Features

- **Server‑authoritative cougar hordes** – weighted archetypes, cropduster events, loot drops, automatic cleanup.
- **Team-centric journey loop** – shared deaths, distance tracking, rubber-banding, custom HUD and leaderboard overlays.
- **Chaos Mod integration** – HTTP bridge to the Chaos Mod ASI with per-player port mapping and effect synchronisation.
- **Menu & debug tools** – F6 NUI for starting/stopping the journey, spawning specific cougar types, triggering events.

## Repository Layout

```
.
├── resources/
│   └── cougars/          # FiveM resource (client, server, NUI, config)
├── ChaosModV-master/     # Patched Chaos Mod source (external trigger support)
├── server.cfg            # FiveM recipe consuming this resource
└── CHANGELOG.md
```

## Quick Start

1. Install a FiveM server (latest artifacts recommended).
2. Drop this repository into your server data folder and add `ensure cougars` to `server.cfg`.
3. Configure `resources/cougars/config.lua` as needed (spawn weights, chaos ports, etc.).
4. Build / install the Chaos Mod fork (see `ChaosModV-master/README_BUILD.md`) and run it alongside each client.
5. Launch the server and press **F6** in-game to open the control menu.

## Development

- Client scripts: `resources/cougars/client`
- Server scripts: `resources/cougars/server`
- HTML / JS UI: `resources/cougars/html`
- Chaos Mod C++ sources: `ChaosModV-master/ChaosMod`

Typical workflow:

```bash
# FiveM resource hot reload
refresh
restart cougars
```

Testing tips:

- Watch the server console for `Spawning <type> cougar via controller <id>` to confirm the server is dispatching spawns.
- Use `testchaos` in the client console to validate the Chaos Mod HTTP bridge.
- Hold `Z` in-game to inspect the live stats overlay.

## License

This project inherits Chaos Mod V’s licensing for the included fork; additional resource code is provided as-is for personal / educational usage. Examine upstream licenses in `ChaosModV-master/LICENSE` before redistribution.
