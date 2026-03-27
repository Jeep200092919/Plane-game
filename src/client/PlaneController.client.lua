-- PlaneController (LocalScript): Handles input, flight physics, and sends state to server
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlaneConfig = require(ReplicatedStorage:WaitForChild("PlaneConfig"))
local PlanePhysics = require(ReplicatedStorage:WaitForChild("PlanePhysics"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local BoardPlaneEvent  = RemoteEvents:WaitForChild("BoardPlane")
local ExitPlaneEvent   = RemoteEvents:WaitForChild("ExitPlane")
local UpdatePlaneState = RemoteEvents:WaitForChild("UpdatePlaneState")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local Controls = PlaneConfig.Controls

-- ─── State ────────────────────────────────────────────────────────────────────

local inPlane       = false
local currentPlane  = nil
local planeBody     = nil
local planeCfg      = nil
local throttle      = 0       -- 0 to 1
local landingGear   = true    -- true = gear down

-- Rotation state (Euler angles in radians)
local pitch = 0
local roll  = 0
local yaw   = 0

-- Network send rate
local SEND_RATE = 1/20
local sendTimer = 0

-- ─── Key helpers ──────────────────────────────────────────────────────────────

local function isHeld(keyCode)
    return UserInputService:IsKeyDown(keyCode)
end

-- ─── Board / Exit ─────────────────────────────────────────────────────────────

local function tryBoard()
    if inPlane then return end
    -- Find nearest plane in workspace
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "PilotSeat" and obj:IsA("VehicleSeat") then
            local body = obj.Parent:FindFirstChild("Body")
            if body and (body.Position - hrp.Position).Magnitude < 15 then
                BoardPlaneEvent:FireServer()
                -- Wait for seat occupation
                task.delay(0.3, function()
                    -- Find current seat
                    for _, seat in ipairs(workspace:GetDescendants()) do
                        if seat.Name == "PilotSeat" and seat:IsA("VehicleSeat") then
                            if seat.Occupant and seat.Occupant.Parent == character then
                                currentPlane = seat.Parent
                                planeBody    = currentPlane:FindFirstChild("Body")
                                local pType  = currentPlane:GetAttribute("PlaneType") or "Fighter"
                                planeCfg     = PlaneConfig.Planes[pType]
                                inPlane      = true
                                throttle     = 0
                                pitch, roll, yaw = 0, 0, 0

                                -- Initialize gyro to current CFrame
                                local gyro = planeBody:FindFirstChild("PlaneGyro")
                                if gyro then gyro.CFrame = planeBody.CFrame end
                                print("Boarded " .. currentPlane.Name)
                            end
                        end
                    end
                end)
                break
            end
        end
    end
end

local function exitPlane()
    if not inPlane then return end
    ExitPlaneEvent:FireServer()
    inPlane      = false
    currentPlane = nil
    planeBody    = nil
    planeCfg     = nil
    throttle     = 0
end

-- ─── Input listeners ──────────────────────────────────────────────────────────

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Controls.ExitPlane then
        if inPlane then
            exitPlane()
        else
            tryBoard()
        end
    end
    if input.KeyCode == Controls.LandingGear and inPlane then
        landingGear = not landingGear
        -- Toggle gear visibility
        if currentPlane then
            for _, part in ipairs(currentPlane:GetDescendants()) do
                if part.Name:match("^Gear") then
                    part.Transparency = landingGear and 0 or 1
                    part.CanCollide   = landingGear
                end
            end
        end
    end
end)

-- ─── Flight update ────────────────────────────────────────────────────────────

local function applyFlightPhysics(dt)
    if not inPlane or not planeBody or not planeCfg then return end
    if not planeBody.Parent then
        -- Plane was destroyed
        inPlane = false
        currentPlane = nil
        planeBody = nil
        planeCfg = nil
        return
    end

    local cfg = planeCfg
    local body = planeBody

    -- ── Throttle ──
    local boost = isHeld(Controls.Boost) and 1.5 or 1.0
    if isHeld(Controls.ThrottleUp) then
        throttle = math.min(1, throttle + cfg.ThrottleAcceleration * dt / cfg.MaxThrust)
    elseif isHeld(Controls.ThrottleDown) then
        throttle = math.max(0, throttle - cfg.ThrottleAcceleration * dt / cfg.MaxThrust)
    end

    -- ── Rotation inputs ──
    local pitchInput = 0
    local rollInput  = 0
    local yawInput   = 0

    if isHeld(Controls.PitchUp)   then pitchInput =  1 end
    if isHeld(Controls.PitchDown) then pitchInput = -1 end
    if isHeld(Controls.RollLeft)  then rollInput  = -1 end
    if isHeld(Controls.RollRight) then rollInput  =  1 end
    if isHeld(Controls.YawLeft)   then yawInput   = -1 end
    if isHeld(Controls.YawRight)  then yawInput   =  1 end

    -- Apply rotation rates
    local pitchRate = math.rad(cfg.PitchSpeed) * dt * pitchInput
    local rollRate  = math.rad(cfg.RollSpeed)  * dt * rollInput
    local yawRate   = math.rad(cfg.YawSpeed)   * dt * yawInput

    -- Current plane orientation
    local cf = body.CFrame
    local lookVec   = cf.LookVector
    local rightVec  = cf.RightVector
    local upVec     = cf.UpVector

    -- Build rotation deltas around local axes
    local rotCF = cf
        * CFrame.Angles(pitchRate, yawRate, -rollRate)
    -- Keep position from original
    rotCF = CFrame.new(cf.Position) * (rotCF - rotCF.Position)

    -- Angular damping: blend toward level flight slightly when no input
    local dampFactor = 1 - math.clamp(cfg.AngularDamping * dt, 0, 0.99)

    -- ── Physics ──
    local velocity   = body.Velocity
    local speed      = velocity.Magnitude
    local altitude   = body.Position.Y

    -- Thrust force along look direction
    local thrustForce = lookVec * cfg.MaxThrust * throttle * boost

    -- Angle of attack
    local aoaDeg = PlanePhysics.GetAngleOfAttack(velocity, lookVec)

    -- Lift (perpendicular to velocity, upward component)
    local liftMag = PlanePhysics.GetLift(speed, aoaDeg, cfg, altitude)
    -- Lift direction: always world up (simplified), scaled by how level the plane is
    local liftDir  = upVec
    local liftForce = liftDir * liftMag

    -- Drag (opposite velocity)
    local dragMag = PlanePhysics.GetDrag(speed, cfg, altitude)
    local dragForce = Vector3.new(0, 0, 0)
    if speed > 0.1 then
        dragForce = -velocity.Unit * dragMag
    end

    -- Lateral drag (resist sideways/yaw drift)
    local lateralVel  = velocity - (velocity:Dot(lookVec) * lookVec)
    local latSpeed    = lateralVel.Magnitude
    local latDragMag  = PlanePhysics.GetLateralDrag(latSpeed, cfg, altitude)
    local latDragForce = Vector3.new(0, 0, 0)
    if latSpeed > 0.1 then
        latDragForce = -lateralVel.Unit * latDragMag
    end

    -- Gravity
    local gravity = Vector3.new(0, -workspace.Gravity, 0)

    -- Net acceleration
    local mass = body:GetMass()
    local netForce = thrustForce + liftForce + dragForce + latDragForce + gravity * mass
    local newVelocity = velocity + (netForce / mass) * dt

    -- Speed cap
    if newVelocity.Magnitude > cfg.MaxSpeed then
        newVelocity = newVelocity.Unit * cfg.MaxSpeed
    end

    -- Update gyro target
    local gyro = body:FindFirstChild("PlaneGyro")
    if gyro then
        -- New orientation from rotation input
        local newCF = CFrame.new(cf.Position) * CFrame.fromMatrix(
            Vector3.new(0,0,0),
            (cf * CFrame.Angles(pitchRate, yawRate, -rollRate)).RightVector,
            (cf * CFrame.Angles(pitchRate, yawRate, -rollRate)).UpVector
        )

        -- Simple approach: rotate current CFrame by input angles
        local rotated = cf * CFrame.Angles(pitchRate, yawRate, -rollRate)
        gyro.CFrame = CFrame.new(cf.Position) * (rotated - rotated.Position)
    end

    -- Send to server
    sendTimer = sendTimer + dt
    if sendTimer >= SEND_RATE then
        sendTimer = 0
        local targetGyroCF = gyro and gyro.CFrame or body.CFrame
        UpdatePlaneState:FireServer(targetGyroCF, newVelocity, throttle)
    end
end

-- ─── Main loop ────────────────────────────────────────────────────────────────

RunService.Heartbeat:Connect(function(dt)
    -- Re-acquire character if needed
    if not character or not character.Parent then
        character = player.Character
        return
    end
    applyFlightPhysics(dt)
end)

-- Handle server-forced exit (e.g. plane destroyed)
ExitPlaneEvent.OnClientEvent:Connect(function()
    inPlane      = false
    currentPlane = nil
    planeBody    = nil
    planeCfg     = nil
    throttle     = 0
end)

-- Proximity prompt: Show "Press F to board" when near a plane
RunService.Heartbeat:Connect(function()
    if inPlane then return end
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "PilotSeat" and obj:IsA("VehicleSeat") then
            local body = obj.Parent and obj.Parent:FindFirstChild("Body")
            if body and (body.Position - hrp.Position).Magnitude < 12 then
                -- Notification handled by PlaneGui
                return
            end
        end
    end
end)

print("[PlaneController] Ready.")
