# Installing chaoscougar on a FiveM server

This resource was developed on a FiveM **client** install (Windows). It has
been syntax-checked but has **not** been launched against a running FXServer
from this repo. You need a valid FiveM license key to run the server.

## 1. Prerequisites

- Windows 10/11 or Linux (tested target: Windows)
- FiveM server artifacts (txAdmin / FXServer): download from
  <https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/>
- A valid FiveM license key from <https://keymaster.fivem.net/>
- A `txData/` directory created by `FXServer.exe` on first launch

## 2. Copy the resource

The main resource lives at `fivemchaos/resource/`. The folder name it lives
under inside `[local]/` is arbitrary; the `fxmanifest.lua` declares the
resource name as `cougars`. Common choices:

```
txData/resources/[local]/cougars/         # the main resource
txData/resources/[local]/cougars_repl/    # optional dev REPL
```

Run `install.ps1` (PowerShell) to copy automatically, or do it manually:

```powershell
# From the repo root
Copy-Item -Recurse -Force .\fivemchaos\resource          .\txData\resources\[local]\cougars
Copy-Item -Recurse -Force .\fivemchaos\resource_repl     .\txData\resources\[local]\cougars_repl
```

On Linux/macOS:

```sh
cp -r fivemchaos/resource      txData/resources/\[local\]/cougars
cp -r fivemchaos/resource_repl txData/resources/\[local\]/cougars_repl
```

## 3. Create your server.cfg

Copy `server.cfg.example` from this repo into `txData/server.cfg` and edit:

```cfg
sv_hostname "My Chaoscougar Server"

# Required: your license key from keymaster.fivem.net
sv_licenseKey "YOUR_KEY_HERE"

# Load resources
ensure mapmanager
ensure chat
ensure spawnmanager
ensure hardcap
ensure sessionmanager

# Cougars (main resource)
ensure cougars

# Optional: dev REPL (HTTP RCE behind token — DO NOT expose to the internet)
ensure cougars_repl

# Dev token (long random string; required for /exec, /event, etc.)
setr chaoscougar_dev_token "CHANGE_ME_TO_LONG_RANDOM_STRING"
```

If you do NOT want the dev REPL, omit the `ensure cougars_repl` and the
`chaoscougar_dev_token` lines.

## 4. Admin ACEs

The admin panel (F5 in-game) requires the `chaoscougar.admin` ACE. Grant it
to your admins:

```cfg
add_ace group.admins chaoscougar.admin allow
add_principal identifier.license:YOUR_LICENSE_HERE group.admins
```

For the dev REPL, the `chaoscougar.dev` ACE gates the `cc:force_effect`
NetEvent:

```cfg
add_ace group.devs chaoscougar.dev allow
add_principal identifier.license:YOUR_LICENSE_HERE group.devs
```

## 5. Run

```powershell
.\FXServer.exe
```

Or on Linux:

```sh
./run.sh
```

Then in the FiveM client, connect to `localhost:30120`.

## 6. Verifying it loaded

In the server console you should see:

```
[cougars] Starting...
...
[cougars] Resource started.
```

To trigger an effect from the server console:

```
cc_effect low_gravity
cc_effects           # list all
```

To start a mission:

```
cc_start
```

## Troubleshooting

| Symptom                                          | Fix                                                      |
|--------------------------------------------------|----------------------------------------------------------|
| `attempt to call global 'Effects' (a nil value)` | `fxmanifest.lua` load order is wrong — `effects_registry.lua` must be first |
| Cougars stand still, don't chase players         | `_G[fx.fn]` returns nil — verify fn name matches registry |
| HUD doesn't show vote panel                      | NUI `ready` callback not firing — check browser devtools console |
| `ERR_NETWORK_MESSAGE_TOO_LARGE` in server log    | A `State.Broadcast` payload exceeded 32KB; raise the cap or split |

## Development

This resource was authored with FiveM's backtick-hash syntax (e.g.
`` `a_c_mtlion` ``). Stock `luac` does not understand that syntax, so all
syntax checks in this repo use a stub that replaces the backticks with
`GetHashKey('...')` calls before passing to `luac -p`.

To run the syntax check yourself (PowerShell):

```powershell
$files = Get-ChildItem -Recurse -Path .\fivemchaos -Filter *.lua
foreach ($f in $files) {
    $src = Get-Content $f.FullName -Raw
    $stub = $src -replace '`([^`]+)`', "GetHashKey('$1')"
    $r = $stub | & luac -p - 2>&1
    if ($LASTEXITCODE -ne 0) { Write-Host "FAIL: $($f.Name)"; $r }
}
```
