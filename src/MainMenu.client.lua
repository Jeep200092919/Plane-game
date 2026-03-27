-- MainMenu.client.lua (LocalScript → StarterPlayerScripts)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ─── Intro Splash ─────────────────────────────────────────────────────────────

local splashGui = Instance.new("ScreenGui")
splashGui.Name = "IntroSplash"
splashGui.ResetOnSpawn = false
splashGui.IgnoreGuiInset = true
splashGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
splashGui.Parent = playerGui

local splashBg = Instance.new("Frame")
splashBg.Size = UDim2.new(1, 0, 1, 0)
splashBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
splashBg.BorderSizePixel = 0
splashBg.Parent = splashGui

local splashLabel = Instance.new("TextLabel")
splashLabel.Size = UDim2.new(0.8, 0, 0, 60)
splashLabel.AnchorPoint = Vector2.new(0.5, 0.5)
splashLabel.Position = UDim2.new(0.5, 0, 0.48, 0)
splashLabel.BackgroundTransparency = 1
splashLabel.Text = "Powered by PrimorixStudios"
splashLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
splashLabel.TextTransparency = 1
splashLabel.Font = Enum.Font.GothamBlack
splashLabel.TextSize = 32
splashLabel.Parent = splashBg

local splashSub = Instance.new("TextLabel")
splashSub.Size = UDim2.new(0.8, 0, 0, 28)
splashSub.AnchorPoint = Vector2.new(0.5, 0.5)
splashSub.Position = UDim2.new(0.5, 0, 0.57, 0)
splashSub.BackgroundTransparency = 1
splashSub.Text = "& Roblox Engine"
splashSub.TextColor3 = Color3.fromRGB(160, 210, 255)
splashSub.TextTransparency = 1
splashSub.Font = Enum.Font.GothamMedium
splashSub.TextSize = 20
splashSub.Parent = splashBg

-- Fade in text
task.wait(0.4)
TweenService:Create(splashLabel, TweenInfo.new(0.8), { TextTransparency = 0 }):Play()
TweenService:Create(splashSub,   TweenInfo.new(0.8), { TextTransparency = 0 }):Play()

-- Hold for 5 seconds total (0.4 wait + 0.8 fade-in + ~3.8 hold = 5s) then fade out
task.wait(3.8)
TweenService:Create(splashLabel, TweenInfo.new(0.6), { TextTransparency = 1 }):Play()
TweenService:Create(splashSub,   TweenInfo.new(0.6), { TextTransparency = 1 }):Play()
TweenService:Create(splashBg,    TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
task.wait(0.65)
splashGui:Destroy()

-- ─── ScreenGui ────────────────────────────────────────────────────────────────

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ─── Background ───────────────────────────────────────────────────────────────

local bg = Instance.new("Frame")
bg.Name = "Background"
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(10, 18, 35)
bg.BorderSizePixel = 0
bg.Parent = screenGui

-- Sky gradient
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 10, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 50, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 120, 180)),
})
gradient.Rotation = 90
gradient.Parent = bg

-- ─── Fighter Jet (ViewportFrame) ─────────────────────────────────────────────

local viewport = Instance.new("ViewportFrame")
viewport.Size = UDim2.new(1, 0, 1, 0)
viewport.Position = UDim2.new(0, 0, 0, 0)
viewport.BackgroundTransparency = 1
viewport.LightColor = Color3.fromRGB(200, 220, 255)
viewport.LightDirection = Vector3.new(-1, -2, -1)
viewport.Ambient = Color3.fromRGB(60, 90, 140)
viewport.ZIndex = 2
viewport.Parent = bg

local planeModel = Instance.new("Model")
planeModel.Parent = viewport

local function vp(name, size, color, cf, trans, mat)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.BrickColor = color
    p.Material = mat or Enum.Material.SmoothPlastic
    p.CFrame = cf
    p.Anchored = true
    p.CastShadow = false
    p.Transparency = trans or 0
    p.Parent = planeModel
    return p
end

local o = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(30), math.rad(-12))

-- Fuselage
vp("Body",    Vector3.new(6,   1.5, 16),  BrickColor.new("Medium stone grey"), o * CFrame.new(0, 0, 0))
-- Cockpit
vp("Cockpit", Vector3.new(2.2, 1.1, 3.8), BrickColor.new("Cyan"),              o * CFrame.new(0, 1.15, -2.5), 0.25)
-- Main wings (left & right as one wide part)
vp("Wings",   Vector3.new(26,  0.35, 6),  BrickColor.new("Dark grey"),         o * CFrame.new(0, -0.2, 0.8))
-- Wing detail stripe
vp("WingLine",Vector3.new(24,  0.1, 0.5), BrickColor.new("Bright blue"),       o * CFrame.new(0, 0, 0.5), 0, Enum.Material.Neon)
-- Tail vertical fin
vp("TailFin", Vector3.new(7,   3.2, 0.5), BrickColor.new("Medium stone grey"), o * CFrame.new(0, 1.6, 7.0))
-- Horizontal stabilisers
vp("HStabL",  Vector3.new(5.5, 0.3, 1.8), BrickColor.new("Dark grey"),         o * CFrame.new(-3.5, 0.2, 6.8))
vp("HStabR",  Vector3.new(5.5, 0.3, 1.8), BrickColor.new("Dark grey"),         o * CFrame.new( 3.5, 0.2, 6.8))
-- Nose cone
vp("Nose",    Vector3.new(3,   0.85, 4),  BrickColor.new("Dark grey"),          o * CFrame.new(0, 0, -9.8))
-- Engine nozzle
vp("Nozzle",  Vector3.new(3,   3,   2),   BrickColor.new("Dark grey"),          o * CFrame.new(0, 0, 8.5), 0, Enum.Material.Metal)
-- Nozzle glow
vp("NozzleGlow", Vector3.new(2, 2, 0.4),  BrickColor.new("Bright orange"),     o * CFrame.new(0, 0, 9.6), 0.3, Enum.Material.Neon)
-- Air intakes (left & right)
vp("IntakeL", Vector3.new(1.2, 1.8, 3.5), BrickColor.new("Dark grey"),         o * CFrame.new(-2.2, -0.4, 1.0))
vp("IntakeR", Vector3.new(1.2, 1.8, 3.5), BrickColor.new("Dark grey"),         o * CFrame.new( 2.2, -0.4, 1.0))
-- Cockpit frame
vp("Canopy",  Vector3.new(2.0, 0.15, 3.6),BrickColor.new("Dark grey"),         o * CFrame.new(0, 1.72, -2.5))
-- Wing missiles (left & right)
vp("MissileL",Vector3.new(0.5, 0.5, 4),   BrickColor.new("Bright red"),        o * CFrame.new(-9, -0.3, 0.5))
vp("MissileR",Vector3.new(0.5, 0.5, 4),   BrickColor.new("Bright red"),        o * CFrame.new( 9, -0.3, 0.5))

-- Camera: angled view showing the jet dramatically on the left side
local vpCam = Instance.new("Camera")
vpCam.FieldOfView = 55
vpCam.Parent = viewport
viewport.CurrentCamera = vpCam

-- Slow camera orbit
local camAngle = 0
RunService.RenderStepped:Connect(function(dt)
    camAngle = camAngle + dt * 0.12   -- very slow rotation
    local radius = 38
    local cx = math.sin(camAngle) * radius * 0.3 + 14  -- drift slightly left-right
    local cz = math.cos(camAngle) * radius + 5
    vpCam.CFrame = CFrame.lookAt(
        Vector3.new(cx, 10, cz),
        Vector3.new(0, 0, 0)
    )
end)

-- ─── Clouds (decorative bars) ─────────────────────────────────────────────────

local function makeCloud(yPos, width, xStart, speed, alpha)
    local cloud = Instance.new("Frame")
    cloud.Size = UDim2.new(0, width, 0, 18)
    cloud.Position = UDim2.new(0, xStart, 0, yPos)
    cloud.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    cloud.BackgroundTransparency = alpha
    cloud.BorderSizePixel = 0
    cloud.Parent = bg
    Instance.new("UICorner", cloud).CornerRadius = UDim.new(1, 0)

    -- Animate cloud drifting right
    local function drift()
        cloud.Position = UDim2.new(0, -width - 10, 0, yPos)
        local tween = TweenService:Create(cloud,
            TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1),
            { Position = UDim2.new(1, 20, 0, yPos) }
        )
        tween:Play()
    end
    drift()
    return cloud
end

makeCloud(80,  220, 100,  28, 0.82)
makeCloud(150, 160, 500,  34, 0.86)
makeCloud(220, 300, 200,  40, 0.80)
makeCloud(310,  90, 700,  22, 0.88)
makeCloud(400, 200, 350,  45, 0.84)

-- ─── Center Panel ─────────────────────────────────────────────────────────────

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 380, 0, 480)
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)
panel.BackgroundColor3 = Color3.fromRGB(8, 16, 32)
panel.BackgroundTransparency = 0.25
panel.BorderSizePixel = 0
panel.Parent = screenGui

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 16)

-- Panel border glow
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 160, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.4
stroke.Parent = panel

-- ─── Title ────────────────────────────────────────────────────────────────────

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 70)
titleLabel.Position = UDim2.new(0, 0, 0, 28)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PLANE GAME"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 48
titleLabel.Parent = panel

-- Title glow effect (duplicate layer)
local titleGlow = titleLabel:Clone()
titleGlow.TextColor3 = Color3.fromRGB(100, 190, 255)
titleGlow.TextTransparency = 0.6
titleGlow.ZIndex = titleLabel.ZIndex - 1
titleGlow.Parent = panel

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(1, 0, 0, 22)
subtitle.Position = UDim2.new(0, 0, 0, 100)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Take to the skies"
subtitle.TextColor3 = Color3.fromRGB(160, 210, 255)
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 16
subtitle.Parent = panel

-- Divider line
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.7, 0, 0, 1)
divider.Position = UDim2.new(0.15, 0, 0, 138)
divider.BackgroundColor3 = Color3.fromRGB(80, 140, 220)
divider.BackgroundTransparency = 0.5
divider.BorderSizePixel = 0
divider.Parent = panel

-- ─── Button factory ───────────────────────────────────────────────────────────

local function makeButton(parent, name, text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 280, 0, 52)
    btn.AnchorPoint = Vector2.new(0.5, 0)
    btn.Position = UDim2.new(0.5, 0, 0, yPos)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    -- Hover/press animations
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {
            BackgroundColor3 = color:Lerp(Color3.new(1,1,1), 0.15),
            Size = UDim2.new(0, 292, 0, 52),
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {
            BackgroundColor3 = color,
            Size = UDim2.new(0, 280, 0, 52),
        }):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.07), {
            Size = UDim2.new(0, 272, 0, 48),
        }):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.07), {
            Size = UDim2.new(0, 280, 0, 52),
        }):Play()
    end)

    return btn
end

local playBtn     = makeButton(panel, "PlayBtn",     "PLAY",     160, Color3.fromRGB(30, 140, 255))
local settingsBtn = makeButton(panel, "SettingsBtn", "SETTINGS", 226, Color3.fromRGB(50, 65, 95))
local creditsBtn  = makeButton(panel, "CreditsBtn",  "CREDITS",  292, Color3.fromRGB(50, 65, 95))
local quitBtn     = makeButton(panel, "QuitBtn",     "QUIT",     358, Color3.fromRGB(160, 40, 40))

-- ─── Settings Panel ───────────────────────────────────────────────────────────

local settingsPanel = Instance.new("Frame")
settingsPanel.Name = "SettingsPanel"
settingsPanel.Size = UDim2.new(0, 380, 0, 480)
settingsPanel.AnchorPoint = Vector2.new(0.5, 0.5)
settingsPanel.Position = UDim2.new(0.5, 500, 0.5, 0)  -- off-screen right
settingsPanel.BackgroundColor3 = Color3.fromRGB(8, 16, 32)
settingsPanel.BackgroundTransparency = 0.25
settingsPanel.BorderSizePixel = 0
settingsPanel.Visible = false
settingsPanel.Parent = screenGui
Instance.new("UICorner", settingsPanel).CornerRadius = UDim.new(0, 16)
local sStroke = stroke:Clone(); sStroke.Parent = settingsPanel

local sTitle = Instance.new("TextLabel")
sTitle.Size = UDim2.new(1, 0, 0, 60)
sTitle.Position = UDim2.new(0, 0, 0, 24)
sTitle.BackgroundTransparency = 1
sTitle.Text = "SETTINGS"
sTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
sTitle.Font = Enum.Font.GothamBlack
sTitle.TextSize = 36
sTitle.Parent = settingsPanel

-- Toggle row helper
local function makeToggle(parent, labelText, yPos, default)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0, 320, 0, 44)
    row.AnchorPoint = Vector2.new(0.5, 0)
    row.Position = UDim2.new(0.5, 0, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(210, 225, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 17
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local state = default
    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(0, 56, 0, 28)
    trackBg.AnchorPoint = Vector2.new(1, 0.5)
    trackBg.Position = UDim2.new(1, 0, 0.5, 0)
    trackBg.BackgroundColor3 = state and Color3.fromRGB(30, 140, 255) or Color3.fromRGB(60, 60, 80)
    trackBg.BorderSizePixel = 0
    trackBg.Parent = row
    Instance.new("UICorner", trackBg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = state and UDim2.new(0.75, 0, 0.5, 0) or UDim2.new(0.25, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.Parent = trackBg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = trackBg

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(trackBg, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Color3.fromRGB(30, 140, 255) or Color3.fromRGB(60, 60, 80)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(0.75, 0, 0.5, 0) or UDim2.new(0.25, 0, 0.5, 0)
        }):Play()
    end)

    return row
end

-- Slider helper
local function makeSlider(parent, labelText, yPos, default)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0, 320, 0, 54)
    row.AnchorPoint = Vector2.new(0.5, 0)
    row.Position = UDim2.new(0.5, 0, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(210, 225, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 17
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 0, 34)
    track.BackgroundColor3 = Color3.fromRGB(40, 55, 85)
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(default, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(30, 140, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 18, 0, 18)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.Position = UDim2.new(default, 0, 0.5, 0)
    handle.BackgroundColor3 = Color3.new(1,1,1)
    handle.BorderSizePixel = 0
    handle.ZIndex = 2
    handle.Parent = track
    Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)

    return row
end

makeToggle(settingsPanel, "Music",         100, true)
makeToggle(settingsPanel, "Sound Effects", 154, true)

-- Show FPS toggle (returns the row so we can grab the button state)
local fpsEnabled = false
local fpsRow = makeToggle(settingsPanel, "Show FPS", 208, false)

-- FPS counter label (top-right corner, always in screenGui)
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPSCounter"
fpsLabel.Size = UDim2.new(0, 100, 0, 28)
fpsLabel.Position = UDim2.new(1, -110, 0, 10)
fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsLabel.BackgroundTransparency = 0.45
fpsLabel.BorderSizePixel = 0
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextSize = 16
fpsLabel.Visible = false
fpsLabel.ZIndex = 10
fpsLabel.Parent = screenGui
Instance.new("UICorner", fpsLabel).CornerRadius = UDim.new(0, 6)

-- Wire toggle to fpsEnabled flag
local fpsToggleBtn = fpsRow:FindFirstChildWhichIsA("Frame", true)
    and fpsRow:FindFirstChildWhichIsA("Frame"):FindFirstChildOfClass("TextButton")
-- Re-use makeToggle's returned row; patch the click by overriding via a separate toggle tracker
do
    -- Find the TextButton inside the toggle track inside fpsRow
    local trackFrame = fpsRow:FindFirstChildWhichIsA("Frame")
    if trackFrame then
        local innerBtn = trackFrame:FindFirstChildOfClass("TextButton")
        if innerBtn then
            innerBtn.MouseButton1Click:Connect(function()
                -- State flips inside makeToggle already; we just mirror it
                fpsEnabled = not fpsEnabled
                fpsLabel.Visible = fpsEnabled
            end)
        end
    end
end

-- FPS update loop
local frameCount = 0
local elapsed = 0
RunService.RenderStepped:Connect(function(dt)
    if not fpsEnabled then return end
    frameCount += 1
    elapsed += dt
    if elapsed >= 0.5 then
        local fps = math.round(frameCount / elapsed)
        fpsLabel.Text = "FPS: " .. fps
        -- Color-code: green ≥60, yellow 30-59, red <30
        if fps >= 60 then
            fpsLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
        elseif fps >= 30 then
            fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 60)
        else
            fpsLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
        frameCount = 0
        elapsed = 0
    end
end)

makeSlider(settingsPanel, "Music Volume",   268, 0.7)
makeSlider(settingsPanel, "SFX Volume",     338, 0.9)

local sBackBtn = makeButton(settingsPanel, "BackBtn", "BACK", 410, Color3.fromRGB(50, 65, 95))

-- ─── Credits Panel ────────────────────────────────────────────────────────────

local creditsPanel = Instance.new("Frame")
creditsPanel.Name = "CreditsPanel"
creditsPanel.Size = UDim2.new(0, 380, 0, 480)
creditsPanel.AnchorPoint = Vector2.new(0.5, 0.5)
creditsPanel.Position = UDim2.new(0.5, 500, 0.5, 0)
creditsPanel.BackgroundColor3 = Color3.fromRGB(8, 16, 32)
creditsPanel.BackgroundTransparency = 0.25
creditsPanel.BorderSizePixel = 0
creditsPanel.Visible = false
creditsPanel.Parent = screenGui
Instance.new("UICorner", creditsPanel).CornerRadius = UDim.new(0, 16)
local cStroke = stroke:Clone(); cStroke.Parent = creditsPanel

local cTitle = Instance.new("TextLabel")
cTitle.Size = UDim2.new(1, 0, 0, 60)
cTitle.Position = UDim2.new(0, 0, 0, 24)
cTitle.BackgroundTransparency = 1
cTitle.Text = "CREDITS"
cTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
cTitle.Font = Enum.Font.GothamBlack
cTitle.TextSize = 36
cTitle.Parent = creditsPanel

local creditsText = Instance.new("TextLabel")
creditsText.Size = UDim2.new(0.85, 0, 0, 280)
creditsText.AnchorPoint = Vector2.new(0.5, 0)
creditsText.Position = UDim2.new(0.5, 0, 0, 100)
creditsText.BackgroundTransparency = 1
creditsText.Text = "Game Design\nGabrielmanso2013\n\nProgramming\nGabrielmanso2013\n\nStudio\nPrimorixStudios\n\nSpecial Thanks\nRoblox Community"
creditsText.TextColor3 = Color3.fromRGB(180, 210, 255)
creditsText.Font = Enum.Font.Gotham
creditsText.TextSize = 18
creditsText.TextYAlignment = Enum.TextYAlignment.Top
creditsText.Parent = creditsPanel

local cBackBtn = makeButton(creditsPanel, "BackBtn", "BACK", 410, Color3.fromRGB(50, 65, 95))

-- ─── Panel transitions ────────────────────────────────────────────────────────

local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function showPanel(panelToShow, panelToHide)
    panelToShow.Visible = true
    TweenService:Create(panelToHide, TWEEN_INFO, { Position = UDim2.new(0.5, -500, 0.5, 0) }):Play()
    TweenService:Create(panelToShow, TWEEN_INFO, { Position = UDim2.new(0.5, 0, 0.5, 0) }):Play()
    task.delay(0.35, function() panelToHide.Visible = false end)
end

settingsBtn.MouseButton1Click:Connect(function()
    settingsPanel.Position = UDim2.new(0.5, 500, 0.5, 0)
    showPanel(settingsPanel, panel)
end)

creditsBtn.MouseButton1Click:Connect(function()
    creditsPanel.Position = UDim2.new(0.5, 500, 0.5, 0)
    showPanel(creditsPanel, panel)
end)

sBackBtn.MouseButton1Click:Connect(function()
    panel.Position = UDim2.new(0.5, -500, 0.5, 0)
    panel.Visible = true
    showPanel(panel, settingsPanel)
end)

cBackBtn.MouseButton1Click:Connect(function()
    panel.Position = UDim2.new(0.5, -500, 0.5, 0)
    panel.Visible = true
    showPanel(panel, creditsPanel)
end)

-- ─── Play button ─────────────────────────────────────────────────────────────

local function showWelcomeMessage()
    local wGui = Instance.new("ScreenGui")
    wGui.Name = "WelcomeMsg"
    wGui.ResetOnSpawn = false
    wGui.IgnoreGuiInset = true
    wGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    wGui.Parent = playerGui

    -- Card
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 420, 0, 130)
    card.AnchorPoint = Vector2.new(0.5, 0)
    card.Position = UDim2.new(0.5, 0, -0.2, 0)   -- starts above screen
    card.BackgroundColor3 = Color3.fromRGB(8, 16, 32)
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel = 0
    card.Parent = wGui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = Color3.fromRGB(80, 160, 255)
    cardStroke.Thickness = 1.5
    cardStroke.Transparency = 0.3
    cardStroke.Parent = card

    -- Icon row
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 36, 0, 36)
    icon.Position = UDim2.new(0, 14, 0, 12)
    icon.BackgroundTransparency = 1
    icon.Text = "✈"
    icon.TextColor3 = Color3.fromRGB(100, 190, 255)
    icon.Font = Enum.Font.GothamBlack
    icon.TextSize = 28
    icon.Parent = card

    -- Welcome line
    local line1 = Instance.new("TextLabel")
    line1.Size = UDim2.new(1, -60, 0, 30)
    line1.Position = UDim2.new(0, 54, 0, 10)
    line1.BackgroundTransparency = 1
    line1.Text = "Welcome to the game!"
    line1.TextColor3 = Color3.fromRGB(255, 255, 255)
    line1.Font = Enum.Font.GothamBold
    line1.TextSize = 20
    line1.TextXAlignment = Enum.TextXAlignment.Left
    line1.Parent = card

    -- Credits line
    local line2 = Instance.new("TextLabel")
    line2.Size = UDim2.new(1, -60, 0, 22)
    line2.Position = UDim2.new(0, 54, 0, 38)
    line2.BackgroundTransparency = 1
    line2.Text = "Created by Gabrielmanso2013  •  Powered by PrimorixStudios"
    line2.TextColor3 = Color3.fromRGB(140, 190, 255)
    line2.Font = Enum.Font.Gotham
    line2.TextSize = 13
    line2.TextXAlignment = Enum.TextXAlignment.Left
    line2.Parent = card

    -- Tip line
    local line3 = Instance.new("TextLabel")
    line3.Size = UDim2.new(1, -20, 0, 22)
    line3.Position = UDim2.new(0, 10, 0, 72)
    line3.BackgroundTransparency = 1
    line3.Text = "Try hitting the enemy plane — enjoy the game ✔️"
    line3.TextColor3 = Color3.fromRGB(100, 220, 130)
    line3.Font = Enum.Font.GothamMedium
    line3.TextSize = 15
    line3.TextXAlignment = Enum.TextXAlignment.Center
    line3.Parent = card

    -- Divider above tip
    local div = Instance.new("Frame")
    div.Size = UDim2.new(0.88, 0, 0, 1)
    div.AnchorPoint = Vector2.new(0.5, 0)
    div.Position = UDim2.new(0.5, 0, 0, 66)
    div.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
    div.BackgroundTransparency = 0.5
    div.BorderSizePixel = 0
    div.Parent = card

    -- Slide down into view
    TweenService:Create(card, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0, 24),
    }):Play()

    -- Hold then slide back up and destroy
    task.delay(4.5, function()
        TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, -0.2, 0),
        }):Play()
        task.delay(0.45, function()
            wGui:Destroy()
        end)
    end)
end

playBtn.MouseButton1Click:Connect(function()
    -- Fade out menu then hide it
    TweenService:Create(bg, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(panel, TweenInfo.new(0.4), {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.4, 0),
    }):Play()
    task.delay(0.65, function()
        screenGui:Destroy()
        showWelcomeMessage()
    end)
end)

-- ─── Quit button ─────────────────────────────────────────────────────────────

quitBtn.MouseButton1Click:Connect(function()
    -- In Roblox you can't force-quit, so kick the player
    player:Kick("Thanks for playing Plane Game!")
end)

-- ─── Panel entrance animation ─────────────────────────────────────────────────

panel.Position = UDim2.new(0.5, 0, 0.6, 0)
panel.BackgroundTransparency = 1
TweenService:Create(panel, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 0.25,
}):Play()

print("[MainMenu] Loaded.")
