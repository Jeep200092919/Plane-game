-- CameraController (LocalScript): Third-person chase camera for the plane
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ExitPlaneEvent = RemoteEvents:WaitForChild("ExitPlane")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Camera parameters
local CAM_DISTANCE   = 30    -- studs behind plane
local CAM_HEIGHT     = 8     -- studs above plane
local CAM_SMOOTHING  = 8     -- lerp factor per second
local CAM_FOV_FLIGHT = 80    -- FOV while flying
local CAM_FOV_WALK   = 70    -- FOV while walking

-- Mouse look orbit
local orbitX = 0   -- yaw offset
local orbitY = 0   -- pitch offset
local MAX_ORBIT_Y = math.rad(40)

local inPlane    = false
local planeBody  = nil

-- ─── Helpers ──────────────────────────────────────────────────────────────────

local function findCurrentPlane()
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

-- ─── Mouse orbit input ────────────────────────────────────────────────────────

UserInputService.InputChanged:Connect(function(input)
    if not inPlane then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Delta
        orbitX = orbitX - delta.X * 0.003
        orbitY = math.clamp(orbitY - delta.Y * 0.003, -MAX_ORBIT_Y, MAX_ORBIT_Y)
    end
end)

-- ─── Camera update ────────────────────────────────────────────────────────────

local lastCamCF = CFrame.new(0, 20, -50)

RunService.RenderStepped:Connect(function(dt)
    planeBody = findCurrentPlane()
    inPlane   = planeBody ~= nil

    if inPlane then
        camera.CameraType = Enum.CameraType.Scriptable
        camera.FieldOfView = CAM_FOV_FLIGHT

        local planeCF   = planeBody.CFrame
        local planePos  = planeBody.Position
        local planeLook = planeCF.LookVector
        local planeUp   = planeCF.UpVector

        -- Orbit offset from mouse
        local orbitCF = CFrame.Angles(orbitY, orbitX, 0)
        local offsetDir = (planeCF * orbitCF).LookVector

        -- Camera target position: behind and above plane
        local desiredPos = planePos
            - offsetDir * CAM_DISTANCE
            + Vector3.new(0, CAM_HEIGHT, 0)

        -- Smooth camera position
        local alpha = math.clamp(CAM_SMOOTHING * dt, 0, 1)
        local smoothPos = lastCamCF.Position:Lerp(desiredPos, alpha)

        -- Look at plane
        local lookAt = planePos + planeUp * 2
        local newCamCF = CFrame.lookAt(smoothPos, lookAt, Vector3.new(0,1,0))
        camera.CFrame = newCamCF
        lastCamCF = newCamCF

        -- Lock mouse
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        -- Return camera control to Roblox default
        camera.CameraType = Enum.CameraType.Custom
        camera.FieldOfView = CAM_FOV_WALK
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        orbitX = 0
        orbitY = 0
    end
end)

ExitPlaneEvent.OnClientEvent:Connect(function()
    inPlane   = false
    planeBody = nil
    camera.CameraType = Enum.CameraType.Custom
    camera.FieldOfView = CAM_FOV_WALK
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end)

print("[CameraController] Ready.")
