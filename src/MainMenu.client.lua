-- MainMenu.client.lua (LocalScript → StarterPlayerScripts)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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

makeToggle(settingsPanel, "Music",          100, true)
makeToggle(settingsPanel, "Sound Effects",  154, true)
makeToggle(settingsPanel, "Show FPS",       208, false)
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
creditsText.Text = "Game Design\nYour Name\n\nProgramming\nYour Name\n\nArt & Assets\nYour Name\n\nSpecial Thanks\nRoblox Community"
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

playBtn.MouseButton1Click:Connect(function()
    -- Fade out menu then hide it
    TweenService:Create(screenGui, TweenInfo.new(0.5), { }):Play()
    TweenService:Create(bg, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(panel, TweenInfo.new(0.4), {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.4, 0),
    }):Play()
    task.delay(0.65, function()
        screenGui:Destroy()
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
