-- PlaneConfig: Shared configuration for all plane types
local PlaneConfig = {}

PlaneConfig.Planes = {
    Fighter = {
        Name = "Fighter Jet",
        -- Thrust (studs/s^2)
        MaxThrust = 280,
        MinThrust = 0,
        ThrottleAcceleration = 40,
        -- Aerodynamics
        LiftCoefficient = 1.8,
        DragCoefficient = 0.06,
        LateralDragCoefficient = 0.5,
        StallAngle = 25,          -- degrees above which lift drops off
        -- Rotation speeds (degrees/s)
        PitchSpeed = 55,
        RollSpeed = 90,
        YawSpeed = 30,
        -- Rotation damping (0-1 per second)
        AngularDamping = 6,
        -- Health
        MaxHealth = 200,
        -- Speeds
        MaxSpeed = 400,
        TakeoffSpeed = 80,        -- speed at which lift exceeds gravity
        -- Dimensions (used for model building)
        BodySize = Vector3.new(6, 1.5, 14),
        WingSize = Vector3.new(22, 0.4, 5),
        TailSize = Vector3.new(8, 3, 0.5),
        -- Colors
        BodyColor = BrickColor.new("Medium stone grey"),
        WingColor = BrickColor.new("Medium stone grey"),
        CockpitColor = BrickColor.new("Cyan"),
        -- Sounds
        EngineSound = "rbxassetid://9116687894",
        ExplosionSound = "rbxassetid://4612378735",
    },
    Biplane = {
        Name = "Biplane",
        MaxThrust = 160,
        MinThrust = 0,
        ThrottleAcceleration = 25,
        LiftCoefficient = 2.2,
        DragCoefficient = 0.10,
        LateralDragCoefficient = 0.6,
        StallAngle = 30,
        PitchSpeed = 40,
        RollSpeed = 60,
        YawSpeed = 35,
        AngularDamping = 5,
        MaxHealth = 150,
        MaxSpeed = 220,
        TakeoffSpeed = 55,
        BodySize = Vector3.new(5, 1.5, 10),
        WingSize = Vector3.new(18, 0.4, 4),
        TailSize = Vector3.new(6, 2.5, 0.5),
        BodyColor = BrickColor.new("Bright red"),
        WingColor = BrickColor.new("Bright red"),
        CockpitColor = BrickColor.new("Cyan"),
        EngineSound = "rbxassetid://9116687894",
        ExplosionSound = "rbxassetid://4612378735",
    },
}

-- Default plane type
PlaneConfig.DefaultPlane = "Fighter"

-- Physics constants
PlaneConfig.Gravity = workspace.Gravity  -- uses Roblox workspace gravity
PlaneConfig.AirDensityAtSea = 1.0        -- relative air density multiplier
PlaneConfig.HeightDensityFalloff = 0.0002 -- density reduction per stud altitude

-- Damage thresholds
PlaneConfig.CrashDamageMinSpeed = 60     -- studs/s below which no crash damage
PlaneConfig.CrashDamageScale = 1.5       -- damage multiplier on crash

-- Respawn
PlaneConfig.RespawnDelay = 5             -- seconds before plane respawns

-- Controls
PlaneConfig.Controls = {
    ThrottleUp   = Enum.KeyCode.Space,
    ThrottleDown = Enum.KeyCode.LeftShift,
    PitchUp      = Enum.KeyCode.S,
    PitchDown    = Enum.KeyCode.W,
    RollLeft     = Enum.KeyCode.A,
    RollRight    = Enum.KeyCode.D,
    YawLeft      = Enum.KeyCode.Q,
    YawRight     = Enum.KeyCode.E,
    LandingGear  = Enum.KeyCode.G,
    ExitPlane    = Enum.KeyCode.F,
    Boost        = Enum.KeyCode.LeftControl,
}

return PlaneConfig
