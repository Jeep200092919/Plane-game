-- SpawnManager: Sets up the map terrain, runway, and spawn pads
local Players = game:GetService("Players")

-- ─── Terrain setup ───────────────────────────────────────────────────────────

local terrain = workspace:WaitForChild("Terrain")

-- Fill sea level ground
local mapSize = 2048
terrain:FillBlock(
    CFrame.new(0, -10, 0),
    Vector3.new(mapSize, 20, mapSize),
    Enum.Material.Grass
)

-- Ocean around the edges
terrain:FillBlock(
    CFrame.new(0, -30, 0),
    Vector3.new(mapSize + 512, 20, mapSize + 512),
    Enum.Material.Water
)

-- Mountains
local function addMountain(cx, cz, radius, height)
    for dx = -radius, radius, 4 do
        for dz = -radius, radius, 4 do
            local dist = math.sqrt(dx*dx + dz*dz)
            if dist < radius then
                local h = height * (1 - dist / radius)^1.5
                terrain:FillCylinder(
                    CFrame.new(cx + dx, h * 0.5, cz + dz),
                    h, 5,
                    Enum.Material.Rock
                )
            end
        end
    end
end

addMountain(300, 400, 120, 250)
addMountain(-400, -300, 90, 180)
addMountain(600, -200, 70, 140)

-- ─── Runway ───────────────────────────────────────────────────────────────────

local function makePart(parent, name, size, color, cframe, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.BrickColor = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CFrame = cframe
    p.Parent = parent
    return p
end

local runwayFolder = Instance.new("Folder")
runwayFolder.Name = "Runway"
runwayFolder.Parent = workspace

-- Main runway surface
makePart(runwayFolder, "RunwaySurface",
    Vector3.new(30, 1, 300),
    BrickColor.new("Dark grey"),
    CFrame.new(0, 0.5, 0),
    Enum.Material.SmoothPlastic
)

-- Center line markings
for i = -6, 6 do
    makePart(runwayFolder, "CenterLine_" .. i,
        Vector3.new(1.5, 0.1, 18),
        BrickColor.new("White"),
        CFrame.new(0, 1.05, i * 22),
        Enum.Material.Neon
    )
end

-- Runway edge lights
for i = -14, 14 do
    local z = i * 10
    makePart(runwayFolder, "LightL_" .. i,
        Vector3.new(0.5, 0.5, 0.5),
        BrickColor.new("Bright yellow"),
        CFrame.new(-16, 1.3, z),
        Enum.Material.Neon
    )
    makePart(runwayFolder, "LightR_" .. i,
        Vector3.new(0.5, 0.5, 0.5),
        BrickColor.new("Bright yellow"),
        CFrame.new(16, 1.3, z),
        Enum.Material.Neon
    )
end

-- Hangar
local hangarFolder = Instance.new("Folder")
hangarFolder.Name = "Hangar"
hangarFolder.Parent = workspace

-- Hangar walls
makePart(hangarFolder, "HangarFloor",  Vector3.new(50, 1, 40),    BrickColor.new("Medium stone grey"), CFrame.new(60, 0.5, 0))
makePart(hangarFolder, "HangarBack",   Vector3.new(50, 20, 1),    BrickColor.new("Medium stone grey"), CFrame.new(60, 10.5, 20))
makePart(hangarFolder, "HangarLeft",   Vector3.new(1, 20, 40),    BrickColor.new("Medium stone grey"), CFrame.new(35, 10.5, 0))
makePart(hangarFolder, "HangarRight",  Vector3.new(1, 20, 40),    BrickColor.new("Medium stone grey"), CFrame.new(85, 10.5, 0))
makePart(hangarFolder, "HangarRoof",   Vector3.new(50, 1, 40),    BrickColor.new("Dark grey"),          CFrame.new(60, 21, 0))

-- ─── Spawn location ───────────────────────────────────────────────────────────

local spawnLoc = Instance.new("SpawnLocation")
spawnLoc.Name = "Spawn"
spawnLoc.Size = Vector3.new(8, 1, 8)
spawnLoc.BrickColor = BrickColor.new("Bright blue")
spawnLoc.CFrame = CFrame.new(0, 2, -60)
spawnLoc.Anchored = true
spawnLoc.Parent = workspace

-- Spawn indicator sign
local signPart = makePart(workspace, "SpawnSign",
    Vector3.new(8, 2, 0.5),
    BrickColor.new("Bright blue"),
    CFrame.new(0, 4, -65)
)
local surfaceGui = Instance.new("SurfaceGui")
surfaceGui.Face = Enum.NormalId.Front
surfaceGui.Parent = signPart
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "Press F near a plane to board!"
label.TextColor3 = Color3.new(1, 1, 1)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Parent = surfaceGui

-- ─── Lighting / Sky ───────────────────────────────────────────────────────────

local lighting = game:GetService("Lighting")
lighting.Brightness = 2
lighting.ClockTime = 10
lighting.FogEnd = 3000
lighting.FogColor = Color3.fromRGB(180, 210, 240)

local sky = Instance.new("Sky")
sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
sky.Parent = lighting

print("[SpawnManager] Map loaded.")
