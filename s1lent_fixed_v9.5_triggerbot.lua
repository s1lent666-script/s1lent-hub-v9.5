-- s1lent hub | V9.4 | V8 aim + V9.2 menu/particles + Aim Lock + HUD saturation
-- s1lent hub | Updated LocalScript + HUD + Settings
-- Place in StarterPlayer > StarterPlayerScripts
-- For your own Roblox Studio experience.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- SAFE UI BOOTSTRAP
--==================================================
-- Creates a minimal launcher before the rest of the script runs.
-- If a later optional feature errors, the launcher remains available.
do
	local ok = pcall(function()
		local existing = playerGui:FindFirstChild("S1lentHubBootstrap")
		if existing then existing:Destroy() end

		local boot = Instance.new("ScreenGui")
		boot.Name = "S1lentHubBootstrap"
		boot.ResetOnSpawn = false
		boot.IgnoreGuiInset = true
		boot.DisplayOrder = 2000
		boot.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		boot.Parent = playerGui

		local button = Instance.new("TextButton")
		button.Name = "Launcher"
		button.Size = UDim2.fromOffset(44, 44)
		button.Position = UDim2.new(0, 14, 0.5, -22)
		button.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
		button.Text = "S"
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.Font = Enum.Font.GothamBold
		button.TextSize = 18
		button.AutoButtonColor = true
		button.ZIndex = 2001
		button.Parent = boot

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 12)
		c.Parent = button

		button.Activated:Connect(function()
			local hub = playerGui:FindFirstChild("S1lentHub")
			local main = hub and hub:FindFirstChild("Main")
			if main and main:IsA("GuiObject") then
				main.Visible = not main.Visible
			end
		end)
	end)
end

local ICON_ID = "rbxassetid://75320811235083"
local SKYBOX_ID = "rbxassetid://8808550143"

local cfg = {
	CombatESPEnabled = false,

	CombatESPBodyColor = Color3.fromRGB(0, 100, 255),
	CombatESPHeadColor = Color3.fromRGB(255, 230, 0),

	-- ESP appearance
	ESPUseRGB = false,
	ESPRGBSpeed = 0.6,
	ESPFillColor = Color3.fromRGB(0, 100, 255),
	ESPFillTransparency = 0.65,
	ESPOutlineColor = Color3.fromRGB(255, 255, 255),
	ESPOutlineTransparency = 0,
	ESPOutlineThickness = 2,

	-- ESP display
	ESP3DBox = true,
	ESP2DBox = false,
	ESPCornerBox = false,
	ESPSkeleton = false,

	-- ESP information
	ESPName = true,
	ESPHealth = true,
	ESPHealthColor = Color3.fromRGB(70, 255, 100),
	ESPTeam = false,
	ESPState = false,
	ESPDistance = true,
	ESPDistanceTextSize = 10,

	-- ESP lines
	ESPLines = false,
	ESPLineColor = Color3.fromRGB(255, 255, 255),
	ESPLineThickness = 1,

	-- ESP performance
	ESPMaxDistance = 1000,
	ESPUpdateRate = 30,
	ESPLowEnd = false,
	ESPHideSelf = true,
	ESPHideDead = true,

	ESPScale = 1.025,

	TrailEnabled = false,
	TrailRainbow = false,
	TrailRainbowSpeed = 0.6,
	TrailWidth = 1.5,
	TrailLifetime = 0.8,
	TrailTransparency = 0.1,

	GhostEnabled = false,
	GhostRainbow = false,
	GhostRainbowSpeed = 0.45,
	GhostMode = "Transparent",
	GhostInterval = 0.2,
	GhostLifetime = 1.1,
	GhostTransparency = 0.45,
	GhostOutlineTransparency = 0.1,

	OrbitEnabled = false,
	OrbitType = "Swords",
	OrbitCount = 3,
	OrbitRadius = 3,
	OrbitSpeed = 1.5,
	OrbitRainbow = false,
	OrbitColorHue = 0.55,

	JumpCircleEnabled = false,
	JumpCircleRainbow = false,
	JumpCircleRainbowSpeed = 0.5,
	JumpCircleSize = 7,
	JumpCircleDuration = 0.8,
	JumpCircleThickness = 0.12,
	JumpColorHue = 0.02,

	StretchAmount = 0,

	-- Angel Wings
	AngelWingsEnabled = false,
	AngelWingsColor = Color3.fromRGB(255, 255, 255),
	AngelWingsRainbow = false,
	AngelWingsRainbowSpeed = 0.45,
	AngelWingsScale = 1,

	-- Visuals
	CustomFOVEnabled = false,
	CustomFOV = 70,

	TargetIndicatorsEnabled = false,
	TargetArrowColor = Color3.fromRGB(255, 65, 80),
	TargetArrowRainbow = false,
	TargetArrowRainbowSpeed = 0.7,
	TargetArrowTransparency = 0.05,
	TargetArrowWidth = 22,
	TargetArrowRadius = 65,
	TargetOutlineEnabled = false,
	TargetOutlineColor = Color3.fromRGB(255, 65, 80),
	TargetOutlineRainbow = false,
	TargetOutlineRainbowSpeed = 0.7,
	TargetOutlineTransparency = 0,

	-- Combat aim assist / test targeting
	AimEnabled = false,
	SilentAimEnabled = false,
	AimFOV = 20,
	AimStrength = 0.35,
	AimRingWidth = 2,
	AimRingTransparency = 0.2,
	AimRingColor = Color3.fromRGB(255, 65, 80),

	-- Trigger Bot (intended for your own Place / test mode)
	TriggerBotEnabled = false,
	TriggerBotFOV = 3,
	TriggerBotDelay = 0.05,
	TriggerBotCooldown = 0.12,
	TriggerBotTeamCheck = true,
	TriggerBotLineOfSight = true,

	-- Target lock (for your own Place / test mode)
	TargetLockEnabled = false,
	TargetLockActive = false,

	-- Rivals Bot / player autopilot (for your own Place / test mode)
	RivalsBotEnabled = false,
	RivalsBotDifficulty = "Nightmare",
	RivalsBotReaction = 1,
	RivalsBotMovement = 1,
	RivalsBotStrafe = true,
	RivalsBotDodge = true,
	RivalsBotAim = 1,
	RivalsBotAggression = 1,
	RivalsBotRange = 140,
	RivalsBotAttackRate = 12,	
	RivalsBotWalkSpeed = 32,
	RivalsBotJumpPower = 75,
	RivalsBotAutoRespawn = true,

	-- First-person hands
	HandsEnabled = false,
	HandsFillColor = Color3.fromRGB(255, 255, 255),
	HandsRainbow = false,
	HandsRainbowSpeed = 0.6,
	HandsTransparency = 0,
	HandsOutlineEnabled = false,
	HandsOutlineColor = Color3.fromRGB(255, 65, 80),
	HandsOutlineRainbow = false,
	HandsOutlineTransparency = 0,
	HandsGlowEnabled = false,
	HandsGlowColor = Color3.fromRGB(255, 65, 80),
	HandsGlowStrength = 2,
	HandsShader = "Default",
	HandsShaderSpeed = 0.8,
	HandsShaderIntensity = 1,

	-- World sky tint
	SkyboxR = 120,
	SkyboxG = 120,
	SkyboxB = 160,

	-- World particles
	WorldParticlesEnabled = false,
	WorldParticleType = "Snow",
	WorldParticleAmount = 35,
	WorldParticleSize = 1,
	WorldParticleSpeed = 2,
	WorldParticleLifetime = 5,
	WorldParticleSpread = 18,
	WorldParticleGravity = -0.8,
	WorldParticleTransparency = 0.15,
	WorldParticleEmissionRate = 8,
	WorldParticleRadius = 35,
	WorldParticleRainbow = false,
	WorldParticleRainbowSpeed = 0.6,
	WorldParticleColor = Color3.fromRGB(255, 255, 255),
	WorldParticleWind = 1,

	-- Menu particles
	MenuParticles = "Off",
	MenuParticleAmount = 24,
	MenuParticleSpeed = 1,

	PulseRingEnabled = false,
	PulseRingRainbow = false,
	PulseRingRadius = 3,
	PulseRingThickness = 0.12,
	PulseRingSpeed = 1.5,
	PulseRingPulseSpeed = 2,
	PulseRingPulseAmount = 0.3,
	PulseRingTransparency = 0.15,
	PulseRingTrail = true,
	PulseRingTrailLifetime = 0.5,

	CrystalCount = 5,
	CrystalSize = 0.7,
	CrystalFloatHeight = 1.5,
	CrystalRainbow = false,
	CrystalRainbowSpeed = 0.5,
	CrystalColorHue = 0.02,

	PreviewEffects = false,

	-- Initial menu scale
	MenuScale = 0.73,

	-- Full-screen color saturation (-1 = grayscale, 0 = normal, 1 = max)
	ScreenSaturation = 0,

	-- HUD visibility
	IslandEnabled = false,
	CoordinatesEnabled = false,
	SpeedEnabled = false,

	-- HUD appearance
	IslandScale = 1,
	CoordinatesScale = 1,
	SpeedScale = 1,

	IslandTransparency = 0.05,
	CoordinatesTransparency = 0.05,
	SpeedTransparency = 0.05,

	IslandX = 0.5,
	IslandY = 0.025,

	CoordinatesX = 0.02,
	CoordinatesY = 0.42,

	SpeedX = 0.02,
	SpeedY = 0.52,
}

local hues = {
	Trail = 0.02,
	Ghost = 0.55,
	Orbit = 0.55,
	Jump = cfg.JumpColorHue,
	Pulse = 0.02,
	Crystal = cfg.CrystalColorHue,
	ESP = 0,
}

local connections = {}
local currentCharacter

local trail
local leftAttachment
local rightAttachment

local jumpConnection
local wasAirborne = false

local ghostAccumulator = 0
local lastGhostPosition
local ghostCount = 0
local MAX_GHOSTS = 8

local orbitObjects = {}
local orbitAngle = 0

local pulseSegments = {}
local pulseFolder
local pulseAngle = 0
local pulseTime = 0
local pulseTrailTimer = 0

-- New ESP objects
local espObjects = {}
local espFolder
local espLastUpdate = 0
local espRGBColor = cfg.ESPFillColor

local skyboxEnabled = false
local customSky
local previousSky
local skyAtmosphere
local applySkyboxTint

local targetIndicatorLayer
local targetIndicatorObjects = {}
local targetOutlineObjects = {}
local targetIndicatorAccumulator = 0

local worldParticleFolder
local worldParticleObjects = {}
local worldParticleAccumulator = 0
local worldParticleRandom = Random.new()

local menuParticleLayer
local menuParticleObjects = {}
local menuParticleAccumulator = 0
local menuParticleRandom = Random.new()

local wingModel
local previewWingModel
local savedHandVisuals = {}
local handHighlights = {}
local handGlowLights = {}
local hiddenClothing = {}
local handPartSet = {}
local handsVisualTime = 0

local aimRing
local aimTarget
local lockedTargetPlayer
local targetLockButton
local botTargetPlayer
local botLastAttack = 0
local botNextStrafe = 0
local botStrafeSign = 1

local stageNames = {}
local stageIndex = 1

local savedFOV = 70
local fovCamera

local screenColorCorrection

local function applyScreenSaturation()
	if not screenColorCorrection or not screenColorCorrection.Parent then
		screenColorCorrection = Lighting:FindFirstChild("S1lentScreenSaturation")
		if not screenColorCorrection then
			screenColorCorrection = Instance.new("ColorCorrectionEffect")
			screenColorCorrection.Name = "S1lentScreenSaturation"
			screenColorCorrection.Parent = Lighting
		end
	end
	screenColorCorrection.Saturation = math.clamp(cfg.ScreenSaturation, -1, 1)
end

local function make(className, props, parent)
	local obj = Instance.new(className)

	for key, value in pairs(props or {}) do
		obj[key] = value
	end

	obj.Parent = parent

	return obj
end

local function corner(obj, radius)
	make("UICorner", {
		CornerRadius = UDim.new(0, radius or 8)
	}, obj)
end

local function colorFor(name)
	return Color3.fromHSV((hues[name] or 0) % 1, 0.9, 1)
end

local function getCharacter()
	return player.Character
end

local function getRoot(char)
	char = char or getCharacter()

	return char and char:FindFirstChild("HumanoidRootPart")
end

local function clearList(list)
	for _, obj in ipairs(list) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end

	table.clear(list)
end

local function makeDraggable(obj, handle)
	local dragging = false
	local dragStart
	local startPosition

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragging = true
		dragStart = input.Position
		startPosition = obj.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end)

	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			local delta = input.Position - dragStart

			obj.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end))
end

local function animatedStroke(obj)
	local ok, stroke = pcall(function()
		return make("UIStroke", {
			Thickness = 1.2,
			Color = Color3.fromRGB(240, 35, 55),
			Transparency = 0,
		}, obj)
	end)
	return ok and stroke or nil
end

--==================================================
-- GUI SETUP
--==================================================

local oldGui = playerGui:FindFirstChild("S1lentHub")

if oldGui then
	oldGui:Destroy()
end

local gui = make("ScreenGui", {
	Name = "S1lentHub",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Enabled = true,
	DisplayOrder = 999,
}, playerGui)

local iconButton = make("ImageButton", {
	Name = "HubIcon",
	Size = UDim2.fromOffset(40, 40),
	Position = UDim2.new(0, 16, 0.45, 0),
	BackgroundColor3 = Color3.fromRGB(15, 15, 18),
	Image = ICON_ID,
	ScaleType = Enum.ScaleType.Fit,
	ImageTransparency = 0,
	AutoButtonColor = false,
	ZIndex = 100,
	Visible = true,
}, gui)

-- Text fallback keeps the button visible even if the image asset does not load.
make("TextLabel", {
	Name = "IconFallback",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "S",
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	ZIndex = 101,
}, iconButton)

corner(iconButton, 12)
animatedStroke(iconButton)
makeDraggable(iconButton, iconButton)

local main = make("Frame", {
	Name = "Main",
	Size = UDim2.fromOffset(610, 350),
	Position = UDim2.new(0.5, -305, 0.5, -175),
	BackgroundColor3 = Color3.fromRGB(13, 13, 16),
	BorderSizePixel = 0,
	Visible = true,
	ClipsDescendants = true,
	ZIndex = 5,
}, gui)

corner(main, 11)
animatedStroke(main)

pcall(function()
	local boot = playerGui:FindFirstChild("S1lentHubBootstrap")
	if boot then boot:Destroy() end
end)

menuParticleLayer = make("Frame", {
	Name = "MenuParticleLayer",
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = 6,
}, main)

local header = make("Frame", {
	BackgroundColor3 = Color3.fromRGB(20, 20, 24),
	BorderSizePixel = 0,
	ZIndex = 9,
}, main)

make("TextLabel", {
	Position = UDim2.fromOffset(14, 0),
	Size = UDim2.new(1, -80, 1, 0),
	BackgroundTransparency = 1,
	Text = "s1lent hub",
	Font = Enum.Font.GothamBold,
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = Color3.fromRGB(245, 245, 245),
}, header)

local closeButton = make("TextButton", {
	Size = UDim2.fromOffset(27, 27),
	Position = UDim2.new(1, -34, 0, 6),
	BackgroundColor3 = Color3.fromRGB(45, 20, 25),
	Text = "×",
	TextColor3 = Color3.fromRGB(255, 75, 85),
	Font = Enum.Font.GothamBold,
	TextSize = 21,
	AutoButtonColor = false,
}, header)

corner(closeButton, 7)
makeDraggable(main, header)

local sidebar = make("Frame", {
	Size = UDim2.new(0, 92, 1, -54),
	BackgroundColor3 = Color3.fromRGB(19, 19, 23),
	BorderSizePixel = 0,
	ZIndex = 8,
}, main)

corner(sidebar, 8)

local content = make("ScrollingFrame", {
	Size = UDim2.new(0, 250, 1, -54),
	BackgroundColor3 = Color3.fromRGB(17, 17, 21),
	BorderSizePixel = 0,
	ZIndex = 7,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = Color3.fromRGB(220, 35, 55),
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)

corner(content, 8)

local contentLayout = make("UIListLayout", {
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, content)

make("UIPadding", {
	PaddingTop = UDim.new(0, 8),
	PaddingLeft = UDim.new(0, 7),
	PaddingRight = UDim.new(0, 7),
	PaddingBottom = UDim.new(0, 9),
}, content)

local currentSectionGroup

local function registerSectionItem(obj)
	if currentSectionGroup then
		table.insert(currentSectionGroup.items, obj)
		obj.Visible = not currentSectionGroup.collapsed
	end
end

local function clearContent()
	currentSectionGroup = nil

	for _, child in ipairs(content:GetChildren()) do
		if child:IsA("GuiObject")
			and child ~= contentLayout
			and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end
end

--==================================================
-- COLLAPSIBLE SECTIONS
--==================================================

local function sectionLabel(text)
	local headerLabel = make("TextLabel", {
		Size = UDim2.new(1, -3, 0, 27),
		BackgroundColor3 = Color3.fromRGB(25, 18, 22),
		BackgroundTransparency = 0.15,
		Text = "  " .. text,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(245, 65, 80),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0,
	}, content)

	corner(headerLabel, 6)

	local group = {
		items = {},
		collapsed = true,
	}

	currentSectionGroup = group

	local arrow = make("TextButton", {
		Size = UDim2.fromOffset(25, 24),
		Position = UDim2.new(1, -27, 0, 1),
		BackgroundTransparency = 1,
		Text = "▶",
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(255, 85, 100),
		AutoButtonColor = false,
	}, headerLabel)

	arrow.Activated:Connect(function()
		group.collapsed = not group.collapsed
		arrow.Text = group.collapsed and "▶" or "▼"

		for _, item in ipairs(group.items) do
			if item and item.Parent then
				item.Visible = not group.collapsed
			end
		end
	end)

	return headerLabel
end

local function actionButton(text, callback)
	local button = make("TextButton", {
		Size = UDim2.new(1, -3, 0, 28),
		BackgroundColor3 = Color3.fromRGB(32, 32, 38),
		Text = text,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(235, 235, 240),
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, content)

	corner(button, 7)
	animatedStroke(button)

	button.Activated:Connect(callback)

	registerSectionItem(button)

	return button
end

local function makeSlider(labelText, minValue, maxValue, initial, callback)
	local holder = make("Frame", {
		Size = UDim2.new(1, -3, 0, 46),
		BackgroundColor3 = Color3.fromRGB(25, 25, 30),
		BorderSizePixel = 0,
	}, content)

	corner(holder, 7)

	local label = make("TextLabel", {
		Position = UDim2.fromOffset(7, 2),
		Size = UDim2.new(1, -14, 0, 17),
		BackgroundTransparency = 1,
		Text = labelText .. ": " .. tostring(initial),
		Font = Enum.Font.Gotham,
		TextSize = 9,
		TextColor3 = Color3.fromRGB(230, 230, 235),
		TextXAlignment = Enum.TextXAlignment.Left,
	}, holder)

	local bar = make("Frame", {
		Position = UDim2.fromOffset(7, 27),
		Size = UDim2.new(1, -14, 0, 6),
		BackgroundColor3 = Color3.fromRGB(58, 58, 65),
		BorderSizePixel = 0,
	}, holder)

	corner(bar, 4)

	local ratio = math.clamp(
		(initial - minValue) / math.max(maxValue - minValue, 0.0001),
		0,
		1
	)

	local fill = make("Frame", {
		Size = UDim2.new(ratio, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(235, 40, 60),
		BorderSizePixel = 0,
	}, bar)

	corner(fill, 4)

	local knob = make("Frame", {
		Size = UDim2.fromOffset(11, 11),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(ratio, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	}, bar)

	corner(knob, 7)

	local dragging = false
	local activeTouch

	local function update(x)
		local width = math.max(bar.AbsoluteSize.X, 1)

		local r = math.clamp(
			(x - bar.AbsolutePosition.X) / width,
			0,
			1
		)

		local value = math.floor(
			(minValue + (maxValue - minValue) * r) * 100 + 0.5
		) / 100

		fill.Size = UDim2.new(r, 0, 1, 0)
		knob.Position = UDim2.new(r, 0, 0.5, 0)

		label.Text = labelText .. ": " .. tostring(value)

		callback(value)
	end

	local function start(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			activeTouch = nil
			update(input.Position.X)
		elseif input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			activeTouch = input
			update(input.Position.X)
		end
	end

	bar.InputBegan:Connect(start)
	knob.InputBegan:Connect(start)

	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			and not activeTouch then
			update(input.Position.X)
		elseif input.UserInputType == Enum.UserInputType.Touch
			and input == activeTouch then
			update(input.Position.X)
		end
	end))

	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or (activeTouch and input == activeTouch) then
			dragging = false
			activeTouch = nil
		end
	end))

	registerSectionItem(holder)

	return holder
end

--==================================================
-- ESP
--==================================================

local function createESPLine(parent)
	local line = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = cfg.ESPLineColor,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(1, 1),
		Visible = false,
		ZIndex = 50,
	}, parent)

	return line
end

local function setLine(line, from, to)
	if not line then
		return
	end

	local delta = to - from
	local length = delta.Magnitude

	if length <= 1 then
		line.Visible = false
		return
	end

	line.Visible = true
	line.Position = UDim2.fromOffset(
		(from.X + to.X) / 2,
		(from.Y + to.Y) / 2
	)

	line.Size = UDim2.fromOffset(
		cfg.ESPLineThickness,
		length
	)

	line.Rotation = math.deg(math.atan2(delta.Y, delta.X)) + 90
end

local function make2DBox(parent)
	local holder = make("Frame", {
		Name = "Box",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 40,
	}, parent)

	local top = make("Frame", {
		BackgroundColor3 = cfg.ESPOutlineColor,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.new(1, 0, 0, cfg.ESPOutlineThickness),
	}, holder)

	local bottom = make("Frame", {
		BackgroundColor3 = cfg.ESPOutlineColor,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -cfg.ESPOutlineThickness),
		Size = UDim2.new(1, 0, 0, cfg.ESPOutlineThickness),
	}, holder)

	local left = make("Frame", {
		BackgroundColor3 = cfg.ESPOutlineColor,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.new(0, cfg.ESPOutlineThickness, 1, 0),
	}, holder)

	local right = make("Frame", {
		BackgroundColor3 = cfg.ESPOutlineColor,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -cfg.ESPOutlineThickness, 0, 0),
		Size = UDim2.new(0, cfg.ESPOutlineThickness, 1, 0),
	}, holder)

	return holder, {top, bottom, left, right}
end

local function makeCornerBox(parent)
	local holder = make("Frame", {
		Name = "CornerBox",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 41,
	}, parent)

	local thickness = math.max(1, cfg.ESPOutlineThickness)
	local cornerSize = 0.25

	local pieces = {}

	local function piece(position, size)
		local p = make("Frame", {
			BackgroundColor3 = cfg.ESPOutlineColor,
			BorderSizePixel = 0,
			Position = position,
			Size = size,
		}, holder)

		table.insert(pieces, p)
	end

	piece(
		UDim2.fromScale(0, 0),
		UDim2.new(cornerSize, 0, 0, thickness)
	)

	piece(
		UDim2.fromScale(0, 0),
		UDim2.new(0, thickness, cornerSize, 0)
	)

	piece(
		UDim2.new(1 - cornerSize, 0, 0, 0),
		UDim2.new(cornerSize, 0, 0, thickness)
	)

	piece(
		UDim2.new(1 - 0, -thickness, 0, 0),
		UDim2.new(0, thickness, cornerSize, 0)
	)

	piece(
		UDim2.new(0, 0, 1, -thickness),
		UDim2.new(cornerSize, 0, 0, thickness)
	)

	piece(
		UDim2.new(0, 0, 1 - cornerSize, 0),
		UDim2.new(0, thickness, cornerSize, 0)
	)

	piece(
		UDim2.new(1 - cornerSize, 0, 1, -thickness),
		UDim2.new(cornerSize, 0, 0, thickness)
	)

	piece(
		UDim2.new(1, -thickness, 1 - cornerSize, 0),
		UDim2.new(0, thickness, cornerSize, 0)
	)

	return holder, pieces
end

local function createESPEntry(otherPlayer)
	if otherPlayer == player then
		return
	end

	local character = otherPlayer.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")

	if not humanoid or not root then
		return
	end

	local billboard = make("BillboardGui", {
		Name = "S1lentESP",
		Adornee = root,
		AlwaysOnTop = true,
		LightInfluence = 0,
		Size = UDim2.fromOffset(90, 150),
		StudsOffset = Vector3.new(0, 1.7, 0),
		Enabled = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, espFolder)

	local box, boxParts = make2DBox(billboard)
	local cornerBox, cornerParts = makeCornerBox(billboard)

	local info = make("Frame", {
		Name = "Info",
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, -80, 0, -38),
		Size = UDim2.fromOffset(160, 36),
	}, billboard)

	local nameLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		Text = otherPlayer.DisplayName,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextStrokeTransparency = 0.4,
	}, info)

	local healthLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 13),
		Size = UDim2.new(1, 0, 0, 12),
		Text = "HP: 100",
		Font = Enum.Font.Gotham,
		TextSize = 9,
		TextColor3 = cfg.ESPHealthColor,
		TextStrokeTransparency = 0.4,
	}, info)

	local extraLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 24),
		Size = UDim2.new(1, 0, 0, 12),
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = cfg.ESPDistanceTextSize,
		TextColor3 = Color3.fromRGB(220, 220, 225),
		TextStrokeTransparency = 0.4,
	}, info)

	local line = createESPLine(gui)

	-- 3D box
	local boxAdornment = make("BoxHandleAdornment", {
		Name = "S1lent3DBox",
		Adornee = root,
		AlwaysOnTop = true,
		ZIndex = 5,
		Size = Vector3.new(4, 6, 2),
		Color3 = cfg.ESPFillColor,
		Transparency = cfg.ESPFillTransparency,
		Visible = false,
	}, espFolder)

	local headAdornment

	if head then
		headAdornment = make("BoxHandleAdornment", {
			Name = "S1lentHeadBox",
			Adornee = head,
			AlwaysOnTop = true,
			ZIndex = 6,
			Size = head.Size * 1.1,
			Color3 = cfg.CombatESPHeadColor,
			Transparency = cfg.ESPFillTransparency,
			Visible = false,
		}, espFolder)
	end

	local highlight = make("Highlight", {
		Name = "S1lentHighlight",
		Adornee = character,
		FillColor = cfg.ESPFillColor,
		FillTransparency = cfg.ESPFillTransparency,
		OutlineColor = cfg.ESPOutlineColor,
		OutlineTransparency = cfg.ESPOutlineTransparency,
		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
		Enabled = false,
	}, espFolder)

	-- Skeleton
	local skeletonFolder = make("Folder", {
		Name = "Skeleton",
	}, espFolder)

	local skeletonParts = {}

	local function addSkeletonPart(a, b)
		local attachment0 = a:FindFirstChild("S1lentESP_A0")

		if not attachment0 then
			attachment0 = make("Attachment", {
				Name = "S1lentESP_A0",
			}, a)
		end

		local attachment1 = b:FindFirstChild("S1lentESP_A1")

		if not attachment1 then
			attachment1 = make("Attachment", {
				Name = "S1lentESP_A1",
			}, b)
		end

		local beam = make("Beam", {
			Attachment0 = attachment0,
			Attachment1 = attachment1,
			FaceCamera = true,
			Width0 = 0.035,
			Width1 = 0.035,
			Color = ColorSequence.new(cfg.ESPOutlineColor),
			Transparency = NumberSequence.new(cfg.ESPOutlineTransparency),
			LightEmission = 1,
			Enabled = false,
		}, skeletonFolder)

		table.insert(skeletonParts, beam)
	end

	local upperTorso = character:FindFirstChild("UpperTorso")
	local lowerTorso = character:FindFirstChild("LowerTorso")

	if head and upperTorso then
		addSkeletonPart(head, upperTorso)
	end

	if upperTorso and lowerTorso then
		addSkeletonPart(upperTorso, lowerTorso)
	end

	local leftUpperArm = character:FindFirstChild("LeftUpperArm")
	local leftLowerArm = character:FindFirstChild("LeftLowerArm")
	local leftHand = character:FindFirstChild("LeftHand")

	local rightUpperArm = character:FindFirstChild("RightUpperArm")
	local rightLowerArm = character:FindFirstChild("RightLowerArm")
	local rightHand = character:FindFirstChild("RightHand")

	local leftUpperLeg = character:FindFirstChild("LeftUpperLeg")
	local leftLowerLeg = character:FindFirstChild("LeftLowerLeg")
	local leftFoot = character:FindFirstChild("LeftFoot")

	local rightUpperLeg = character:FindFirstChild("RightUpperLeg")
	local rightLowerLeg = character:FindFirstChild("RightLowerLeg")
	local rightFoot = character:FindFirstChild("RightFoot")

	if upperTorso and leftUpperArm then
		addSkeletonPart(upperTorso, leftUpperArm)
	end

	if leftUpperArm and leftLowerArm then
		addSkeletonPart(leftUpperArm, leftLowerArm)
	end

	if leftLowerArm and leftHand then
		addSkeletonPart(leftLowerArm, leftHand)
	end

	if upperTorso and rightUpperArm then
		addSkeletonPart(upperTorso, rightUpperArm)
	end

	if rightUpperArm and rightLowerArm then
		addSkeletonPart(rightUpperArm, rightLowerArm)
	end

	if rightLowerArm and rightHand then
		addSkeletonPart(rightLowerArm, rightHand)
	end

	if lowerTorso and leftUpperLeg then
		addSkeletonPart(lowerTorso, leftUpperLeg)
	end

	if leftUpperLeg and leftLowerLeg then
		addSkeletonPart(leftUpperLeg, leftLowerLeg)
	end

	if leftLowerLeg and leftFoot then
		addSkeletonPart(leftLowerLeg, leftFoot)
	end

	if lowerTorso and rightUpperLeg then
		addSkeletonPart(lowerTorso, rightUpperLeg)
	end

	if rightUpperLeg and rightLowerLeg then
		addSkeletonPart(rightUpperLeg, rightLowerLeg)
	end

	if rightLowerLeg and rightFoot then
		addSkeletonPart(rightLowerLeg, rightFoot)
	end

	local entry = {
		player = otherPlayer,
		character = character,
		humanoid = humanoid,
		root = root,
		head = head,

		billboard = billboard,
		box = box,
		boxParts = boxParts,
		cornerBox = cornerBox,
		cornerParts = cornerParts,

		info = info,
		nameLabel = nameLabel,
		healthLabel = healthLabel,
		extraLabel = extraLabel,

		line = line,

		boxAdornment = boxAdornment,
		headAdornment = headAdornment,
		highlight = highlight,

		skeletonParts = skeletonParts,
	}

	table.insert(espObjects, entry)
end

local function clearESP()
	if espFolder then
		espFolder:Destroy()
		espFolder = nil
	end

	for _, entry in ipairs(espObjects) do
		if entry.line and entry.line.Parent then
			entry.line:Destroy()
		end
	end

	table.clear(espObjects)
end

local function getESPColor()
	if cfg.ESPUseRGB then
		return espRGBColor
	end

	return cfg.ESPFillColor
end

local function updateESPEntry(entry)
	local otherPlayer = entry.player
	local character = otherPlayer.Character

	if not character or not character.Parent then
		entry.billboard.Enabled = false
		entry.boxAdornment.Visible = false
		entry.highlight.Enabled = false
		if entry.headAdornment then
			entry.headAdornment.Visible = false
		end
		entry.line.Visible = false

		for _, beam in ipairs(entry.skeletonParts) do
			beam.Enabled = false
		end

		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")

	if not humanoid or not root then
		entry.billboard.Enabled = false
		entry.boxAdornment.Visible = false
		entry.highlight.Enabled = false
		entry.line.Visible = false
		return
	end

	entry.humanoid = humanoid
	entry.root = root
	entry.head = head

	if cfg.ESPHideSelf and otherPlayer == player then
		entry.billboard.Enabled = false
		entry.boxAdornment.Visible = false
		entry.highlight.Enabled = false
		entry.line.Visible = false
		return
	end

	if cfg.ESPHideDead and humanoid.Health <= 0 then
		entry.billboard.Enabled = false
		entry.boxAdornment.Visible = false
		entry.highlight.Enabled = false

		if entry.headAdornment then
			entry.headAdornment.Visible = false
		end

		entry.line.Visible = false

		for _, beam in ipairs(entry.skeletonParts) do
			beam.Enabled = false
		end

		return
	end

	local localRoot = getRoot()

	if not localRoot then
		return
	end

	local distance = (root.Position - localRoot.Position).Magnitude

	if distance > cfg.ESPMaxDistance then
		entry.billboard.Enabled = false
		entry.boxAdornment.Visible = false
		entry.highlight.Enabled = false
		entry.line.Visible = false

		if entry.headAdornment then
			entry.headAdornment.Visible = false
		end

		for _, beam in ipairs(entry.skeletonParts) do
			beam.Enabled = false
		end

		return
	end

	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	local viewportPoint, onScreen = camera:WorldToViewportPoint(root.Position)

	if not onScreen or viewportPoint.Z <= 0 then
		entry.billboard.Enabled = false
		entry.boxAdornment.Visible = false
		entry.highlight.Enabled = false
		entry.line.Visible = false

		if entry.headAdornment then
			entry.headAdornment.Visible = false
		end

		for _, beam in ipairs(entry.skeletonParts) do
			beam.Enabled = false
		end

		return
	end

	local espColor = getESPColor()

	-- 3D BOX / HIGHLIGHT
	entry.boxAdornment.Color3 = espColor
	entry.boxAdornment.Transparency = cfg.ESPFillTransparency
	entry.boxAdornment.Visible = cfg.ESP3DBox

	entry.highlight.FillColor = cfg.ESPFillColor
	entry.highlight.FillTransparency = cfg.ESPFillTransparency
	entry.highlight.OutlineColor = cfg.ESPOutlineColor
	entry.highlight.OutlineTransparency = cfg.ESPOutlineTransparency
	entry.highlight.Enabled = cfg.ESP3DBox

	if entry.headAdornment and head then
		entry.headAdornment.Adornee = head
		entry.headAdornment.Size = head.Size * cfg.ESPScale
		entry.headAdornment.Color3 =
			cfg.ESPUseRGB and espColor or cfg.CombatESPHeadColor
		entry.headAdornment.Transparency = cfg.ESPFillTransparency
		entry.headAdornment.Visible = cfg.ESP3DBox
	end

	-- 2D / CORNER BOX
	entry.billboard.Enabled =
		cfg.ESP2DBox
		or cfg.ESPCornerBox
		or cfg.ESPName
		or cfg.ESPHealth
		or cfg.ESPTeam
		or cfg.ESPState
		or cfg.ESPDistance

	entry.box.Visible = cfg.ESP2DBox
	entry.cornerBox.Visible = cfg.ESPCornerBox

	for _, part in ipairs(entry.boxParts) do
		part.BackgroundColor3 = cfg.ESPOutlineColor
		part.BackgroundTransparency = cfg.ESPOutlineTransparency
	end

	for _, part in ipairs(entry.cornerParts) do
		part.BackgroundColor3 = cfg.ESPOutlineColor
		part.BackgroundTransparency = cfg.ESPOutlineTransparency
	end

	-- INFO
	entry.nameLabel.Visible = cfg.ESPName
	entry.healthLabel.Visible = cfg.ESPHealth

	local health = math.max(0, humanoid.Health)
	local maxHealth = math.max(1, humanoid.MaxHealth)
	local hpPercent = math.clamp(health / maxHealth, 0, 1)

	entry.nameLabel.Text = otherPlayer.DisplayName

	entry.healthLabel.Text = string.format(
		"HP: %d / %d",
		math.floor(health + 0.5),
		math.floor(maxHealth + 0.5)
	)

	entry.healthLabel.TextColor3 = cfg.ESPHealthColor

	local extra = {}

	if cfg.ESPTeam then
		local teamName = otherPlayer.Team
			and otherPlayer.Team.Name
			or "No Team"

		table.insert(extra, teamName)
	end

	if cfg.ESPState then
		local state = humanoid:GetState()
		table.insert(extra, state.Name)
	end

	if cfg.ESPDistance then
		table.insert(extra, string.format("%d studs", math.floor(distance + 0.5)))
	end

	entry.extraLabel.Visible = #extra > 0
	entry.extraLabel.Text = table.concat(extra, "  •  ")
	entry.extraLabel.TextSize = cfg.ESPDistanceTextSize

	-- LINE
	if cfg.ESPLines then
		local targetPosition = camera:WorldToViewportPoint(root.Position)

		setLine(
			entry.line,
			Vector2.new(
				camera.ViewportSize.X / 2,
				camera.ViewportSize.Y
			),
			Vector2.new(
				targetPosition.X,
				targetPosition.Y
			)
		)

		entry.line.BackgroundColor3 = cfg.ESPLineColor
		entry.line.Size = UDim2.fromOffset(
			cfg.ESPLineThickness,
			entry.line.AbsoluteSize.Y
		)
	else
		entry.line.Visible = false
	end

	-- SKELETON
	for _, beam in ipairs(entry.skeletonParts) do
		beam.Enabled = cfg.ESPSkeleton
		beam.Color = ColorSequence.new(cfg.ESPOutlineColor)
		beam.Width0 = math.max(0.01, cfg.ESPOutlineThickness * 0.018)
		beam.Width1 = math.max(0.01, cfg.ESPOutlineThickness * 0.018)
		beam.Transparency = NumberSequence.new(cfg.ESPOutlineTransparency)
	end
end

local function createESP()
	clearESP()

	if not cfg.CombatESPEnabled then
		return
	end

	espFolder = make("Folder", {
		Name = "S1lentCombatESP",
	}, workspace)

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			createESPEntry(otherPlayer)
		end
	end

	espLastUpdate = 0
end

local function updateESP(dt)
	if not cfg.CombatESPEnabled or not espFolder then
		return
	end

	local updateRate = math.max(
		1,
		cfg.ESPLowEnd and math.min(cfg.ESPUpdateRate, 15) or cfg.ESPUpdateRate
	)

	local interval = 1 / updateRate

	espLastUpdate += dt

	if espLastUpdate < interval then
		return
	end

	espLastUpdate = 0

	for _, entry in ipairs(espObjects) do
		if entry then
			updateESPEntry(entry)
		end
	end
end

--==================================================
-- SKYBOX
--==================================================

local function toggleSkybox()
	if skyboxEnabled then
		skyboxEnabled = false

		if customSky then
			customSky:Destroy()
			customSky = nil
		end

		if skyAtmosphere then
			skyAtmosphere:Destroy()
			skyAtmosphere = nil
		end

		if previousSky and previousSky.Parent == nil then
			previousSky.Parent = Lighting
		end

		previousSky = nil

		return
	end

	previousSky = Lighting:FindFirstChildOfClass("Sky")

	-- Remove every Sky so the old textured sky cannot bleed through.
	for _, obj in ipairs(Lighting:GetChildren()) do
		if obj:IsA("Sky") then
			if not previousSky then previousSky = obj end
			obj.Parent = nil
		end
	end

	skyAtmosphere = Instance.new("Atmosphere")
	skyAtmosphere.Name = "S1lentSolidSky"
	skyAtmosphere.Offset = 0
	skyAtmosphere.Glare = 0
	skyAtmosphere.Haze = 0
	skyAtmosphere.Density = 1
	skyAtmosphere.Parent = Lighting

	skyboxEnabled = true
	applySkyboxTint()
end

--==================================================
-- JUMP CIRCLE
--==================================================

local function createJumpCircle()
	if not cfg.JumpCircleEnabled then
		return
	end

	local char = getCharacter()
	local root = getRoot(char)

	if not char or not root then
		return
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {char}

	local result = workspace:Raycast(
		root.Position,
		Vector3.new(0, -12, 0),
		params
	)

	if not result then
		return
	end

	local center = result.Position + result.Normal * 0.06

	local ring = Instance.new("Model")
	ring.Name = "S1lentJumpCircle"
	ring.Parent = workspace

	local count = 24
	local duration = math.max(0.15, cfg.JumpCircleDuration)

	for i = 1, count do
		local angle = (i - 1) / count * math.pi * 2

		local dot = make("Part", {
			Shape = Enum.PartType.Ball,

			Size = Vector3.new(
				cfg.JumpCircleThickness,
				cfg.JumpCircleThickness,
				cfg.JumpCircleThickness
			),

			Anchored = true,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
			CastShadow = false,

			Material = Enum.Material.Neon,
			Color = colorFor("Jump"),

			Position = center + Vector3.new(
				math.cos(angle) * 0.45,
				0,
				math.sin(angle) * 0.45
			),
		}, ring)

		TweenService:Create(
			dot,
			TweenInfo.new(
				duration,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Position = center + Vector3.new(
					math.cos(angle) * cfg.JumpCircleSize,
					0,
					math.sin(angle) * cfg.JumpCircleSize
				),

				Transparency = 1,

				Size = Vector3.new(
					0.025,
					0.025,
					0.025
				),
			}
		):Play()
	end

	Debris:AddItem(ring, duration + 0.15)
end

local function connectJumpCircle(char)
	if jumpConnection then
		jumpConnection:Disconnect()
		jumpConnection = nil
	end

	local humanoid = char:WaitForChild("Humanoid", 8)

	if not humanoid then
		return
	end

	wasAirborne = false

	jumpConnection = humanoid.StateChanged:Connect(function(_, state)
		if state == Enum.HumanoidStateType.Jumping
			or state == Enum.HumanoidStateType.Freefall then

			wasAirborne = true

		elseif state == Enum.HumanoidStateType.Landed and wasAirborne then
			wasAirborne = false
			createJumpCircle()
		end
	end)
end

--==================================================
-- PLAYER TRAIL
--==================================================

local function setupTrail(char)
	if trail then trail:Destroy() end
	if leftAttachment then leftAttachment:Destroy() end
	if rightAttachment then rightAttachment:Destroy() end

	trail, leftAttachment, rightAttachment = nil, nil, nil

	local root = char:WaitForChild("HumanoidRootPart", 8)

	if not root or char ~= getCharacter() then
		return
	end

	leftAttachment = make("Attachment", {
		Name = "S1lentRibbonLeft",
		Position = Vector3.new(-0.8, 0.1, 0.75),
	}, root)

	rightAttachment = make("Attachment", {
		Name = "S1lentRibbonRight",
		Position = Vector3.new(0.8, 0.1, 0.75),
	}, root)

	trail = make("Trail", {
		Name = "S1lentRibbonTrail",
		Attachment0 = leftAttachment,
		Attachment1 = rightAttachment,

		Enabled = cfg.TrailEnabled,
		FaceCamera = true,

		LightEmission = 0.8,
		LightInfluence = 0,

		Lifetime = cfg.TrailLifetime,
		MinLength = 0.05,

		WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, cfg.TrailWidth),
			NumberSequenceKeypoint.new(1, 0.05),
		}),

		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, cfg.TrailTransparency),
			NumberSequenceKeypoint.new(1, 1),
		}),

		Color = ColorSequence.new(colorFor("Trail")),
	}, root)
end

local function refreshTrail()
	if not trail then
		return
	end

	trail.Enabled = cfg.TrailEnabled
	trail.Lifetime = cfg.TrailLifetime
	trail.Color = ColorSequence.new(colorFor("Trail"))

	trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, cfg.TrailWidth),
		NumberSequenceKeypoint.new(1, 0.05),
	})

	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, cfg.TrailTransparency),
		NumberSequenceKeypoint.new(1, 1),
	})
end

--==================================================
-- GHOST AFTERIMAGES
--==================================================

local function createGhost()
	if ghostCount >= MAX_GHOSTS then
		return
	end

	local char = getCharacter()

	if not char then
		return
	end

	local oldArchivable = char.Archivable
	char.Archivable = true

	local success, ghost = pcall(function()
		return char:Clone()
	end)

	char.Archivable = oldArchivable

	if not success or not ghost then
		return
	end

	ghost.Name = "S1lentGhostSilhouette"

	for _, item in ipairs(ghost:GetDescendants()) do
		if item:IsA("Accessory")
			or item:IsA("Tool")
			or item:IsA("Humanoid")
			or item:IsA("Animator")
			or item:IsA("Script")
			or item:IsA("LocalScript")
			or item:IsA("ModuleScript")
			or item:IsA("Decal")
			or item:IsA("Texture")
			or item:IsA("SurfaceAppearance")
			or item:IsA("Shirt")
			or item:IsA("Pants")
			or item:IsA("ShirtGraphic")
			or item:IsA("BodyColors") then

			item:Destroy()
		end
	end

	local partCount = 0
	local color = colorFor("Ghost")
	local outlineMode = cfg.GhostMode == "Outline"

	for _, item in ipairs(ghost:GetDescendants()) do
		if item:IsA("BasePart") then
			if item.Name == "HumanoidRootPart" then
				item:Destroy()
			else
				partCount += 1

				item.Anchored = true
				item.CanCollide = false
				item.CanTouch = false
				item.CanQuery = false

				item.Material = Enum.Material.Neon
				item.Color = color

				if item:IsA("MeshPart") then
					pcall(function()
						item.TextureID = ""
					end)
				end

				for _, sub in ipairs(item:GetChildren()) do
					if sub:IsA("SpecialMesh") then
						pcall(function()
							sub.TextureId = ""
						end)
					end
				end

				item.Transparency =
					outlineMode
					and 0.96
					or cfg.GhostTransparency
			end
		end
	end

	if partCount == 0 then
		ghost:Destroy()
		return
	end

	ghost.Parent = workspace
	ghostCount += 1

	local highlight

	if outlineMode then
		highlight = make("Highlight", {
			Adornee = ghost,
			FillTransparency = 1,
			OutlineColor = color,
			OutlineTransparency = cfg.GhostOutlineTransparency,
			DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
		}, ghost)
	end

	local fade = TweenInfo.new(
		cfg.GhostLifetime,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	for _, item in ipairs(ghost:GetDescendants()) do
		if item:IsA("BasePart") then
			TweenService:Create(
				item,
				fade,
				{Transparency = 1}
			):Play()
		end
	end

	if highlight then
		TweenService:Create(
			highlight,
			fade,
			{OutlineTransparency = 1}
		):Play()
	end

	Debris:AddItem(
		ghost,
		cfg.GhostLifetime + 0.15
	)

	task.delay(
		cfg.GhostLifetime + 0.2,
		function()
			ghostCount = math.max(
				0,
				ghostCount - 1
			)
		end
	)
end

--==================================================
-- ORBIT OBJECTS
--==================================================

local function makeOrbitPart(parent, name, size, color, material, shape)
	return make("Part", {
		Name = name,
		Size = size,
		Color = color,
		Material = material or Enum.Material.Neon,
		Shape = shape or Enum.PartType.Block,
		Anchored = true,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
		CastShadow = false,
		Massless = true,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
	}, parent)
end

local function buildSword()
	local model = Instance.new("Model")
	model.Name = "S1lentOrbitSword"

	local handle = makeOrbitPart(
		model,
		"Handle",
		Vector3.new(0.18, 0.8, 0.18),
		Color3.fromRGB(35, 35, 42),
		Enum.Material.Metal
	)

	handle.CFrame = CFrame.new(0, -0.55, 0)

	local guard = makeOrbitPart(
		model,
		"Guard",
		Vector3.new(0.75, 0.13, 0.2),
		colorFor("Orbit")
	)

	guard.CFrame = CFrame.new(0, -0.08, 0)

	local blade = makeOrbitPart(
		model,
		"Blade",
		Vector3.new(0.25, 1.5, 0.12),
		colorFor("Orbit")
	)

	blade.CFrame = CFrame.new(0, 0.75, 0)

	local tip = makeOrbitPart(
		model,
		"Tip",
		Vector3.new(0.18, 0.25, 0.12),
		colorFor("Orbit")
	)

	tip.CFrame =
		CFrame.new(0, 1.6, 0)
		* CFrame.Angles(0, 0, math.rad(45))

	model.PrimaryPart = handle
	model.Parent = workspace

	return model
end

local function buildGhostParticle(parent)
	local model = Instance.new("Model")
	model.Name = "S1lentOrbitGhost"

	local body = makeOrbitPart(
		model,
		"GhostOrb",
		Vector3.new(0.62, 0.62, 0.62),
		colorFor("Orbit"),
		Enum.Material.Neon,
		Enum.PartType.Ball
	)

	make("PointLight", {
		Color = colorFor("Orbit"),
		Brightness = 1.4,
		Range = 8,
		Shadows = false,
	}, body)

	local a0 = make("Attachment", {
		Name = "GhostTrailStart",
		Position = Vector3.new(0, 0, 0.18),
	}, body)

	local a1 = make("Attachment", {
		Name = "GhostTrailEnd",
		Position = Vector3.new(0, 0, -0.18),
	}, body)

	make("Trail", {
		Name = "S1lentGhostTail",
		Attachment0 = a0,
		Attachment1 = a1,
		Enabled = true,
		FaceCamera = true,
		Lifetime = 0.45,
		MinLength = 0.02,
		LightEmission = 1,
		LightInfluence = 0,

		WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.22),
			NumberSequenceKeypoint.new(0.35, 0.13),
			NumberSequenceKeypoint.new(1, 0),
		}),

		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.05),
			NumberSequenceKeypoint.new(1, 1),
		}),

		Color = ColorSequence.new(colorFor("Orbit")),
	}, body)

	model.PrimaryPart = body
	model.Parent = parent or workspace

	return model
end

local function buildDiamond(parent, name, size, color)
	local model = make("Model", {
		Name = name
	}, parent)

	local s = math.max(0.15, size)

	local top = makeOrbitPart(
		model,
		"CrystalTop",
		Vector3.new(s, s, s),
		color
	)

	top.Shape = Enum.PartType.Ball
	top.Size = Vector3.new(
		s * 0.35,
		s * 0.35,
		s * 0.35
	)

	local first

	for ring = 1, 2 do
		for i = 1, 4 do
			local angle = (i - 1) * math.pi / 2

			local wedge = make("WedgePart", {
				Name =
					ring == 1
					and "UpperFacet"
					or "LowerFacet",

				Size = Vector3.new(
					s * 0.7,
					s * 0.65,
					s * 0.7
				),

				Anchored = true,
				CanCollide = false,
				CanTouch = false,
				CanQuery = false,
				CastShadow = false,

				Material = Enum.Material.Neon,
				Color = color,

				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
			}, model)

			local y =
				ring == 1
				and s * 0.22
				or -s * 0.22

			local tilt =
				ring == 1
				and math.rad(180)
				or 0

			wedge.CFrame =
				CFrame.new(0, y, 0)
				* CFrame.Angles(
					tilt,
					angle,
					math.rad(45)
				)

			first = first or wedge
		end
	end

	model.PrimaryPart = first or top

	return model
end

local function clearOrbitObjects()
	clearList(orbitObjects)
end

local function rebuildOrbitObjects()
	clearOrbitObjects()

	if not cfg.OrbitEnabled then
		return
	end

	local count = math.clamp(
		math.floor(cfg.OrbitCount + 0.5),
		1,
		12
	)

	for _ = 1, count do
		local model

		if cfg.OrbitType == "Swords" then
			model = buildSword()
		elseif cfg.OrbitType == "Ghosts" then
			model = buildGhostParticle(workspace)
		else
			model = buildDiamond(
				workspace,
				"S1lentOrbitCrystal",
				cfg.CrystalSize,
				colorFor("Crystal")
			)
		end

		table.insert(orbitObjects, model)
	end
end

--==================================================
-- PULSE RING
--==================================================

local function clearPulseRing()
	clearList(pulseSegments)

	if pulseFolder then
		pulseFolder:Destroy()
		pulseFolder = nil
	end
end

local function createPulseRing()
	clearPulseRing()

	if not cfg.PulseRingEnabled then
		return
	end

	pulseFolder = make("Folder", {
		Name = "S1lentPulseRing",
	}, workspace)

	for _ = 1, 48 do
		local segment = make("Part", {
			Name = "RingSegment",

			Size = Vector3.new(
				0.2,
				cfg.PulseRingThickness,
				0.25
			),

			Anchored = true,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
			CastShadow = false,

			Material = Enum.Material.Neon,
			Color = colorFor("Pulse"),
			Transparency = cfg.PulseRingTransparency,
		}, pulseFolder)

		table.insert(pulseSegments, segment)
	end
end

local function createPulseTrailSnapshot()
	if not cfg.PulseRingTrail
		or #pulseSegments == 0 then
		return
	end

	local snapshot = make("Folder", {
		Name = "S1lentPulseTrail",
	}, workspace)

	for _, segment in ipairs(pulseSegments) do
		if segment and segment.Parent then
			local copy = segment:Clone()

			copy.Parent = snapshot
			copy.Anchored = true
			copy.CanCollide = false
			copy.CanTouch = false
			copy.CanQuery = false

			TweenService:Create(
				copy,
				TweenInfo.new(
					cfg.PulseRingTrailLifetime
				),
				{
					Transparency = 1,
					Size = Vector3.new(
						0.01,
						0.01,
						0.01
					),
				}
			):Play()
		end
	end

	Debris:AddItem(
		snapshot,
		cfg.PulseRingTrailLifetime + 0.1
	)
end

local function updatePulseRing(dt, root)
	if not cfg.PulseRingEnabled
		or #pulseSegments == 0 then
		return
	end

	pulseAngle += dt * cfg.PulseRingSpeed
	pulseTime += dt
	pulseTrailTimer += dt

	local pulse = 1
		+ math.sin(
			pulseTime
			* cfg.PulseRingPulseSpeed
			* math.pi
			* 2
		)
		* cfg.PulseRingPulseAmount

	local radius = math.max(
		0.1,
		cfg.PulseRingRadius * pulse
	)

	local char = getCharacter()
	local humanoid =
		char
		and char:FindFirstChildOfClass("Humanoid")

	local footOffset =
		humanoid
		and humanoid.HipHeight + 1
		or 2.65

	local center =
		root.Position
		- Vector3.new(0, footOffset, 0)

	for index, segment in ipairs(pulseSegments) do
		local angle =
			index / #pulseSegments
			* math.pi
			* 2
			+ pulseAngle

		local position =
			center
			+ Vector3.new(
				math.cos(angle) * radius,
				0,
				math.sin(angle) * radius
			)

		segment.Color = colorFor("Pulse")
		segment.Transparency =
			cfg.PulseRingTransparency

		segment.Size = Vector3.new(
			math.max(
				0.04,
				radius * 0.08
			),
			cfg.PulseRingThickness,
			math.max(
				0.08,
				radius * 0.32
			)
		)

		segment.CFrame = CFrame.lookAt(
			position,
			position
				+ Vector3.new(
					-math.sin(angle),
					0,
					math.cos(angle)
				)
		)
	end

	if cfg.PulseRingTrail
		and pulseTrailTimer >= 0.12 then

		pulseTrailTimer = 0
		createPulseTrailSnapshot()
	end
end

--==================================================
-- HUD PANELS
--==================================================

local function makeHudPanel(
	name,
	width,
	height,
	position,
	text
)
	local panel = make("Frame", {
		Name = name,

		Size = UDim2.fromOffset(
			width,
			height
		),

		Position = position,

		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.05,

		BorderSizePixel = 0,

		Visible = false,

		ZIndex = 20,
	}, gui)

	corner(panel, 16)

	make("UIStroke", {
		Color = Color3.fromRGB(45, 45, 52),
		Thickness = 1,
		Transparency = 0.15,
	}, panel)

	local label = make("TextLabel", {
		Name = "Text",

		Size = UDim2.new(
			1,
			-16,
			1,
			-8
		),

		Position = UDim2.fromOffset(
			8,
			4
		),

		BackgroundTransparency = 1,

		Text = text,

		Font = Enum.Font.GothamMedium,
		TextSize = 12,

		TextColor3 =
			Color3.fromRGB(
				245,
				245,
				250
			),

		TextXAlignment =
			Enum.TextXAlignment.Center,

		TextYAlignment =
			Enum.TextYAlignment.Center,

		TextWrapped = false,

		ZIndex = 21,
	}, panel)

	return panel, label
end

local island, islandLabel = makeHudPanel(
	"S1lentDynamicIsland",
	255,
	34,
	UDim2.new(
		cfg.IslandX,
		-127,
		cfg.IslandY,
		0
	),
	"by s1lent  |  FPS --  |  -- ms"
)

island.BackgroundTransparency =
	cfg.IslandTransparency

island.Visible = cfg.IslandEnabled

makeDraggable(island, island)

local coordinatesPanel, coordinatesLabel =
	makeHudPanel(
		"S1lentCoordinates",
		230,
		38,
		UDim2.new(
			cfg.CoordinatesX,
			0,
			cfg.CoordinatesY,
			0
		),
		"X: --   Y: --   Z: --"
	)

coordinatesPanel.BackgroundTransparency =
	cfg.CoordinatesTransparency

coordinatesPanel.Visible =
	cfg.CoordinatesEnabled

makeDraggable(
	coordinatesPanel,
	coordinatesPanel
)

local speedPanel, speedLabel =
	makeHudPanel(
		"S1lentSpeedometer",
		155,
		38,
		UDim2.new(
			cfg.SpeedX,
			0,
			cfg.SpeedY,
			0
		),
		"0.0 / сек"
	)

speedPanel.BackgroundTransparency =
	cfg.SpeedTransparency

speedPanel.Visible =
	cfg.SpeedEnabled

makeDraggable(
	speedPanel,
	speedPanel
)

local function applyPanelScale(panel, scale)
	panel.Size = UDim2.fromOffset(
		panel.AbsoluteSize.X * scale,
		panel.AbsoluteSize.Y * scale
	)
end

local function applyHudAppearance()
	island.Visible = cfg.IslandEnabled
	coordinatesPanel.Visible =
		cfg.CoordinatesEnabled
	speedPanel.Visible =
		cfg.SpeedEnabled

	island.BackgroundTransparency =
		cfg.IslandTransparency

	coordinatesPanel.BackgroundTransparency =
		cfg.CoordinatesTransparency

	speedPanel.BackgroundTransparency =
		cfg.SpeedTransparency

	island.Position = UDim2.new(
		cfg.IslandX,
		-127,
		cfg.IslandY,
		0
	)

	coordinatesPanel.Position =
		UDim2.new(
			cfg.CoordinatesX,
			0,
			cfg.CoordinatesY,
			0
		)

	speedPanel.Position =
		UDim2.new(
			cfg.SpeedX,
			0,
			cfg.SpeedY,
			0
		)
end

-- FPS is estimated from rendered frame delta.
-- Ping uses Roblox's Player:GetNetworkPing(),
-- returned in seconds and displayed as ms.

local displayedFPS = 0
local fpsAccumulator = 0
local fpsFrames = 0
local fpsUpdateAccumulator = 0

local function updateHud(dt)
	fpsAccumulator += dt
	fpsFrames += 1
	fpsUpdateAccumulator += dt

	if fpsUpdateAccumulator >= 0.35 then
		displayedFPS = math.floor(
			fpsFrames
				/ math.max(
					fpsAccumulator,
					0.001
				)
				+ 0.5
		)

		fpsAccumulator = 0
		fpsFrames = 0
		fpsUpdateAccumulator = 0

		local pingMs = math.floor(
			player:GetNetworkPing()
				* 1000
				+ 0.5
		)

		islandLabel.Text = string.format(
			"by s1lent  |  FPS %d  |  %d ms",
			displayedFPS,
			pingMs
		)
	end

	local root = getRoot()

	if not root then
		return
	end

	if cfg.CoordinatesEnabled then
		local p = root.Position

		coordinatesLabel.Text =
			string.format(
				"X: %.1f   Y: %.1f   Z: %.1f",
				p.X,
				p.Y,
				p.Z
			)
	end

	if cfg.SpeedEnabled then
		local velocity =
			root.AssemblyLinearVelocity

		local horizontalSpeed =
			Vector3.new(
				velocity.X,
				0,
				velocity.Z
			).Magnitude

		speedLabel.Text =
			string.format(
				"%.1f / сек",
				horizontalSpeed
			)
	end
end

--==================================================
-- AVATAR PREVIEW
--==================================================

local previewPanel = make("Frame", {
	ZIndex = 8,

	Position =
		UDim2.new(
			0,
			364,
			0,
			47
		),

	Size =
		UDim2.new(
			1,
			-371,
			1,
			-54
		),

	BackgroundColor3 =
		Color3.fromRGB(
			17,
			17,
			21
		),

	BorderSizePixel = 0,
	ClipsDescendants = true,
}, main)

corner(previewPanel, 8)

make("TextLabel", {
	Position =
		UDim2.fromOffset(
			8,
			5
		),

	Size =
		UDim2.new(
			1,
			-16,
			0,
			22
		),

	BackgroundTransparency = 1,

	Text = "AVATAR PREVIEW",

	Font = Enum.Font.GothamBold,
	TextSize = 11,

	TextColor3 =
		Color3.fromRGB(
			245,
			65,
			80
		),

	TextXAlignment =
		Enum.TextXAlignment.Left,
}, previewPanel)

local viewport = make("ViewportFrame", {
	Name = "AvatarViewport",

	Position =
		UDim2.fromOffset(
			7,
			30
		),

	Size =
		UDim2.new(
			1,
			-14,
			1,
			-65
		),

	BackgroundColor3 =
		Color3.fromRGB(
			11,
			11,
			15
		),

	BorderSizePixel = 0,

	Ambient =
		Color3.fromRGB(
			190,
			190,
			205
		),

	LightColor =
		Color3.fromRGB(
			255,
			235,
			235
		),

	LightDirection =
		Vector3.new(
			-1,
			-1,
			-1
		),
}, previewPanel)

corner(viewport, 7)

local previewWorld = Instance.new("WorldModel")
previewWorld.Parent = viewport

local previewCamera = Instance.new("Camera")
previewCamera.FieldOfView = 35
previewCamera.Parent = viewport

viewport.CurrentCamera = previewCamera

local previewModel
local previewYaw = math.rad(180)
local previewBasePivot = CFrame.new()

local previewDragging = false
local previewLastX = 0
local previewTouch

local previewStatus = make("TextLabel", {
	Position =
		UDim2.new(
			0,
			7,
			1,
			-31
		),

	Size =
		UDim2.new(
			1,
			-14,
			0,
			24
		),

	BackgroundTransparency = 1,

	Text = "Drag to rotate • Avatar",

	Font = Enum.Font.Gotham,
	TextSize = 9,

	TextColor3 =
		Color3.fromRGB(
			175,
			175,
			185
		),

	TextWrapped = true,
}, previewPanel)

local previewDecor = {}
local previewEffectTime = 0

local function clearPreview()
	previewModel = nil

	for _, child in ipairs(
		previewWorld:GetChildren()
	) do
		child:Destroy()
	end
end

local function clearPreviewDecor()
	clearList(previewDecor)
end

local function refreshPreview()
	local char = player.Character

	if not char then
		previewStatus.Text =
			"Waiting for character..."
		return
	end

	local oldArchivable = char.Archivable
	char.Archivable = true

	local success, clone = pcall(function()
		return char:Clone()
	end)

	char.Archivable = oldArchivable

	if not success or not clone then
		previewStatus.Text =
			"Could not load avatar"
		return
	end

	clearPreview()

	clone.Name = "S1lentAvatarPreview"

	for _, item in ipairs(
		clone:GetDescendants()
	) do
		if item:IsA("Script")
			or item:IsA("LocalScript")
			or item:IsA("ModuleScript")
			or item:IsA("Tool")
			or item:IsA("ForceField") then

			item:Destroy()

		elseif item:IsA("BasePart") then
			item.Anchored = true
			item.CanCollide = false
			item.CanTouch = false
			item.CanQuery = false
		end
	end

	local humanoid =
		clone:FindFirstChildOfClass(
			"Humanoid"
		)

	if humanoid then
		humanoid.DisplayDistanceType =
			Enum.HumanoidDisplayDistanceType.None

		humanoid.AutoRotate = false
	end

	clone.Parent = previewWorld
	previewModel = clone

	local ok, boxCFrame, boxSize =
		pcall(function()
			return clone:GetBoundingBox()
		end)

	if not ok then
		previewStatus.Text =
			"Avatar loaded"
		return
	end

	local center = boxCFrame.Position
	local height = math.max(
		boxSize.Y,
		3
	)

	previewBasePivot =
		CFrame.new(-center)
		* clone:GetPivot()

	clone:PivotTo(
		previewBasePivot
		* CFrame.Angles(
			0,
			previewYaw,
			0
		)
	)

	local distance =
		math.max(
			height * 2.3,
			6
		)

	previewCamera.CFrame =
		CFrame.lookAt(
			Vector3.new(
				0,
				height * 0.05,
				distance
			),
			Vector3.new(
				0,
				height * 0.05,
				0
			)
		)

	previewStatus.Text =
		"Drag to rotate • Effects when enabled"
end

local function rebuildPreviewDecor()
	clearPreviewDecor()

	if not cfg.PreviewEffects
		or not cfg.OrbitEnabled
		or not previewModel then
		return
	end

	for _ = 1, math.clamp(
		math.floor(
			cfg.OrbitCount + 0.5
		),
		1,
		12
	) do

		local obj

		if cfg.OrbitType == "Ghosts" then
			obj = buildGhostParticle(
				previewWorld
			)

		elseif cfg.OrbitType == "Crystals" then
			obj = buildDiamond(
				previewWorld,
				"PreviewCrystal",
				cfg.CrystalSize,
				colorFor("Crystal")
			)

		else
			obj = make("Part", {
				Name = "PreviewSwordOrb",
				Shape = Enum.PartType.Ball,
				Size =
					Vector3.new(
						0.16,
						0.16,
						0.16
					),

				Anchored = true,
				CanCollide = false,
				CanTouch = false,
				CanQuery = false,

				Material =
					Enum.Material.Neon,

				Color = colorFor("Orbit"),
			}, previewWorld)
		end

		table.insert(
			previewDecor,
			obj
		)
	end
end

local function rotatePreview(deltaX)
	if not previewModel then
		return
	end

	previewYaw += deltaX * 0.012

	previewModel:PivotTo(
		previewBasePivot
		* CFrame.Angles(
			0,
			previewYaw,
			0
		)
	)
end

viewport.InputBegan:Connect(function(input)
	if input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		previewDragging = true
		previewTouch = nil
		previewLastX = input.Position.X

	elseif input.UserInputType ==
		Enum.UserInputType.Touch then

		previewDragging = true
		previewTouch = input
		previewLastX = input.Position.X
	end
end)

table.insert(
	connections,
	UserInputService.InputChanged:Connect(
		function(input)

			if not previewDragging then
				return
			end

			if input.UserInputType ==
				Enum.UserInputType.MouseMovement
				and not previewTouch then

				local delta =
					input.Position.X
					- previewLastX

				previewLastX =
					input.Position.X

				rotatePreview(delta)

			elseif input.UserInputType ==
				Enum.UserInputType.Touch
				and input == previewTouch then

				local delta =
					input.Position.X
					- previewLastX

				previewLastX =
					input.Position.X

				rotatePreview(delta)
			end
		end
	)
)

table.insert(
	connections,
	UserInputService.InputEnded:Connect(
		function(input)

			if input.UserInputType ==
				Enum.UserInputType.MouseButton1
				or (
					previewTouch
					and input == previewTouch
				) then

				previewDragging = false
				previewTouch = nil
			end
		end
	)
)

local function updatePreviewDecor(dt)
	if not cfg.PreviewEffects
		or not cfg.OrbitEnabled
		or not previewModel then

		if #previewDecor > 0 then
			clearPreviewDecor()
		end

		return
	end

	if #previewDecor == 0 then
		rebuildPreviewDecor()
	end

	previewEffectTime += dt

	local _, size =
		previewModel:GetBoundingBox()

	local radius =
		math.max(
			size.X * 0.7,
			1.1
		)

	local height =
		math.max(
			size.Y * 0.38,
			1.2
		)

	for i, obj in ipairs(previewDecor) do
		if obj and obj.Parent then
			local angle =
				previewEffectTime
				* cfg.OrbitSpeed
				+ (i - 1)
				* math.pi
				* 2
				/ math.max(
					#previewDecor,
					1
				)

			local y =
				height
				+ math.sin(
					previewEffectTime
					* 2
					+ i
				)
				* 0.3
				- size.Y * 0.5

			local pos = Vector3.new(
				math.cos(angle) * radius,
				y,
				math.sin(angle) * radius
			)

			if obj:IsA("Model") then
				obj:PivotTo(
					CFrame.new(pos)
					* CFrame.Angles(
						0,
						-angle,
						0
					)
				)

				for _, part in ipairs(
					obj:GetDescendants()
				) do

					if part:IsA("BasePart")
						and part.Material ==
							Enum.Material.Neon then

						part.Color =
							cfg.OrbitType ==
								"Crystals"
							and colorFor("Crystal")
							or colorFor("Orbit")

					elseif part:IsA("PointLight") then
						part.Color =
							colorFor("Orbit")
					end
				end

			elseif obj:IsA("BasePart") then
				obj.Position = pos
				obj.Color =
					colorFor("Orbit")
			end
		end
	end
end

--==================================================
-- MENU PARTICLES
--==================================================

local function clearMenuParticles()
	for _, obj in ipairs(menuParticleObjects) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end
	table.clear(menuParticleObjects)
end

local function getMenuParticleGlyph(mode)
	if mode == "Sakura" then return "🌸" end
	if mode == "Autumn" then return ({"🍂", "🍁"})[menuParticleRandom:NextInteger(1,2)] end
	if mode == "Matrix" then
		local chars = "01ABCDEFGHIJKLMNOPQRSTUVWXYZ@$%<>[]{}"
		local i = menuParticleRandom:NextInteger(1, #chars)
		return chars:sub(i, i)
	end
	return ""
end

local function spawnMenuParticle()
	if cfg.MenuParticles == "Off" or not menuParticleLayer then return end

	local holder = make("Frame", {
		Name = "MenuParticle",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(menuParticleRandom:NextNumber(0.01, 0.99), 0, -0.08, 0),
		Size = UDim2.fromOffset(34, 34),
		ZIndex = 6,
	}, menuParticleLayer)
	table.insert(menuParticleObjects, holder)

	local mode = cfg.MenuParticles
	local fadeTargets = {}
	if mode == "Snow" then
		for _, spec in ipairs({{34,0.82},{26,0.72},{18,0.58},{10,0.35}}) do
			local dot = make("Frame", {AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromOffset(spec[1],spec[1]), BackgroundColor3=Color3.fromRGB(245,250,255), BackgroundTransparency=1, BorderSizePixel=0, ZIndex=6}, holder)
			corner(dot, spec[1])
			table.insert(fadeTargets, {dot, spec[2]})
		end
	elseif mode == "Sakura" then
		local label = make("TextLabel", {BackgroundTransparency=1, Size=UDim2.fromScale(1,1), Text="🌸", Font=Enum.Font.Gotham, TextSize=24, TextColor3=Color3.fromRGB(255,170,210), TextStrokeTransparency=1, TextTransparency=1, ZIndex=6}, holder)
		table.insert(fadeTargets, {label, 0})
	elseif mode == "Matrix" then
		for i=1,4 do
			local ch = make("TextLabel", {BackgroundTransparency=1, Size=UDim2.fromOffset(20,20), Position=UDim2.new(0.5,0,0,(i-1)*-9), AnchorPoint=Vector2.new(0.5,0), Text=getMenuParticleGlyph("Matrix"), Font=Enum.Font.Code, TextSize=menuParticleRandom:NextInteger(10,18), TextColor3=Color3.fromHSV(0.28 + i*0.015,0.85,1), TextTransparency=1, ZIndex=6}, holder)
		table.insert(fadeTargets, {ch, (i-1)*0.18})
		end
	else
		local label = make("TextLabel", {BackgroundTransparency=1, Size=UDim2.fromScale(1,1), Text=getMenuParticleGlyph(mode), Font=Enum.Font.Gotham, TextSize=22, TextColor3=Color3.fromRGB(245,190,90), TextStrokeTransparency=1, TextTransparency=1, ZIndex=6}, holder)
		table.insert(fadeTargets, {label, 0})
	end

	for _, pair in ipairs(fadeTargets) do
		local obj, target = pair[1], pair[2]
		local props = {}
		if obj:IsA("TextLabel") then
			props.TextTransparency = target
			props.TextStrokeTransparency = math.clamp(target + 0.45, 0, 1)
		else
			props.BackgroundTransparency = target
		end
		TweenService:Create(obj, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
	end

	local duration = math.max(2, 7 / math.max(cfg.MenuParticleSpeed,0.1))
	local drift = menuParticleRandom:NextNumber(-0.12,0.12)
	TweenService:Create(holder, TweenInfo.new(duration,Enum.EasingStyle.Linear), {
		Position=UDim2.new(math.clamp(holder.Position.X.Scale+drift,-0.05,1.05),0,1.08,0),
		Rotation=menuParticleRandom:NextInteger(-160,160)
	}):Play()

	task.delay(duration, function()
		if holder and holder.Parent then holder:Destroy() end
		for i,item in ipairs(menuParticleObjects) do
			if item==holder then table.remove(menuParticleObjects,i) break end
		end
	end)
end

local function updateMenuParticles(dt)
	if cfg.MenuParticles == "Off" or not main.Visible then
		if cfg.MenuParticles == "Off" and #menuParticleObjects > 0 then
			clearMenuParticles()
		end
		return
	end

	menuParticleAccumulator += dt
	local interval = 1 / math.max(1, cfg.MenuParticleAmount)
	while menuParticleAccumulator >= interval do
		menuParticleAccumulator -= interval
		if #menuParticleObjects < math.clamp(cfg.MenuParticleAmount, 4, 100) then
			spawnMenuParticle()
		else
			break
		end
	end
end

--==================================================
-- WORLD PARTICLES
--==================================================

local function clearWorldParticles()
	for _, obj in ipairs(worldParticleObjects) do
		if obj and obj.part and obj.part.Parent then
			obj.part:Destroy()
		end
	end
	table.clear(worldParticleObjects)

	if worldParticleFolder then
		worldParticleFolder:Destroy()
		worldParticleFolder = nil
	end
end

local function worldParticleStyle()
	local mode = cfg.WorldParticleType

	if mode == "Snow" then
		return "❄", Color3.fromRGB(235, 245, 255)
	elseif mode == "Sakura" then
		return ({ "✿", "❀", "❁" })[worldParticleRandom:NextInteger(1, 3)], Color3.fromRGB(255, 170, 205)
	elseif mode == "Autumn Leaves" then
		return ({ "🍂", "🍁", "❧" })[worldParticleRandom:NextInteger(1, 3)], Color3.fromRGB(235, 110, 45)
	elseif mode == "Fireflies" then
		return "✦", Color3.fromRGB(220, 255, 100)
	elseif mode == "Sparks" then
		return "•", Color3.fromRGB(255, 190, 70)
	elseif mode == "Dust" then
		return "•", Color3.fromRGB(190, 180, 165)
	elseif mode == "Bubbles" then
		return "○", Color3.fromRGB(130, 220, 255)
	elseif mode == "Hearts" then
		return "♥", Color3.fromRGB(255, 90, 130)
	elseif mode == "Stars" then
		return "★", Color3.fromRGB(255, 245, 150)
	elseif mode == "Matrix" then
		local chars = "01ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		local i = worldParticleRandom:NextInteger(1, #chars)
		return chars:sub(i, i), Color3.fromRGB(60, 255, 110)
	elseif mode == "Ash" then
		return "·", Color3.fromRGB(120, 120, 120)
	elseif mode == "Rain" then
		return "│", Color3.fromRGB(100, 170, 255)
	end

	return "•", cfg.WorldParticleColor
end

local function spawnWorldParticle()
	if not cfg.WorldParticlesEnabled then
		return
	end

	local root = getRoot()
	if not root then
		return
	end

	if not worldParticleFolder or not worldParticleFolder.Parent then
		worldParticleFolder = make("Folder", {
			Name = "S1lentWorldParticles",
		}, workspace)
	end

	local glyph, baseColor = worldParticleStyle()
	local angle = worldParticleRandom:NextNumber(0, math.pi * 2)
	local radius = worldParticleRandom:NextNumber(4, math.max(5, cfg.WorldParticleRadius))
	local pos = root.Position + Vector3.new(
		math.cos(angle) * radius,
		worldParticleRandom:NextNumber(1, math.max(2, cfg.WorldParticleRadius * 0.6)),
		math.sin(angle) * radius
	)

	local part = make("Part", {
		Name = "WorldParticle",
		Size = Vector3.new(0.08, 0.08, 0.08),
		Position = pos,
		Anchored = true,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
		Transparency = 1,
		CastShadow = false,
	}, worldParticleFolder)

	local billboard = make("BillboardGui", {
		Size = UDim2.fromOffset(
			22 * cfg.WorldParticleSize,
			22 * cfg.WorldParticleSize
		),
		AlwaysOnTop = true,
		LightInfluence = 0,
		StudsOffset = Vector3.new(0, 0, 0),
	}, part)

	local label = make("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = glyph,
		Font = Enum.Font.GothamBold,
		TextSize = math.floor(16 * cfg.WorldParticleSize),
		TextColor3 = baseColor,
		TextTransparency = cfg.WorldParticleTransparency,
	}, billboard)

	local speed = cfg.WorldParticleSpeed * worldParticleRandom:NextNumber(0.55, 1.45)
	local velocity

	if cfg.WorldParticleType == "Rain" then
		velocity = Vector3.new(
			worldParticleRandom:NextNumber(-1, 1) * cfg.WorldParticleWind,
			-speed * 3,
			worldParticleRandom:NextNumber(-1, 1) * cfg.WorldParticleWind
		)
	else
		velocity = Vector3.new(
			worldParticleRandom:NextNumber(-cfg.WorldParticleSpread, cfg.WorldParticleSpread) * 0.08
				+ cfg.WorldParticleWind * 0.08,
			worldParticleRandom:NextNumber(-0.25, 0.7) * speed,
			worldParticleRandom:NextNumber(-cfg.WorldParticleSpread, cfg.WorldParticleSpread) * 0.08
		)
	end

	table.insert(worldParticleObjects, {
		part = part,
		label = label,
		velocity = velocity,
		life = cfg.WorldParticleLifetime * worldParticleRandom:NextNumber(0.7, 1.3),
		age = 0,
		baseColor = baseColor,
		rotation = worldParticleRandom:NextNumber(-90, 90),
	})
end

local function updateWorldParticles(dt)
	if not cfg.WorldParticlesEnabled then
		if #worldParticleObjects > 0 then
			clearWorldParticles()
		end
		return
	end

	local root = getRoot()
	if not root then
		return
	end

	if not worldParticleFolder or not worldParticleFolder.Parent then
		worldParticleFolder = make("Folder", {
			Name = "S1lentWorldParticles",
		}, workspace)
	end

	worldParticleAccumulator += dt
	local emissionInterval = 1 / math.max(0.1, cfg.WorldParticleEmissionRate)

	while worldParticleAccumulator >= emissionInterval do
		worldParticleAccumulator -= emissionInterval
		if #worldParticleObjects < math.clamp(cfg.WorldParticleAmount, 1, 250) then
			spawnWorldParticle()
		else
			break
		end
	end

	for i = #worldParticleObjects, 1, -1 do
		local obj = worldParticleObjects[i]

		if not obj.part or not obj.part.Parent then
			table.remove(worldParticleObjects, i)
			continue
		end

		obj.age += dt
		obj.velocity += Vector3.new(
			0,
			cfg.WorldParticleGravity * dt,
			0
		)

		obj.part.Position += obj.velocity * dt
		obj.label.Rotation += 35 * dt

		if cfg.WorldParticleRainbow then
			local hue = (time() * cfg.WorldParticleRainbowSpeed + i * 0.013) % 1
			obj.label.TextColor3 = Color3.fromHSV(hue, 0.9, 1)
		else
			obj.label.TextColor3 = obj.baseColor:Lerp(
				cfg.WorldParticleColor,
				0.35
			)
		end

		if obj.age >= obj.life
			or (obj.part.Position - root.Position).Magnitude > cfg.WorldParticleRadius * 1.8 then
			obj.part:Destroy()
			table.remove(worldParticleObjects, i)
		end
	end
end

--==================================================
-- SKYBOX COLOR
--==================================================

applySkyboxTint = function()
	if not skyboxEnabled then
		return
	end

	local color = Color3.fromRGB(
		math.clamp(math.floor(cfg.SkyboxR + 0.5), 0, 255),
		math.clamp(math.floor(cfg.SkyboxG + 0.5), 0, 255),
		math.clamp(math.floor(cfg.SkyboxB + 0.5), 0, 255)
	)

	if skyAtmosphere and skyAtmosphere.Parent then
		-- Dense atmosphere turns the sky into a near-solid selected color.
		skyAtmosphere.Color = color
		skyAtmosphere.Decay = color
		skyAtmosphere.Density = 1
		skyAtmosphere.Haze = 0
		skyAtmosphere.Glare = 0
	end

	Lighting.ColorShift_Top = color
	Lighting.ColorShift_Bottom = color
	Lighting.Ambient = color
	Lighting.OutdoorAmbient = color
	Lighting.ColorShift_Bottom = color
end

--==================================================
-- ANGEL WINGS
--==================================================

local function getWingTorso(model)
	return model
		and (
			model:FindFirstChild("UpperTorso")
			or model:FindFirstChild("Torso")
			or model:FindFirstChild("HumanoidRootPart")
		)
end

local function destroyWings(model)
	if model and model.Parent then
		model:Destroy()
	end
	return nil
end

local function buildWingModel(parent, torso, previewMode)
	if not torso then
		return nil
	end

	local model = Instance.new("Model")
	model.Name = "S1lentAngelWings"
	model.Parent = parent

	local color = cfg.AngelWingsColor
	local scale = math.clamp(cfg.AngelWingsScale, 0.4, 3)

	for side = -1, 1, 2 do
		for i = 1, 4 do
			local feather = make("WedgePart", {
				Name = (side == -1 and "Left" or "Right") .. "Feather" .. i,
				Size = Vector3.new(
					0.45 * scale,
					0.8 * scale + i * 0.12 * scale,
					0.18 * scale
				),
				Material = Enum.Material.SmoothPlastic,
				Color = color,
				Anchored = previewMode,
				CanCollide = false,
				CanTouch = false,
				CanQuery = false,
				CastShadow = false,
				Massless = true,
			}, model)

			local x = side * (0.42 + i * 0.22) * scale
			local y = 0.35 - i * 0.12
			local z = 0.18 + i * 0.05

			local cf = torso.CFrame
				* CFrame.new(x, y, z)
				* CFrame.Angles(
					math.rad(side * -12),
					math.rad(side * 18),
					math.rad(side * (18 + i * 5))
				)

			feather.CFrame = cf

			if not previewMode then
				local weld = make("WeldConstraint", {
					Part0 = torso,
					Part1 = feather,
				}, feather)
			end
		end
	end

	return model
end

local function rebuildAngelWings()
	wingModel = destroyWings(wingModel)

	if not cfg.AngelWingsEnabled then
		return
	end

	local char = getCharacter()
	local torso = getWingTorso(char)

	if torso then
		wingModel = buildWingModel(char, torso, false)
	end
end

local function updateWingColors()
	local color = cfg.AngelWingsColor
	if cfg.AngelWingsRainbow then
		color = Color3.fromHSV(
			(time() * cfg.AngelWingsRainbowSpeed) % 1,
			0.9,
			1
		)
	end

	for _, model in ipairs({ wingModel, previewWingModel }) do
		if model then
			for _, item in ipairs(model:GetDescendants()) do
				if item:IsA("BasePart") then
					item.Color = color
				end
			end
		end
	end
end

local function rebuildPreviewWings()
	previewWingModel = destroyWings(previewWingModel)

	if not cfg.AngelWingsEnabled or not previewModel then
		return
	end

	local torso = getWingTorso(previewModel)
	if torso then
		previewWingModel = buildWingModel(
			previewModel,
			torso,
			true
		)
	end
end

--==================================================
-- TARGET INDICATORS
--==================================================

local function clearTargetIndicators()
	for _, obj in ipairs(targetIndicatorObjects) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end
	table.clear(targetIndicatorObjects)
end

local function clearTargetOutlines()
	for _, obj in ipairs(targetOutlineObjects) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end
	table.clear(targetOutlineObjects)
end

local function ensureTargetIndicatorLayer()
	if targetIndicatorLayer and targetIndicatorLayer.Parent then
		return
	end

	targetIndicatorLayer = make("Frame", {
		Name = "TargetIndicatorLayer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 80,
	}, gui)
end

local function updateTargetIndicators()
	if not cfg.TargetIndicatorsEnabled then
		clearTargetIndicators()
		return
	end

	ensureTargetIndicatorLayer()
	clearTargetIndicators()

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local viewport = camera.ViewportSize
	local center = viewport * 0.5
	local minViewport = math.min(viewport.X, viewport.Y)
	local radius = (minViewport * 0.5) * (math.clamp(cfg.TargetArrowRadius, 10, 95) / 100)

	local arrowColor = cfg.TargetArrowColor
	if cfg.TargetArrowRainbow then
		arrowColor = Color3.fromHSV(
			(time() * cfg.TargetArrowRainbowSpeed) % 1,
			0.9,
			1
		)
	end

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local char = otherPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			if root and hum and hum.Health > 0 then
				-- Use camera-local direction instead of on-screen visibility.
				-- This keeps the indicator visible even while looking directly at the player.
				local localPosition = camera.CFrame:PointToObjectSpace(root.Position)
				local direction = Vector2.new(localPosition.X, -localPosition.Y)

				if direction.Magnitude < 0.01 then
					local horizontal = Vector3.new(
						root.Position.X - camera.CFrame.Position.X,
						0,
						root.Position.Z - camera.CFrame.Position.Z
					)
					local fallback = camera.CFrame:VectorToObjectSpace(horizontal)
					direction = Vector2.new(fallback.X, 0)
				end

				if direction.Magnitude < 0.01 then
					direction = Vector2.new(1, 0)
				end

				direction = direction.Unit

				local position = center + direction * radius

				local arrow = make("TextLabel", {
					Name = "TargetArrow",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromOffset(position.X, position.Y),
					Size = UDim2.fromOffset(
						math.max(12, cfg.TargetArrowWidth + 8),
						math.max(12, cfg.TargetArrowWidth + 8)
					),
					BackgroundTransparency = 1,
					Text = "➤",
					Font = Enum.Font.GothamBold,
					TextSize = math.clamp(cfg.TargetArrowWidth, 10, 50),
					TextColor3 = arrowColor,
					TextTransparency = cfg.TargetArrowTransparency,
					Rotation = math.deg(math.atan2(direction.Y, direction.X)),
					ZIndex = 81,
				}, targetIndicatorLayer)

				table.insert(targetIndicatorObjects, arrow)
			end
		end
	end
end

local function updateTargetOutlines()
	if not cfg.TargetOutlineEnabled then
		clearTargetOutlines()
		return
	end

	local outlineColor = cfg.TargetOutlineColor
	if cfg.TargetOutlineRainbow then
		outlineColor = Color3.fromHSV(
			(time() * cfg.TargetOutlineRainbowSpeed) % 1,
			0.9,
			1
		)
	end

	local valid = {}

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local char = otherPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			if char and hum and hum.Health > 0 then
				valid[char] = true

				local highlight = nil
				for _, entry in ipairs(targetOutlineObjects) do
					if entry and entry.Adornee == char then
						highlight = entry
						break
					end
				end

				if not highlight then
					highlight = make("Highlight", {
						Name = "S1lentTargetOutline",
						Adornee = char,
						DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
						FillTransparency = 1,
						OutlineColor = outlineColor,
						OutlineTransparency = cfg.TargetOutlineTransparency,
					}, char)
					table.insert(targetOutlineObjects, highlight)
				else
					highlight.OutlineColor = outlineColor
					highlight.OutlineTransparency = cfg.TargetOutlineTransparency
				end
			end
		end
	end

	for i = #targetOutlineObjects, 1, -1 do
		local obj = targetOutlineObjects[i]
		if not obj.Adornee or not valid[obj.Adornee] then
			if obj.Parent then
				obj:Destroy()
			end
			table.remove(targetOutlineObjects, i)
		end
	end
end

--==================================================
-- COMBAT AIM ASSIST / TEST TARGETING
--==================================================

local triggerBotNextFire = 0
local triggerBotPendingAt = nil
local triggerBotPendingTarget = nil

local function isTriggerBotAllowedPlace()
	-- Safety gate: Trigger Bot is enabled only in the creator's own Place.
	-- For a group-owned Place, set the explicit PlaceId whitelist below.
	local ownUserPlace = game.CreatorType == Enum.CreatorType.User and game.CreatorId == player.UserId
	local explicitPlace = false
	return ownUserPlace or explicitPlace
end

local function getTriggerBotTarget()
	local camera = workspace.CurrentCamera
	if not camera then return nil end

	local center = camera.ViewportSize * 0.5
	local best, bestDistance = nil, math.huge

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			if (not cfg.TriggerBotTeamCheck) or otherPlayer.Team ~= player.Team then
				local char = otherPlayer.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local head = char and char:FindFirstChild("Head")
				if hum and hum.Health > 0 and head then
					local point, visible = camera:WorldToViewportPoint(head.Position)
					if visible and point.Z > 0 then
						local distance = (Vector2.new(point.X, point.Y) - center).Magnitude
						if distance < bestDistance then
							if (not cfg.TriggerBotLineOfSight) then
								bestDistance = distance
								best = head
							else
								local origin = camera.CFrame.Position
								local direction = head.Position - origin
								local params = RaycastParams.new()
								params.FilterType = Enum.RaycastFilterType.Exclude
								params.FilterDescendantsInstances = {player.Character}
								local hit = workspace:Raycast(origin, direction, params)
								if hit and hit.Instance and hit.Instance:IsDescendantOf(char) then
									bestDistance = distance
									best = head
								end
							end
						end
					end
				end
			end
		end
	end

	if not best then return nil end
	local fovPixels = math.tan(math.rad(math.max(0.1, cfg.TriggerBotFOV) * 0.5)) / math.tan(math.rad(math.max(1, camera.FieldOfView) * 0.5)) * (camera.ViewportSize.Y * 0.5)
	if bestDistance <= fovPixels then
		return best
	end
	return nil
end

local function triggerBotActivate()
	if not isTriggerBotAllowedPlace() then return end
	local char = player.Character
	if not char then return end
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then return end
	pcall(function() tool:Activate() end)
end

local function updateTriggerBot()
	if not cfg.TriggerBotEnabled or not isTriggerBotAllowedPlace() then
		triggerBotPendingAt = nil
		triggerBotPendingTarget = nil
		return
	end

	local now = os.clock()
	if triggerBotPendingAt and now >= triggerBotPendingAt then
		local target = triggerBotPendingTarget
		triggerBotPendingAt = nil
		triggerBotPendingTarget = nil
		if target and target.Parent then
			triggerBotActivate()
			triggerBotNextFire = now + math.max(0, cfg.TriggerBotCooldown)
		end
	end

	if now < triggerBotNextFire or triggerBotPendingAt then return end
	local target = getTriggerBotTarget()
	if target then
		triggerBotPendingTarget = target
		triggerBotPendingAt = now + math.max(0, cfg.TriggerBotDelay)
	end
end

local function getAimTarget()
	local camera = workspace.CurrentCamera
	if not camera then return nil end

	-- Aim Lock: once a player is locked, keep resolving that same player's
	-- current character/head so respawn does not change the locked target.
	if cfg.TargetLockEnabled and cfg.TargetLockActive and lockedTargetPlayer and lockedTargetPlayer.Parent == Players then
		local char = lockedTargetPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local head = char and char:FindFirstChild("Head")
		if hum and hum.Health > 0 and head then
			return head
		end
		return nil
	end
	local center = camera.ViewportSize * 0.5
	local best, bestDistance = nil, math.huge

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local char = otherPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local head = char and char:FindFirstChild("Head")
			if hum and hum.Health > 0 and head then
				local point, visible = camera:WorldToViewportPoint(head.Position)
				if visible and point.Z > 0 then
					local distance = (Vector2.new(point.X, point.Y) - center).Magnitude
					if distance < bestDistance then
						bestDistance = distance
						best = head
					end
				end
			end
		end
	end

	if not best then return nil end
	local fovPixels = math.tan(math.rad(cfg.AimFOV * 0.5)) / math.tan(math.rad(camera.FieldOfView * 0.5)) * (camera.ViewportSize.Y * 0.5)
	local point = camera:WorldToViewportPoint(best.Position)
	if (Vector2.new(point.X, point.Y) - center).Magnitude <= fovPixels then
		return best
	end
	return nil
end

local function ensureAimRing()
	if aimRing and aimRing.Parent then return end
	aimRing = make("Frame", {
		Name = "AimFOVRing",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(160, 160),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 95,
		Visible = false,
	}, gui)
	make("UICorner", {CornerRadius = UDim.new(1, 0)}, aimRing)
	make("UIStroke", {Thickness = cfg.AimRingWidth, Color = cfg.AimRingColor, Transparency = cfg.AimRingTransparency}, aimRing)
end

local function updateAimAssist()
	ensureAimRing()

	local camera = workspace.CurrentCamera
	if not camera then
		if aimRing then aimRing.Visible = false end
		shared.S1lentSilentTarget = nil
		shared.S1lentSilentDirection = nil
		return
	end

	if not cfg.AimEnabled and not cfg.SilentAimEnabled then
		aimRing.Visible = false
		aimTarget = nil
		shared.S1lentSilentTarget = nil
		shared.S1lentSilentDirection = nil
		return
	end

	local viewport = camera.ViewportSize
	local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	local fov = math.max(1, cfg.AimFOV)
	local cameraFov = math.max(1, camera.FieldOfView)

	local radius =
		math.tan(math.rad(fov * 0.5))
		/ math.tan(math.rad(cameraFov * 0.5))
		* (viewport.Y * 0.5)

	aimRing.Position = UDim2.fromOffset(center.X, center.Y)
	aimRing.Size = UDim2.fromOffset(math.max(4, radius * 2), math.max(4, radius * 2))
	aimRing.Visible = true

	local stroke = aimRing:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Thickness = math.max(1, cfg.AimRingWidth)
		stroke.Color = cfg.AimRingColor
		stroke.Transparency = math.clamp(cfg.AimRingTransparency, 0, 1)
	end

	aimTarget = getAimTarget()

	if aimTarget then
		local direction = aimTarget.Position - camera.CFrame.Position
		if direction.Magnitude > 0.001 then
			shared.S1lentSilentTarget = cfg.SilentAimEnabled and aimTarget or nil
			shared.S1lentSilentDirection = cfg.SilentAimEnabled and direction.Unit or nil

			if cfg.AimEnabled then
				local desired = CFrame.lookAt(camera.CFrame.Position, aimTarget.Position)
				local strength = math.clamp(cfg.AimStrength, 0, 1)
				camera.CFrame = camera.CFrame:Lerp(desired, strength)
			end
		end
	else
		shared.S1lentSilentTarget = nil
		shared.S1lentSilentDirection = nil
	end
end


--==================================================
-- AIM LOCK BUTTON
--==================================================

local function getPlayerFromAimTarget(target)
	if not target then return nil end
	local char = target:FindFirstAncestorOfClass("Model")
	return char and Players:GetPlayerFromCharacter(char) or nil
end

local function updateTargetLockButton()
	if not targetLockButton then return end
	targetLockButton.Visible = cfg.TargetLockEnabled
	if cfg.TargetLockActive and lockedTargetPlayer then
		targetLockButton.Text = "LOCKED: " .. lockedTargetPlayer.DisplayName
		targetLockButton.BackgroundColor3 = Color3.fromRGB(80, 25, 34)
	else
		targetLockButton.Text = "AIM LOCK"
		targetLockButton.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	end
end

local function ensureTargetLockButton()
	if targetLockButton and targetLockButton.Parent then
		updateTargetLockButton()
		return
	end
	targetLockButton = make("TextButton", {
		Name = "TargetLockButton",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 48),
		Size = UDim2.fromOffset(126, 28),
		BackgroundColor3 = Color3.fromRGB(30, 30, 36),
		BorderSizePixel = 0,
		Text = "AIM LOCK",
		TextColor3 = Color3.fromRGB(245, 245, 245),
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 110,
	}, gui)
	corner(targetLockButton, 7)
	animatedStroke(targetLockButton)
	targetLockButton.Activated:Connect(function()
		if not cfg.TargetLockEnabled then return end
		if cfg.TargetLockActive then
			cfg.TargetLockActive = false
			lockedTargetPlayer = nil
		else
			local p = getPlayerFromAimTarget(aimTarget)
			if p and p ~= player then
				lockedTargetPlayer = p
				cfg.TargetLockActive = true
			end
		end
		updateTargetLockButton()
	end)
	updateTargetLockButton()
end

ensureTargetLockButton()

--==================================================
-- CUSTOM FOV
--==================================================

local function updateCustomFOV()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	if cfg.CustomFOVEnabled then
		if fovCamera ~= camera then
			fovCamera = camera
			savedFOV = camera.FieldOfView
		end
		camera.FieldOfView = math.clamp(cfg.CustomFOV, 30, 120)
	else
		if fovCamera == camera then
			camera.FieldOfView = savedFOV
		end
		fovCamera = nil
	end
end

--==================================================
-- FIRST-PERSON HANDS
--==================================================

local function getHandParts(char)
	local result = {}
	local seen = {}

	local function addPart(item)
		if item:IsA("BasePart") and not seen[item] then
			seen[item] = true
			table.insert(result, item)
		end
	end

	if char then
		for _, item in ipairs(char:GetDescendants()) do
			if item:IsA("BasePart") then
				local name = item.Name:lower()
				if name:find("leftarm") or name:find("rightarm") or name:find("leftupperarm") or name:find("rightupperarm")
					or name:find("leftlowerarm") or name:find("rightlowerarm") or name:find("lefthand") or name:find("righthand") then
					addPart(item)
				end
			end
		end
	end

	local camera = workspace.CurrentCamera
	if camera then
		for _, item in ipairs(camera:GetDescendants()) do
			if item:IsA("BasePart") then
				local model = item:FindFirstAncestorOfClass("Model")
				local n = model and model.Name:lower() or ""
				local pn = item.Name:lower()
				if n:find("viewmodel") or n:find("view model") or n:find("firstperson") or n:find("first_person") or n:find("hands")
					or pn:find("leftarm") or pn:find("rightarm") or pn:find("left_arm") or pn:find("right_arm")
					or pn:find("lefthand") or pn:find("righthand") or pn:find("left_hand") or pn:find("right_hand")
					or pn == "larm" or pn == "rarm" then
					addPart(item)
				end
			end
		end
	end

	return result
end

local function clearHandsVisuals()
	for _, entry in ipairs(savedHandVisuals) do
		if entry.part and entry.part.Parent then
			entry.part.Color = entry.color
			entry.part.Material = entry.material
			entry.part.Transparency = entry.transparency
			entry.part.Reflectance = entry.reflectance
		end
	end
	table.clear(savedHandVisuals)

	for _, h in ipairs(handHighlights) do
		if h and h.Parent then h:Destroy() end
	end
	table.clear(handHighlights)

	for _, light in ipairs(handGlowLights) do
		if light and light.Parent then light:Destroy() end
	end
	table.clear(handGlowLights)

	for _, entry in ipairs(hiddenClothing) do
		if entry.obj and entry.obj.Parent then
			if entry.obj:IsA("Shirt") then
				entry.obj.ShirtTemplate = entry.value
			elseif entry.obj:IsA("Pants") then
				entry.obj.PantsTemplate = entry.value
			elseif entry.obj:IsA("Accessory") and entry.obj:FindFirstChild("Handle") then
				entry.obj.Handle.LocalTransparencyModifier = entry.value
			elseif entry.obj:IsA("BasePart") then
				entry.obj.LocalTransparencyModifier = entry.value
			end
		end
	end
	table.clear(hiddenClothing)
	table.clear(handPartSet)
end

local function applyHandsVisuals()
	clearHandsVisuals()

	if not cfg.HandsEnabled then
		return
	end

	local char = getCharacter()
	if char then
		for _, item in ipairs(char:GetChildren()) do
			if item:IsA("Shirt") then
				table.insert(hiddenClothing, {obj=item, value=item.ShirtTemplate})
				item.ShirtTemplate = ""
			elseif item:IsA("Pants") then
				table.insert(hiddenClothing, {obj=item, value=item.PantsTemplate})
				item.PantsTemplate = ""
			elseif item:IsA("Accessory") then
				local handle = item:FindFirstChild("Handle")
				if handle and handle:IsA("BasePart") then
					table.insert(hiddenClothing, {obj=item, value=handle.LocalTransparencyModifier})
					handle.LocalTransparencyModifier = 1
				end
			end
		end
	end

	for _, part in ipairs(getHandParts(char)) do
		handPartSet[part] = true
		table.insert(savedHandVisuals, {
			part = part,
			color = part.Color,
			material = part.Material,
			transparency = part.Transparency,
			reflectance = part.Reflectance,
		})

		part.Color = cfg.HandsFillColor
		part.Transparency = cfg.HandsTransparency

		if cfg.HandsShader == "Neon"
			or cfg.HandsShader == "Cosmic"
			or cfg.HandsShader == "Holographic"
			or cfg.HandsShader == "Pulse" then
			part.Material = Enum.Material.Neon
		elseif cfg.HandsShader == "Glass" then
			part.Material = Enum.Material.Glass
			part.Transparency = math.max(part.Transparency, 0.18)
		elseif cfg.HandsShader == "Metal" then
			part.Material = Enum.Material.Metal
		else
			part.Material = Enum.Material.SmoothPlastic
		end

		if cfg.HandsOutlineEnabled then
			local highlight = make("Highlight", {
				Name = "S1lentHandOutline",
				Adornee = part,
				FillTransparency = 1,
				OutlineColor = cfg.HandsOutlineColor,
				OutlineTransparency = cfg.HandsOutlineTransparency,
				DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
			}, part)
			table.insert(handHighlights, highlight)
		end

		if cfg.HandsGlowEnabled then
			local light = make("PointLight", {
				Color = cfg.HandsGlowColor,
				Brightness = cfg.HandsGlowStrength,
				Range = 5,
				Shadows = false,
			}, part)
			table.insert(handGlowLights, light)
		end
	end
end

local function syncHandsViewModel()
	if not cfg.HandsEnabled then return end

	local camera = workspace.CurrentCamera
	if not camera then return end

	for _, part in ipairs(getHandParts(getCharacter())) do
		if part and part.Parent and not handPartSet[part] then
			handPartSet[part] = true
			table.insert(savedHandVisuals, {
				part = part,
				color = part.Color,
				material = part.Material,
				transparency = part.Transparency,
				reflectance = part.Reflectance,
			})

			part.Color = cfg.HandsFillColor
			part.Transparency = cfg.HandsTransparency
			part.Material =
				(cfg.HandsShader == "Glass" and Enum.Material.Glass)
				or (cfg.HandsShader == "Metal" and Enum.Material.Metal)
				or (cfg.HandsShader == "Default" and Enum.Material.SmoothPlastic)
				or Enum.Material.Neon

			if cfg.HandsOutlineEnabled then
				table.insert(handHighlights, make("Highlight", {
					Name = "S1lentHandOutline",
					Adornee = part,
					FillTransparency = 1,
					OutlineColor = cfg.HandsOutlineColor,
					OutlineTransparency = cfg.HandsOutlineTransparency,
					DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
				}, part))
			end

			if cfg.HandsGlowEnabled then
				table.insert(handGlowLights, make("PointLight", {
					Color = cfg.HandsGlowColor,
					Brightness = cfg.HandsGlowStrength,
					Range = 5,
					Shadows = false,
				}, part))
			end
		end
	end
end

local function updateHandsVisuals(dt)
	if not cfg.HandsEnabled then
		return
	end

	handsVisualTime += dt

	local color = cfg.HandsFillColor
	if cfg.HandsRainbow then
		color = Color3.fromHSV(
			(handsVisualTime * cfg.HandsRainbowSpeed) % 1,
			0.9,
			1
		)
	elseif cfg.HandsShader == "Cosmic" then
		color = Color3.fromHSV(
			(handsVisualTime * cfg.HandsShaderSpeed * 0.35) % 1,
			0.75,
			1
		)
	elseif cfg.HandsShader == "Holographic" then
		color = Color3.fromHSV(
			(0.55 + math.sin(handsVisualTime * cfg.HandsShaderSpeed) * 0.18) % 1,
			0.65,
			1
		)
	end

	local pulse = 1
	if cfg.HandsShader == "Pulse" then
		pulse = 0.55
			+ 0.45 * (
				0.5
				+ 0.5 * math.sin(
					handsVisualTime * cfg.HandsShaderSpeed * math.pi * 2
				)
			)
	end

	for _, entry in ipairs(savedHandVisuals) do
		if entry.part and entry.part.Parent then
			entry.part.Color = color
			if cfg.HandsShader == "Glass" then
				entry.part.Transparency = math.clamp(
					math.max(cfg.HandsTransparency, 0.18),
					0,
					0.95
				)
			else
				entry.part.Transparency = math.clamp(
					cfg.HandsTransparency
						+ (1 - pulse) * 0.25,
					0,
					0.95
				)
			end
		end
	end

	for _, h in ipairs(handHighlights) do
		if h and h.Parent then
			local outlineColor = cfg.HandsOutlineColor
			if cfg.HandsOutlineRainbow then
				outlineColor = Color3.fromHSV(
					(handsVisualTime * cfg.HandsRainbowSpeed) % 1,
					0.9,
					1
				)
			end
			h.OutlineColor = outlineColor
		end
	end

	for _, light in ipairs(handGlowLights) do
		if light and light.Parent then
			local glowColor = cfg.HandsGlowColor
			if cfg.HandsRainbow then
				glowColor = Color3.fromHSV(
					(handsVisualTime * cfg.HandsRainbowSpeed) % 1,
					0.9,
					1
				)
			end
			light.Color = glowColor
			light.Brightness = cfg.HandsGlowStrength * (0.65 + pulse * 0.35)
		end
	end
end

--==================================================
-- STRETCH CHANGER
--==================================================

local stretchRenderConnection

local function applyStretch()
	if not stretchRenderConnection then
		stretchRenderConnection = RunService.RenderStepped:Connect(function()
			local camera = workspace.CurrentCamera
			if not camera then
				return
			end

			local amount = math.clamp(cfg.StretchAmount, 0, 100)
			local yScale = 1 - (amount / 100) * 0.8

			if amount <= 0 then
				return
			end

			camera.CFrame = camera.CFrame * CFrame.new(
				0, 0, 0,
				1, 0, 0,
				0, yScale, 0,
				0, 0, 1
			)
		end)
	end
end

--==================================================
-- MENU SCALE
--==================================================

local function applyMenuScale(v)
	v = math.clamp(v, 0.7, 1.15)

	main.Position = UDim2.new(
		0.5,
		-305 * v,
		0.5,
		-175 * v
	)

	main.Size = UDim2.fromOffset(
		610 * v,
		350 * v
	)

	sidebar.Size = UDim2.new(
		0,
		92 * v,
		1,
		-54 * v
	)

	content.Position = UDim2.fromOffset(
		106 * v,
		47 * v
	)

	content.Size = UDim2.new(
		0,
		250 * v,
		1,
		-54 * v
	)

	menuParticleLayer.Position = UDim2.fromOffset(0, 0)
	menuParticleLayer.Size = UDim2.fromScale(1, 1)

	previewPanel.Position = UDim2.new(
		0,
		364 * v,
		0,
		47 * v
	)

	previewPanel.Size = UDim2.new(
		1,
		-371 * v,
		1,
		-54 * v
	)
end

--==================================================
-- TABS
--==================================================

local tabs = {
	"Combat",
	"Player",
	"World",
	"Visuals",
	"HUD",
	"Settings"
}

local tabButtons = {}
local renderTab

for i, tabName in ipairs(tabs) do
	local button = make("TextButton", {
		Position =
			UDim2.fromOffset(
				5,
				6 + (i - 1) * 34
			),

		Size =
			UDim2.new(
				1,
				-10,
				0,
				29
			),

		BackgroundColor3 =
			Color3.fromRGB(
				29,
				29,
				34
			),

		Text = tabName,

		Font =
			Enum.Font.GothamMedium,

		TextSize = 10,

		TextColor3 =
			Color3.fromRGB(
				235,
				235,
				240
			),

		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, sidebar)

	corner(button, 7)

	tabButtons[tabName] = button

	button.Activated:Connect(function()
		renderTab(tabName)
	end)
end

--==================================================
-- ESP PRESETS
--==================================================

local function applyESPPreset(name)
	if name == "Minimal" then
		cfg.CombatESPEnabled = true

		cfg.ESP3DBox = false
		cfg.ESP2DBox = true
		cfg.ESPCornerBox = false
		cfg.ESPSkeleton = false

		cfg.ESPName = true
		cfg.ESPHealth = true
		cfg.ESPTeam = false
		cfg.ESPState = false
		cfg.ESPDistance = false

		cfg.ESPLines = false

		cfg.ESPUseRGB = false

	elseif name == "Classic" then
		cfg.CombatESPEnabled = true

		cfg.ESP3DBox = true
		cfg.ESP2DBox = true
		cfg.ESPCornerBox = false
		cfg.ESPSkeleton = false

		cfg.ESPName = true
		cfg.ESPHealth = true
		cfg.ESPTeam = false
		cfg.ESPState = false
		cfg.ESPDistance = true

		cfg.ESPLines = false

		cfg.ESPUseRGB = false

	elseif name == "RGB" then
		cfg.CombatESPEnabled = true

		cfg.ESP3DBox = true
		cfg.ESP2DBox = true
		cfg.ESPCornerBox = false
		cfg.ESPSkeleton = true

		cfg.ESPName = true
		cfg.ESPHealth = true
		cfg.ESPTeam = true
		cfg.ESPState = true
		cfg.ESPDistance = true

		cfg.ESPLines = true

		cfg.ESPUseRGB = true

	elseif name == "Competitive" then
		cfg.CombatESPEnabled = true

		cfg.ESP3DBox = false
		cfg.ESP2DBox = false
		cfg.ESPCornerBox = true
		cfg.ESPSkeleton = true

		cfg.ESPName = true
		cfg.ESPHealth = true
		cfg.ESPTeam = false
		cfg.ESPState = false
		cfg.ESPDistance = true

		cfg.ESPLines = true

		cfg.ESPUseRGB = false
	end

	createESP()
end

--==================================================
-- TAB CONTENT
--==================================================

local function refreshStageList()
	table.clear(stageNames)

	local seen = {}

	local function addStage(obj)
		if seen[obj] then return end
		if not (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Folder")) then return end

		local name = obj.Name
		local lower = name:lower()

		if lower:find("stage")
			or lower:find("level")
			or lower:find("round")
			or lower:find("map") then
			seen[obj] = true
			table.insert(stageNames, name)
		end
	end

	local roots = {
		workspace:FindFirstChild("Stages"),
		workspace:FindFirstChild("Stage"),
		workspace:FindFirstChild("Maps"),
		workspace:FindFirstChild("Map"),
		workspace:FindFirstChild("Levels"),
		workspace:FindFirstChild("Rounds"),
		workspace:FindFirstChild("CurrentMap"),
	}

	for _, root in ipairs(roots) do
		if root then
			for _, obj in ipairs(root:GetChildren()) do
				addStage(obj)
			end
		end
	end

	if #stageNames == 0 then
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj.Parent ~= workspace and (obj:IsA("Model") or obj:IsA("BasePart")) then
				local n = obj.Name:lower()
				if n:match("^stage[%s_%-]?%d+")
					or n:match("^level[%s_%-]?%d+")
					or n:match("^round[%s_%-]?%d+") then
					addStage(obj)
				end
			end
		end
	end

	if #stageNames == 0 then
		for _, obj in ipairs(workspace:GetChildren()) do
			if obj:IsA("Model") or obj:IsA("BasePart") then
				local n = obj.Name:lower()
				if n:match("^%d+$") or n:match("^map[%s_%-]?%d+") then
					addStage(obj)
				end
			end
		end
	end

	table.sort(stageNames, function(a, b)
		local an = tonumber(a:match("%d+"))
		local bn = tonumber(b:match("%d+"))
		if an and bn and an ~= bn then return an < bn end
		return a:lower() < b:lower()
	end)

	stageIndex = math.clamp(stageIndex, 1, math.max(1, #stageNames))
end

local function teleportToStage(name)
	local char = getCharacter()
	local root = getRoot(char)
	if not root or not name then return end

	local obj = workspace:FindFirstChild(name, true)
	if not obj then return end

	local target = obj
	if obj:IsA("Model") then
		local preferred = obj:FindFirstChild("SpawnLocation", true)
			or obj:FindFirstChild("Spawn", true)
			or obj:FindFirstChild("Start", true)
			or obj.PrimaryPart
		if preferred and preferred:IsA("BasePart") then
			target = preferred
		end
	end

	local cf
	if target:IsA("BasePart") then
		cf = target.CFrame
	elseif target:IsA("Model") then
		cf = target:GetPivot()
	end

	if cf then
		root.CFrame = cf + Vector3.new(0, 4, 0)
	end
end

renderTab = function(tabName)
	clearContent()

	for name, button in pairs(tabButtons) do
		button.BackgroundColor3 =
			name == tabName
			and Color3.fromRGB(
				80,
				25,
				34
			)
			or Color3.fromRGB(
				29,
				29,
				34
			)
	end

	if tabName == "Combat" then

		-- MAIN ESP
		sectionLabel("AIM / TARGETING")
		actionButton("Aim Assist: " .. (cfg.AimEnabled and "ON" or "OFF"), function()
			cfg.AimEnabled=not cfg.AimEnabled
			renderTab("Combat")
		end)
		actionButton("Silent Aim Test: " .. (cfg.SilentAimEnabled and "ON" or "OFF"), function()
			cfg.SilentAimEnabled=not cfg.SilentAimEnabled
			renderTab("Combat")
		end)
		makeSlider("Aim FOV", 1, 90, cfg.AimFOV, function(v) cfg.AimFOV=v end)
		makeSlider("Aim Strength", 0, 1, cfg.AimStrength, function(v) cfg.AimStrength=v end)
		actionButton("Trigger Bot: " .. (cfg.TriggerBotEnabled and "ON" or "OFF"), function()
			cfg.TriggerBotEnabled = not cfg.TriggerBotEnabled
			triggerBotPendingAt = nil
			triggerBotPendingTarget = nil
			renderTab("Combat")
		end)
		makeSlider("Trigger FOV", 0.5, 20, cfg.TriggerBotFOV, function(v) cfg.TriggerBotFOV=v end)
		makeSlider("Trigger Delay", 0, 0.5, cfg.TriggerBotDelay, function(v) cfg.TriggerBotDelay=v end)
		makeSlider("Trigger Cooldown", 0.05, 1, cfg.TriggerBotCooldown, function(v) cfg.TriggerBotCooldown=v end)
		actionButton("Trigger Team Check: " .. (cfg.TriggerBotTeamCheck and "ON" or "OFF"), function()
			cfg.TriggerBotTeamCheck = not cfg.TriggerBotTeamCheck
			renderTab("Combat")
		end)
		actionButton("Trigger Line of Sight: " .. (cfg.TriggerBotLineOfSight and "ON" or "OFF"), function()
			cfg.TriggerBotLineOfSight = not cfg.TriggerBotLineOfSight
			renderTab("Combat")
		end)
		actionButton("Target Lock: " .. (cfg.TargetLockEnabled and "ON" or "OFF"), function()
			cfg.TargetLockEnabled = not cfg.TargetLockEnabled
			if not cfg.TargetLockEnabled then
				cfg.TargetLockActive = false
				lockedTargetPlayer = nil
			end
			updateTargetLockButton()
			renderTab("Combat")
		end)
		makeSlider("FOV Ring Width", 1, 8, cfg.AimRingWidth, function(v) cfg.AimRingWidth=v end)
		makeSlider("FOV Ring Transparency", 0, 1, cfg.AimRingTransparency, function(v) cfg.AimRingTransparency=v end)

		sectionLabel("RIVALS BOT / PLAYER AUTOPILOT")
		actionButton("Rivals Bot: " .. (cfg.RivalsBotEnabled and "ON" or "OFF"), function()
			cfg.RivalsBotEnabled = not cfg.RivalsBotEnabled
			if not cfg.RivalsBotEnabled then botTargetPlayer = nil end
			renderTab("Combat")
		end)
		actionButton("Difficulty: " .. cfg.RivalsBotDifficulty, function()
			local order = {"Normal", "Hard", "Insane", "Nightmare"}
			local i = 1
			for n,v in ipairs(order) do if v == cfg.RivalsBotDifficulty then i=n break end end
			cfg.RivalsBotDifficulty = order[(i % #order) + 1]
			renderTab("Combat")
		end)
		makeSlider("Bot Reaction", 0.1, 1, cfg.RivalsBotReaction, function(v) cfg.RivalsBotReaction=v end)
		makeSlider("Bot Movement", 0.1, 1, cfg.RivalsBotMovement, function(v) cfg.RivalsBotMovement=v end)
		makeSlider("Bot Aim", 0.1, 1, cfg.RivalsBotAim, function(v) cfg.RivalsBotAim=v end)
		makeSlider("Bot Aggression", 0.1, 1, cfg.RivalsBotAggression, function(v) cfg.RivalsBotAggression=v end)
		makeSlider("Bot Range", 30, 250, cfg.RivalsBotRange, function(v) cfg.RivalsBotRange=v end)
		makeSlider("Bot Attack Rate", 2, 20, cfg.RivalsBotAttackRate, function(v) cfg.RivalsBotAttackRate=v end)
		makeSlider("Bot Walk Speed", 16, 60, cfg.RivalsBotWalkSpeed, function(v) cfg.RivalsBotWalkSpeed=v end)
		makeSlider("Bot Jump Power", 40, 120, cfg.RivalsBotJumpPower, function(v) cfg.RivalsBotJumpPower=v end)
	actionButton("Strafe: " .. (cfg.RivalsBotStrafe and "ON" or "OFF"), function() cfg.RivalsBotStrafe=not cfg.RivalsBotStrafe; renderTab("Combat") end)
		actionButton("Dodge / Jump: " .. (cfg.RivalsBotDodge and "ON" or "OFF"), function() cfg.RivalsBotDodge=not cfg.RivalsBotDodge; renderTab("Combat") end)

		sectionLabel("COMBAT ESP")

		actionButton(
			"ESP: "
				.. (
					cfg.CombatESPEnabled
					and "ON"
					or "OFF"
				),

			function()
				cfg.CombatESPEnabled =
					not cfg.CombatESPEnabled

				if cfg.CombatESPEnabled then
					createESP()
				else
					clearESP()
				end

				applyMenuScale(0.73)
renderTab("Combat")
			end
		)

		-- APPEARANCE
		sectionLabel("ESP APPEARANCE")

		actionButton(
			"RGB Mode: "
				.. (
					cfg.ESPUseRGB
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESPUseRGB =
					not cfg.ESPUseRGB

				renderTab("Combat")
			end
		)

		makeSlider(
			"RGB Speed",
			0.1,
			5,
			cfg.ESPRGBSpeed,

			function(v)
				cfg.ESPRGBSpeed = v
			end
		)

		actionButton(
			"Body Color",

			function()
				cfg.ESPFillColor =
					Color3.fromRGB(
						0,
						100,
						255
					)

				cfg.CombatESPBodyColor =
					cfg.ESPFillColor

				createESP()
			end
		)

		actionButton(
			"Head Color",

			function()
				cfg.CombatESPHeadColor =
					Color3.fromRGB(
						255,
						230,
						0
					)

				createESP()
			end
		)

		actionButton(
			"Fill Color: Blue",

			function()
				cfg.ESPFillColor =
					Color3.fromRGB(
						0,
						100,
						255
					)

				createESP()
			end
		)

		makeSlider(
			"Fill Transparency",
			0,
			1,
			cfg.ESPFillTransparency,

			function(v)
				cfg.ESPFillTransparency = v
			end
		)

		actionButton(
			"Outline Color: White",

			function()
				cfg.ESPOutlineColor =
					Color3.fromRGB(
						255,
						255,
						255
					)

				createESP()
			end
		)

		makeSlider(
			"Outline Transparency",
			0,
			1,
			cfg.ESPOutlineTransparency,

			function(v)
				cfg.ESPOutlineTransparency = v
			end
		)

		makeSlider(
			"Outline Thickness",
			1,
			5,
			cfg.ESPOutlineThickness,

			function(v)
				cfg.ESPOutlineThickness = v
			end
		)

		-- DISPLAY
		sectionLabel("ESP DISPLAY")

		actionButton(
			"3D Box: "
				.. (
					cfg.ESP3DBox
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESP3DBox =
					not cfg.ESP3DBox

				renderTab("Combat")
			end
		)

		actionButton(
			"2D Box: "
				.. (
					cfg.ESP2DBox
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESP2DBox =
					not cfg.ESP2DBox

				renderTab("Combat")
			end
		)

		actionButton(
			"Corner Box: "
				.. (
					cfg.ESPCornerBox
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESPCornerBox =
					not cfg.ESPCornerBox

				renderTab("Combat")
			end
		)

		actionButton(
			"Skeleton: "
				.. (
					cfg.ESPSkeleton
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESPSkeleton =
					not cfg.ESPSkeleton

				renderTab("Combat")
			end
		)

		-- PLAYER INFO
		sectionLabel("PLAYER INFO")

		actionButton(
			"Player Name: "
				.. (
					cfg.ESPName
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESPName =
					not cfg.ESPName

				renderTab("Combat")
			end
		)

		actionButton(
			"HP: "
				.. (
					cfg.ESPHealth
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESPHealth =
					not cfg.ESPHealth

				renderTab("Combat")
			end
		)

		actionButton(
			"HP Color: Green",

			function()
				cfg.ESPHealthColor =
					Color3.fromRGB(
						70,
						255,
						100
					)

				renderTab("Combat")
			end
		)

		actionButton(
			"Team: "
				.. (
					cfg.ESPTeam
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESPTeam =
					not cfg.ESPTeam

				renderTab("Combat")
			end
		)

		actionButton(
			"State: "
				.. (
					cfg.ESPState
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESPState =
					not cfg.ESPState

				renderTab("Combat")
			end
		)

		actionButton(
			"Distance: "
				.. (
					cfg.ESPDistance
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESPDistance =
					not cfg.ESPDistance

				renderTab("Combat")
			end
		)

		makeSlider(
			"Distance Text Size",
			8,
			18,
			cfg.ESPDistanceTextSize,

			function(v)
				cfg.ESPDistanceTextSize = v
			end
		)

		-- LINES
		sectionLabel("ESP LINES")

		actionButton(
			"Lines: "
				.. (
					cfg.ESPLines
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESPLines =
					not cfg.ESPLines

				renderTab("Combat")
			end
		)

		actionButton(
			"Line Color: White",

			function()
				cfg.ESPLineColor =
					Color3.fromRGB(
						255,
						255,
						255
					)

				renderTab("Combat")
			end
		)

		makeSlider(
			"Line Thickness",
			1,
			5,
			cfg.ESPLineThickness,

			function(v)
				cfg.ESPLineThickness = v
			end
		)

		-- PERFORMANCE
		sectionLabel("ESP PERFORMANCE")

		makeSlider(
			"Max Distance",
			50,
			2000,
			cfg.ESPMaxDistance,

			function(v)
				cfg.ESPMaxDistance = v
			end
		)

		makeSlider(
			"Update Rate",
			5,
			60,
			cfg.ESPUpdateRate,

			function(v)
				cfg.ESPUpdateRate =
					math.clamp(
						math.floor(
							v + 0.5
						),
						1,
						60
					)
			end
		)

		actionButton(
			"Low-End Mode: "
				.. (
					cfg.ESPLowEnd
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESPLowEnd =
					not cfg.ESPLowEnd

				renderTab("Combat")
			end
		)

		actionButton(
			"Hide Self: "
				.. (
					cfg.ESPHideSelf
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESPHideSelf =
					not cfg.ESPHideSelf

				renderTab("Combat")
			end
		)

		actionButton(
			"Hide Dead: "
				.. (
					cfg.ESPHideDead
					and "ON"
					or "OFF"
				),

			function()
				cfg.ESPHideDead =
					not cfg.ESPHideDead

				renderTab("Combat")
			end
		)

		-- PRESETS
		sectionLabel("ESP PRESETS")

		actionButton(
			"Minimal",

			function()
				applyESPPreset("Minimal")
				renderTab("Combat")
			end
		)

		actionButton(
			"Classic",

			function()
				applyESPPreset("Classic")
				renderTab("Combat")
			end
		)

		actionButton(
			"RGB",

			function()
				applyESPPreset("RGB")
				renderTab("Combat")
			end
		)

		actionButton(
			"Competitive",

			function()
				applyESPPreset("Competitive")
				pcall(function()
	renderTab("Combat")
end)

-- Apply the requested initial menu scale (0.73) immediately.
local function applyInitialMenuScale()
	local v = math.clamp(cfg.MenuScale or 0.73, 0.7, 1.15)

	main.Size = UDim2.fromOffset(610 * v, 350 * v)
	main.Position = UDim2.new(0.5, -(305 * v), 0.5, -(175 * v))

	sidebar.Size = UDim2.new(0, 92 * v, 1, -54 * v)
	sidebar.Position = UDim2.fromOffset(7 * v, 47 * v)

	content.Position = UDim2.fromOffset(106 * v, 47 * v)
	content.Size = UDim2.new(0, 250 * v, 1, -54 * v)

	menuParticleLayer.Position = UDim2.fromOffset(0, 0)
	menuParticleLayer.Size = UDim2.fromScale(1, 1)

	previewPanel.Position = UDim2.new(0, 364 * v, 0, 47 * v)
	previewPanel.Size = UDim2.new(1, -371 * v, 1, -54 * v)
end

applyInitialMenuScale()
			end
		)

	elseif tabName == "Player" then

		sectionLabel("JUMP CIRCLE")

		actionButton(
			"Jump Circle: "
				.. (
					cfg.JumpCircleEnabled
					and "ON"
					or "OFF"
				),

			function()
				cfg.JumpCircleEnabled =
					not cfg.JumpCircleEnabled

				renderTab("Player")
			end
		)

		actionButton(
			"Jump Rainbow: "
				.. (
					cfg.JumpCircleRainbow
					and "ON"
					or "OFF"
				),

			function()
				cfg.JumpCircleRainbow =
					not cfg.JumpCircleRainbow

				renderTab("Player")
			end
		)

		makeSlider(
			"Circle Color Hue",
			0,
			1,
			hues.Jump,

			function(v)
				hues.Jump = v
				cfg.JumpColorHue = v
			end
		)

		makeSlider(
			"Circle Rainbow Speed",
			0.1,
			3,
			cfg.JumpCircleRainbowSpeed,

			function(v)
				cfg.JumpCircleRainbowSpeed = v
			end
		)

		makeSlider(
			"Circle Size",
			2,
			15,
			cfg.JumpCircleSize,

			function(v)
				cfg.JumpCircleSize = v
			end
		)

		makeSlider(
			"Circle Duration",
			0.2,
			2,
			cfg.JumpCircleDuration,

			function(v)
				cfg.JumpCircleDuration = v
			end
		)

		makeSlider(
			"Circle Thickness",
			0.03,
			0.4,
			cfg.JumpCircleThickness,

			function(v)
				cfg.JumpCircleThickness = v
			end
		)

		sectionLabel("PULSE RING")

		actionButton(
			"Pulse Ring: "
				.. (
					cfg.PulseRingEnabled
					and "ON"
					or "OFF"
				),

			function()
				cfg.PulseRingEnabled =
					not cfg.PulseRingEnabled

				createPulseRing()
				renderTab("Player")
			end
		)

		actionButton(
			"Ring Rainbow: "
				.. (
					cfg.PulseRingRainbow
					and "ON"
					or "OFF"
				),

			function()
				cfg.PulseRingRainbow =
					not cfg.PulseRingRainbow

				renderTab("Player")
			end
		)

		actionButton(
			"Fading Trail: "
				.. (
					cfg.PulseRingTrail
					and "ON"
					or "OFF"
				),

			function()
				cfg.PulseRingTrail =
					not cfg.PulseRingTrail

				renderTab("Player")
			end
		)

		makeSlider(
			"Ring Radius",
			1,
			8,
			cfg.PulseRingRadius,

			function(v)
				cfg.PulseRingRadius = v
			end
		)

		makeSlider(
			"Ring Thickness",
			0.03,
			0.4,
			cfg.PulseRingThickness,

			function(v)
				cfg.PulseRingThickness = v
			end
		)

		makeSlider(
			"Ring Speed",
			0.1,
			6,
			cfg.PulseRingSpeed,

			function(v)
				cfg.PulseRingSpeed = v
			end
		)

		makeSlider(
			"Pulse Speed",
			0.1,
			6,
			cfg.PulseRingPulseSpeed,

			function(v)
				cfg.PulseRingPulseSpeed = v
			end
		)

		makeSlider(
			"Pulse Amount",
			0.05,
			0.8,
			cfg.PulseRingPulseAmount,

			function(v)
				cfg.PulseRingPulseAmount = v
			end
		)

		makeSlider(
			"Ring Transparency",
			0,
			0.8,
			cfg.PulseRingTransparency,

			function(v)
				cfg.PulseRingTransparency = v
			end
		)

		makeSlider(
			"Trail Lifetime",
			0.1,
			2,
			cfg.PulseRingTrailLifetime,

			function(v)
				cfg.PulseRingTrailLifetime = v
			end
		)

		sectionLabel("CONTINUOUS BACK TRAIL")

		actionButton(
			"Trail: "
				.. (
					cfg.TrailEnabled
					and "ON"
					or "OFF"
				),

			function()
				cfg.TrailEnabled =
					not cfg.TrailEnabled

				if not trail
					and getCharacter() then
					task.spawn(
						setupTrail,
						getCharacter()
					)
				end

				refreshTrail()
				renderTab("Player")
			end
		)

		actionButton(
			"Trail Rainbow: "
				.. (
					cfg.TrailRainbow
					and "ON"
					or "OFF"
				),

			function()
				cfg.TrailRainbow =
					not cfg.TrailRainbow

				renderTab("Player")
			end
		)

		makeSlider(
			"Trail Rainbow Speed",
			0.1,
			3,
			cfg.TrailRainbowSpeed,

			function(v)
				cfg.TrailRainbowSpeed = v
			end
		)

		makeSlider(
			"Trail Width",
			0.1,
			5,
			cfg.TrailWidth,

			function(v)
				cfg.TrailWidth = v
				refreshTrail()
			end
		)

		makeSlider(
			"Trail Lifetime",
			0.1,
			3,
			cfg.TrailLifetime,

			function(v)
				cfg.TrailLifetime = v
				refreshTrail()
			end
		)

		makeSlider(
			"Trail Transparency",
			0,
			0.8,
			cfg.TrailTransparency,

			function(v)
				cfg.TrailTransparency = v
				refreshTrail()
			end
		)

		sectionLabel("GHOST EFFECT")

		actionButton(
			"Ghost: "
				.. (
					cfg.GhostEnabled
					and "ON"
					or "OFF"
				),

			function()
				cfg.GhostEnabled =
					not cfg.GhostEnabled

				ghostAccumulator = 0
				lastGhostPosition = nil

				renderTab("Player")
			end
		)

		actionButton(
			"Ghost Mode: "
				.. cfg.GhostMode,

			function()
				cfg.GhostMode =
					cfg.GhostMode ==
						"Transparent"
					and "Outline"
					or "Transparent"

				renderTab("Player")
			end
		)

		actionButton(
			"Ghost Rainbow: "
				.. (
					cfg.GhostRainbow
					and "ON"
					or "OFF"
				),

			function()
				cfg.GhostRainbow =
					not cfg.GhostRainbow

				renderTab("Player")
			end
		)

		makeSlider(
			"Ghost Color Hue",
			0,
			1,
			hues.Ghost,

			function(v)
				hues.Ghost = v
			end
		)

		makeSlider(
			"Ghost Rainbow Speed",
			0.1,
			3,
			cfg.GhostRainbowSpeed,

			function(v)
				cfg.GhostRainbowSpeed = v
			end
		)

		makeSlider(
			"Ghost Interval",
			0.06,
			0.6,
			cfg.GhostInterval,

			function(v)
				cfg.GhostInterval = v
			end
		)

		makeSlider(
			"Ghost Lifetime",
			0.2,
			3,
			cfg.GhostLifetime,

			function(v)
				cfg.GhostLifetime = v
			end
		)

		makeSlider(
			"Ghost Transparency",
			0.05,
			0.95,
			cfg.GhostTransparency,

			function(v)
				cfg.GhostTransparency = v
			end
		)

		makeSlider(
			"Ghost Outline Transparency",
			0,
			1,
			cfg.GhostOutlineTransparency,

			function(v)
				cfg.GhostOutlineTransparency = v
			end
		)

		sectionLabel("ORBITING OBJECTS")

		actionButton(
			"Orbit: "
				.. (
					cfg.OrbitEnabled
					and "ON"
					or "OFF"
				),

			function()
				cfg.OrbitEnabled =
					not cfg.OrbitEnabled

				rebuildOrbitObjects()
				rebuildPreviewDecor()

				renderTab("Player")
			end
		)

		actionButton(
			"Orbit Type: "
				.. cfg.OrbitType,

			function()
				if cfg.OrbitType == "Swords" then
					cfg.OrbitType = "Ghosts"

				elseif cfg.OrbitType == "Ghosts" then
					cfg.OrbitType = "Crystals"

				else
					cfg.OrbitType = "Swords"
				end

				rebuildOrbitObjects()
				rebuildPreviewDecor()

				renderTab("Player")
			end
		)

		makeSlider(
			"Orbit Color Hue",
			0,
			1,
			hues.Orbit,

			function(v)
				hues.Orbit = v
				cfg.OrbitColorHue = v
			end
		)

		makeSlider(
			"Orbit Count",
			1,
			12,
			cfg.OrbitCount,

			function(v)
				cfg.OrbitCount =
					math.clamp(
						math.floor(
							v + 0.5
						),
						1,
						12
					)

				rebuildOrbitObjects()
				rebuildPreviewDecor()
			end
		)

		makeSlider(
			"Orbit Radius",
			1.5,
			7,
			cfg.OrbitRadius,

			function(v)
				cfg.OrbitRadius = v
			end
		)

		makeSlider(
			"Orbit Speed",
			0.2,
			4,
			cfg.OrbitSpeed,

			function(v)
				cfg.OrbitSpeed = v
			end
		)

		actionButton(
			"Orbit Rainbow: "
				.. (
					cfg.OrbitRainbow
					and "ON"
					or "OFF"
				),

			function()
				cfg.OrbitRainbow =
					not cfg.OrbitRainbow

				renderTab("Player")
			end
		)

		sectionLabel("DIAMOND CRYSTALS")

		actionButton(
			"Crystal Rainbow: "
				.. (
					cfg.CrystalRainbow
					and "ON"
					or "OFF"
				),

			function()
				cfg.CrystalRainbow =
					not cfg.CrystalRainbow

				renderTab("Player")
			end
		)

		makeSlider(
			"Crystal Color Hue",
			0,
			1,
			hues.Crystal,

			function(v)
				hues.Crystal = v
				cfg.CrystalColorHue = v
			end
		)

		makeSlider(
			"Crystal Rainbow Speed",
			0.1,
			3,
			cfg.CrystalRainbowSpeed,

			function(v)
				cfg.CrystalRainbowSpeed = v
			end
		)

		makeSlider(
			"Crystal Size",
			0.2,
			2,
			cfg.CrystalSize,

			function(v)
				cfg.CrystalSize = v

				if cfg.OrbitType ==
					"Crystals" then

					rebuildOrbitObjects()
					rebuildPreviewDecor()
				end
			end
		)

		makeSlider(
			"Crystal Height",
			0,
			4,
			cfg.CrystalFloatHeight,

			function(v)
				cfg.CrystalFloatHeight = v
			end
		)

		sectionLabel("PREVIEW")

		actionButton(
			"Preview Effects: "
				.. (
					cfg.PreviewEffects
					and "ON"
					or "OFF"
				),

			function()
				cfg.PreviewEffects =
					not cfg.PreviewEffects

				rebuildPreviewDecor()
				renderTab("Player")
			end
		)

		sectionLabel("ANGEL WINGS")

		actionButton(
			"Angel Wings: "
				.. (
					cfg.AngelWingsEnabled
					and "ON"
					or "OFF"
				),
			function()
				cfg.AngelWingsEnabled = not cfg.AngelWingsEnabled
				rebuildAngelWings()
				rebuildPreviewWings()
				renderTab("Player")
			end
		)

		actionButton(
			"Angel Rainbow: "
				.. (
					cfg.AngelWingsRainbow
					and "ON"
					or "OFF"
				),
			function()
				cfg.AngelWingsRainbow = not cfg.AngelWingsRainbow
				renderTab("Player")
			end
		)

		makeSlider(
			"Wings Red",
			0,
			255,
			cfg.AngelWingsColor.R * 255,
			function(v)
				cfg.AngelWingsColor = Color3.fromRGB(
					math.floor(v + 0.5),
					math.floor(cfg.AngelWingsColor.G * 255 + 0.5),
					math.floor(cfg.AngelWingsColor.B * 255 + 0.5)
				)
				updateWingColors()
			end
		)

		makeSlider(
			"Wings Green",
			0,
			255,
			cfg.AngelWingsColor.G * 255,
			function(v)
				cfg.AngelWingsColor = Color3.fromRGB(
					math.floor(cfg.AngelWingsColor.R * 255 + 0.5),
					math.floor(v + 0.5),
					math.floor(cfg.AngelWingsColor.B * 255 + 0.5)
				)
				updateWingColors()
			end
		)

		makeSlider(
			"Wings Blue",
			0,
			255,
			cfg.AngelWingsColor.B * 255,
			function(v)
				cfg.AngelWingsColor = Color3.fromRGB(
					math.floor(cfg.AngelWingsColor.R * 255 + 0.5),
					math.floor(cfg.AngelWingsColor.G * 255 + 0.5),
					math.floor(v + 0.5)
				)
				updateWingColors()
			end
		)

		makeSlider(
			"Wings Scale",
			0.4,
			3,
			cfg.AngelWingsScale,
			function(v)
				cfg.AngelWingsScale = v
				rebuildAngelWings()
				rebuildPreviewWings()
			end
		)

	elseif tabName == "World" then
		sectionLabel("STAGE CHANGER")
		refreshStageList()
		actionButton("Stage: " .. (stageNames[stageIndex] or "Not found"), function()
			if #stageNames > 0 then stageIndex = stageIndex % #stageNames + 1 end
			renderTab("World")
		end)
		actionButton("Teleport To Stage", function()
			if stageNames[stageIndex] then teleportToStage(stageNames[stageIndex]) end
		end)

		sectionLabel("WORLD")

		actionButton(
			"Skybox: "
				.. (
					skyboxEnabled
					and "ON"
					or "OFF"
				),

			function()
				toggleSkybox()
				renderTab("World")
			end
		)

		makeSlider(
			"Skybox Red",
			0,
			255,
			cfg.SkyboxR,
			function(v)
				cfg.SkyboxR = v
				applySkyboxTint()
			end
		)

		makeSlider(
			"Skybox Green",
			0,
			255,
			cfg.SkyboxG,
			function(v)
				cfg.SkyboxG = v
				applySkyboxTint()
			end
		)

		makeSlider(
			"Skybox Blue",
			0,
			255,
			cfg.SkyboxB,
			function(v)
				cfg.SkyboxB = v
				applySkyboxTint()
			end
		)

		actionButton(
			"Copy Skybox ID",

			function()
				if typeof(setclipboard) ==
					"function" then

					pcall(
						setclipboard,
						"8808550143"
					)
				end
			end
		)

		sectionLabel("WORLD PARTICLES")

		actionButton(
			"World Particles: "
				.. (
					cfg.WorldParticlesEnabled
					and "ON"
					or "OFF"
				),
			function()
				cfg.WorldParticlesEnabled = not cfg.WorldParticlesEnabled
				if not cfg.WorldParticlesEnabled then
					clearWorldParticles()
				end
				renderTab("World")
			end
		)

		actionButton(
			"Particle Type: " .. cfg.WorldParticleType,
			function()
				local types = {
					"Snow",
					"Sakura",
					"Autumn Leaves",
					"Fireflies",
					"Sparks",
					"Dust",
					"Bubbles",
					"Hearts",
					"Stars",
					"Matrix",
					"Ash",
					"Rain",
				}
				local index = table.find(types, cfg.WorldParticleType) or 1
				cfg.WorldParticleType = types[index % #types + 1]
				clearWorldParticles()
				renderTab("World")
			end
		)

		actionButton(
			"Rainbow Particles: "
				.. (
					cfg.WorldParticleRainbow
					and "ON"
					or "OFF"
				),
			function()
				cfg.WorldParticleRainbow = not cfg.WorldParticleRainbow
				renderTab("World")
			end
		)

		makeSlider(
			"Particle Amount",
			1,
			250,
			cfg.WorldParticleAmount,
			function(v)
				cfg.WorldParticleAmount = math.clamp(math.floor(v + 0.5), 1, 250)
			end
		)

		makeSlider(
			"Particle Size",
			0.4,
			3,
			cfg.WorldParticleSize,
			function(v)
				cfg.WorldParticleSize = v
			end
		)

		makeSlider(
			"Particle Speed",
			0.1,
			10,
			cfg.WorldParticleSpeed,
			function(v)
				cfg.WorldParticleSpeed = v
			end
		)

		makeSlider(
			"Particle Lifetime",
			1,
			15,
			cfg.WorldParticleLifetime,
			function(v)
				cfg.WorldParticleLifetime = v
			end
		)

		makeSlider(
			"Particle Spread",
			1,
			50,
			cfg.WorldParticleSpread,
			function(v)
				cfg.WorldParticleSpread = v
			end
		)

		makeSlider(
			"Particle Gravity",
			-5,
			5,
			cfg.WorldParticleGravity,
			function(v)
				cfg.WorldParticleGravity = v
			end
		)

		makeSlider(
			"Particle Transparency",
			0,
			0.95,
			cfg.WorldParticleTransparency,
			function(v)
				cfg.WorldParticleTransparency = v
			end
		)

		makeSlider(
			"Emission Rate",
			0.5,
			40,
			cfg.WorldParticleEmissionRate,
			function(v)
				cfg.WorldParticleEmissionRate = v
			end
		)

		makeSlider(
			"World Radius",
			8,
			80,
			cfg.WorldParticleRadius,
			function(v)
				cfg.WorldParticleRadius = v
			end
		)

		makeSlider(
			"Rainbow Speed",
			0.1,
			3,
			cfg.WorldParticleRainbowSpeed,
			function(v)
				cfg.WorldParticleRainbowSpeed = v
			end
		)

		makeSlider(
			"Wind",
			-10,
			10,
			cfg.WorldParticleWind,
			function(v)
				cfg.WorldParticleWind = v
			end
		)

		makeSlider(
			"Particle Red",
			0,
			255,
			cfg.WorldParticleColor.R * 255,
			function(v)
				cfg.WorldParticleColor = Color3.fromRGB(
					math.floor(v + 0.5),
					math.floor(cfg.WorldParticleColor.G * 255 + 0.5),
					math.floor(cfg.WorldParticleColor.B * 255 + 0.5)
				)
			end
		)

		makeSlider(
			"Particle Green",
			0,
			255,
			cfg.WorldParticleColor.G * 255,
			function(v)
				cfg.WorldParticleColor = Color3.fromRGB(
					math.floor(cfg.WorldParticleColor.R * 255 + 0.5),
					math.floor(v + 0.5),
					math.floor(cfg.WorldParticleColor.B * 255 + 0.5)
				)
			end
		)

		makeSlider(
			"Particle Blue",
			0,
			255,
			cfg.WorldParticleColor.B * 255,
			function(v)
				cfg.WorldParticleColor = Color3.fromRGB(
					math.floor(cfg.WorldParticleColor.R * 255 + 0.5),
					math.floor(cfg.WorldParticleColor.G * 255 + 0.5),
					math.floor(v + 0.5)
				)
			end
		)

	elseif tabName == "Visuals" then

		sectionLabel("VISUAL SETTINGS")

		actionButton(
			"Preview Effects: "
				.. (
					cfg.PreviewEffects
					and "ON"
					or "OFF"
				),

			function()
				cfg.PreviewEffects =
					not cfg.PreviewEffects

				rebuildPreviewDecor()
				renderTab("Visuals")
			end
		)

		actionButton(
			"Refresh Avatar Preview",

			function()
				refreshPreview()
				rebuildPreviewDecor()
				rebuildPreviewWings()
			end
		)

		sectionLabel("CUSTOM FOV")

		actionButton(
			"Custom FOV: "
				.. (
					cfg.CustomFOVEnabled
					and "ON"
					or "OFF"
				),
			function()
				cfg.CustomFOVEnabled = not cfg.CustomFOVEnabled
				updateCustomFOV()
				renderTab("Visuals")
			end
		)

		makeSlider(
			"FOV",
			30,
			120,
			cfg.CustomFOV,
			function(v)
				cfg.CustomFOV = math.clamp(math.floor(v + 0.5), 30, 120)
				updateCustomFOV()
			end
		)

		sectionLabel("TARGET INDICATORS")

		actionButton(
			"Target Indicators: "
				.. (
					cfg.TargetIndicatorsEnabled
					and "ON"
					or "OFF"
				),
			function()
				cfg.TargetIndicatorsEnabled = not cfg.TargetIndicatorsEnabled
				renderTab("Visuals")
			end
		)

		actionButton(
			"Rainbow Arrows: "
				.. (
					cfg.TargetArrowRainbow
					and "ON"
					or "OFF"
				),
			function()
				cfg.TargetArrowRainbow = not cfg.TargetArrowRainbow
				renderTab("Visuals")
			end
		)

		makeSlider(
			"Arrow Red",
			0,
			255,
			cfg.TargetArrowColor.R * 255,
			function(v)
				cfg.TargetArrowColor = Color3.fromRGB(
					math.floor(v + 0.5),
					math.floor(cfg.TargetArrowColor.G * 255 + 0.5),
					math.floor(cfg.TargetArrowColor.B * 255 + 0.5)
				)
			end
		)

		makeSlider(
			"Arrow Green",
			0,
			255,
			cfg.TargetArrowColor.G * 255,
			function(v)
				cfg.TargetArrowColor = Color3.fromRGB(
					math.floor(cfg.TargetArrowColor.R * 255 + 0.5),
					math.floor(v + 0.5),
					math.floor(cfg.TargetArrowColor.B * 255 + 0.5)
				)
			end
		)

		makeSlider(
			"Arrow Blue",
			0,
			255,
			cfg.TargetArrowColor.B * 255,
			function(v)
				cfg.TargetArrowColor = Color3.fromRGB(
					math.floor(cfg.TargetArrowColor.R * 255 + 0.5),
					math.floor(cfg.TargetArrowColor.G * 255 + 0.5),
					math.floor(v + 0.5)
				)
			end
		)

		makeSlider(
			"Arrow Transparency",
			0,
			0.95,
			cfg.TargetArrowTransparency,
			function(v)
				cfg.TargetArrowTransparency = v
			end
		)

		makeSlider(
			"Arrow Width",
			10,
			50,
			cfg.TargetArrowWidth,
			function(v)
				cfg.TargetArrowWidth = math.floor(v + 0.5)
			end
		)

		makeSlider(
			"Arrow Radius",
			10,
			95,
			cfg.TargetArrowRadius,
			function(v)
				cfg.TargetArrowRadius = math.floor(v + 0.5)
			end
		)

		makeSlider(
			"Arrow Rainbow Speed",
			0.1,
			3,
			cfg.TargetArrowRainbowSpeed,
			function(v)
				cfg.TargetArrowRainbowSpeed = v
			end
		)

		actionButton(
			"Target Outline: "
				.. (
					cfg.TargetOutlineEnabled
					and "ON"
					or "OFF"
				),
			function()
				cfg.TargetOutlineEnabled = not cfg.TargetOutlineEnabled
				if not cfg.TargetOutlineEnabled then
					clearTargetOutlines()
				end
				renderTab("Visuals")
			end
		)

		actionButton(
			"Rainbow Outline: "
				.. (
					cfg.TargetOutlineRainbow
					and "ON"
					or "OFF"
				),
			function()
				cfg.TargetOutlineRainbow = not cfg.TargetOutlineRainbow
				renderTab("Visuals")
			end
		)

		makeSlider(
			"Outline Red",
			0,
			255,
			cfg.TargetOutlineColor.R * 255,
			function(v)
				cfg.TargetOutlineColor = Color3.fromRGB(
					math.floor(v + 0.5),
					math.floor(cfg.TargetOutlineColor.G * 255 + 0.5),
					math.floor(cfg.TargetOutlineColor.B * 255 + 0.5)
				)
			end
		)

		makeSlider(
			"Outline Green",
			0,
			255,
			cfg.TargetOutlineColor.G * 255,
			function(v)
				cfg.TargetOutlineColor = Color3.fromRGB(
					math.floor(cfg.TargetOutlineColor.R * 255 + 0.5),
					math.floor(v + 0.5),
					math.floor(cfg.TargetOutlineColor.B * 255 + 0.5)
				)
			end
		)

		makeSlider(
			"Outline Blue",
			0,
			255,
			cfg.TargetOutlineColor.B * 255,
			function(v)
				cfg.TargetOutlineColor = Color3.fromRGB(
					math.floor(cfg.TargetOutlineColor.R * 255 + 0.5),
					math.floor(cfg.TargetOutlineColor.G * 255 + 0.5),
					math.floor(v + 0.5)
				)
			end
		)

		makeSlider(
			"Outline Transparency",
			0,
			0.95,
			cfg.TargetOutlineTransparency,
			function(v)
				cfg.TargetOutlineTransparency = v
			end
		)

		makeSlider(
			"Outline Rainbow Speed",
			0.1,
			3,
			cfg.TargetOutlineRainbowSpeed,
			function(v)
				cfg.TargetOutlineRainbowSpeed = v
			end
		)

		sectionLabel("FIRST-PERSON HANDS")

		actionButton(
			"Hands FX: "
				.. (
					cfg.HandsEnabled
					and "ON"
					or "OFF"
				),
			function()
				cfg.HandsEnabled = not cfg.HandsEnabled
				applyHandsVisuals()
				renderTab("Visuals")
			end
		)

		actionButton(
			"Hand Shader: " .. cfg.HandsShader,
			function()
				local shaders = {
					"Default",
					"Neon",
					"Cosmic",
					"Holographic",
					"Pulse",
					"Glass",
					"Metal",
				}
				local index = table.find(shaders, cfg.HandsShader) or 1
				cfg.HandsShader = shaders[index % #shaders + 1]
				applyHandsVisuals()
				renderTab("Visuals")
			end
		)

		actionButton(
			"Rainbow Fill: "
				.. (
					cfg.HandsRainbow
					and "ON"
					or "OFF"
				),
			function()
				cfg.HandsRainbow = not cfg.HandsRainbow
				renderTab("Visuals")
			end
		)

		actionButton(
			"Hand Outline: "
				.. (
					cfg.HandsOutlineEnabled
					and "ON"
					or "OFF"
				),
			function()
				cfg.HandsOutlineEnabled = not cfg.HandsOutlineEnabled
				applyHandsVisuals()
				renderTab("Visuals")
			end
		)

		actionButton(
			"Rainbow Outline: "
				.. (
					cfg.HandsOutlineRainbow
					and "ON"
					or "OFF"
				),
			function()
				cfg.HandsOutlineRainbow = not cfg.HandsOutlineRainbow
				renderTab("Visuals")
			end
		)

		actionButton(
			"Hand Glow: "
				.. (
					cfg.HandsGlowEnabled
					and "ON"
					or "OFF"
				),
			function()
				cfg.HandsGlowEnabled = not cfg.HandsGlowEnabled
				applyHandsVisuals()
				renderTab("Visuals")
			end
		)

		makeSlider(
			"Hand Red",
			0,
			255,
			cfg.HandsFillColor.R * 255,
			function(v)
				cfg.HandsFillColor = Color3.fromRGB(
					math.floor(v + 0.5),
					math.floor(cfg.HandsFillColor.G * 255 + 0.5),
					math.floor(cfg.HandsFillColor.B * 255 + 0.5)
				)
				applyHandsVisuals()
			end
		)

		makeSlider(
			"Hand Green",
			0,
			255,
			cfg.HandsFillColor.G * 255,
			function(v)
				cfg.HandsFillColor = Color3.fromRGB(
					math.floor(cfg.HandsFillColor.R * 255 + 0.5),
					math.floor(v + 0.5),
					math.floor(cfg.HandsFillColor.B * 255 + 0.5)
				)
				applyHandsVisuals()
			end
		)

		makeSlider(
			"Hand Blue",
			0,
			255,
			cfg.HandsFillColor.B * 255,
			function(v)
				cfg.HandsFillColor = Color3.fromRGB(
					math.floor(cfg.HandsFillColor.R * 255 + 0.5),
					math.floor(cfg.HandsFillColor.G * 255 + 0.5),
					math.floor(v + 0.5)
				)
				applyHandsVisuals()
			end
		)

		makeSlider(
			"Outline Red",
			0,
			255,
			cfg.HandsOutlineColor.R * 255,
			function(v)
				cfg.HandsOutlineColor = Color3.fromRGB(
					math.floor(v + 0.5),
					math.floor(cfg.HandsOutlineColor.G * 255 + 0.5),
					math.floor(cfg.HandsOutlineColor.B * 255 + 0.5)
				)
				applyHandsVisuals()
			end
		)

		makeSlider(
			"Outline Green",
			0,
			255,
			cfg.HandsOutlineColor.G * 255,
			function(v)
				cfg.HandsOutlineColor = Color3.fromRGB(
					math.floor(cfg.HandsOutlineColor.R * 255 + 0.5),
					math.floor(v + 0.5),
					math.floor(cfg.HandsOutlineColor.B * 255 + 0.5)
				)
				applyHandsVisuals()
			end
		)

		makeSlider(
			"Outline Blue",
			0,
			255,
			cfg.HandsOutlineColor.B * 255,
			function(v)
				cfg.HandsOutlineColor = Color3.fromRGB(
					math.floor(cfg.HandsOutlineColor.R * 255 + 0.5),
					math.floor(cfg.HandsOutlineColor.G * 255 + 0.5),
					math.floor(v + 0.5)
				)
				applyHandsVisuals()
			end
		)

		makeSlider(
			"Glow Red",
			0,
			255,
			cfg.HandsGlowColor.R * 255,
			function(v)
				cfg.HandsGlowColor = Color3.fromRGB(
					math.floor(v + 0.5),
					math.floor(cfg.HandsGlowColor.G * 255 + 0.5),
					math.floor(cfg.HandsGlowColor.B * 255 + 0.5)
				)
				applyHandsVisuals()
			end
		)

		makeSlider(
			"Glow Green",
			0,
			255,
			cfg.HandsGlowColor.G * 255,
			function(v)
				cfg.HandsGlowColor = Color3.fromRGB(
					math.floor(cfg.HandsGlowColor.R * 255 + 0.5),
					math.floor(v + 0.5),
					math.floor(cfg.HandsGlowColor.B * 255 + 0.5)
				)
				applyHandsVisuals()
			end
		)

		makeSlider(
			"Glow Blue",
			0,
			255,
			cfg.HandsGlowColor.B * 255,
			function(v)
				cfg.HandsGlowColor = Color3.fromRGB(
					math.floor(cfg.HandsGlowColor.R * 255 + 0.5),
					math.floor(cfg.HandsGlowColor.G * 255 + 0.5),
					math.floor(v + 0.5)
				)
				applyHandsVisuals()
			end
		)

		makeSlider(
			"Hand Transparency",
			0,
			0.9,
			cfg.HandsTransparency,
			function(v)
				cfg.HandsTransparency = v
				applyHandsVisuals()
			end
		)

		makeSlider(
			"Outline Transparency",
			0,
			0.95,
			cfg.HandsOutlineTransparency,
			function(v)
				cfg.HandsOutlineTransparency = v
			end
		)

		makeSlider(
			"Glow Strength",
			0,
			8,
			cfg.HandsGlowStrength,
			function(v)
				cfg.HandsGlowStrength = v
			end
		)

		makeSlider(
			"Shader Speed",
			0.1,
			3,
			cfg.HandsShaderSpeed,
			function(v)
				cfg.HandsShaderSpeed = v
			end
		)

		makeSlider(
			"Rainbow Speed",
			0.1,
			3,
			cfg.HandsRainbowSpeed,
			function(v)
				cfg.HandsRainbowSpeed = v
			end
		)

	elseif tabName == "HUD" then

		sectionLabel("STRETCH")

		makeSlider(
			"Stretch Changer",
			0,
			100,
			cfg.StretchAmount,
			function(v)
				cfg.StretchAmount = math.clamp(v, 0, 100)
				applyStretch()
			end
		)

		sectionLabel("SCREEN COLOR")

		makeSlider(
			"Color Saturation",
			-1,
			1,
			cfg.ScreenSaturation,
			function(v)
				cfg.ScreenSaturation = math.clamp(v, -1, 1)
				applyScreenSaturation()
			end
		)

		sectionLabel("HUD VISIBILITY")

		actionButton(
			"Dynamic Island: "
				.. (
					cfg.IslandEnabled
					and "ON"
					or "OFF"
				),

			function()
				cfg.IslandEnabled =
					not cfg.IslandEnabled

				applyHudAppearance()
				renderTab("HUD")
			end
		)

		actionButton(
			"Coordinates: "
				.. (
					cfg.CoordinatesEnabled
					and "ON"
					or "OFF"
				),

			function()
				cfg.CoordinatesEnabled =
					not cfg.CoordinatesEnabled

				applyHudAppearance()
				renderTab("HUD")
			end
		)

		actionButton(
			"Speedometer: "
				.. (
					cfg.SpeedEnabled
					and "ON"
					or "OFF"
				),

			function()
				cfg.SpeedEnabled =
					not cfg.SpeedEnabled

				applyHudAppearance()
				

renderTab("HUD")
			end
		)

	elseif tabName == "Settings" then

		sectionLabel("MENU APPEARANCE")

		makeSlider(
			"Menu Scale",
			0.7,
			1.15,
			0.73,

			function(v)
				applyMenuScale(v)
			end
		)

		sectionLabel("MENU PARTICLES")

		actionButton(
			"Menu Particles: " .. cfg.MenuParticles,
			function()
				local types = {
					"Off",
					"Sakura",
					"Snow",
					"Matrix",
					"Autumn",
				}
				local index = table.find(types, cfg.MenuParticles) or 1
				cfg.MenuParticles = types[index % #types + 1]
				clearMenuParticles()
				renderTab("Settings")
			end
		)

		makeSlider(
			"Particle Amount",
			4,
			80,
			cfg.MenuParticleAmount,
			function(v)
				cfg.MenuParticleAmount = math.clamp(math.floor(v + 0.5), 4, 80)
			end
		)

		makeSlider(
			"Particle Speed",
			0.2,
			3,
			cfg.MenuParticleSpeed,
			function(v)
				cfg.MenuParticleSpeed = v
			end
		)

		sectionLabel("DYNAMIC ISLAND SETTINGS")

		makeSlider(
			"Island Scale",
			0.7,
			1.5,
			cfg.IslandScale,

			function(v)
				cfg.IslandScale = v

				island.Size =
					UDim2.fromOffset(
						255 * v,
						34 * v
					)
			end
		)

		makeSlider(
			"Island X",
			0,
			1,
			cfg.IslandX,

			function(v)
				cfg.IslandX = v

				island.Position =
					UDim2.new(
						v,
						-127,
						cfg.IslandY,
						0
					)
			end
		)

		makeSlider(
			"Island Y",
			0,
			0.25,
			cfg.IslandY,

			function(v)
				cfg.IslandY = v

				island.Position =
					UDim2.new(
						cfg.IslandX,
						-127,
						v,
						0
					)
			end
		)

		makeSlider(
			"Island Transparency",
			0,
			0.8,
			cfg.IslandTransparency,

			function(v)
				cfg.IslandTransparency = v
				island.BackgroundTransparency = v
			end
		)

		sectionLabel("COORDINATES PANEL")

		makeSlider(
			"Coordinates Scale",
			0.7,
			1.5,
			cfg.CoordinatesScale,

			function(v)
				cfg.CoordinatesScale = v

				coordinatesPanel.Size =
					UDim2.fromOffset(
						230 * v,
						38 * v
					)
			end
		)

		makeSlider(
			"Coordinates X",
			0,
			0.8,
			cfg.CoordinatesX,

			function(v)
				cfg.CoordinatesX = v

				coordinatesPanel.Position =
					UDim2.new(
						v,
						0,
						cfg.CoordinatesY,
						0
					)
			end
		)

		makeSlider(
			"Coordinates Y",
			0,
			1,
			cfg.CoordinatesY,

			function(v)
				cfg.CoordinatesY = v

				coordinatesPanel.Position =
					UDim2.new(
						cfg.CoordinatesX,
						0,
						v,
						0
					)
			end
		)

		makeSlider(
			"Coordinates Transparency",
			0,
			0.8,
			cfg.CoordinatesTransparency,

			function(v)
				cfg.CoordinatesTransparency = v
				coordinatesPanel.BackgroundTransparency = v
			end
		)

		sectionLabel("SPEEDOMETER PANEL")

		makeSlider(
			"Speedometer Scale",
			0.7,
			1.5,
			cfg.SpeedScale,

			function(v)
				cfg.SpeedScale = v

				speedPanel.Size =
					UDim2.fromOffset(
						155 * v,
						38 * v
					)
			end
		)

		makeSlider(
			"Speedometer X",
			0,
			0.8,
			cfg.SpeedX,

			function(v)
				cfg.SpeedX = v

				speedPanel.Position =
					UDim2.new(
						v,
						0,
						cfg.SpeedY,
						0
					)
			end
		)

		makeSlider(
			"Speedometer Y",
			0,
			1,
			cfg.SpeedY,

			function(v)
				cfg.SpeedY = v

				speedPanel.Position =
					UDim2.new(
						cfg.SpeedX,
						0,
						v,
						0
					)
			end
		)

		makeSlider(
			"Speedometer Transparency",
			0,
			0.8,
			cfg.SpeedTransparency,

			function(v)
				cfg.SpeedTransparency = v
				speedPanel.BackgroundTransparency = v
			end
		)
	end
end

--==================================================
-- BUTTONS
--==================================================

iconButton.Activated:Connect(function()
	main.Visible = not main.Visible
end)

closeButton.Activated:Connect(function()
	main.Visible = false
end)

--==================================================
-- MAIN UPDATE LOOP
--==================================================

table.insert(
	connections,
	RunService.Heartbeat:Connect(function(dt)

		updateHud(dt)

		if cfg.TrailRainbow then
			hues.Trail =
				(
					hues.Trail
					+ dt
						* cfg.TrailRainbowSpeed
						* 0.15
				) % 1

			refreshTrail()
		end

		if cfg.GhostRainbow then
			hues.Ghost =
				(
					hues.Ghost
					+ dt
						* cfg.GhostRainbowSpeed
						* 0.15
				) % 1
		end

		if cfg.OrbitRainbow then
			hues.Orbit =
				(
					hues.Orbit
					+ dt * 0.15
				) % 1
		end

		if cfg.JumpCircleRainbow then
			hues.Jump =
				(
					hues.Jump
					+ dt
						* cfg.JumpCircleRainbowSpeed
						* 0.15
				) % 1
		end

		if cfg.PulseRingRainbow then
			hues.Pulse =
				(
					hues.Pulse
					+ dt * 0.5 * 0.15
				) % 1
		end

		if cfg.CrystalRainbow then
			hues.Crystal =
				(
					hues.Crystal
					+ dt
						* cfg.CrystalRainbowSpeed
						* 0.15
				) % 1
		end

		-- ESP RGB
		if cfg.ESPUseRGB then
			hues.ESP =
				(
					hues.ESP
					+ dt
						* cfg.ESPRGBSpeed
						* 0.15
				) % 1

			espRGBColor =
				Color3.fromHSV(
					hues.ESP,
					0.9,
					1
				)
		end

		updatePreviewDecor(dt)
		updateMenuParticles(dt)
		updateWorldParticles(dt)
		updateWingColors()
		syncHandsViewModel()
		updateHandsVisuals(dt)
		updateCustomFOV()
		applyStretch()

		targetIndicatorAccumulator += dt
		if targetIndicatorAccumulator >= 0.12 then
			targetIndicatorAccumulator = 0
			updateTargetIndicators()
			updateTargetOutlines()
		end

		local char = getCharacter()
		local root = getRoot(char)

		if not char or not root then
			return
		end

		if char ~= currentCharacter then
			currentCharacter = char

			lastGhostPosition = nil

			task.spawn(
				setupTrail,
				char
			)

			task.spawn(
				connectJumpCircle,
				char
			)

			rebuildOrbitObjects()
			createPulseRing()

			task.delay(
				0.3,
				function()
					refreshPreview()
					rebuildPreviewDecor()
				end
			)

			if cfg.CombatESPEnabled then
				task.delay(
					0.5,
					createESP
				)
			end
		end

		if cfg.CombatESPEnabled then
			updateESP(dt)
		end

		if cfg.GhostEnabled then
			local position = root.Position

			if not lastGhostPosition then
				lastGhostPosition = position
			end

			local distance =
				(
					position
					- lastGhostPosition
				).Magnitude

			ghostAccumulator += dt

			if distance >= 0.12
				and ghostAccumulator >=
					cfg.GhostInterval then

				ghostAccumulator = 0
				lastGhostPosition = position

				createGhost()

			elseif ghostAccumulator >
				cfg.GhostInterval * 2 then

				ghostAccumulator = 0
				lastGhostPosition = position
			end
		else
			ghostAccumulator = 0
			lastGhostPosition = nil
		end

		if cfg.OrbitEnabled then
			local wantedCount =
				math.clamp(
					math.floor(
						cfg.OrbitCount + 0.5
					),
					1,
					12
				)

			if #orbitObjects ~=
				wantedCount then

				rebuildOrbitObjects()
			end

			orbitAngle +=
				dt * cfg.OrbitSpeed

			local count =
				#orbitObjects

			for i, model in ipairs(
				orbitObjects
			) do

				if model
					and model.Parent then

					local angle =
						orbitAngle
						+ (i - 1)
						* math.pi
						* 2
						/ math.max(
							count,
							1
						)

					local radius =
						cfg.OrbitRadius

					local height =
						1.5
						+ math.sin(
							orbitAngle
								* 1.8
								+ i
						)
						* 0.45

					if cfg.OrbitType ==
						"Ghosts" then

						height =
							(
								i % 2 == 0
								and 0.45
								or 2.15
							)
							+ math.sin(
								angle * 1.15
							) * 0.8

					elseif cfg.OrbitType ==
						"Crystals" then

						height =
							cfg.CrystalFloatHeight
							+ math.sin(
								orbitAngle * 2
									+ i * 1.7
							) * 0.65
					end

					local position =
						root.Position
						+ Vector3.new(
							math.cos(angle)
								* radius,
							height,
							math.sin(angle)
								* radius
						)

					local target

					if cfg.OrbitType ==
						"Swords" then

						target =
							CFrame.lookAt(
								position,
								root.Position
									+ Vector3.new(
										0,
										1.5,
										0
									)
							)
							* CFrame.Angles(
								math.rad(90),
								0,
								math.rad(
									orbitAngle * 40
								)
							)
					else

						target =
							CFrame.new(
								position
							)
							* CFrame.Angles(
								math.sin(
									orbitAngle + i
								) * 0.3,

								-angle
									+ orbitAngle,

								math.cos(
									orbitAngle + i
								) * 0.3
							)
					end

					model:PivotTo(target)

					local color =
						cfg.OrbitType ==
							"Crystals"
						and colorFor("Crystal")
						or colorFor("Orbit")

					for _, part in ipairs(
						model:GetDescendants()
					) do

						if part:IsA("BasePart")
							and part.Material ==
								Enum.Material.Neon then

							part.Color = color

						elseif part:IsA("PointLight") then
							part.Color = color

						elseif part:IsA("Trail")
							and cfg.OrbitType ==
								"Ghosts" then

							part.Color =
								ColorSequence.new(
									color
								)
						end
					end
				end
			end

		elseif #orbitObjects > 0 then
			clearOrbitObjects()
		end

		if cfg.PulseRingEnabled then

			if #pulseSegments == 0 then
				createPulseRing()
			end

			updatePulseRing(
				dt,
				root
			)

		elseif #pulseSegments > 0 then
			clearPulseRing()
		end
	end)
)

--==================================================
-- PLAYER EVENTS
--==================================================

local function hookPlayer(otherPlayer)
	if otherPlayer == player then
		return
	end

	otherPlayer.CharacterAdded:Connect(
		function()

			task.wait(0.5)

			if cfg.CombatESPEnabled then
				createESP()
			end
		end
	)
end

for _, otherPlayer in ipairs(
	Players:GetPlayers()
) do
	hookPlayer(otherPlayer)
end

Players.PlayerAdded:Connect(
	hookPlayer
)

Players.PlayerRemoving:Connect(
	function()
		if cfg.CombatESPEnabled then
			task.defer(createESP)
		end
	end
)

player.CharacterAdded:Connect(
	function(char)

		currentCharacter = char
		lastGhostPosition = nil

		task.spawn(
			function()

				setupTrail(char)
				connectJumpCircle(char)

				rebuildOrbitObjects()
				createPulseRing()
				rebuildAngelWings()
				applyHandsVisuals()
			end
		)

		task.delay(
			1,
			function()

				refreshPreview()
				rebuildPreviewDecor()
				rebuildPreviewWings()

				if cfg.CombatESPEnabled then
					createESP()
				end
			end
		)
	end
)

player.CharacterRemoving:Connect(
	function()

		clearOrbitObjects()
		clearPulseRing()
		clearESP()
		clearPreviewDecor()
		clearTargetIndicators()
		clearTargetOutlines()
		clearWorldParticles()
		wingModel = destroyWings(wingModel)
		previewWingModel = destroyWings(previewWingModel)
		clearHandsVisuals()

		if trail then
			trail:Destroy()
			trail = nil
		end

		if leftAttachment then
			leftAttachment:Destroy()
			leftAttachment = nil
		end

		if rightAttachment then
			rightAttachment:Destroy()
			rightAttachment = nil
		end

		if jumpConnection then
			jumpConnection:Disconnect()
			jumpConnection = nil
		end
	end
)

--==================================================
-- INITIAL SETUP
--==================================================

applyHudAppearance()
applyScreenSaturation()

if getCharacter() then
	currentCharacter = getCharacter()

	task.spawn(
		function()

			setupTrail(
				currentCharacter
			)

			connectJumpCircle(
				currentCharacter
			)

			rebuildOrbitObjects()
			createPulseRing()
			rebuildAngelWings()
			applyHandsVisuals()

			refreshPreview()
			rebuildPreviewDecor()
			rebuildPreviewWings()
		end
	)
else

	player.CharacterAdded:Once(
		function()

			task.wait(0.5)

			refreshPreview()
			rebuildPreviewDecor()
			rebuildPreviewWings()
		end
	)
end

applyMenuScale(0.73)


pcall(function()
	RunService:UnbindFromRenderStep("S1lentAimAssist")
end)

RunService:BindToRenderStep(
	"S1lentAimAssist",
	Enum.RenderPriority.Camera.Value + 1,
	function(dt)
		updateAimAssist()
		updateTriggerBot()
		updateRivalsBot(dt)
	end
)
renderTab("Combat")