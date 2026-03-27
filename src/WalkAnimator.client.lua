-- WalkAnimator.client.lua
-- Place this LocalScript inside StarterCharacterScripts alongside Walk2
local RunService = game:GetService("RunService")
local KSProvider = game:GetService("KeyframeSequenceProvider")

local character = script.Parent
local humanoid  = character:WaitForChild("Humanoid")
local animator  = humanoid:WaitForChild("Animator")

-- Walk2 is cloned from StarterCharacterScripts into the character at spawn
local walkKFS = character:WaitForChild("Walk2", 5)
if not walkKFS then
    warn("[WalkAnimator] Walk2 not found in character.")
    return
end

-- Register the KeyframeSequence so it gets a usable temporary asset ID
local tempId  = KSProvider:RegisterKeyframeSequence(walkKFS)
local animObj = Instance.new("Animation")
animObj.AnimationId = tempId

local walkTrack = animator:LoadAnimation(animObj)
walkTrack.Priority = Enum.AnimationPriority.Core
walkTrack.Looped   = true

-- Stop the default walk animation from Roblox's built-in Animate script
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
        -- Scale animation speed to match walk speed (default WalkSpeed = 16)
        walkTrack:AdjustSpeed(humanoid.WalkSpeed / 16)
    else
        if isPlaying then
            walkTrack:Stop(0.15)
            isPlaying = false
        end
    end
end)
