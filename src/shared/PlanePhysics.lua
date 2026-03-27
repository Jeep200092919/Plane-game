-- PlanePhysics: Shared aerodynamics calculations
local PlanePhysics = {}

-- Returns lift force magnitude given speed, angle of attack, config, and altitude
function PlanePhysics.GetLift(speed, angleOfAttack, config, altitude)
    local airDensity = 1.0 - (altitude * (config.HeightDensityFalloff or 0.0002))
    airDensity = math.max(airDensity, 0.1)

    -- Stall: lift drops sharply past stall angle
    local stallFactor = 1.0
    local absAoA = math.abs(angleOfAttack)
    local stallAngle = config.StallAngle or 25
    if absAoA > stallAngle then
        stallFactor = math.max(0, 1 - (absAoA - stallAngle) / stallAngle)
    end

    -- L = 0.5 * rho * v^2 * CL
    local lift = 0.5 * airDensity * (speed * speed) * config.LiftCoefficient * stallFactor
    return lift
end

-- Returns drag force magnitude given speed, config, and altitude
function PlanePhysics.GetDrag(speed, config, altitude)
    local airDensity = 1.0 - (altitude * (config.HeightDensityFalloff or 0.0002))
    airDensity = math.max(airDensity, 0.1)
    -- D = 0.5 * rho * v^2 * CD
    local drag = 0.5 * airDensity * (speed * speed) * config.DragCoefficient
    return drag
end

-- Returns lateral (sideways/yaw) drag force
function PlanePhysics.GetLateralDrag(lateralSpeed, config, altitude)
    local airDensity = 1.0 - (altitude * (config.HeightDensityFalloff or 0.0002))
    airDensity = math.max(airDensity, 0.1)
    local drag = 0.5 * airDensity * (lateralSpeed * lateralSpeed) * config.LateralDragCoefficient
    return drag
end

-- Angle of attack in degrees between velocity vector and plane's forward direction
function PlanePhysics.GetAngleOfAttack(velocity, lookVector)
    if velocity.Magnitude < 0.5 then return 0 end
    local velNorm = velocity.Unit
    local dot = velNorm:Dot(lookVector)
    dot = math.clamp(dot, -1, 1)
    local angleDeg = math.deg(math.acos(dot))
    return angleDeg
end

return PlanePhysics
