local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- // CONFIGURATION
local HUB_NAME = "Unified Hub | dsc.gg/unifiedhub"
local ICON_ID = "rbxassetid://78764031032098"
local THEME = {
	Primary = Color3.fromRGB(139, 92, 246),
	Background = Color3.fromRGB(28, 28, 34),
	Element = Color3.fromRGB(42, 42, 52),
	Surface = Color3.fromRGB(30, 26, 34),
	Text = Color3.fromRGB(235, 235, 245),
	TextDark = Color3.fromRGB(170, 170, 190),
	StrokeSoft = Color3.fromRGB(78, 78, 96),
}

local UI = {}
UI._Alive = true
UI._Open = true
UI._CurrentTab = nil
UI._Settings = {
	MinimizeKeyCode = Enum.KeyCode.RightControl,
}

-- // CORE UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UnifiedHub_Final"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local success, parent = pcall(function() return gethui() or game:GetService("CoreGui") end)
local _DefaultParent = success and parent or Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = nil
UI.ScreenGui = ScreenGui

-- // UTILS
local function AddCorner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = inst
end

local function AddStroke(inst, thickness, color, transparency)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness or 1
	s.Color = color or THEME.StrokeSoft
	s.Transparency = transparency or 0.35
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
end

local function AddGradient(inst, c1, c2, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c1),
		ColorSequenceKeypoint.new(1, c2),
	})
	g.Rotation = rot or 90
	g.Parent = inst
	return g
end

-- // MAIN FRAME
local MAIN_W = 460
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(MAIN_W, 550)
Main.Position = UDim2.new(0.5, -math.floor(MAIN_W / 2), 0.5, -275)
Main.BackgroundColor3 = THEME.Background
Main.BackgroundTransparency = 0.08
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
AddCorner(Main, 12)

AddStroke(Main, 1, THEME.StrokeSoft, 0.35)
AddGradient(Main, Color3.fromRGB(18, 18, 26), Color3.fromRGB(14, 14, 18), 90)

-- // TABS BAR (TOP)
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -20, 0, 35)
TabBar.Position = UDim2.fromOffset(10, 55)
TabBar.BackgroundTransparency = 1
TabBar.ZIndex = 10
TabBar.Parent = Main

local TabList = Instance.new("Frame")
TabList.Name = "TabList"
TabList.Size = UDim2.fromScale(1, 1)
TabList.BackgroundTransparency = 1
TabList.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 15)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Parent = TabList

-- // CONTAINER
local ContainerHolder = Instance.new("Frame")
ContainerHolder.Name = "ContainerHolder"
ContainerHolder.Size = UDim2.new(1, -20, 1, -110)
ContainerHolder.Position = UDim2.fromOffset(10, 100)
ContainerHolder.BackgroundTransparency = 1
ContainerHolder.Parent = Main

local Container = ContainerHolder

local function ToggleMinimize()
	local target = (Main.Size.Y.Offset > 60) and UDim2.fromOffset(MAIN_W, 50) or UDim2.fromOffset(MAIN_W, 550)
	TweenService:Create(Main, TweenInfo.new(0.4), {Size = target}):Play()
end

-- // TOP BAR (DRAGGABLE)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1
TopBar.Parent = Main

local Icon = Instance.new("ImageLabel")
Icon.Size = UDim2.fromOffset(35, 35)
Icon.Position = UDim2.fromOffset(10, 7.5)
Icon.Image = ICON_ID
Icon.BackgroundTransparency = 1
Icon.Parent = TopBar
AddCorner(Icon, 8)

local Title = Instance.new("TextLabel")
Title.Text = HUB_NAME
Title.Size = UDim2.new(1, -150, 1, 0)
Title.Position = UDim2.fromOffset(55, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = THEME.Text
Title.TextSize = 17
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Dragging Logic
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Buttons ( - then X )
local function CreateHeaderBtn(txt, xOff, color, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(30, 30)
	b.Position = UDim2.new(1, xOff, 0, 10)
	b.BackgroundColor3 = color
	b.BackgroundTransparency = 0.25
	b.Text = txt
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 20
	b.Parent = TopBar
	AddCorner(b, 6)
	AddStroke(b, 1, THEME.StrokeSoft, 0.55)
	b.MouseButton1Click:Connect(cb)
end

CreateHeaderBtn("-", -75, THEME.Primary, function()
	ToggleMinimize()
end)

CreateHeaderBtn("×", -35, Color3.fromRGB(170, 60, 70), function() ScreenGui:Destroy() end)

-- // TABS
local Tabs = {}
local CurrentTab = nil

function UI:CreateTab(opt)
	opt = opt or {}
	local tabName = opt.Name or "Tab"
	
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(0, 100, 1, 0)
	tabBtn.BackgroundColor3 = THEME.Element
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = tabName
	tabBtn.Font = Enum.Font.GothamSemibold
	tabBtn.TextSize = 14
	tabBtn.TextColor3 = THEME.TextDark
	tabBtn.Parent = TabList
	AddCorner(tabBtn, 6)
	
	-- Automatic width adjustment
	local textSize = game:GetService("TextService"):GetTextSize(tabName, 14, Enum.Font.GothamSemibold, Vector2.new(1000, 1000))
	tabBtn.Size = UDim2.new(0, textSize.X + 10, 1, 0)
	
	local container = Instance.new("ScrollingFrame")
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.ScrollBarThickness = 2
	container.ScrollBarImageColor3 = THEME.Primary
	container.ScrollBarImageTransparency = 0.55
	container.Visible = false
	container.Parent = ContainerHolder
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = container
	
	local tab = {
		Name = tabName,
		Button = tabBtn,
		Container = container
	}
	
	tabBtn.MouseButton1Click:Connect(function()
		self:SelectTab(tabName)
	end)
	
	Tabs[tabName] = tab
	
	if not CurrentTab then
		self:SelectTab(tabName)
	end
	
	function tab:CreateSection(sectionTitle)
		local header = Instance.new("TextLabel")
		header.BackgroundTransparency = 1
		header.Text = tostring(sectionTitle or "Section")
		header.Font = Enum.Font.GothamBold
		header.TextSize = 14
		header.TextColor3 = THEME.Text
		header.TextXAlignment = Enum.TextXAlignment.Left
		header.Size = UDim2.new(0.95, 0, 0, 24)
		header.Parent = container

		local sec = {}
		sec.Body = container
		sec.Header = header
		return sec
	end
	
	function tab:CreateLockedSection(sectionTitle)
		return tab:CreateSection(sectionTitle)
	end
	
	return tab
end

function UI:SelectTab(name)
	if CurrentTab == name then return end
	
	for n, t in pairs(Tabs) do
		if n == name then
			t.Container.Visible = true
			t.Container.CanvasPosition = Vector2.zero
			TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.25, TextColor3 = THEME.Text}):Play()
			CurrentTab = name
		else
			t.Container.Visible = false
			TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = THEME.TextDark}):Play()
		end
	end
end

-- // COMPONENT LIBRARY
local Lib = {}

function Lib:Button(text, callback, parentOverride)
	local parentTarget = parentOverride or Container
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 45)
	btn.BackgroundColor3 = THEME.Element
	btn.BackgroundTransparency = 0.25
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 16
	btn.TextColor3 = THEME.Text
	btn.Parent = parentTarget
	AddCorner(btn, 8)
	AddStroke(btn, 1, THEME.StrokeSoft, 0.5)
	btn.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)
	return {Frame = btn}
end

function Lib:Toggle(text, callback, parentOverride, default)
	local parentTarget = parentOverride or Container
	local enabled = false
	if default == true then
		enabled = true
	end
	local tFrame = Instance.new("TextButton")
	tFrame.Size = UDim2.new(0.95, 0, 0, 45)
	tFrame.BackgroundColor3 = THEME.Element
	tFrame.BackgroundTransparency = 0.25
	tFrame.BorderSizePixel = 0
	tFrame.Text = "  " .. text
	tFrame.TextXAlignment = Enum.TextXAlignment.Left
	tFrame.Font = Enum.Font.GothamSemibold
	tFrame.TextSize = 16
	tFrame.TextColor3 = THEME.Text
	tFrame.Parent = parentTarget
	AddCorner(tFrame, 8)
	AddStroke(tFrame, 1, THEME.StrokeSoft, 0.5)

	local switch = Instance.new("Frame")
	switch.Size = UDim2.fromOffset(35, 20)
	switch.Position = UDim2.new(1, -45, 0.5, -10)
	switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	switch.BackgroundTransparency = 0.88
	switch.BorderSizePixel = 0
	switch.Parent = tFrame
	AddCorner(switch, 10)
	AddStroke(switch, 1, THEME.StrokeSoft, 0.55)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = enabled and UDim2.fromOffset(17, 2) or UDim2.fromOffset(2, 2)
	knob.BackgroundColor3 = enabled and THEME.Primary or THEME.Text
	knob.BackgroundTransparency = 0.05
	knob.BorderSizePixel = 0
	knob.Parent = switch
	AddCorner(knob, 999)

	local glow = Instance.new("UIStroke")
	glow.Thickness = 2
	glow.Color = THEME.Primary
	glow.Transparency = enabled and 0.35 or 1
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.Parent = switch

	tFrame.MouseButton1Click:Connect(function()
		enabled = not enabled
		TweenService:Create(knob, TweenInfo.new(0.22), {
			Position = enabled and UDim2.fromOffset(17, 2) or UDim2.fromOffset(2, 2),
			BackgroundColor3 = enabled and THEME.Primary or THEME.Text,
		}):Play()
		TweenService:Create(glow, TweenInfo.new(0.22), {Transparency = enabled and 0.35 or 1}):Play()
		TweenService:Create(switch, TweenInfo.new(0.22), {BackgroundTransparency = enabled and 0.80 or 0.88}):Play()
		if callback then
			callback(enabled)
		end
	end)

	local api = {}
	api.Frame = tFrame
	function api:Set(v)
		local nv = (v == true)
		if nv == enabled then return end
		enabled = nv
		TweenService:Create(knob, TweenInfo.new(0.01), {
			Position = enabled and UDim2.fromOffset(17, 2) or UDim2.fromOffset(2, 2),
			BackgroundColor3 = enabled and THEME.Primary or THEME.Text,
		}):Play()
		TweenService:Create(glow, TweenInfo.new(0.01), {Transparency = enabled and 0.35 or 1}):Play()
		TweenService:Create(switch, TweenInfo.new(0.01), {BackgroundTransparency = enabled and 0.80 or 0.88}):Play()
		if callback then
			callback(enabled)
		end
	end
	function api:Get()
		return enabled
	end
	return api
end

function Lib:Textbox(text, placeholder, callback, parentOverride, default)
	local parentTarget = parentOverride or Container
	local boxFrame = Instance.new("Frame")
	boxFrame.Size = UDim2.new(0.95, 0, 0, 45)
	boxFrame.BackgroundColor3 = THEME.Element
	boxFrame.BackgroundTransparency = 0.25
	boxFrame.BorderSizePixel = 0
	boxFrame.Parent = parentTarget
	AddCorner(boxFrame, 8)
	AddStroke(boxFrame, 1, THEME.StrokeSoft, 0.5)

	local label = Instance.new("TextLabel")
	label.Text = "  " .. text
	label.Size = UDim2.new(0.4, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamSemibold
	label.TextColor3 = THEME.Text
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = boxFrame

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(0.5, 0, 0.7, 0)
	input.Position = UDim2.new(0.45, 0, 0.15, 0)
	input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	input.BackgroundTransparency = 0.92
	input.BorderSizePixel = 0
	input.PlaceholderText = placeholder or "Type here..."
	input.PlaceholderColor3 = THEME.TextDark
	input.Text = tostring(default or "")
	input.TextColor3 = THEME.Text
	input.Font = Enum.Font.Gotham
	input.TextSize = 14
	input.Parent = boxFrame
	AddCorner(input, 6)
	AddStroke(input, 1, THEME.StrokeSoft, 0.55)

	input.FocusLost:Connect(function(enter)
		if callback then
			callback(input.Text, enter)
		end
	end)

	local api = {}
	api.Frame = boxFrame
	api.Box = input
	function api:Set(v)
		input.Text = tostring(v or "")
	end
	function api:Get()
		return input.Text
	end
	return api
end

function Lib:Slider(text, min, max, default, callback, parentOverride, step)
	local parentTarget = parentOverride or Container
	local sFrame = Instance.new("Frame")
	sFrame.Size = UDim2.new(0.95, 0, 0, 60)
	sFrame.BackgroundColor3 = THEME.Element
	sFrame.BackgroundTransparency = 0.25
	sFrame.BorderSizePixel = 0
	sFrame.Parent = parentTarget
	AddCorner(sFrame, 8)
	AddStroke(sFrame, 1, THEME.StrokeSoft, 0.5)

	local label = Instance.new("TextLabel")
	label.Text = "  " .. text
	label.Size = UDim2.new(1, 0, 0, 30)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamSemibold
	label.TextColor3 = THEME.Text
	label.TextSize = 15
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = sFrame

	local valLabel = Instance.new("TextLabel")
	valLabel.Size = UDim2.new(1, -10, 0, 30)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = tostring(default)
	valLabel.TextColor3 = THEME.TextDark
	valLabel.TextXAlignment = Enum.TextXAlignment.Right
	valLabel.Parent = sFrame

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0.9, 0, 0, 6)
	bar.Position = UDim2.new(0.05, 0, 0.75, 0)
	bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bar.BackgroundTransparency = 0.92
	bar.BorderSizePixel = 0
	bar.Parent = sFrame
	AddCorner(bar, 3)
	AddStroke(bar, 1, THEME.StrokeSoft, 0.6)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale((default - min) / (max - min), 1)
	fill.BackgroundColor3 = THEME.Primary
	fill.Parent = bar
	AddCorner(fill, 3)
	fill.BorderSizePixel = 0
	AddGradient(fill, Color3.fromRGB(160, 120, 255), THEME.Primary, 0)

	local function applyValue(val)
		local v = tonumber(val) or min
		if step and tonumber(step) then
			local st = tonumber(step)
			if st > 0 then
				v = math.floor((v / st) + 0.5) * st
			end
		end
		v = math.clamp(v, min, max)
		valLabel.Text = tostring(v)
		fill.Size = UDim2.fromScale((v - min) / (max - min), 1)
		if callback then
			callback(v)
		end
		return v
	end

	local current = applyValue(default)

	local function update(input)
		local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		fill.Size = UDim2.fromScale(pos, 1)
		local val = min + (max - min) * pos
		current = applyValue(val)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			update(input)
			local move = UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
			end)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then move:Disconnect() end
			end)
		end
	end)

	local api = {}
	api.Frame = sFrame
	function api:Set(v)
		current = applyValue(v)
	end
	function api:Get()
		return current
	end
	return api
end

function Lib:Bind(text, defaultKeyCode, callback, parentOverride)
	local parentTarget = parentOverride or Container
	local waiting = false
	local current = defaultKeyCode

	local row = Instance.new("TextButton")
	row.Size = UDim2.new(0.95, 0, 0, 45)
	row.BackgroundColor3 = THEME.Element
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.Text = ""
	row.AutoButtonColor = false
	row.Parent = parentTarget
	AddCorner(row, 8)
	AddStroke(row, 1, THEME.StrokeSoft, 0.5)

	local lbl = Instance.new("TextLabel")
	lbl.Text = "  " .. text
	lbl.Size = UDim2.new(0.6, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextColor3 = THEME.Text
	lbl.TextSize = 16
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row
	lbl.ZIndex = 52

	local keyBtn = Instance.new("TextButton")
	keyBtn.Size = UDim2.new(0, 120, 0, 28)
	keyBtn.Position = UDim2.new(1, -130, 0.5, -14)
	keyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	keyBtn.BackgroundTransparency = 0.92
	keyBtn.BorderSizePixel = 0
	keyBtn.TextColor3 = THEME.Text
	keyBtn.Font = Enum.Font.Gotham
	keyBtn.TextSize = 14
	keyBtn.AutoButtonColor = false
	keyBtn.Parent = row
	AddCorner(keyBtn, 8)
	AddStroke(keyBtn, 1, THEME.StrokeSoft, 0.55)

	local function render()
		if waiting then
			keyBtn.Text = "..."
			return
		end
		if typeof(current) == "EnumItem" then
			keyBtn.Text = tostring(current.Name)
		else
			keyBtn.Text = "None"
		end
	end

	local function setKey(kc)
		current = kc
		render()
		if callback then
			callback(kc)
		end
	end

	local function inputBegan(input)
		if input.KeyCode == Enum.KeyCode.Escape then
			setKey(Enum.KeyCode.Unknown)
			return
		end
		if input.KeyCode ~= Enum.KeyCode.Unknown then
			setKey(input.KeyCode)
			return
		end
	end

	keyBtn.MouseButton1Click:Connect(function()
		waiting = true
		render()
		local conn
		conn = UserInputService.InputBegan:Connect(function(input)
			if not waiting then
				if conn then conn:Disconnect() end
				return
			end
			inputBegan(input)
			waiting = false
			render()
			if conn then conn:Disconnect() end
		end)
	end)

	local api = {}
	api.Frame = row
	function api:Set(kc)
		setKey(kc)
	end
	function api:Get()
		return current
	end
	return api
end

function Lib:Dropdown(text, options, default, callback, parentOverride)
	local parentTarget = parentOverride or Container
	options = options or {}
	local selected = default or options[1] or ""

	local ROW_H = 45
	local LIST_TOP_PAD = 6
	local LIST_SIDE_PAD = 7
	local OPEN_T = 0.16
	local CLOSE_T = 0.12

	local row = Instance.new("Frame")
	row.Size = UDim2.new(0.95, 0, 0, ROW_H)
	row.BackgroundColor3 = THEME.Element
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.Parent = parentTarget
	row.ZIndex = 50
	AddCorner(row, 8)
	AddStroke(row, 1, THEME.StrokeSoft, 0.5)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = row
	btn.ZIndex = 51

	local lbl = Instance.new("TextLabel")
	lbl.Text = "  " .. tostring(text)
	lbl.Size = UDim2.new(0.6, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextColor3 = THEME.Text
	lbl.TextSize = 16
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row
	lbl.ZIndex = 52

	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0.4, -32, 1, 0)
	val.Position = UDim2.new(0.6, 0, 0, 0)
	val.BackgroundTransparency = 1
	val.Font = Enum.Font.Gotham
	val.TextColor3 = THEME.TextDark
	val.TextSize = 14
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Parent = row
	val.ZIndex = 52

	local caret = Instance.new("TextLabel")
	caret.Size = UDim2.fromOffset(18, 18)
	caret.Position = UDim2.new(1, -24, 0, (ROW_H / 2) - 9)
	caret.BackgroundTransparency = 1
	caret.Font = Enum.Font.GothamBold
	caret.TextColor3 = THEME.Text
	caret.TextSize = 14
	caret.Text = "v"
	caret.Parent = row
	caret.ZIndex = 52

	local listParent = row:FindFirstAncestorOfClass("ScreenGui") or row
	local overlay = nil

	local listFrame = Instance.new("Frame")
	listFrame.Visible = false
	listFrame.BackgroundColor3 = THEME.Background
	listFrame.BackgroundTransparency = 0.12
	listFrame.BorderSizePixel = 0
	listFrame.ClipsDescendants = true
	listFrame.Size = UDim2.new(0, 0, 0, 0)
	listFrame.ZIndex = 300
	listFrame.Parent = listParent
	AddCorner(listFrame, 8)
	AddStroke(listFrame, 1, THEME.StrokeSoft, 0.65)

	local listBgBtn = Instance.new("TextButton")
	listBgBtn.BackgroundTransparency = 1
	listBgBtn.Text = ""
	listBgBtn.AutoButtonColor = false
	listBgBtn.Size = UDim2.fromScale(1, 1)
	listBgBtn.ZIndex = 300
	listBgBtn.Parent = listFrame

	local content = Instance.new("Frame")
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.Size = UDim2.fromScale(1, 1)
	content.ZIndex = 301
	content.Parent = listFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 6)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = content

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = content

	local open = false
	local rsConn

	local function getParentAbs()
		if listFrame.Parent and listFrame.Parent:IsA("GuiObject") then
			return listFrame.Parent.AbsolutePosition
		end
		return Vector2.new(0, 0)
	end

	local function setValue(v)
		selected = v
		val.Text = tostring(v)
		if callback then
			callback(v)
		end
	end

	local optionButtons = {}
	local function renderSelected()
		for _, b in pairs(optionButtons) do
			if b and b.Parent then
				local opt = b:GetAttribute("_Opt")
				local isSel = (opt == selected)
				b.Text = (isSel and "✓ " or "") .. tostring(opt)
				b.TextColor3 = isSel and THEME.Primary or THEME.Text
			end
		end
	end

	local function updateListPos(setSize)
		local pAbs = getParentAbs()
		local ap = row.AbsolutePosition
		local size = row.AbsoluteSize
		local h = listLayout.AbsoluteContentSize.Y + 16
		local w = math.floor(size.X - (LIST_SIDE_PAD * 2))
		listFrame.Position = UDim2.fromOffset((ap.X - pAbs.X) + LIST_SIDE_PAD, (ap.Y - pAbs.Y) + size.Y + LIST_TOP_PAD)
		if setSize then
			listFrame.Size = open and UDim2.fromOffset(w, h) or UDim2.fromOffset(w, 0)
		end
		return w, h
	end

	local function closeList()
		if not open then return end
		open = false
		caret.Text = "v"
		local w = updateListPos(false)
		TweenService:Create(listFrame, TweenInfo.new(CLOSE_T, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(w, 0)}):Play()
		task.delay(CLOSE_T + 0.01, function()
			if open then return end
			listFrame.Visible = false
			if overlay then
				overlay:Destroy()
				overlay = nil
			end
			if rsConn then rsConn:Disconnect() rsConn = nil end
		end)
	end

	listBgBtn.MouseButton1Click:Connect(function()
		closeList()
	end)

	for i, opt in ipairs(options) do
		local choice = opt
		local o = Instance.new("TextButton")
		o.Size = UDim2.new(1, 0, 0, 26)
		o.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		o.BackgroundTransparency = 1
		o.BorderSizePixel = 0
		o.Text = tostring(choice)
		o.TextColor3 = THEME.Text
		o.Font = Enum.Font.Gotham
		o.TextSize = 14
		o.AutoButtonColor = true
		o.LayoutOrder = i
		o.ZIndex = 301
		o:SetAttribute("_Opt", choice)
		o.Parent = content
		o.MouseButton1Click:Connect(function()
			setValue(choice)
			renderSelected()
			closeList()
		end)
		optionButtons[i] = o
	end

	btn.MouseButton1Click:Connect(function()
		open = not open
		caret.Text = open and "^" or "v"
		if open then
			if listParent and listParent:IsA("ScreenGui") then
				overlay = Instance.new("TextButton")
				overlay.Name = "DropdownOverlay"
				overlay.BackgroundTransparency = 1
				overlay.Text = ""
				overlay.AutoButtonColor = false
				overlay.Size = UDim2.fromScale(1, 1)
				overlay.ZIndex = 1
				overlay.Parent = listParent
				overlay.MouseButton1Click:Connect(function()
					closeList()
				end)
			end

			listFrame.Visible = true
			local w, h = updateListPos(true)
			TweenService:Create(listFrame, TweenInfo.new(OPEN_T, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(w, h)}):Play()
			if rsConn then rsConn:Disconnect() end
			rsConn = RunService.RenderStepped:Connect(function()
				if open then
					updateListPos(false)
				end
			end)
		else
			closeList()
		end
	end)

	setValue(selected)
	renderSelected()

	local api = {}
	api.Frame = row
	function api:Set(v)
		setValue(v)
	end
	function api:Get()
		return selected
	end
	return api
end

function Lib:MultiDropdown(text, options, default, callback, parentOverride)
	local parentTarget = parentOverride or Container
	options = options or {}
	local selected = {}
	if type(default) == "table" then
		for _, v in ipairs(default) do
			selected[tostring(v)] = true
		end
	end

	local ROW_H = 45
	local LIST_TOP_PAD = 6
	local LIST_SIDE_PAD = 7
	local OPEN_T = 0.16
	local CLOSE_T = 0.12

	local row = Instance.new("Frame")
	row.Size = UDim2.new(0.95, 0, 0, ROW_H)
	row.BackgroundColor3 = THEME.Element
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.Parent = parentTarget
	row.ZIndex = 50
	AddCorner(row, 8)
	AddStroke(row, 1, THEME.StrokeSoft, 0.5)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = row
	btn.ZIndex = 51

	local lbl = Instance.new("TextLabel")
	lbl.Text = "  " .. tostring(text)
	lbl.Size = UDim2.new(0.6, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextColor3 = THEME.Text
	lbl.TextSize = 16
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row
	lbl.ZIndex = 52

	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0.4, -32, 1, 0)
	val.Position = UDim2.new(0.6, 0, 0, 0)
	val.BackgroundTransparency = 1
	val.Font = Enum.Font.Gotham
	val.TextColor3 = THEME.TextDark
	val.TextSize = 14
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Parent = row
	val.ZIndex = 52

	local caret = Instance.new("TextLabel")
	caret.Size = UDim2.fromOffset(18, 18)
	caret.Position = UDim2.new(1, -24, 0, (ROW_H / 2) - 9)
	caret.BackgroundTransparency = 1
	caret.Font = Enum.Font.GothamBold
	caret.TextColor3 = THEME.Text
	caret.TextSize = 14
	caret.Text = "v"
	caret.Parent = row
	caret.ZIndex = 52

	local listParent = row:FindFirstAncestorOfClass("ScreenGui") or row
	local overlay = nil

	local listFrame = Instance.new("Frame")
	listFrame.Visible = false
	listFrame.BackgroundColor3 = THEME.Background
	listFrame.BackgroundTransparency = 0.12
	listFrame.BorderSizePixel = 0
	listFrame.ClipsDescendants = true
	listFrame.Size = UDim2.new(0, 0, 0, 0)
	listFrame.ZIndex = 300
	listFrame.Parent = listParent
	AddCorner(listFrame, 8)
	AddStroke(listFrame, 1, THEME.StrokeSoft, 0.65)

	local listBgBtn = Instance.new("TextButton")
	listBgBtn.BackgroundTransparency = 1
	listBgBtn.Text = ""
	listBgBtn.AutoButtonColor = false
	listBgBtn.Size = UDim2.fromScale(1, 1)
	listBgBtn.ZIndex = 300
	listBgBtn.Parent = listFrame

	local content = Instance.new("Frame")
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.Size = UDim2.fromScale(1, 1)
	content.ZIndex = 301
	content.Parent = listFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 6)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = content

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = content

	local open = false
	local rsConn

	local function getParentAbs()
		if listFrame.Parent and listFrame.Parent:IsA("GuiObject") then
			return listFrame.Parent.AbsolutePosition
		end
		return Vector2.new(0, 0)
	end

	local function emit()
		local out = {}
		for _, v in ipairs(options) do
			if selected[tostring(v)] then
				table.insert(out, v)
			end
		end
		val.Text = table.concat(out, ", ")
		if callback then
			callback(out)
		end
	end

	local optionButtons = {}
	local function renderSelected()
		for _, b in pairs(optionButtons) do
			if b and b.Parent then
				local opt = b:GetAttribute("_Opt")
				local isSel = selected[tostring(opt)] == true
				b.Text = (isSel and "✓ " or "") .. tostring(opt)
				b.TextColor3 = isSel and THEME.Primary or THEME.Text
			end
		end
	end

	local function updateListPos(setSize)
		local pAbs = getParentAbs()
		local ap = row.AbsolutePosition
		local size = row.AbsoluteSize
		local h = listLayout.AbsoluteContentSize.Y + 16
		local w = math.floor(size.X - (LIST_SIDE_PAD * 2))
		listFrame.Position = UDim2.fromOffset((ap.X - pAbs.X) + LIST_SIDE_PAD, (ap.Y - pAbs.Y) + size.Y + LIST_TOP_PAD)
		if setSize then
			listFrame.Size = open and UDim2.fromOffset(w, h) or UDim2.fromOffset(w, 0)
		end
		return w, h
	end

	local function closeList()
		if not open then return end
		open = false
		caret.Text = "v"
		local w = updateListPos(false)
		TweenService:Create(listFrame, TweenInfo.new(CLOSE_T, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(w, 0)}):Play()
		task.delay(CLOSE_T + 0.01, function()
			if open then return end
			listFrame.Visible = false
			if overlay then
				overlay:Destroy()
				overlay = nil
			end
			if rsConn then rsConn:Disconnect() rsConn = nil end
		end)
	end

	listBgBtn.MouseButton1Click:Connect(function()
		closeList()
	end)

	for i, opt in ipairs(options) do
		local choice = opt
		local o = Instance.new("TextButton")
		o.Size = UDim2.new(1, 0, 0, 26)
		o.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		o.BackgroundTransparency = 1
		o.BorderSizePixel = 0
		o.Text = tostring(choice)
		o.TextColor3 = THEME.Text
		o.Font = Enum.Font.Gotham
		o.TextSize = 14
		o.AutoButtonColor = true
		o.LayoutOrder = i
		o.ZIndex = 301
		o:SetAttribute("_Opt", choice)
		o.Parent = content
		o.MouseButton1Click:Connect(function()
			local k = tostring(choice)
			selected[k] = not selected[k]
			emit()
			renderSelected()
		end)
		optionButtons[i] = o
	end

	btn.MouseButton1Click:Connect(function()
		open = not open
		caret.Text = open and "^" or "v"
		if open then
			if listParent and listParent:IsA("ScreenGui") then
				overlay = Instance.new("TextButton")
				overlay.Name = "MultiDropdownOverlay"
				overlay.BackgroundTransparency = 1
				overlay.Text = ""
				overlay.AutoButtonColor = false
				overlay.Size = UDim2.fromScale(1, 1)
				overlay.ZIndex = 1
				overlay.Parent = listParent
				overlay.MouseButton1Click:Connect(function()
					closeList()
				end)
			end

			listFrame.Visible = true
			local w, h = updateListPos(true)
			TweenService:Create(listFrame, TweenInfo.new(OPEN_T, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(w, h)}):Play()
			if rsConn then rsConn:Disconnect() end
			rsConn = RunService.RenderStepped:Connect(function()
				if open then
					updateListPos(false)
				end
			end)
		else
			closeList()
		end
	end)

	emit()

	local api = {}
	api.Frame = row
	function api:Set(values)
		selected = {}
		if type(values) == "table" then
			for _, v in ipairs(values) do
				selected[tostring(v)] = true
			end
		end
		emit()
	end
	function api:Get()
		local out = {}
		for _, v in ipairs(options) do
			if selected[tostring(v)] then
				table.insert(out, v)
			end
		end
		return out
	end
	return api
end

function UI:CreateWindow(config)
	config = config or {}
	if not ScreenGui.Parent then
		ScreenGui.Parent = _DefaultParent
	end
	if type(config.Title) == "string" and config.Title ~= "" then
		Title.Text = config.Title
	end
	self:SetOpen(true)
	return self
end

function UI:CreateButton(sectionBody, opt)
	opt = opt or {}
	return Lib:Button(opt.Name or "Button", opt.Callback, sectionBody)
end

function UI:CreateLockedButton(sectionBody, opt)
	opt = opt or {}
	return Lib:Button(opt.Name or "Locked", opt.Callback, sectionBody)
end

function UI:CreateToggle(sectionBody, opt)
	opt = opt or {}
	return Lib:Toggle(opt.Name or "Toggle", opt.Callback, sectionBody, opt.Default)
end

function UI:CreateTextbox(sectionBody, opt)
	opt = opt or {}
	return Lib:Textbox(opt.Name or "Input", opt.Placeholder, opt.Callback, sectionBody, opt.Default)
end

function UI:CreateSlider(sectionBody, opt)
	opt = opt or {}
	return Lib:Slider(opt.Name or "Slider", tonumber(opt.Min) or 0, tonumber(opt.Max) or 100, tonumber(opt.Default) or 0, opt.Callback, sectionBody, opt.Step)
end

function UI:CreateDropdown(sectionBody, opt)
	opt = opt or {}
	return Lib:Dropdown(opt.Name or "Dropdown", opt.List or {}, opt.Default, opt.Callback, sectionBody)
end

function UI:CreateMultiDropdown(sectionBody, opt)
	opt = opt or {}
	return Lib:MultiDropdown(opt.Name or "Multi Dropdown", opt.List or {}, opt.Default, opt.Callback, sectionBody)
end

function UI:CreateBind(sectionBody, opt)
	opt = opt or {}
	local default = opt.Default
	local kc = Enum.KeyCode.Unknown
	if typeof(default) == "EnumItem" then
		kc = default
	elseif type(default) == "string" and Enum.KeyCode[default] then
		kc = Enum.KeyCode[default]
	end
	return Lib:Bind(opt.Name or "Bind", kc, opt.Callback, sectionBody)
end

function UI:Unload()
	pcall(function()
		if self.ScreenGui then
			self.ScreenGui:Destroy()
		end
	end)
	self._Alive = false
end

return UI
