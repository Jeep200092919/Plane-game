-- MissionGui.client.lua (LocalScript → StarterPlayerScripts)
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ─── Mission Definitions ──────────────────────────────────────────────────────

local MISSIONS = {
    {
        id          = "survive_1min",
        title       = "Survivor",
        desc        = "Stay alive for 1 minute",
        icon        = "⏱",
        goal        = 60,
        unit        = "s",
        rewardText  = "+10 Speed",
        reward = function(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = hum.WalkSpeed + 10 end
        end,
    },
    {
        id          = "bounty_kills",
        title       = "Bounty Hunter",
        desc        = "Hit the enemy plane 3 times",
        icon        = "🎯",
        goal        = 3,
        unit        = " hits",
        rewardText  = "+15 Speed & +50 Jump",
        reward = function(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed  = hum.WalkSpeed  + 15
                hum.JumpPower  = hum.JumpPower   + 50
            end
        end,
    },
    {
        id          = "sky_high",
        title       = "Sky High",
        desc        = "Reach an altitude of 300 studs",
        icon        = "🚀",
        goal        = 300,
        unit        = " studs",
        rewardText  = "Max Health +50",
        reward = function(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = hum.MaxHealth + 50
                hum.Health    = hum.MaxHealth
            end
        end,
    },
    {
        id          = "speed_demon",
        title       = "Speed Demon",
        desc        = "Stay in the air for 30 seconds",
        icon        = "💨",
        goal        = 30,
        unit        = "s",
        rewardText  = "+20 Speed",
        reward = function(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = hum.WalkSpeed + 20 end
        end,
    },
    {
        id          = "veteran",
        title       = "Veteran",
        desc        = "Play for 3 minutes",
        icon        = "🏆",
        goal        = 180,
        unit        = "s",
        rewardText  = "+25 Speed & Max Health +100",
        reward = function(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = hum.WalkSpeed + 25
                hum.MaxHealth = hum.MaxHealth + 100
                hum.Health    = hum.MaxHealth
            end
        end,
    },
}

-- Progress state
local progress  = {}
local completed = {}
for _, m in ipairs(MISSIONS) do
    progress[m.id]  = 0
    completed[m.id] = false
end

-- ─── ScreenGui ────────────────────────────────────────────────────────────────

local screenGui = Instance.new("ScreenGui")
screenGui.Name            = "MissionGui"
screenGui.ResetOnSpawn    = false
screenGui.IgnoreGuiInset  = true
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
screenGui.Parent          = playerGui

-- ─── Toggle Button ────────────────────────────────────────────────────────────

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size            = UDim2.new(0, 130, 0, 40)
toggleBtn.Position        = UDim2.new(0, 16, 1, -56)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text            = "📋  MISSIONS"
toggleBtn.TextColor3      = Color3.fromRGB(255, 255, 255)
toggleBtn.Font            = Enum.Font.GothamBold
toggleBtn.TextSize        = 15
toggleBtn.Parent          = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)
local tStroke = Instance.new("UIStroke")
tStroke.Color       = Color3.fromRGB(60, 120, 255)
tStroke.Thickness   = 1.5
tStroke.Transparency = 0.4
tStroke.Parent = toggleBtn

-- Completed count badge
local badge = Instance.new("TextLabel")
badge.Size              = UDim2.new(0, 22, 0, 22)
badge.AnchorPoint       = Vector2.new(1, 0)
badge.Position          = UDim2.new(1, 6, 0, -6)
badge.BackgroundColor3  = Color3.fromRGB(255, 60, 60)
badge.BorderSizePixel   = 0
badge.Text              = "0"
badge.TextColor3        = Color3.new(1,1,1)
badge.Font              = Enum.Font.GothamBold
badge.TextSize          = 13
badge.ZIndex            = 5
badge.Visible           = false
badge.Parent            = toggleBtn
Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)

-- ─── Mission Panel ────────────────────────────────────────────────────────────

local PANEL_W = 320
local PANEL_H = 48 + #MISSIONS * 96 + 12

local panel = Instance.new("Frame")
panel.Name              = "MissionPanel"
panel.Size              = UDim2.new(0, PANEL_W, 0, PANEL_H)
panel.Position          = UDim2.new(0, -PANEL_W - 10, 1, -(PANEL_H + 60))
panel.BackgroundColor3  = Color3.fromRGB(8, 16, 32)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel   = 0
panel.ClipsDescendants  = true
panel.Parent            = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
local pStroke = Instance.new("UIStroke")
pStroke.Color       = Color3.fromRGB(60, 120, 255)
pStroke.Thickness   = 1.5
pStroke.Transparency = 0.35
pStroke.Parent      = panel

-- Panel header
local header = Instance.new("TextLabel")
header.Size             = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(20, 40, 90)
header.BackgroundTransparency = 0.3
header.BorderSizePixel  = 0
header.Text             = "MISSIONS"
header.TextColor3       = Color3.fromRGB(255, 255, 255)
header.Font             = Enum.Font.GothamBlack
header.TextSize         = 18
header.Parent           = panel

local headerDiv = Instance.new("Frame")
headerDiv.Size              = UDim2.new(1, 0, 0, 2)
headerDiv.Position          = UDim2.new(0, 0, 0, 44)
headerDiv.BackgroundColor3  = Color3.fromRGB(60, 120, 255)
headerDiv.BackgroundTransparency = 0.5
headerDiv.BorderSizePixel   = 0
headerDiv.Parent            = panel

-- ─── Mission Cards ────────────────────────────────────────────────────────────

local cards = {}

local function makeCard(mission, index)
    local yPos = 48 + (index - 1) * 96

    local card = Instance.new("Frame")
    card.Name               = mission.id
    card.Size               = UDim2.new(1, -20, 0, 84)
    card.Position           = UDim2.new(0, 10, 0, yPos)
    card.BackgroundColor3   = Color3.fromRGB(15, 28, 55)
    card.BackgroundTransparency = 0.2
    card.BorderSizePixel    = 0
    card.Parent             = panel
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Size               = UDim2.new(0, 40, 0, 40)
    icon.Position           = UDim2.new(0, 10, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Text               = mission.icon
    icon.TextSize           = 26
    icon.Font               = Enum.Font.GothamBold
    icon.Parent             = card

    -- Title
    local title = Instance.new("TextLabel")
    title.Size              = UDim2.new(1, -70, 0, 22)
    title.Position          = UDim2.new(0, 54, 0, 8)
    title.BackgroundTransparency = 1
    title.Text              = mission.title
    title.TextColor3        = Color3.fromRGB(255, 255, 255)
    title.Font              = Enum.Font.GothamBold
    title.TextSize          = 16
    title.TextXAlignment    = Enum.TextXAlignment.Left
    title.Parent            = card

    -- Description
    local desc = Instance.new("TextLabel")
    desc.Size               = UDim2.new(1, -70, 0, 18)
    desc.Position           = UDim2.new(0, 54, 0, 28)
    desc.BackgroundTransparency = 1
    desc.Text               = mission.desc
    desc.TextColor3         = Color3.fromRGB(160, 190, 230)
    desc.Font               = Enum.Font.Gotham
    desc.TextSize           = 13
    desc.TextXAlignment     = Enum.TextXAlignment.Left
    desc.Parent             = card

    -- Reward label
    local reward = Instance.new("TextLabel")
    reward.Size             = UDim2.new(1, -16, 0, 16)
    reward.Position         = UDim2.new(0, 8, 0, 48)
    reward.BackgroundTransparency = 1
    reward.Text             = "🎁 Reward: " .. mission.rewardText
    reward.TextColor3       = Color3.fromRGB(100, 220, 130)
    reward.Font             = Enum.Font.GothamMedium
    reward.TextSize         = 12
    reward.TextXAlignment   = Enum.TextXAlignment.Left
    reward.Parent           = card

    -- Progress bar bg
    local barBg = Instance.new("Frame")
    barBg.Size              = UDim2.new(1, -16, 0, 8)
    barBg.Position          = UDim2.new(0, 8, 0, 68)
    barBg.BackgroundColor3  = Color3.fromRGB(30, 45, 80)
    barBg.BorderSizePixel   = 0
    barBg.Parent            = card
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local bar = Instance.new("Frame")
    bar.Name                = "Bar"
    bar.Size                = UDim2.new(0, 0, 1, 0)
    bar.BackgroundColor3    = Color3.fromRGB(30, 140, 255)
    bar.BorderSizePixel     = 0
    bar.Parent              = barBg
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    -- Progress text (top-right of card)
    local progText = Instance.new("TextLabel")
    progText.Name           = "ProgText"
    progText.Size           = UDim2.new(0, 70, 0, 20)
    progText.AnchorPoint    = Vector2.new(1, 0)
    progText.Position       = UDim2.new(1, -8, 0, 8)
    progText.BackgroundTransparency = 1
    progText.Text           = "0 / " .. mission.goal .. mission.unit
    progText.TextColor3     = Color3.fromRGB(180, 200, 240)
    progText.Font           = Enum.Font.Code
    progText.TextSize       = 12
    progText.TextXAlignment = Enum.TextXAlignment.Right
    progText.Parent         = card

    cards[mission.id] = { card = card, bar = bar, progText = progText, title = title, desc = desc }
    return card
end

for i, m in ipairs(MISSIONS) do
    makeCard(m, i)
end

-- ─── Panel toggle ─────────────────────────────────────────────────────────────

local panelOpen = false
local OPEN_POS  = UDim2.new(0, 16,            1, -(PANEL_H + 60))
local CLOSE_POS = UDim2.new(0, -PANEL_W - 10, 1, -(PANEL_H + 60))
local TWEEN     = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

toggleBtn.MouseButton1Click:Connect(function()
    panelOpen = not panelOpen
    TweenService:Create(panel, TWEEN, {
        Position = panelOpen and OPEN_POS or CLOSE_POS
    }):Play()
    toggleBtn.BackgroundColor3 = panelOpen
        and Color3.fromRGB(30, 60, 130)
        or  Color3.fromRGB(20, 40, 80)
end)

-- ─── Completion Notification ──────────────────────────────────────────────────

local function showComplete(mission)
    local notif = Instance.new("Frame")
    notif.Size              = UDim2.new(0, 340, 0, 80)
    notif.AnchorPoint       = Vector2.new(0.5, 0)
    notif.Position          = UDim2.new(0.5, 0, -0.15, 0)
    notif.BackgroundColor3  = Color3.fromRGB(10, 30, 10)
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel   = 0
    notif.ZIndex            = 10
    notif.Parent            = screenGui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 12)

    local nStroke = Instance.new("UIStroke")
    nStroke.Color       = Color3.fromRGB(60, 220, 100)
    nStroke.Thickness   = 2
    nStroke.Parent      = notif

    local checkmark = Instance.new("TextLabel")
    checkmark.Size      = UDim2.new(0, 50, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text      = "✔"
    checkmark.TextColor3 = Color3.fromRGB(60, 220, 100)
    checkmark.Font      = Enum.Font.GothamBlack
    checkmark.TextSize  = 32
    checkmark.ZIndex    = 11
    checkmark.Parent    = notif

    local nTitle = Instance.new("TextLabel")
    nTitle.Size         = UDim2.new(1, -60, 0, 28)
    nTitle.Position     = UDim2.new(0, 54, 0, 8)
    nTitle.BackgroundTransparency = 1
    nTitle.Text         = "Mission Complete!  " .. mission.icon .. " " .. mission.title
    nTitle.TextColor3   = Color3.fromRGB(255, 255, 255)
    nTitle.Font         = Enum.Font.GothamBold
    nTitle.TextSize     = 17
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.ZIndex       = 11
    nTitle.Parent       = notif

    local nReward = Instance.new("TextLabel")
    nReward.Size        = UDim2.new(1, -60, 0, 20)
    nReward.Position    = UDim2.new(0, 54, 0, 38)
    nReward.BackgroundTransparency = 1
    nReward.Text        = "🎁 " .. mission.rewardText .. " applied!"
    nReward.TextColor3  = Color3.fromRGB(100, 220, 130)
    nReward.Font        = Enum.Font.GothamMedium
    nReward.TextSize    = 14
    nReward.TextXAlignment = Enum.TextXAlignment.Left
    nReward.ZIndex      = 11
    nReward.Parent      = notif

    -- Slide in
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0, 20)
    }):Play()

    -- Slide out after 3.5s
    task.delay(3.5, function()
        TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, -0.15, 0)
        }):Play()
        task.delay(0.45, function() notif:Destroy() end)
    end)
end

-- ─── Update card visuals ──────────────────────────────────────────────────────

local function updateCard(mission)
    local c = cards[mission.id]
    if not c then return end

    local pct = math.clamp(progress[mission.id] / mission.goal, 0, 1)

    TweenService:Create(c.bar, TweenInfo.new(0.3), {
        Size = UDim2.new(pct, 0, 1, 0)
    }):Play()

    if completed[mission.id] then
        c.progText.Text      = "✔ DONE"
        c.progText.TextColor3 = Color3.fromRGB(60, 220, 100)
        c.bar.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
        c.card.BackgroundColor3 = Color3.fromRGB(10, 35, 15)
        c.title.TextColor3   = Color3.fromRGB(100, 255, 130)
    else
        local val = math.floor(progress[mission.id])
        c.progText.Text = val .. " / " .. mission.goal .. mission.unit
    end

    -- Update badge count
    local doneCount = 0
    for _, m in ipairs(MISSIONS) do
        if completed[m.id] then doneCount += 1 end
    end
    badge.Text    = tostring(doneCount)
    badge.Visible = doneCount > 0
end

-- ─── Complete a mission ───────────────────────────────────────────────────────

local function completeMission(mission)
    if completed[mission.id] then return end
    completed[mission.id] = true
    progress[mission.id]  = mission.goal

    local char = player.Character
    if char then mission.reward(char) end

    updateCard(mission)
    showComplete(mission)
end

-- ─── Tracking logic ───────────────────────────────────────────────────────────

local sessionTime  = 0
local aliveTime    = 0
local airTime      = 0
local peakAltitude = 0

RunService.Heartbeat:Connect(function(dt)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    sessionTime += dt
    aliveTime   += dt

    local altitude = hrp.Position.Y
    if altitude > peakAltitude then peakAltitude = altitude end

    local state    = hum:GetState()
    local inAir    = state == Enum.HumanoidStateType.Freefall
                  or state == Enum.HumanoidStateType.Jumping
                  or altitude > 10
    if inAir then airTime += dt end

    -- Update progress values
    progress["survive_1min"] = math.min(aliveTime,    60)
    progress["speed_demon"]  = math.min(airTime,       30)
    progress["veteran"]      = math.min(sessionTime,  180)
    progress["sky_high"]     = math.min(peakAltitude, 300)

    -- Check completions
    for _, m in ipairs(MISSIONS) do
        if not completed[m.id] and progress[m.id] >= m.goal then
            completeMission(m)
        end
    end

    -- Refresh card visuals every ~0.25s (use a simple throttle)
end)

-- Throttled UI refresh (every 0.25s)
local uiTimer = 0
RunService.RenderStepped:Connect(function(dt)
    uiTimer += dt
    if uiTimer < 0.25 then return end
    uiTimer = 0
    for _, m in ipairs(MISSIONS) do
        if not completed[m.id] then updateCard(m) end
    end
end)

-- ─── Bounty kill tracking (listens for workspace hit events) ─────────────────
-- Connect to the FireWeapon remote if it exists (fired when enemy plane is hit)

local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")
if remotes then
    local fireWeapon = remotes:FindFirstChild("FireWeapon")
    if fireWeapon then
        fireWeapon.OnClientEvent:Connect(function()
            if completed["bounty_kills"] then return end
            progress["bounty_kills"] = math.min(progress["bounty_kills"] + 1, 3)
            updateCard(MISSIONS[2])
            if progress["bounty_kills"] >= 3 then
                completeMission(MISSIONS[2])
            end
        end)
    end
end

-- Reset alive time on character death
player.CharacterAdded:Connect(function(char)
    aliveTime = 0
    airTime   = 0
end)

print("[MissionGui] Loaded — " .. #MISSIONS .. " missions active.")
