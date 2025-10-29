# Chaos Mod V with External Trigger System

This is the complete Chaos Mod V with integrated external trigger HTTP system for the Cougar Journey mod.

## Build Requirements

- Visual Studio 2022 (with C++ development tools)
- CMake 3.31 or higher
- Windows 10/11 SDK

## Build Instructions

### Method 1: Using the BUILD.bat file
1. Open "Developer Command Prompt for VS 2022" or "Developer PowerShell for VS 2022"
2. Navigate to this directory
3. Run: `BUILD.bat`

### Method 2: Manual Build
1. Open "Developer Command Prompt for VS 2022"
2. Create build directory: `mkdir build && cd build`
3. Configure: `cmake .. -A x64`
4. Build: `cmake --build . --config Release`

## Features Added

- HTTP server for external triggering (port 8080 by default)
- CORS support for web-based requests
- All 350+ real Chaos Mod V effects mapped correctly
- FiveM integration ready

## Configuration

After installation, edit your `scripts/chaosmod/config.ini` to enable:
```
[ExternalTrigger]
ExternalTrigger_Enabled=true
ExternalTrigger_Port=8080
```

## Installation

1. Build the project (follow instructions above)
2. Copy `ChaosMod.asi` to your GTA V `scripts` folder
3. Ensure ScriptHookV is installed
4. Start GTA V and the HTTP server will be available at http://127.0.0.1:8080

## API Endpoints

- `GET /ping` - Health check
- `POST /trigger` - Trigger an effect (JSON: {"effectId": "player_ragdoll", "duration": 3000})
- `GET /status` - Server status

## Testing

Send a POST request to test:
```
curl -X POST http://127.0.0.1:8080/trigger \
  -H "Content-Type: application/json" \
  -d '{"effectId": "player_ragdoll", "duration": 3000}'
```