-- PlaneGui (LocalScript): HUD showing speed, altitude, throttle, and status
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ExitPlaneEvent = RemoteEvents:WaitForChild("ExitPlane")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ─── Build GUI ────────────────────────────────────────────────────────────────

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlaneHUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- HUD container (bottom-left)
local hudFrame = Instance.new("Frame")
hudFrame.Name = "HUD"
hudFrame.Size = UDim2.new(0, 260, 0, 200)
hudFrame.Position = UDim2.new(0, 16, 1, -216)
hudFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
hudFrame.BackgroundTransparency = 0.45
hudFrame.BorderSizePixel = 0
hudFrame.Visible = false
hudFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = hudFrame

local function makeLabel(parent, name, pos, text, size)
    local lbl = Instance.new("TextLabel")
    lbl.Name = name
    lbl.Size = UDim2.new(1, -16, 0, size or 22)
    lbl.Position = pos
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Code
    lbl.TextSize = size or 18
    lbl.Parent = parent
    return lbl
end

local lblTitle    = makeLabel(hudFrame, "Title",    UDim2.new(0, 8, 0,  8),  "PLANE HUD", 20)
lblTitle.TextColor3 = Color3.fromRGB(100, 220, 255)
lblTitle.Font = Enum.Font.GothamBold

local lblSpeed    = makeLabel(hudFrame, "Speed",    UDim2.new(0, 8, 0, 38), "Speed:    --- kn")
local lblAlt      = makeLabel(hudFrame, "Altitude", UDim2.new(0, 8, 0, 64), "Altitude: ---  m")
local lblThrottle = makeLabel(hudFrame, "Throttle", UDim2.new(0, 8, 0, 90), "Throttle: ---  %")
local lblGear     = makeLabel(hudFrame, "Gear",     UDim2.new(0, 8, 0,116), "Gear:     DOWN")
lblGear.TextColor3 = Color3.fromRGB(100, 255, 100)

local lblStall    = makeLabel(hudFrame, "Stall",    UDim2.new(0, 8, 0,142), "")
lblStall.TextColor3 = Color3.fromRGB(255, 80, 80)
lblStall.Font = Enum.Font.GothamBold

local lblControls = makeLabel(hudFrame, "Controls", UDim2.new(0, 8, 0,168), "W/S=Pitch  A/D=Roll  Q/E=Yaw", 13)
lblControls.TextColor3 = Color3.fromRGB(180, 180, 180)

-- "Board" hint (center screen)
local boardHint = Instance.new("TextLabel")
boardHint.Name = "BoardHint"
boardHint.Size = UDim2.new(0, 320, 0, 40)
boardHint.Position = UDim2.new(0.5, -160, 0.8, 0)
boardHint.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
boardHint.BackgroundTransparency = 0.5
boardHint.BorderSizePixel = 0
boardHint.Text = "Press F to board plane"
boardHint.TextColor3 = Color3.new(1, 1, 1)
boardHint.TextScaled = true
boardHint.Font = Enum.Font.GothamBold
boardHint.Visible = false
boardHint.Parent = screenGui
Instance.new("UICorner", boardHint).CornerRadius = UDim.new(0, 6)

-- ─── Throttle bar ─────────────────────────────────────────────────────────────

local throttleBarBg = Instance.new("Frame")
throttleBarBg.Name = "ThrottleBg"
throttleBarBg.Size = UDim2.new(0, 20, 0, 160)
throttleBarBg.Position = UDim2.new(0, 270, 1, -180)
throttleBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
throttleBarBg.BackgroundTransparency = 0.4
throttleBarBg.BorderSizePixel = 0
throttleBarBg.Visible = false
throttleBarBg.Parent = screenGui
Instance.new("UICorner", throttleBarBg).CornerRadius = UDim.new(0, 4)

local throttleBar = Instance.new("Frame")
throttleBar.Name = "ThrottleBar"
throttleBar.Size = UDim2.new(1, 0, 0, 0)
throttleBar.Position = UDim2.new(0, 0, 1, 0)
throttleBar.AnchorPoint = Vector2.new(0, 1)
throttleBar.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
throttleBar.BorderSizePixel = 0
throttleBar.Parent = throttleBarBg
Instance.new("UICorner", throttleBar).CornerRadius = UDim.new(0, 4)

-- ─── State tracking ──────────────────────────────────────────────────────────

local inPlane   = false
local gearDown  = true

local function findCurrentPlaneBody()
    local character = player.Character
    if not character then return nil end
    for _, seat in ipairs(workspace:GetDescendants()) do
        if seat.Name == "PilotSeat" and seat:IsA("VehicleSeat") then
            if seat.Occupant and seat.Occupant.Parent == character then
                return seat.Parent:FindFirstChild("Body")
            end
        end
    end
    return nil
end

local function nearbyPlane()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "PilotSeat" and obj:IsA("VehicleSeat") then
            if not obj.Occupant then
                local body = obj.Parent and obj.Parent:FindFirstChild("Body")
                if body and (body.Position - hrp.Position).Magnitude < 12 then
                    return true
                end
            end
        end
    end
    return false
end

-- ─── Update loop ─────────────────────────────────────────────────────────────

local PlaneConfig = require(ReplicatedStorage:WaitForChild("PlaneConfig"))

RunService.Heartbeat:Connect(function()
    local planeBody = findCurrentPlaneBody()
    inPlane = planeBody ~= nil

    hudFrame.Visible      = inPlane
    throttleBarBg.Visible = inPlane

    if inPlane then
        local vel     = planeBody.Velocity
        local speed   = vel.Magnitude
        local knots   = math.floor(speed * 0.5924)  -- studs/s to knots approx
        local alt     = math.floor(planeBody.Position.Y)

        -- Read throttle from BodyVelocity velocity magnitude (approximate)
        local bv = planeBody:FindFirstChild("PlaneVelocity")
        local bvVel = bv and bv.Velocity or Vector3.new()
        local cfg = PlaneConfig.Planes[planeBody.Parent:GetAttribute("PlaneType") or "Fighter"]
        local throttlePct = math.floor(math.clamp(bvVel.Magnitude / (cfg and cfg.MaxSpeed or 400), 0, 1) * 100)

        lblSpeed.Text    = string.format("Speed:    %3d kn", knots)
        lblAlt.Text      = string.format("Altitude: %4d m", alt)
        lblThrottle.Text = string.format("Throttle: %3d %%", throttlePct)

        -- Stall warning
        local lookVec = planeBody.CFrame.LookVector
        local aoaDeg  = speed > 1 and math.deg(math.acos(math.clamp(vel.Unit:Dot(lookVec), -1, 1))) or 0
        local stallAngle = cfg and cfg.StallAngle or 25
        if aoaDeg > stallAngle and speed > 20 then
            lblStall.Text = "!!! STALL !!!"
        else
            lblStall.Text = ""
        end

        -- Throttle bar fill
        throttleBar.Size = UDim2.new(1, 0, throttlePct / 100, 0)
        throttleBar.Position = UDim2.new(0, 0, 1, 0)
    end

    -- Boarding hint
    boardHint.Visible = not inPlane and nearbyPlane()
end)

ExitPlaneEvent.OnClientEvent:Connect(function()
    inPlane = false
    hudFrame.Visible      = false
    throttleBarBg.Visible = false
end)

print("[PlaneGui] Ready.")
