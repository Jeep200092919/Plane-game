-- PlaneServer: Manages plane instances, seating, damage, and replication
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaneConfig = require(ReplicatedStorage:WaitForChild("PlaneConfig"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BoardPlaneEvent    = RemoteEvents:WaitForChild("BoardPlane")
local ExitPlaneEvent     = RemoteEvents:WaitForChild("ExitPlane")
local UpdatePlaneState   = RemoteEvents:WaitForChild("UpdatePlaneState")

-- Track which plane each player is piloting
local pilotMap = {}   -- [player] = planeModel
local planeMap = {}   -- [planeModel] = { config, health, pilot }

-- ─── Model builder ───────────────────────────────────────────────────────────

local function weld(part, root)
    local w = Instance.new("WeldConstraint")
    w.Part0 = root
    w.Part1 = part
    w.Parent = root
end

local function addPart(parent, name, size, color, cframe)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.BrickColor = color
    p.Material = Enum.Material.SmoothPlastic
    p.CFrame = cframe
    p.Parent = parent
    return p
end

local function buildPlaneModel(planeType, spawnCFrame)
    local cfg = PlaneConfig.Planes[planeType]
    local model = Instance.new("Model")
    model.Name = planeType .. "_Plane"

    -- Body (root part)
    local body = addPart(model, "Body", cfg.BodySize, cfg.BodyColor, spawnCFrame)
    body.Anchored = false
    model.PrimaryPart = body

    -- Cockpit
    local cockpitSize = Vector3.new(cfg.BodySize.X * 0.4, cfg.BodySize.Y * 0.8, cfg.BodySize.Z * 0.25)
    local cockpitCF = spawnCFrame * CFrame.new(0, cfg.BodySize.Y * 0.6, -cfg.BodySize.Z * 0.15)
    local cockpit = addPart(model, "Cockpit", cockpitSize, cfg.CockpitColor, cockpitCF)
    cockpit.Transparency = 0.3
    weld(cockpit, body)

    -- Wings (main)
    local wingOffset = Vector3.new(0, -cfg.BodySize.Y * 0.1, cfg.BodySize.Z * 0.05)
    local wingCF = spawnCFrame * CFrame.new(wingOffset)
    local wings = addPart(model, "Wings", cfg.WingSize, cfg.WingColor, wingCF)
    weld(wings, body)

    -- Tail fin (vertical)
    local tailFinCF = spawnCFrame * CFrame.new(0, cfg.TailSize.Y * 0.5, cfg.BodySize.Z * 0.45)
    local tailFin = addPart(model, "TailFin", cfg.TailSize, cfg.BodyColor, tailFinCF)
    weld(tailFin, body)

    -- Horizontal stabilizer
    local hStabSize = Vector3.new(cfg.TailSize.X * 0.75, cfg.TailSize.Z, cfg.BodySize.Z * 0.12)
    local hStabCF = spawnCFrame * CFrame.new(0, cfg.TailSize.Y * 0.1, cfg.BodySize.Z * 0.42)
    local hStab = addPart(model, "HStab", hStabSize, cfg.WingColor, hStabCF)
    weld(hStab, body)

    -- Nose cone
    local noseConeSize = Vector3.new(cfg.BodySize.X * 0.6, cfg.BodySize.Y * 0.6, cfg.BodySize.Z * 0.25)
    local noseCF = spawnCFrame * CFrame.new(0, 0, -cfg.BodySize.Z * 0.6)
    local nose = addPart(model, "Nose", noseConeSize, cfg.BodyColor, noseCF)
    weld(nose, body)

    -- Landing gear (left wheel)
    local gearSize = Vector3.new(0.6, 2, 0.6)
    local lgLCF = spawnCFrame * CFrame.new(-cfg.WingSize.X * 0.25, -cfg.BodySize.Y * 0.9, cfg.BodySize.Z * 0.1)
    local gearL = addPart(model, "GearLeft", gearSize, BrickColor.new("Black"), lgLCF)
    gearL.Shape = Enum.PartType.Cylinder
    weld(gearL, body)

    -- Landing gear (right wheel)
    local lgRCF = spawnCFrame * CFrame.new(cfg.WingSize.X * 0.25, -cfg.BodySize.Y * 0.9, cfg.BodySize.Z * 0.1)
    local gearR = addPart(model, "GearRight", gearSize, BrickColor.new("Black"), lgRCF)
    gearR.Shape = Enum.PartType.Cylinder
    weld(gearR, body)

    -- Tail wheel
    local twCF = spawnCFrame * CFrame.new(0, -cfg.BodySize.Y * 0.9, cfg.BodySize.Z * 0.45)
    local tailWheel = addPart(model, "GearTail", Vector3.new(0.4, 1, 0.4), BrickColor.new("Black"), twCF)
    tailWheel.Shape = Enum.PartType.Cylinder
    weld(tailWheel, body)

    -- Seat (VehicleSeat for pilot)
    local seat = Instance.new("VehicleSeat")
    seat.Name = "PilotSeat"
    seat.Size = Vector3.new(1.5, 0.5, 1.5)
    seat.CFrame = spawnCFrame * CFrame.new(0, cfg.BodySize.Y * 0.5, -cfg.BodySize.Z * 0.15)
    seat.Transparency = 1
    seat.MaxSpeed = 0   -- we control movement ourselves
    seat.Parent = model
    weld(seat, body)

    -- BodyGyro for rotation stabilization (controlled by client via UpdatePlaneState)
    local gyro = Instance.new("BodyGyro")
    gyro.Name = "PlaneGyro"
    gyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    gyro.P = 1e5
    gyro.D = 500
    gyro.CFrame = body.CFrame
    gyro.Parent = body

    -- BodyVelocity for thrust (also controlled by client state)
    local bv = Instance.new("BodyVelocity")
    bv.Name = "PlaneVelocity"
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = body

    -- Engine sound
    local sound = Instance.new("Sound")
    sound.Name = "EngineSound"
    sound.SoundId = cfg.EngineSound
    sound.Looped = true
    sound.Volume = 0
    sound.RollOffMaxDistance = 150
    sound.Parent = body

    -- Attribute: plane type
    model:SetAttribute("PlaneType", planeType)
    model:SetAttribute("Health", cfg.MaxHealth)

    model.Parent = workspace
    return model
end

-- ─── Spawn Planes ────────────────────────────────────────────────────────────

local SpawnPositions = {
    CFrame.new(0, 20, 0),
    CFrame.new(30, 20, 0),
    CFrame.new(-30, 20, 0),
}

local function spawnPlane(planeType, index)
    local spawnCF = SpawnPositions[index] or CFrame.new(index * 35, 20, 0)
    local model = buildPlaneModel(planeType, spawnCF)
    local cfg = PlaneConfig.Planes[planeType]
    planeMap[model] = {
        config  = cfg,
        health  = cfg.MaxHealth,
        pilot   = nil,
        type    = planeType,
        spawnCF = spawnCF,
    }
    return model
end

-- Spawn initial planes
local planes = {
    spawnPlane("Fighter", 1),
    spawnPlane("Biplane", 2),
}

-- ─── Board / Exit ────────────────────────────────────────────────────────────

local function getClosestPlane(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best, bestDist = nil, 15  -- within 15 studs
    for model, data in pairs(planeMap) do
        if not data.pilot then
            local body = model:FindFirstChild("Body")
            if body then
                local dist = (body.Position - hrp.Position).Magnitude
                if dist < bestDist then
                    best = model
                    bestDist = dist
                end
            end
        end
    end
    return best
end

BoardPlaneEvent.OnServerEvent:Connect(function(player)
    if pilotMap[player] then return end
    local character = player.Character
    if not character then return end
    local plane = getClosestPlane(character)
    if not plane then return end
    local data = planeMap[plane]
    if data.pilot then return end

    data.pilot = player
    pilotMap[player] = plane

    -- Weld player to seat
    local seat = plane:FindFirstChild("PilotSeat")
    if seat then
        seat:Sit(character:FindFirstChildOfClass("Humanoid"))
    end

    -- Disable landing gear collision when in air
    local sound = plane:FindFirstChild("Body") and plane.Body:FindFirstChild("EngineSound")
    if sound then sound:Play() end

    print(player.Name .. " boarded " .. plane.Name)
end)

ExitPlaneEvent.OnServerEvent:Connect(function(player)
    local plane = pilotMap[player]
    if not plane then return end
    local data = planeMap[plane]
    data.pilot = nil
    pilotMap[player] = nil

    -- Eject character
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.Sit = false end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local body = plane:FindFirstChild("Body")
        if hrp and body then
            hrp.CFrame = body.CFrame * CFrame.new(0, 5, 0)
            hrp.Velocity = body.Velocity * 0.3
        end
    end

    -- Stop velocity-based movement
    local body = plane:FindFirstChild("Body")
    if body then
        local bv = body:FindFirstChild("PlaneVelocity")
        if bv then bv.Velocity = Vector3.new(0, 0, 0) end
        local sound = body:FindFirstChild("EngineSound")
        if sound then sound:Stop() end
    end

    print(player.Name .. " exited plane")
end)

-- ─── State updates from client (physics applied server-side) ─────────────────

UpdatePlaneState.OnServerEvent:Connect(function(player, gyroCF, velocity, throttle)
    local plane = pilotMap[player]
    if not plane then return end
    local body = plane:FindFirstChild("Body")
    if not body then return end

    local gyro = body:FindFirstChild("PlaneGyro")
    local bv   = body:FindFirstChild("PlaneVelocity")
    if gyro then gyro.CFrame = gyroCF end
    if bv then bv.Velocity = velocity end

    -- Engine sound volume
    local sound = body:FindFirstChild("EngineSound")
    if sound then
        sound.Volume = math.clamp(throttle * 2, 0, 1)
        sound.PlaybackSpeed = 0.8 + throttle * 0.8
    end
end)

-- ─── Damage on collision ─────────────────────────────────────────────────────

local function handleCollision(plane, data, otherPart, relVelocity)
    local speed = relVelocity.Magnitude
    local minSpeed = PlaneConfig.CrashDamageMinSpeed or 60
    if speed < minSpeed then return end

    local damage = (speed - minSpeed) * (PlaneConfig.CrashDamageScale or 1.5)
    data.health = data.health - damage

    if data.health <= 0 then
        -- Explosion effect: fire RemoteEvent to all clients
        local body = plane:FindFirstChild("Body")
        local pos = body and body.Position or Vector3.new(0, 0, 0)

        -- Eject pilot if any
        if data.pilot then
            ExitPlaneEvent:FireClient(data.pilot)
            local pilot = data.pilot
            data.pilot = nil
            pilotMap[pilot] = nil
        end

        -- Destroy plane and respawn after delay
        plane:Destroy()
        planeMap[plane] = nil

        task.delay(PlaneConfig.RespawnDelay or 5, function()
            local newPlane = spawnPlane(data.type, 1)
            table.insert(planes, newPlane)
        end)
    end
end

-- Set up touch events on all plane bodies
local function setupCollision(plane, data)
    local body = plane:FindFirstChild("Body")
    if not body then return end
    body.Touched:Connect(function(otherPart)
        if otherPart:IsDescendantOf(plane) then return end
        -- Skip player characters
        local charCheck = Players:GetPlayerFromCharacter(otherPart.Parent)
        if charCheck then return end
        local relVel = body.Velocity - (otherPart.Velocity or Vector3.new())
        handleCollision(plane, data, otherPart, relVel)
    end)
end

for _, plane in ipairs(planes) do
    setupCollision(plane, planeMap[plane])
end

-- ─── Player cleanup ──────────────────────────────────────────────────────────

Players.PlayerRemoving:Connect(function(player)
    if pilotMap[player] then
        ExitPlaneEvent:FireClient(player)
        local plane = pilotMap[player]
        if plane and planeMap[plane] then
            planeMap[plane].pilot = nil
        end
        pilotMap[player] = nil
    end
end)

print("[PlaneServer] Initialized with " .. #planes .. " planes.")
