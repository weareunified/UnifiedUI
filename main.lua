local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local UI = {}
UI.Tabs = {}
UI.CurrentTab = nil

local THEME = {
	Purple = Color3.fromRGB(138, 43, 226),
	Black = Color3.fromRGB(10, 10, 10),
	DarkGray = Color3.fromRGB(26, 26, 26),
	Gray = Color3.fromRGB(40, 40, 40),
	LightGray = Color3.fromRGB(60, 60, 60),
	White = Color3.fromRGB(224, 224, 224),
	SubText = Color3.fromRGB(160, 160, 160),
}

local function Tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quad), props):Play()
end

local function AddCorner(obj, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = obj
	return corner
end

function UI:CreateWindow(config)
	local title = config.Title or "Unified.wtf"
	
	local sg = Instance.new("ScreenGui")
	sg.Name = "UnifiedHub"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	pcall(function()
		if gethui then
			sg.Parent = gethui()
		elseif syn and syn.protect_gui then
			syn.protect_gui(sg)
			sg.Parent = game:GetService("CoreGui")
		else
			sg.Parent = game:GetService("CoreGui")
		end
	end)
	
	if not sg.Parent then
		sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	
	self.ScreenGui = sg
	
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 700, 0, 500)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = THEME.Black
	main.BorderSizePixel = 0
	main.Parent = sg
	AddCorner(main, 12)
	
	self.Main = main
	
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 50)
	header.BackgroundColor3 = THEME.DarkGray
	header.BorderSizePixel = 0
	header.Parent = main
	AddCorner(header, 12)
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0, 300, 1, 0)
	titleLabel.Position = UDim2.new(0, 15, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = THEME.White
	titleLabel.TextSize = 16
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = header
	
	local tabsContainer = Instance.new("Frame")
	tabsContainer.Name = "TabsContainer"
	tabsContainer.Size = UDim2.new(1, -320, 1, 0)
	tabsContainer.Position = UDim2.new(0, 320, 0, 0)
	tabsContainer.BackgroundTransparency = 1
	tabsContainer.Parent = header
	
	local tabsList = Instance.new("UIListLayout")
	tabsList.FillDirection = Enum.FillDirection.Horizontal
	tabsList.HorizontalAlignment = Enum.HorizontalAlignment.Left
	tabsList.VerticalAlignment = Enum.VerticalAlignment.Center
	tabsList.Padding = UDim.new(0, 8)
	tabsList.Parent = tabsContainer

	
	self.TabsContainer = tabsContainer
	
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, 0, 1, -50)
	content.Position = UDim2.new(0, 0, 0, 50)
	content.BackgroundTransparency = 1
	content.Parent = main
	
	self.Content = content
	
	local dragging, dragInput, dragStart, startPos
	
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	
	return self
end

function UI:CreateTab(config)
	local name = config.Name or "Tab"
	
	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = name
	tabBtn.Size = UDim2.new(0, 100, 0, 35)
	tabBtn.BackgroundColor3 = THEME.Gray
	tabBtn.BorderSizePixel = 0
	tabBtn.Text = name
	tabBtn.TextColor3 = THEME.SubText

	tabBtn.TextSize = 14
	tabBtn.Font = Enum.Font.GothamSemibold
	tabBtn.AutoButtonColor = false
	tabBtn.Parent = self.TabsContainer
	AddCorner(tabBtn, 6)
	
	local page = Instance.new("ScrollingFrame")
	page.Name = name .. "Page"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = THEME.Purple
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Visible = false
	page.Parent = self.Content
	
	local pageLayout = Instance.new("UIListLayout")
	pageLayout.Padding = UDim.new(0, 10)
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Parent = page
	
	pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
	end)
	
	local pagePadding = Instance.new("UIPadding")
	pagePadding.PaddingTop = UDim.new(0, 10)
	pagePadding.PaddingLeft = UDim.new(0, 10)
	pagePadding.PaddingRight = UDim.new(0, 10)
	pagePadding.PaddingBottom = UDim.new(0, 10)
	pagePadding.Parent = page
	
	local tab = {Name = name, Button = tabBtn, Page = page, Sections = {}}
	
	self.Tabs[name] = tab
	
	tabBtn.MouseButton1Click:Connect(function()
		self:SelectTab(name)
	end)
	
	if not self.CurrentTab then
		self:SelectTab(name)
	end
	
	return tab
end

function UI:SelectTab(name)
	local tab = self.Tabs[name]
	if not tab then return end
	
	for _, t in pairs(self.Tabs) do
		t.Page.Visible = false
		t.Button.BackgroundColor3 = THEME.Gray
		t.Button.TextColor3 = THEME.SubText
	end

	
	tab.Page.Visible = true
	tab.Button.BackgroundColor3 = THEME.Purple
	tab.Button.TextColor3 = THEME.White
	
	self.CurrentTab = name
end

function UI.CreateSection(tab, title)
	local section = Instance.new("Frame")
	section.Name = "Section"
	section.Size = UDim2.new(1, -10, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = THEME.DarkGray
	section.BorderSizePixel = 0
	section.Parent = tab.Page
	AddCorner(section, 8)
	
	local sectionPadding = Instance.new("UIPadding")
	sectionPadding.PaddingTop = UDim.new(0, 10)
	sectionPadding.PaddingLeft = UDim.new(0, 10)
	sectionPadding.PaddingRight = UDim.new(0, 10)
	sectionPadding.PaddingBottom = UDim.new(0, 10)
	sectionPadding.Parent = section
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 25)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title or "Section"
	titleLabel.TextColor3 = THEME.Purple
	titleLabel.TextSize = 15
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = section
	
	local body = Instance.new("Frame")
	body.Name = "Body"
	body.Size = UDim2.new(1, 0, 0, 0)
	body.Position = UDim2.new(0, 0, 0, 30)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.BackgroundTransparency = 1
	body.Parent = section
	
	local bodyLayout = Instance.new("UIListLayout")
	bodyLayout.Padding = UDim.new(0, 8)
	bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	bodyLayout.Parent = body
	
	bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		section.Size = UDim2.new(1, -10, 0, bodyLayout.AbsoluteContentSize.Y + 45)
	end)
	
	return {Body = body, Frame = section}
end


function UI:CreateButton(parent, config)
	local name = config.Name or "Button"
	local callback = config.Callback or function() end
	
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, 0, 0, 35)
	btn.BackgroundColor3 = THEME.Gray
	btn.BorderSizePixel = 0
	btn.Text = name
	btn.TextColor3 = THEME.White
	btn.TextSize = 14
	btn.Font = Enum.Font.GothamSemibold
	btn.AutoButtonColor = false
	btn.Parent = parent
	AddCorner(btn, 6)
	
	btn.MouseEnter:Connect(function()
		Tween(btn, {BackgroundColor3 = THEME.LightGray}, 0.2)
	end)
	
	btn.MouseLeave:Connect(function()
		Tween(btn, {BackgroundColor3 = THEME.Gray}, 0.2)
	end)
	
	btn.MouseButton1Click:Connect(function()
		Tween(btn, {BackgroundColor3 = THEME.Purple}, 0.1)
		task.wait(0.1)
		Tween(btn, {BackgroundColor3 = THEME.Gray}, 0.2)
		callback()
	end)
	
	return {Frame = btn}
end

function UI:CreateToggle(parent, config)
	local name = config.Name or "Toggle"
	local default = config.Default or false
	local callback = config.Callback or function() end
	
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = UDim2.new(1, 0, 0, 35)
	frame.BackgroundColor3 = THEME.Gray
	frame.BorderSizePixel = 0
	frame.Parent = parent
	AddCorner(frame, 6)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -50, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = THEME.White

	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
	
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 40, 0, 20)
	toggle.Position = UDim2.new(1, -45, 0.5, 0)
	toggle.AnchorPoint = Vector2.new(0, 0.5)
	toggle.BackgroundColor3 = default and THEME.Purple or THEME.LightGray
	toggle.BorderSizePixel = 0
	toggle.Text = ""
	toggle.AutoButtonColor = false
	toggle.Parent = frame
	AddCorner(toggle, 10)
	
	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 16, 0, 16)
	indicator.Position = default and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
	indicator.AnchorPoint = Vector2.new(0, 0.5)
	indicator.BackgroundColor3 = THEME.White
	indicator.BorderSizePixel = 0
	indicator.Parent = toggle
	AddCorner(indicator, 8)
	
	local state = default
	
	toggle.MouseButton1Click:Connect(function()
		state = not state
		Tween(toggle, {BackgroundColor3 = state and THEME.Purple or THEME.LightGray}, 0.2)
		Tween(indicator, {Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)}, 0.2)
		callback(state)
	end)
	
	return {Frame = frame, Set = function(val) 
		state = val
		toggle.BackgroundColor3 = state and THEME.Purple or THEME.LightGray
		indicator.Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
	end}
end

function UI:CreateSlider(parent, config)
	local name = config.Name or "Slider"
	local min = config.Min or 0
	local max = config.Max or 100
	local default = config.Default or min
	local callback = config.Callback or function() end
	
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = UDim2.new(1, 0, 0, 50)
	frame.BackgroundColor3 = THEME.Gray

	frame.BorderSizePixel = 0
	frame.Parent = parent
	AddCorner(frame, 6)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 0, 20)
	label.Position = UDim2.new(0, 10, 0, 5)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = THEME.White
	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 0, 20)
	valueLabel.Position = UDim2.new(1, -55, 0, 5)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = THEME.Purple
	valueLabel.TextSize = 14
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = frame
	
	local sliderBack = Instance.new("Frame")
	sliderBack.Size = UDim2.new(1, -20, 0, 6)
	sliderBack.Position = UDim2.new(0, 10, 1, -15)
	sliderBack.BackgroundColor3 = THEME.LightGray
	sliderBack.BorderSizePixel = 0
	sliderBack.Parent = frame
	AddCorner(sliderBack, 3)
	
	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	sliderFill.BackgroundColor3 = THEME.Purple
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = sliderBack
	AddCorner(sliderFill, 3)
	
	local dragging = false
	
	local function update(input)
		local pos = (input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X
		pos = math.clamp(pos, 0, 1)
		local value = math.floor(min + (max - min) * pos)
		sliderFill.Size = UDim2.new(pos, 0, 1, 0)
		valueLabel.Text = tostring(value)
		callback(value)
	end

	
	sliderBack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			update(input)
		end
	end)
	
	sliderBack.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end)
	
	return {Frame = frame}
end

function UI:CreateDropdown(parent, config)
	local name = config.Name or "Dropdown"
	local list = config.List or {}
	local default = config.Default or list[1]
	local callback = config.Callback or function() end
	
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = UDim2.new(1, 0, 0, 35)
	frame.BackgroundColor3 = THEME.Gray
	frame.BorderSizePixel = 0
	frame.Parent = parent
	AddCorner(frame, 6)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, -10, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = THEME.White
	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
	
	local dropdown = Instance.new("TextButton")
	dropdown.Size = UDim2.new(0.5, -15, 0, 25)
	dropdown.Position = UDim2.new(0.5, 5, 0.5, 0)
	dropdown.AnchorPoint = Vector2.new(0, 0.5)

	dropdown.BackgroundColor3 = THEME.LightGray
	dropdown.BorderSizePixel = 0
	dropdown.Text = default or "Select"
	dropdown.TextColor3 = THEME.White
	dropdown.TextSize = 13
	dropdown.Font = Enum.Font.Gotham
	dropdown.AutoButtonColor = false
	dropdown.Parent = frame
	AddCorner(dropdown, 5)
	
	local dropdownList = Instance.new("Frame")
	dropdownList.Size = UDim2.new(1, 0, 0, 0)
	dropdownList.Position = UDim2.new(0, 0, 1, 5)
	dropdownList.BackgroundColor3 = THEME.DarkGray
	dropdownList.BorderSizePixel = 0
	dropdownList.Visible = false
	dropdownList.ZIndex = 10
	dropdownList.Parent = dropdown
	AddCorner(dropdownList, 5)
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = dropdownList
	
	for _, item in ipairs(list) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 25)
		btn.BackgroundColor3 = THEME.Gray
		btn.BorderSizePixel = 0
		btn.Text = item
		btn.TextColor3 = THEME.White
		btn.TextSize = 13
		btn.Font = Enum.Font.Gotham
		btn.AutoButtonColor = false
		btn.ZIndex = 11
		btn.Parent = dropdownList
		AddCorner(btn, 4)
		
		btn.MouseButton1Click:Connect(function()
			dropdown.Text = item
			dropdownList.Visible = false
			callback(item)
		end)
		
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = THEME.Purple
		end)
		
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = THEME.Gray
		end)
	end

	
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		dropdownList.Size = UDim2.new(1, 0, 0, math.min(listLayout.AbsoluteContentSize.Y, 150))
	end)
	
	dropdown.MouseButton1Click:Connect(function()
		dropdownList.Visible = not dropdownList.Visible
	end)
	
	return {Frame = frame}
end

function UI:CreateTextbox(parent, config)
	local name = config.Name or "Textbox"
	local placeholder = config.Placeholder or "Enter text..."
	local callback = config.Callback or function() end
	
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = UDim2.new(1, 0, 0, 35)
	frame.BackgroundColor3 = THEME.Gray
	frame.BorderSizePixel = 0
	frame.Parent = parent
	AddCorner(frame, 6)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.4, -10, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = THEME.White
	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
	
	local textbox = Instance.new("TextBox")
	textbox.Size = UDim2.new(0.6, -15, 0, 25)
	textbox.Position = UDim2.new(0.4, 5, 0.5, 0)
	textbox.AnchorPoint = Vector2.new(0, 0.5)
	textbox.BackgroundColor3 = THEME.LightGray
	textbox.BorderSizePixel = 0
	textbox.Text = ""
	textbox.PlaceholderText = placeholder
	textbox.TextColor3 = THEME.White
	textbox.PlaceholderColor3 = THEME.SubText
	textbox.TextSize = 13
	textbox.Font = Enum.Font.Gotham
	textbox.ClearTextOnFocus = false
	textbox.Parent = frame
	AddCorner(textbox, 5)

	
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = textbox
	
	textbox.FocusLost:Connect(function(enter)
		callback(textbox.Text, enter)
	end)
	
	return {Frame = frame, Set = function(text) textbox.Text = text end}
end

function UI:Notify(title, message, duration)
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 300, 0, 80)
	notif.Position = UDim2.new(1, -310, 1, 100)
	notif.BackgroundColor3 = THEME.DarkGray
	notif.BorderSizePixel = 0
	notif.Parent = self.ScreenGui
	AddCorner(notif, 8)
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 25)
	titleLabel.Position = UDim2.new(0, 10, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = THEME.Purple
	titleLabel.TextSize = 15
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notif
	
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Size = UDim2.new(1, -20, 0, 35)
	messageLabel.Position = UDim2.new(0, 10, 0, 35)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = message
	messageLabel.TextColor3 = THEME.White
	messageLabel.TextSize = 13
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextWrapped = true
	messageLabel.Parent = notif
	
	Tween(notif, {Position = UDim2.new(1, -310, 1, -90)}, 0.5)
	
	task.delay(duration or 3, function()
		Tween(notif, {Position = UDim2.new(1, -310, 1, 100)}, 0.5)
		task.wait(0.5)
		notif:Destroy()
	end)
end

return UI
