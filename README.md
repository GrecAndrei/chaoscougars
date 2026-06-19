# chaoscougar

A FiveM chaos-mod resource: players race from LSIA to Paleto Bay while the
server spawns aggressive cougars (mountain lions), baller chasers, splinter
packs, and a steady stream of randomized effects (gravity flips, drunk cam,
meteors, META chaos, etc.).

## What you get

- 500+ effects across 7 categories: vehicle, player, peds, visual, weather,
  misc, spawn, and META (modifiers that affect the chaos loop itself).
  (369 in `effects_generated_registry.lua`, 142 in `effects_registry.lua`.)
- 12 cougar spawner types: `fence`, `car`, `shooter`, `swarm`, `splitter`,
  `bomber`, `phantom`, `magnetic`, `stun`, `ball_blue`, `ball_purple`, `jesus`.
- Server-authoritative director: spawn rate, cougar count, and targeting scale
  with mission progress (difficulty 0.0→1.0).
- Vote-to-pause (F9 in-game), admin panel (F5), HUD overlay, late-join sync.
- Hardened security: ACE-gated admin, type-validated payloads, dev REPL behind
  token, payload-size caps on broadcasts.

## Layout

```
chaoscougar/
├── fivemchaos/
│   ├── resource/          # main resource (cougars + chaos + HUD)
│   ├── resource_repl/     # dev REPL resource (HTTP RCE behind dev token)
│   └── resource_test/     # in-process test harness
├── INSTALL.md             # server setup
├── server.cfg.example     # template for your txData/server.cfg
├── install.ps1            # PowerShell installer (copies resource to FXServer)
└── CHANGELOG.md
```

## Quick start

See [INSTALL.md](INSTALL.md). TL;DR:

1. Drop `fivemchaos/resource/` into your `txData/resources/[local]/` directory.
2. Copy `server.cfg.example` into your `txData/` and add your license key.
3. Set a `chaoscougar_dev_token` in `server.cfg` if you want the dev REPL.
4. `ensure cougars` in the FiveM console.

## In-game controls

| Key | Action                       |
|-----|------------------------------|
| F5  | Toggle admin panel           |
| F9  | Toggle pause vote            |
| G (admin) | Start mission         |
| K (admin) | Stop mission          |

## Security

Admin endpoints require the `chaoscougar.admin` ACE. Grant it via:

```cfg
add_ace group.admin chaoscougar.admin allow
add_principal identifier.license:YOUR_LICENSE group.admin
```

The dev REPL (`fivemchaos/resource_repl/`) exposes Lua execution. It is
gated on an `X-CC-Dev-Token` header matching the `chaoscougar_dev_token`
ConVar. Set that in `server.cfg`:

```cfg
setr chaoscougar_dev_token "pick-a-long-random-string"
```

If unset, the dev REPL is fully locked down (read-only status endpoints
still work for debugging).

## License

MIT.
