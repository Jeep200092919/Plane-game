-- WalkAnimator.client.lua
-- Place this LocalScript inside StarterCharacterScripts
local RunService = game:GetService("RunService")

local character = script.Parent
local humanoid  = character:WaitForChild("Humanoid")
local animator  = humanoid:WaitForChild("Animator")

-- Walk2 animation ID
local animObj = Instance.new("Animation")
animObj.AnimationId = "rbxassetid://101653416557544"

local walkTrack = animator:LoadAnimation(animObj)
walkTrack.Priority = Enum.AnimationPriority.Core
walkTrack.Looped   = true

-- Stop the default walk/run animations from Roblox's built-in Animate script
task.defer(function()
    local animScript = character:FindFirstChild("Animate")
    if animScript then
        local walkFolder = animScript:FindFirstChild("walk")
        if walkFolder then
            local defaultWalk = walkFolder:FindFirstChild("WalkAnim")
            if defaultWalk then defaultWalk.AnimationId = "" end
        end
        local runFolder = animScript:FindFirstChild("run")
        if runFolder then
            local defaultRun = runFolder:FindFirstChild("RunAnim")
            if defaultRun then defaultRun.AnimationId = "" end
        end
    end
end)

-- Play / stop based on whether the character is moving
local isPlaying = false
local conn

conn = RunService.Heartbeat:Connect(function()
    if not humanoid or not humanoid.Parent then
        conn:Disconnect()
        return
    end

    local state    = humanoid:GetState()
    local moving   = humanoid.MoveDirection.Magnitude > 0.1
    local grounded = state ~= Enum.HumanoidStateType.Jumping
                  and state ~= Enum.HumanoidStateType.Freefall

    if moving and grounded then
        if not isPlaying then
            walkTrack:Play(0.15)
            isPlaying = true
        end
        walkTrack:AdjustSpeed(humanoid.WalkSpeed / 16)
    else
        if isPlaying then
            walkTrack:Stop(0.15)
            isPlaying = false
        end
    end
end)

