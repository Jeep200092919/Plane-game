# Roblox Plane Game

A physics-based airplane game for Roblox with realistic aerodynamics, multiple plane types, and a full HUD.

## Features

- **Two plane types**: Fighter Jet & Biplane — each with unique speed, lift, and handling stats
- **Realistic aerodynamics**: thrust, lift (with stall), drag, lateral drag, and gravity
- **Flight controls**: pitch, roll, yaw, throttle, boost, landing gear toggle
- **Third-person camera** with mouse-look orbit
- **HUD**: speed (knots), altitude, throttle bar, stall warning
- **Map**: Runway with edge lights, hangar, mountains, ocean, and sky
- **Multiplayer**: server-authoritative physics via RemoteEvents
- **Damage system**: crash damage scales with impact speed; plane respawns after destruction

## Controls

| Key | Action |
|-----|--------|
| `F` | Board / Exit plane (within 15 studs) |
| `Space` | Throttle up |
| `Left Shift` | Throttle down |
| `Left Ctrl` | Boost (1.5× thrust) |
| `W` | Pitch up |
| `S` | Pitch down |
| `A` | Roll left |
| `D` | Roll right |
| `Q` | Yaw left |
| `E` | Yaw right |
| `G` | Toggle landing gear |

## Project Structure

```
Plane-game/
├── default.project.json        # Rojo project config
└── src/
    ├── client/
    │   ├── PlaneController.client.lua   # Input + flight physics (client)
    │   ├── CameraController.client.lua  # Chase camera with mouse orbit
    │   └── PlaneGui.client.lua          # HUD (speed, altitude, throttle, stall)
    ├── server/
    │   ├── PlaneServer.server.lua       # Plane models, seating, state replication
    │   └── SpawnManager.server.lua      # Map, terrain, runway, lighting
    └── shared/
        ├── PlaneConfig.lua              # Plane stats, controls, physics constants
        └── PlanePhysics.lua             # Aerodynamics calculations (lift/drag/AoA)
```

## Setup

### With Rojo (recommended)
1. Install [Rojo](https://rojo.space/) and the Rojo VS Code extension / Roblox Studio plugin
2. Clone this repository
3. Run `rojo serve` in the project root
4. Connect from Roblox Studio via the Rojo plugin
5. Press **Play** in Studio

### Manual import
1. Open Roblox Studio and create a new **Baseplate** place
2. Copy each `.lua` file into the corresponding Roblox service:
   - `src/client/*.client.lua` → `StarterPlayer > StarterPlayerScripts`
   - `src/server/*.server.lua` → `ServerScriptService`
   - `src/shared/*.lua` → `ReplicatedStorage` (as ModuleScripts)
3. Create the RemoteEvents folder in `ReplicatedStorage`:
   - `RemoteEvents/BoardPlane` (RemoteEvent)
   - `RemoteEvents/ExitPlane` (RemoteEvent)
   - `RemoteEvents/UpdatePlaneState` (RemoteEvent)
   - `RemoteEvents/FireWeapon` (RemoteEvent)
4. Press **Play**

## Physics Notes

Aerodynamic forces are computed each `Heartbeat` on the client and the resulting velocity/orientation are sent to the server at 20 Hz via `UpdatePlaneState`. The server applies them through `BodyVelocity` and `BodyGyro` constraints, keeping the simulation smooth for all players.

Lift = 0.5 × ρ × v² × CL × stallFactor
Drag = 0.5 × ρ × v² × CD
Air density decreases with altitude at a rate of `HeightDensityFalloff` per stud.
