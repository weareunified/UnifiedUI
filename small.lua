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

-- // CORE UI SETUP (LAZY INIT)
local ScreenGui, Main, TabBar, TabList, ContainerHolder, TopBar, Title

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

local function InitializeUI()
	if ScreenGui then return end
	
	ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "UnifiedHub_Final"
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local success, parent = pcall(function() return gethui() or game:GetService("CoreGui") end)
	ScreenGui.Parent = success and parent or Players.LocalPlayer:WaitForChild("PlayerGui")

	Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.fromOffset(460, 550)
	Main.Position = UDim2.new(0.5, -230, 0.5, -275)
	Main.BackgroundColor3 = THEME.Background
	Main.BackgroundTransparency = 0.08
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui
	AddCorner(Main, 12)
	AddStroke(Main, 1, THEME.StrokeSoft, 0.35)
	AddGradient(Main, Color3.fromRGB(18, 18, 26), Color3.fromRGB(14, 14, 18), 90)

	TabBar = Instance.new("Frame")
	TabBar.Name = "TabBar"
	TabBar.Size = UDim2.new(1, -20, 0, 35)
	TabBar.Position = UDim2.fromOffset(10, 55)
	TabBar.BackgroundTransparency = 1
	TabBar.ZIndex = 10
	TabBar.Parent = Main

	TabList = Instance.new("Frame")
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

	ContainerHolder = Instance.new("Frame")
	ContainerHolder.Name = "ContainerHolder"
	ContainerHolder.Size = UDim2.new(1, -20, 1, -110)
	ContainerHolder.Position = UDim2.fromOffset(10, 100)
	ContainerHolder.BackgroundTransparency = 1
	ContainerHolder.Parent = Main

	TopBar = Instance.new("Frame")
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

	Title = Instance.new("TextLabel")
	Title.Text = HUB_NAME
	Title.Size = UDim2.new(1, -150, 1, 0)
	Title.Position = UDim2.fromOffset(55, 0)
	Title.Font = Enum.Font.GothamBold
	Title.TextColor3 = THEME.Text
	Title.TextSize = 17
	Title.BackgroundTransparency = 1
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = TopBar

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
		UI:ToggleMinimize()
	end)

	CreateHeaderBtn("×", -35, Color3.fromRGB(170, 60, 70), function() UI:Unload() end)
	
	UI._Open = true
end

function UI:ToggleMinimize()
	InitializeUI()
	local isMinimizing = Main.Size.Y.Offset > 60
	local targetSize = isMinimizing and UDim2.fromOffset(460, 50) or UDim2.fromOffset(460, 550)
	
	TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = targetSize}):Play()
	
	TabBar.Visible = not isMinimizing
	ContainerHolder.Visible = not isMinimizing
	
	if isMinimizing then
		for _, v in pairs(ScreenGui:GetChildren()) do
			if v.Name:find("Overlay") or (v:IsA("Frame") and v.ZIndex >= 300) then
				v.Visible = false
			end
		end
	end
end

-- // TABS
local Tabs = {}
local CurrentTabName = nil

function UI:CreateTab(opt)
	InitializeUI()
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
	
	local textSize = game:GetService("TextService"):GetTextSize(tabName, 14, Enum.Font.GothamSemibold, Vector2.new(1000, 1000))
	tabBtn.Size = UDim2.fromOffset(textSize.X + 20, 35)
	
	local container = Instance.new("ScrollingFrame")
	container.Size = UDim2.fromScale(1, 1)
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
	if not CurrentTabName then self:SelectTab(tabName) end
	
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

		return {Body = container, Header = header}
	end
	
	return tab
end

function UI:SelectTab(name)
	if CurrentTabName == name then return end
	for n, t in pairs(Tabs) do
		local isMatch = (n == name)
		t.Container.Visible = isMatch
		if isMatch then
			t.Container.CanvasPosition = Vector2.zero
			TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.25, TextColor3 = THEME.Text}):Play()
			CurrentTabName = name
		else
			TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = THEME.TextDark}):Play()
		end
	end
end

-- // COMPONENT LIBRARY
local Lib = {}

function Lib:Button(text, callback, parentOverride)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.95, 0, 0, 45)
	btn.BackgroundColor3 = THEME.Element
	btn.BackgroundTransparency = 0.25
	btn.Text = text
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 16
	btn.TextColor3 = THEME.Text
	btn.Parent = parentOverride or ContainerHolder
	AddCorner(btn, 8)
	AddStroke(btn, 1, THEME.StrokeSoft, 0.5)
	btn.MouseButton1Click:Connect(function() if callback then callback() end end)
	return {Frame = btn}
end

function Lib:Toggle(text, callback, parentOverride, default)
	local enabled = default or false
	local tFrame = Instance.new("TextButton")
	tFrame.Size = UDim2.new(0.95, 0, 0, 45)
	tFrame.BackgroundColor3 = THEME.Element
	tFrame.BackgroundTransparency = 0.25
	tFrame.Text = "  " .. text
	tFrame.TextXAlignment = Enum.TextXAlignment.Left
	tFrame.Font = Enum.Font.GothamSemibold
	tFrame.TextSize = 16
	tFrame.TextColor3 = THEME.Text
	tFrame.Parent = parentOverride or ContainerHolder
	AddCorner(tFrame, 8)
	AddStroke(tFrame, 1, THEME.StrokeSoft, 0.5)

	local switch = Instance.new("Frame")
	switch.Size = UDim2.fromOffset(35, 20)
	switch.Position = UDim2.new(1, -45, 0.5, -10)
	switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	switch.BackgroundTransparency = 0.88
	switch.Parent = tFrame
	AddCorner(switch, 10)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = enabled and UDim2.fromOffset(17, 2) or UDim2.fromOffset(2, 2)
	knob.BackgroundColor3 = enabled and THEME.Primary or THEME.Text
	knob.Parent = switch
	AddCorner(knob, 999)

	tFrame.MouseButton1Click:Connect(function()
		enabled = not enabled
		TweenService:Create(knob, TweenInfo.new(0.2), {
			Position = enabled and UDim2.fromOffset(17, 2) or UDim2.fromOffset(2, 2),
			BackgroundColor3 = enabled and THEME.Primary or THEME.Text,
		}):Play()
		if callback then callback(enabled) end
	end)

	return {Frame = tFrame, Set = function(_, v) enabled = v end}
end

function Lib:Textbox(text, placeholder, callback, parentOverride, default)
	local boxFrame = Instance.new("Frame")
	boxFrame.Size = UDim2.new(0.95, 0, 0, 45)
	boxFrame.BackgroundColor3 = THEME.Element
	boxFrame.BackgroundTransparency = 0.25
	boxFrame.Parent = parentOverride or ContainerHolder
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
	input.PlaceholderText = placeholder or "Type here..."
	input.Text = tostring(default or "")
	input.TextColor3 = THEME.Text
	input.Font = Enum.Font.Gotham
	input.TextSize = 14
	input.Parent = boxFrame
	AddCorner(input, 6)

	input.FocusLost:Connect(function(enter) if callback then callback(input.Text, enter) end end)
	return {Frame = boxFrame, Box = input}
end

function Lib:Slider(text, min, max, default, callback, parentOverride, step)
	local sFrame = Instance.new("Frame")
	sFrame.Size = UDim2.new(0.95, 0, 0, 60)
	sFrame.BackgroundColor3 = THEME.Element
	sFrame.BackgroundTransparency = 0.25
	sFrame.Parent = parentOverride or ContainerHolder
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
	bar.Parent = sFrame
	AddCorner(bar, 3)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale((default - min) / (max - min), 1)
	fill.BackgroundColor3 = THEME.Primary
	fill.Parent = bar
	AddCorner(fill, 3)

	local function applyValue(val)
		local v = math.clamp(tonumber(val) or min, min, max)
		if step and tonumber(step) > 0 then v = math.floor((v / step) + 0.5) * step end
		valLabel.Text = tostring(v)
		fill.Size = UDim2.fromScale((v - min) / (max - min), 1)
		if callback then callback(v) end
		return v
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local move = UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					applyValue(min + (max - min) * pos)
				end
			end)
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then move:Disconnect() end end)
		end
	end)

	return {Frame = sFrame, Set = function(_, v) applyValue(v) end}
end

function Lib:Bind(text, defaultKeyCode, callback, parentOverride)
	local current = defaultKeyCode
	local waiting = false
	local row = Instance.new("TextButton")
	row.Size = UDim2.new(0.95, 0, 0, 45)
	row.BackgroundColor3 = THEME.Element
	row.BackgroundTransparency = 0.25
	row.Text = ""
	row.Parent = parentOverride or ContainerHolder
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

	local keyBtn = Instance.new("TextButton")
	keyBtn.Size = UDim2.new(0, 120, 0, 28)
	keyBtn.Position = UDim2.new(1, -130, 0.5, -14)
	keyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	keyBtn.BackgroundTransparency = 0.92
	keyBtn.Text = tostring(current.Name or current)
	keyBtn.Parent = row
	AddCorner(keyBtn, 8)

	keyBtn.MouseButton1Click:Connect(function()
		waiting = true
		keyBtn.Text = "..."
		local conn
		conn = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				current = input.KeyCode
				keyBtn.Text = tostring(current.Name)
				if callback then callback(current) end
				conn:Disconnect()
				waiting = false
			end
		end)
	end)

	return {Frame = row}
end

function Lib:Dropdown(text, options, default, callback, parentOverride)
	local selected = default or options[1] or ""
	local row = Instance.new("Frame")
	row.Size = UDim2.new(0.95, 0, 0, 45)
	row.BackgroundColor3 = THEME.Element
	row.BackgroundTransparency = 0.25
	row.Parent = parentOverride or ContainerHolder
	AddCorner(row, 8)
	AddStroke(row, 1, THEME.StrokeSoft, 0.5)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromScale(1, 1)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = row

	local lbl = Instance.new("TextLabel")
	lbl.Text = "  " .. text
	lbl.Size = UDim2.fromScale(0.6, 1)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextColor3 = THEME.Text
	lbl.TextSize = 16
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row

	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0.4, -30, 1, 0)
	val.Position = UDim2.fromScale(0.6, 0)
	val.BackgroundTransparency = 1
	val.Text = tostring(selected)
	val.TextColor3 = THEME.TextDark
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Parent = row

	return {Frame = row}
end

function UI:CreateWindow(config)
	InitializeUI()
	if config and config.Title then Title.Text = config.Title end
	return self
end

function UI:CreateButton(p, opt) return Lib:Button(opt.Name, opt.Callback, p) end
function UI:CreateToggle(p, opt) return Lib:Toggle(opt.Name, opt.Callback, p, opt.Default) end
function UI:CreateTextbox(p, opt) return Lib:Textbox(opt.Name, opt.Placeholder, opt.Callback, p, opt.Default) end
function UI:CreateSlider(p, opt) return Lib:Slider(opt.Name, opt.Min, opt.Max, opt.Default, opt.Callback, p, opt.Step) end
function UI:CreateBind(p, opt) 
	local kc = opt.Default
	if type(kc) == "string" then kc = Enum.KeyCode[kc] end
	return Lib:Bind(opt.Name, kc or Enum.KeyCode.Unknown, opt.Callback, p)
end

function UI:Unload()
	if ScreenGui then ScreenGui:Destroy() ScreenGui = nil end
	UI._Alive = false
end

return UI
