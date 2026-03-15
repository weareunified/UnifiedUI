local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local function _HasTouchGui()
	local plr = Players.LocalPlayer
	local pg = plr and plr:FindFirstChildOfClass("PlayerGui")
	return (pg and pg:FindFirstChild("TouchGui")) ~= nil
end

local IS_MOBILE = (UserInputService.TouchEnabled and _HasTouchGui())
local TEXT_SCALE = IS_MOBILE and 0.95 or 1.1

local LOCAL_PLAYER = Players.LocalPlayer
local EASE_STYLE = Enum.EasingStyle.Quint
local EASE_DIR = Enum.EasingDirection.Out

	local THEME = {
	Primary = Color3.fromRGB(139, 92, 246),
	BG = Color3.fromRGB(13, 13, 18),
	Panel = Color3.fromRGB(20, 20, 28),
	Panel2 = Color3.fromRGB(26, 26, 36),
	Surface = Color3.fromRGB(16, 16, 24),
	Text = Color3.fromRGB(240, 240, 255),
	SubText = Color3.fromRGB(160, 160, 180),
	Stroke = Color3.fromRGB(40, 40, 55),
	StrokeSoft = Color3.fromRGB(32, 32, 42),
	Shadow = Color3.fromRGB(0, 0, 0),
}

local THEME_PRESETS = {
	Default = {
		Primary = Color3.fromRGB(139, 92, 246),
		BG = Color3.fromRGB(13, 13, 18),
		Panel = Color3.fromRGB(20, 20, 28),
		Panel2 = Color3.fromRGB(26, 26, 36),
		Surface = Color3.fromRGB(16, 16, 24),
		Text = Color3.fromRGB(240, 240, 255),
		SubText = Color3.fromRGB(160, 160, 180),
		Stroke = Color3.fromRGB(40, 40, 55),
		StrokeSoft = Color3.fromRGB(32, 32, 42),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Special = {
		Primary = Color3.fromRGB(255, 90, 205),
		BG = Color3.fromRGB(10, 10, 15),
		Panel = Color3.fromRGB(18, 18, 26),
		Panel2 = Color3.fromRGB(24, 24, 34),
		Surface = Color3.fromRGB(14, 14, 22),
		Text = Color3.fromRGB(255, 255, 255),
		SubText = Color3.fromRGB(180, 180, 210),
		Stroke = Color3.fromRGB(45, 45, 65),
		StrokeSoft = Color3.fromRGB(35, 35, 50),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Dark = {
		Primary = Color3.fromRGB(139, 92, 246),
		BG = Color3.fromRGB(8, 8, 12),
		Panel = Color3.fromRGB(14, 14, 20),
		Panel2 = Color3.fromRGB(20, 20, 28),
		Surface = Color3.fromRGB(12, 12, 18),
		Text = Color3.fromRGB(235, 235, 245),
		SubText = Color3.fromRGB(150, 150, 170),
		Stroke = Color3.fromRGB(35, 35, 50),
		StrokeSoft = Color3.fromRGB(28, 28, 38),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Light = {
		Primary = Color3.fromRGB(70, 110, 255),
		BG = Color3.fromRGB(247, 248, 252),
		Panel = Color3.fromRGB(255, 255, 255),
		Panel2 = Color3.fromRGB(242, 244, 248),
		Surface = Color3.fromRGB(250, 250, 252),
		Text = Color3.fromRGB(18, 18, 22),
		SubText = Color3.fromRGB(90, 90, 105),
		Stroke = Color3.fromRGB(170, 170, 185),
		StrokeSoft = Color3.fromRGB(200, 200, 212),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Ocean = {
		Primary = Color3.fromRGB(35, 160, 255),
		BG = Color3.fromRGB(10, 14, 20),
		Panel = Color3.fromRGB(16, 20, 28),
		Panel2 = Color3.fromRGB(22, 26, 36),
		Surface = Color3.fromRGB(14, 18, 24),
		Text = Color3.fromRGB(240, 245, 255),
		SubText = Color3.fromRGB(160, 175, 200),
		Stroke = Color3.fromRGB(35, 45, 60),
		StrokeSoft = Color3.fromRGB(28, 35, 50),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Emerald = {
		Primary = Color3.fromRGB(16, 185, 129),
		BG = Color3.fromRGB(8, 12, 10),
		Panel = Color3.fromRGB(14, 18, 16),
		Panel2 = Color3.fromRGB(20, 24, 22),
		Surface = Color3.fromRGB(12, 16, 14),
		Text = Color3.fromRGB(240, 255, 245),
		SubText = Color3.fromRGB(160, 190, 170),
		Stroke = Color3.fromRGB(35, 50, 40),
		StrokeSoft = Color3.fromRGB(28, 40, 32),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Crimson = {
		Primary = Color3.fromRGB(255, 45, 45),
		BG = Color3.fromRGB(12, 8, 8),
		Panel = Color3.fromRGB(20, 14, 14),
		Panel2 = Color3.fromRGB(26, 20, 20),
		Surface = Color3.fromRGB(16, 12, 12),
		Text = Color3.fromRGB(255, 240, 240),
		SubText = Color3.fromRGB(190, 160, 160),
		Stroke = Color3.fromRGB(50, 35, 35),
		StrokeSoft = Color3.fromRGB(40, 28, 28),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
	Sunset = {
		Primary = Color3.fromRGB(249, 115, 22),
		BG = Color3.fromRGB(12, 10, 8),
		Panel = Color3.fromRGB(20, 16, 14),
		Panel2 = Color3.fromRGB(26, 22, 20),
		Surface = Color3.fromRGB(16, 14, 12),
		Text = Color3.fromRGB(255, 245, 240),
		SubText = Color3.fromRGB(190, 170, 160),
		Stroke = Color3.fromRGB(50, 40, 35),
		StrokeSoft = Color3.fromRGB(40, 32, 28),
		Shadow = Color3.fromRGB(0, 0, 0),
	},
}

	local THEME = THEME_PRESETS.Default

local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end)

local function GetUIParent()
	local parent
	pcall(function()
		if gethui then
			parent = gethui()
		end
	end)
	if parent then return parent end

	pcall(function()
		parent = game:GetService("CoreGui")
	end)
	if parent then return parent end

	if LOCAL_PLAYER then
		local pg = LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")
		if pg then return pg end
	end

	return game:GetService("Players")
end

local function Tween(inst, props, t, style, dir)
	local ti = TweenInfo.new(t or 0.35, style or EASE_STYLE, dir or EASE_DIR)
	local tw = TweenService:Create(inst, ti, props)
	tw:Play()
	return tw
end

local function Round(n)
	return UDim.new(0, n)
end

local function ScalePx(n)
	return math.floor((n * TEXT_SCALE) + 0.5)
end

local function _NormSearch(s)
	s = tostring(s or "")
	s = s:gsub("<[^>]->", "")
	s = s:lower()
	s = s:gsub("%s+", " ")
	s = s:gsub("^%s+", ""):gsub("%s+$", "")
	return s
end

local function _StripRichText(s)
	s = tostring(s or "")
	s = s:gsub("<[^>]->", "")
	return s
end

local function AddCorner(inst, r)
	local c = Instance.new("UICorner")
	local rr = r or 10
	if rr < 900 then
		rr = math.max(6, math.floor((rr * 1.2) + 0.5))
	end
	c.CornerRadius = UDim.new(0, rr)
	c.Parent = inst
	return c
end

local function AddStroke(inst, thickness, color, transparency)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness or 1.2
	s.Color = color or THEME.Stroke
	s.Transparency = transparency or 0.75
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
end

local function AddShadow(inst, zindex)
	local s = Instance.new("ImageLabel")
	s.Name = "Shadow"
	s.BackgroundTransparency = 1
	s.Image = "rbxassetid://6014261993"
	s.ImageColor3 = Color3.new(0, 0, 0)
	s.ImageTransparency = 0.6
	s.Position = UDim2.new(0.5, 0, 0.5, 0)
	s.AnchorPoint = Vector2.new(0.5, 0.5)
	s.Size = UDim2.new(1, 30, 1, 30)
	s.ZIndex = (zindex or inst.ZIndex) - 1
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

local function MakeText(parent, text, size, weight)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Text = text or ""
	pcall(function()
		lbl:SetAttribute("UH_OrigText", tostring(text or ""))
	end)
	lbl.Font = (weight == "bold") and Enum.Font.GothamBold or (weight == "semibold" and Enum.Font.GothamSemibold or Enum.Font.GothamMedium)
	lbl.TextSize = math.floor((((size or 14) * TEXT_SCALE) + 0.5))
	lbl.TextColor3 = THEME.Text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Center
	lbl.RichText = true
	lbl.ClipsDescendants = true
	lbl.Parent = parent
	return lbl
end

local function MakeButtonBase(parent)
	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = parent
	return btn
end

local function AddScale(inst, s)
	local sc = Instance.new("UIScale")
	sc.Scale = s or 1
	sc.Parent = inst
	return sc
end

local function SetVisibleRecursive(gui, visible)
	for _, d in ipairs(gui:GetDescendants()) do
		if d:IsA("GuiObject") then
			d.Visible = visible
		end
	end
end

local function Ripple(parent, x, y, color)
	local r = Instance.new("Frame")
	r.Name = "Ripple"
	r.BackgroundColor3 = color or THEME.Primary
	r.BackgroundTransparency = 0.55
	r.BorderSizePixel = 0
	r.ZIndex = parent.ZIndex + 30
	r.AnchorPoint = Vector2.new(0.5, 0.5)
	r.Position = UDim2.fromOffset(x, y)
	r.Size = UDim2.fromOffset(0, 0)
	AddCorner(r, 999)
	r.Parent = parent

	local maxSize = 140
	Tween(r, {Size = UDim2.fromOffset(maxSize, maxSize), BackgroundTransparency = 1}, 0.55)
	task.delay(0.6, function()
		pcall(function() r:Destroy() end)
	end)
end

local function BindHoverFX(btn, glowTarget)
	local scale = AddScale(btn, 1)
	local glow = nil
	if glowTarget then
		glow = Instance.new("UIStroke")
		glow.Thickness = 1
		glow.Color = THEME.Primary
		glow.Transparency = 1
		glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		glow.Parent = glowTarget
	end

	btn.MouseEnter:Connect(function()
		Tween(scale, {Scale = 1.02}, 0.22)
		if glow then Tween(glow, {Transparency = 0.70}, 0.22) end
	end)
	btn.MouseLeave:Connect(function()
		Tween(scale, {Scale = 1}, 0.22)
		if glow then Tween(glow, {Transparency = 1}, 0.22) end
	end)
end

local function BindClickFX(btn, surface)
	btn.MouseButton1Down:Connect(function()
		local sc = btn:FindFirstChildOfClass("UIScale")
		if sc then Tween(sc, {Scale = 0.985}, 0.12) end
	end)
	btn.MouseButton1Up:Connect(function()
		local sc = btn:FindFirstChildOfClass("UIScale")
		if sc then Tween(sc, {Scale = 1.03}, 0.14) end
		if surface then
			local pos = UserInputService:GetMouseLocation()
			local inset = Vector2.new(0, 0)
			pcall(function()
				local gi = GuiService:GetGuiInset()
				inset = Vector2.new(gi.X, gi.Y)
			end)
			local corrected = Vector2.new(pos.X - inset.X, pos.Y - inset.Y)
			local abs = surface.AbsolutePosition
			local relX = corrected.X - abs.X
			local relY = corrected.Y - abs.Y
			Ripple(surface, relX, relY, THEME.Primary)
		end
		task.delay(0.06, function()
			local sc = btn:FindFirstChildOfClass("UIScale")
			if sc then Tween(sc, {Scale = 1}, 0.18) end
		end)
	end)
end

local function AutoCanvas(scrolling, layout)
	local function update()
		local pad = 16
		local y = layout.AbsoluteContentSize.Y + pad
		Tween(scrolling, {CanvasSize = UDim2.new(0, 0, 0, y)}, 0.18)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	update()
end

local UI = {}
local Tabs = {}

function UI:GetTheme()
	return THEME
end

UI._Alive = true
UI._Open = true
UI._TabSwitchToken = 0

UI._ProgressiveBuild = false
UI._BuildYieldSteps = 0
UI._BuildYieldSeconds = 0
UI._AutoBuildYieldSeconds = false
UI._TunedBuildYieldSeconds = 0

function UI:_AutoTuneBuildYieldSeconds()
	-- Auto tune based on current Heartbeat delta time.
	-- Goal:
	-- - Low FPS: don't add extra waiting (yield by frames only).
	-- - High FPS: add a small delay so the UI visibly loads in pieces.
	local sum = 0
	local n = 0
	for _ = 1, 12 do
		local dt = RunService.Heartbeat:Wait()
		if type(dt) == "number" and dt > 0 then
			sum += dt
			n += 1
		end
	end
	local avg = (n > 0) and (sum / n) or (1 / 60)
	local fps = (avg > 0) and (1 / avg) or 60

	-- Tuned values:
	-- - <40 fps: no artificial delay
	-- - 40-80 fps: small delay
	-- - >80 fps: more visible progressive delay
	if fps < 40 then
		self._TunedBuildYieldSeconds = 0
	elseif fps < 80 then
		self._TunedBuildYieldSeconds = 0.05
	else
		self._TunedBuildYieldSeconds = 0.12
	end

	return self._TunedBuildYieldSeconds
end

function UI:_YieldBuild(steps)
	return
end

UI._SearchToken = 0
UI._Settings = UI._Settings or {}

local function _CopyTheme(src)
	local t = {}
	for k, v in pairs(src or {}) do
		t[k] = v
	end
	return t
end

local function _SameColor(a, b)
	if typeof(a) ~= "Color3" or typeof(b) ~= "Color3" then return false end
	local eps = 0.005
	return math.abs(a.R - b.R) < eps and math.abs(a.G - b.G) < eps and math.abs(a.B - b.B) < eps
end

local function _NormThemeName(s)
	s = tostring(s or "")
	s = s:gsub("^%s+", ""):gsub("%s+$", "")
	return s
end

function UI:SetTheme(theme)
	local old = _CopyTheme(THEME)
	local newTheme = nil

	if type(theme) == "string" then
		local raw = _NormThemeName(theme)
		newTheme = THEME_PRESETS[raw]
		if newTheme == nil then
			local needle = raw:lower()
			for k, v in pairs(THEME_PRESETS) do
				if type(k) == "string" and k:lower() == needle then
					newTheme = v
					theme = k
					break
				end
			end
		end
	elseif type(theme) == "table" then
		newTheme = theme
	end

	if type(newTheme) ~= "table" then return false end

	for k, _ in pairs(THEME) do
		if typeof(newTheme[k]) == "Color3" then
			THEME[k] = newTheme[k]
		end
	end

	self._Settings.Theme = (type(theme) == "string") and theme or (self._Settings.Theme or "Custom")

	local sg = self.ScreenGui
	if not sg then return true end

	for _, inst in ipairs(sg:GetDescendants()) do
		pcall(function()
			if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
				local tc = inst.TextColor3
				for k, oc in pairs(old) do
					if _SameColor(tc, oc) then
						inst.TextColor3 = THEME[k]
						break
					end
				end
			elseif inst:IsA("GuiObject") then
				local bc = inst.BackgroundColor3
				for k, oc in pairs(old) do
					if _SameColor(bc, oc) then
						inst.BackgroundColor3 = THEME[k]
						break
					end
				end
			elseif inst:IsA("UIStroke") then
				local c = inst.Color
				for k, oc in pairs(old) do
					if _SameColor(c, oc) then
						inst.Color = THEME[k]
						break
					end
				end
			elseif inst:IsA("UIGradient") then
				local cs = inst.Color
				local keys = cs.Keypoints
				local changed = false
				for i = 1, #keys do
					local kp = keys[i]
					local col = kp.Value
					for k, oc in pairs(old) do
						if _SameColor(col, oc) then
							keys[i] = ColorSequenceKeypoint.new(kp.Time, THEME[k])
							changed = true
							break
						end
					end
				end
				if changed then
					inst.Color = ColorSequence.new(keys)
				end
			end
		end)
	end

	pcall(function()
		if type(self._SaveSettings) == "function" then
			self:_SaveSettings()
		end
	end)

	pcall(function()
		if type(updateBackgroundGlow) == "function" then
			updateBackgroundGlow()
		end
	end)

	return true
end

UI.ThemePresets = THEME_PRESETS

function UI:GetThemeNames()
	local preferred = {"Default", "Special", "Dark", "Light", "Crimson", "Ocean", "Emerald", "Sunset"}
	local out = {}
	local used = {}
	for _, name in ipairs(preferred) do
		if THEME_PRESETS[name] ~= nil then
			table.insert(out, name)
			used[name] = true
		end
	end
	local extra = {}
	for k, _ in pairs(THEME_PRESETS) do
		if type(k) == "string" and not used[k] then
			table.insert(extra, k)
		end
	end
	table.sort(extra)
	for _, k in ipairs(extra) do
		table.insert(out, k)
	end
	return out
end

UI._Settings = {
	MinimizeKeyCode = Enum.KeyCode.RightControl,
	NotificationsEnabled = true,
	NotificationPosition = "BottomRight",
	AutoLoadEnabled = false,
	AutoLoadName = "default",
	Theme = "",
	Opacity = 90,
	FadeSpeed = 0.35,
}
UI._AwaitingKeybind = false
UI._KeybindButton = nil
UI._KeybindLabel = nil

UI._AwaitingBind = nil
UI._BindControls = {}

UI._UIState = {}
UI._Controls = {}

pcall(function()
	UI:_LoadSettings()
end)

function UI:_ApplySearch(rawQuery)
	local query = _NormSearch(rawQuery)

	local currentName = self._CurrentTab
	local t = currentName and Tabs[currentName]
	if type(t) ~= "table" or not t.Page then
		return
	end

	local page = t.Page

	local function setAllVisibleInPage()
		for _, d in ipairs(page:GetDescendants()) do
			if d:IsA("GuiObject") then
				local st = d:GetAttribute("UH_SearchText")
				if st ~= nil then
					d.Visible = true
				end
			end
		end
		for _, sec in ipairs(page:GetDescendants()) do
			if sec:IsA("Frame") and sec.Name == "Section" then
				sec.Visible = true
			end
		end
	end

	if query == "" then
		setAllVisibleInPage()
		return
	end

	for _, sec in ipairs(page:GetDescendants()) do
		if not (sec:IsA("Frame") and sec.Name == "Section") then
			continue
		end

		local secKey = sec:GetAttribute("UH_SearchText")
		local secOrig = sec:GetAttribute("UH_SectionTitle")
		local secTranslated = sec:GetAttribute("UH_SectionTitle_Translated")
		local secTitle = _NormSearch(secKey or secTranslated or secOrig or "")
		local secMatch = (secTitle ~= "" and secTitle:find(query, 1, true) ~= nil)
		local secAny = false

		for _, obj in ipairs(sec:GetDescendants()) do
			if obj:IsA("GuiObject") then
				local st = obj:GetAttribute("UH_SearchText")
				if st ~= nil then
					local text = _NormSearch(st)
					local ok = secMatch or (text ~= "" and text:find(query, 1, true) ~= nil)
					obj.Visible = ok
					if ok then
						secAny = true
					end
				end
			end
		end

		sec.Visible = secAny or secMatch
	end
end

local function _GetRequest()
	return (syn and syn.request) or http_request or request
end

local function _NormPath(p)
	p = tostring(p or "")
	return (p:gsub("\\\\", "/"))
end

local function _SanitizeConfigName(name)
	name = tostring(name or "")
	name = name:gsub("^%s+", ""):gsub("%s+$", "")
	name = name:gsub("[\\/:*?\"<>|]", "_")
	name = name:gsub("%s+", " ")
	if name == "" then
		name = "default"
	end
	return name
end

local function _ReadFile(path)
	path = _NormPath(path)
	local rf = readfile or (syn and syn.readfile)
	if type(rf) ~= "function" then return nil end
	local ok, res = pcall(rf, path)
	if ok then return res end
	return nil
end

local function _WriteFile(path, data)
	local rawPath = tostring(path or "")
	local normPath = _NormPath(rawPath)
	local wf = writefile or (syn and syn.writefile)
	local isf = isfile or (syn and syn.isfile)
	local rf = readfile or (syn and syn.readfile)
	if type(wf) ~= "function" then return false end
	for _ = 1, 3 do
		local ok = pcall(wf, normPath, data)
		if (not ok) and normPath ~= rawPath then
			ok = pcall(wf, rawPath, data)
		end
		if ok then
			local verified = true
			if type(isf) == "function" then
				local ok2, exists = pcall(isf, normPath)
				if (not ok2 or not exists) and normPath ~= rawPath then
					local ok3, exists2 = pcall(isf, rawPath)
					verified = ok3 and exists2 == true
				else
					verified = ok2 and exists == true
				end
			end
			if verified and type(rf) == "function" then
				local ok3, contents = pcall(rf, normPath)
				if (not ok3 or contents == nil) and normPath ~= rawPath then
					ok3, contents = pcall(rf, rawPath)
				end
				verified = ok3 and type(contents) == "string" and #contents > 0
			end
			if verified then
				return true
			end
		end
		task.wait(0.05)
	end
	return false
end

local function _EnsureFolder(path)
	path = _NormPath(path)
	local mf = makefolder or (syn and syn.makefolder)
	local isf = isfolder or (syn and syn.isfolder)
	if type(mf) ~= "function" then return end
	if type(isf) == "function" then
		local ok, exists = pcall(isf, path)
		if ok and exists then return end
	end
	pcall(mf, path)
end

local CONFIG_DIR = "Unified"
local SETTINGS_PATH = CONFIG_DIR .. "/config.json"
local CONFIGS_DIR = CONFIG_DIR .. "/configs"
local PREMIUM_KEY_PATH = CONFIG_DIR .. "/premium.key"

function UI:GetPremiumKey()
	_EnsureFolder(CONFIG_DIR)
	local raw = _ReadFile(PREMIUM_KEY_PATH)
	if type(raw) ~= "string" then
		return ""
	end
	raw = raw:gsub("^%s+", ""):gsub("%s+$", "")
	return raw
end

function UI:HasPremium()
	return self:GetPremiumKey() ~= ""
end

function UI:SetPremiumKey(key)
	key = tostring(key or "")
	key = key:gsub("^%s+", ""):gsub("%s+$", "")
	if key == "" then
		return false
	end
	_EnsureFolder(CONFIG_DIR)
	return _WriteFile(PREMIUM_KEY_PATH, key) == true
end

function UI:_LoadSettings()
	_EnsureFolder(CONFIG_DIR)
	local raw = _ReadFile(SETTINGS_PATH)
	if type(raw) ~= "string" or raw == "" then return end
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if not ok or type(decoded) ~= "table" then return end
	if typeof(decoded.MinimizeKeyCode) == "string" and Enum.KeyCode[decoded.MinimizeKeyCode] then
		self._Settings.MinimizeKeyCode = Enum.KeyCode[decoded.MinimizeKeyCode]
	end
	if type(decoded.NotificationsEnabled) == "boolean" then
		self._Settings.NotificationsEnabled = decoded.NotificationsEnabled
	end
	if type(decoded.NotificationPosition) == "string" then
		self._Settings.NotificationPosition = decoded.NotificationPosition
	end
	self._Settings.AutoLoadEnabled = false
	self._Settings.AutoLoadEnabled = false
	if type(decoded.AutoLoadName) == "string" then
		self._Settings.AutoLoadName = decoded.AutoLoadName
	end
	if type(decoded.Opacity) == "number" then
		self._Settings.Opacity = decoded.Opacity
	end
	if type(decoded.Theme) == "string" then
		self._Settings.Theme = decoded.Theme
	end
	if type(decoded.UIState) == "table" then
		self._UIState = decoded.UIState
	end
end

function UI:_SaveSettings()
	_EnsureFolder(CONFIG_DIR)
	local payload = {
		MinimizeKeyCode = (self._Settings and self._Settings.MinimizeKeyCode and self._Settings.MinimizeKeyCode.Name) or "RightControl",
		NotificationsEnabled = (self._Settings and self._Settings.NotificationsEnabled) ~= false,
		NotificationPosition = (self._Settings and self._Settings.NotificationPosition) or "BottomRight",
		AutoLoadEnabled = false,
		AutoLoadName = (self._Settings and self._Settings.AutoLoadName) or "default",
		Theme = (self._Settings and self._Settings.Theme) or "",
		Opacity = (self._Settings and self._Settings.Opacity) or 90,
		UIState = self._UIState,
	}
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(payload)
	end)
	if not ok or type(encoded) ~= "string" then return false end
	local ok2 = _WriteFile(SETTINGS_PATH, encoded)
	return ok2 == true
end

function UI:_ListConfigs()
	_EnsureFolder(CONFIGS_DIR)
	local lf = listfiles or (syn and syn.listfiles)
	if type(lf) ~= "function" then
		return {"default"}
	end
	local out = {}
	local ok, files = pcall(lf, CONFIGS_DIR)
	if ok and type(files) == "table" then
		for _, p in ipairs(files) do
			local s = tostring(p)
			local name = s:match("([^/\\]+)%.json$")
			if name and name ~= "" then
				table.insert(out, name)
			end
		end
	end
	table.sort(out)
	if #out == 0 then
		out = {"default"}
	end
	return out
end

function UI:_LoadConfig(name)
	name = _SanitizeConfigName(name)
	_EnsureFolder(CONFIGS_DIR)
	local raw = _ReadFile(CONFIGS_DIR .. "/" .. name .. ".json")
	if type(raw) ~= "string" or raw == "" then return false end
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if not ok or type(decoded) ~= "table" then return false end
	local loadedOpacity = nil
	if type(decoded.Settings) == "table" then
		if typeof(decoded.Settings.MinimizeKeyCode) == "string" and Enum.KeyCode[decoded.Settings.MinimizeKeyCode] then
			self._Settings.MinimizeKeyCode = Enum.KeyCode[decoded.Settings.MinimizeKeyCode]
		end
		if type(decoded.Settings.NotificationsEnabled) == "boolean" then
			self._Settings.NotificationsEnabled = decoded.Settings.NotificationsEnabled
		end
		if type(decoded.Settings.NotificationPosition) == "string" then
			self._Settings.NotificationPosition = decoded.Settings.NotificationPosition
		end
		if type(decoded.Settings.Opacity) == "number" then
			loadedOpacity = decoded.Settings.Opacity
			self._Settings.Opacity = decoded.Settings.Opacity
		end
	end
	if type(decoded.UIState) == "table" then
		self._UIState = decoded.UIState
	end
	pcall(function() self:_SaveSettings() end)
	pcall(function()
		for k, api in pairs(self._Controls or {}) do
			local v = self._UIState[k]
			if v ~= nil and api and api.Set then
				api:Set(v)
			end
		end
		if loadedOpacity ~= nil then
			self._Settings.Opacity = loadedOpacity
			for k, api in pairs(self._Controls or {}) do
				if type(k) == "string" and k:match("/Slider/Change Opacity$") and api and api.Set then
					api:Set(loadedOpacity)
				end
			end
		end
		if self._Main and self._Settings.Opacity then
			self._Main.BackgroundTransparency = 1 - (self._Settings.Opacity / 100)
		end
	end)
	return true
end

function UI:_SaveConfig(name)
	name = _SanitizeConfigName(name)
	_EnsureFolder(CONFIGS_DIR)
	local payload = {
		Settings = {
			MinimizeKeyCode = (self._Settings and self._Settings.MinimizeKeyCode and self._Settings.MinimizeKeyCode.Name) or "RightControl",
			NotificationsEnabled = (self._Settings and self._Settings.NotificationsEnabled) ~= false,
			NotificationPosition = (self._Settings and self._Settings.NotificationPosition) or "BottomRight",
			Opacity = (self._Settings and self._Settings.Opacity) or 90,
		},
		UIState = self._UIState,
	}
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(payload)
	end)
	if not ok or type(encoded) ~= "string" then return false end
	local ok2 = _WriteFile(CONFIGS_DIR .. "/" .. name .. ".json", encoded)
	return ok2 == true
end

function UI:_DeleteConfig(name)
	name = _SanitizeConfigName(name)
	_EnsureFolder(CONFIGS_DIR)
	local path = CONFIGS_DIR .. "/" .. name .. ".json"
	local df = delfile or (syn and syn.delfile)
	if type(df) ~= "function" then return false end
	local ok, res = pcall(df, path)
	return ok == true
end

function UI:_GetPersistKey(sectionBody, controlType, controlName)
	local tab = "Unknown"
	local sec = "Unknown"
	pcall(function()
		local node = sectionBody
		while node do
			if node:IsA("ScrollingFrame") then
				local t = node:GetAttribute("UH_TabName")
				if t ~= nil then
					tab = t
					break
				end
			end
			node = node.Parent
		end
		local section = sectionBody
		while section and section.Parent do
			if section:IsA("Frame") and section.Name == "Section" then break end
			section = section.Parent
		end
		if section then
			sec = section:GetAttribute("UH_SectionTitle") or sec
		end
	end)
	return tostring(tab) .. "/" .. tostring(sec) .. "/" .. tostring(controlType) .. "/" .. tostring(controlName)
end

	pcall(function()
	end)

function UI:_QueueOnTeleport()
	local q = (syn and syn.queue_on_teleport) or queue_on_teleport
	if type(q) ~= "function" then
		return false, "queue_on_teleport not supported"
	end
	local url = "https://pastefy.app/yvEUCKU4/raw"
	local code = "pcall(function() loadstring(game:HttpGet('" .. url .. "'))() end)"

	local ok, err = pcall(function()
		q(code)
	end)
	if ok then return true end
	return false, tostring(err)
end

local _PendingTeleport = nil
pcall(function()
	TeleportService.TeleportInitFailed:Connect(function(plr, result, errMsg)
		if plr ~= Players.LocalPlayer then return end
		local pending = _PendingTeleport
		if type(pending) ~= "table" or type(pending.try) ~= "function" then return end
		if pending.tries >= (pending.maxTries or 3) then
			_PendingTeleport = nil
			pcall(function()
				UI:Notify("Teleport", "Failed: " .. tostring(errMsg or result), 3)
			end)
			return
		end
		pending.tries += 1
		task.delay(0.25, function()
			pcall(pending.try)
		end)
	end)
end)

local function _TryRejoin()
	local plr = Players.LocalPlayer
	if not plr then return false, "No LocalPlayer" end
	local placeId = game.PlaceId
	local jobId = game.JobId
	local qOk, qErr = UI:_QueueOnTeleport()
	if not qOk then
		UI:Notify("Auto Execute", tostring(qErr), 3)
	end
	local function doTeleport()
		if type(jobId) == "string" and jobId ~= "" then
			TeleportService:TeleportToPlaceInstance(placeId, jobId, plr)
		else
			TeleportService:Teleport(placeId, plr)
		end
	end
	_PendingTeleport = {tries = 1, maxTries = 3, try = doTeleport}
	local ok, err = pcall(doTeleport)
	if ok then return true end
	local ok2, err2 = pcall(function()
		TeleportService:Teleport(placeId, plr)
	end)
	if ok2 then return true end
	return false, tostring(err2 or err)
end

local function _FetchServers(cursor)
	local req = _GetRequest()
	if type(req) ~= "function" then
		return nil, "HTTP request not supported"
	end
	local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
	if cursor and cursor ~= "" then
		url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
	end
	local ok, res = pcall(function()
		return req({Url = url, Method = "GET"})
	end)
	if not ok or type(res) ~= "table" then
		return nil, "Request failed"
	end
	local body = res.Body or res.body
	if type(body) ~= "string" then
		return nil, "Bad response"
	end
	local ok2, decoded = pcall(function()
		return HttpService:JSONDecode(body)
	end)
	if not ok2 or type(decoded) ~= "table" then
		return nil, "Decode failed"
	end
	return decoded
end

local function _TryServerhop(preferPing)
	local plr = Players.LocalPlayer
	if not plr then return false, "No LocalPlayer" end
	local qOk, qErr = UI:_QueueOnTeleport()
	if not qOk then
		UI:Notify("Auto Execute", tostring(qErr), 3)
	end

	local candidates = {}
	local cursor = nil
	for _ = 1, 3 do
		local page, err = _FetchServers(cursor)
		if not page then
			return false, err
		end
		cursor = page.nextPageCursor
		if type(page.data) == "table" then
			for _, s in ipairs(page.data) do
				if type(s) == "table" then
					local id = s.id
					local playing = tonumber(s.playing) or 0
					local maxPlayers = tonumber(s.maxPlayers) or 0
					local ping = tonumber(s.ping)
					local minPlayers = math.max(3, math.floor(maxPlayers * 0.25))
					if id and id ~= game.JobId and maxPlayers > 0 and playing >= minPlayers and playing < maxPlayers then
						table.insert(candidates, {id = id, playing = playing, maxPlayers = maxPlayers, ping = ping})
					end
				end
			end
		end
		if #candidates >= 25 then break end
		if not cursor then break end
	end

	if #candidates == 0 then
		return false, "No suitable servers found"
	end

	local pick = nil
	if preferPing then
		local hasPing = false
		for _, c in ipairs(candidates) do
			if type(c.ping) == "number" then hasPing = true break end
		end
		if hasPing then
			table.sort(candidates, function(a, b)
				return (a.ping or 1e9) < (b.ping or 1e9)
			end)
			pick = candidates[1]
		end
	end
	if not pick then
		pick = candidates[math.random(1, #candidates)]
	end

	local tries = math.min(5, #candidates)
	local idx = 1
	local function doTeleport()
		local target = candidates[idx] or pick
		idx = math.clamp(idx + 1, 1, tries)
		if not target or not target.id then
			error("No server candidate")
		end
		TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, plr)
	end
	_PendingTeleport = {tries = 1, maxTries = tries, try = doTeleport}
	local ok, err = pcall(doTeleport)
	if ok then return true end
	return false, tostring(err or "Teleport failed")
end

function UI:Notify(title, body, duration)
	if self._Settings and self._Settings.NotificationsEnabled == false then return end
	
	local stack = self._NotifyStack
	if not stack and type(self._NotifyStacks) == "table" then
		local key = (self._Settings and self._Settings.NotificationPosition) or "BottomRight"
		stack = self._NotifyStacks[key] or self._NotifyStacks.BottomRight
		self._NotifyStack = stack
	end
	
	if not stack then 
		-- Fallback to finding it if initialized but not assigned
		if type(self._NotifyStacks) == "table" then
			stack = self._NotifyStacks.BottomRight
			self._NotifyStack = stack
		end
	end
	
	if not stack then return end
	local posKey = "BottomRight"
	pcall(function()
		posKey = stack:GetAttribute("UH_NotifyPos") or posKey
	end)

	local card = Instance.new("Frame")
	card.Name = "Notification"
	card.BackgroundColor3 = THEME.Panel
	card.BackgroundTransparency = 1 -- Start transparent for tween
	card.BorderSizePixel = 0
	card.Size = UDim2.fromOffset(320, 78)
	card.ClipsDescendants = true -- Revert to original clipping
	
	local isRight = tostring(posKey):find("Right") ~= nil
	local isBottom = tostring(posKey):find("Bottom") ~= nil
	local yScale = isBottom and 1 or 0
	local yInOff = isBottom and -8 or 8
	local xOutOff = isRight and 340 or -340
	local xInOff = isRight and -334 or 14
	card.Position = UDim2.new(isRight and 1 or 0, xOutOff, yScale, 0)
	card.ZIndex = 2000
	AddCorner(card, 14)
	AddStroke(card, 1, THEME.StrokeSoft, 0.35)
	AddShadow(card, 1999)
	AddGradient(card, THEME.Surface, THEME.Panel, 90)
	card.Parent = stack

	local dur = duration or 2.6
	
	local glow = Instance.new("UIStroke")
	glow.Thickness = 2
	glow.Color = THEME.Primary
	glow.Transparency = 1
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.Parent = card

	local inner = Instance.new("Frame")
	inner.BackgroundTransparency = 1
	inner.Size = UDim2.new(1, -18, 1, -18)
	inner.Position = UDim2.fromOffset(9, 9)
	inner.ZIndex = 2001
	inner.Parent = card

	local t1 = MakeText(inner, title or "Notification", 14, "bold")
	t1.ZIndex = 2002
	t1.Size = UDim2.new(1, -10, 0, 18)
	t1.Position = UDim2.fromOffset(0, 0)
	t1.Parent = inner

	local t2 = MakeText(inner, body or "", 12, "")
	t2.TextColor3 = THEME.SubText
	t2.ZIndex = 2002
	t2.Size = UDim2.new(1, -10, 1, -24)
	t2.Position = UDim2.fromOffset(0, 22)
	t2.TextWrapped = true
	t2.TextYAlignment = Enum.TextYAlignment.Top
	t2.Parent = inner

	local close = MakeButtonBase(inner)
	close.ZIndex = 2003
	close.Size = UDim2.fromOffset(22, 22)
	close.Position = UDim2.new(1, -22, 0, -2)
	close.Parent = inner
	local closeBg = Instance.new("Frame")
	closeBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	closeBg.BackgroundTransparency = 0.92
	closeBg.BorderSizePixel = 0
	closeBg.Size = UDim2.fromScale(1, 1)
	closeBg.ZIndex = 203
	AddCorner(closeBg, 8)
	AddStroke(closeBg, 1, THEME.StrokeSoft, 0.55)
	closeBg.Parent = close
	local x = MakeText(closeBg, "×", 16, "bold")
	x.TextColor3 = THEME.Text
	x.TextXAlignment = Enum.TextXAlignment.Center
	x.Size = UDim2.fromScale(1, 1)
	x.ZIndex = 204
	BindHoverFX(close, closeBg)
	BindClickFX(close, closeBg)

	local scale = AddScale(card, 1)
	scale.Scale = 0.96
	card.BackgroundTransparency = 1
	Tween(scale, {Scale = 1}, 0.35)
	Tween(card, {Position = UDim2.new(isRight and 1 or 0, xInOff, yScale, yInOff), BackgroundTransparency = 0.08}, 0.35)

	local function dismiss()
		if not card.Parent then return end
		Tween(scale, {Scale = 0.96}, 0.22)
		Tween(card, {Position = UDim2.new(isRight and 1 or 0, xOutOff, yScale, yInOff), BackgroundTransparency = 1}, 0.28)
		task.delay(0.32, function()
			pcall(function() card:Destroy() end)
		end)
	end

	close.MouseButton1Click:Connect(dismiss)
	task.delay(dur, dismiss)
end

function UI:SetNotificationPosition(pos)
	if type(self._NotifyStacks) ~= "table" then return false end
	pos = tostring(pos or "")
	pos = pos:gsub("%s+", "")
	local map = {
		TopLeft = "TopLeft",
		BottomLeft = "BottomLeft",
		TopRight = "TopRight",
		BottomRight = "BottomRight",
	}
	local key = map[pos] or map[pos:lower():gsub("^%l", string.upper)]
	if not key then
		local needle = pos:lower()
		for k, _ in pairs(map) do
			if k:lower() == needle then
				key = k
				break
			end
		end
	end
	key = key or "BottomRight"
	local target = self._NotifyStacks[key] or self._NotifyStacks.BottomRight
	if not target then return false end

	local prev = self._NotifyStack
	self._NotifyStack = target
	if self._Settings then
		self._Settings.NotificationPosition = key
	end
	pcall(function()
		if type(self._SaveSettings) == "function" then
			self:_SaveSettings()
		end
	end)

	pcall(function()
		if prev and prev ~= target then
			for _, child in ipairs(prev:GetChildren()) do
				if child:IsA("Frame") and child.Name == "Notification" then
					child.Parent = target
				end
			end
		end
	end)

	return true
end

local function MakeDraggable(handle, target)
	local dragging = false
	local dragStart, startPos
	local connA, connB

	local function update(input)
		local delta = input.Position - dragStart
		target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position

			if connA then connA:Disconnect() connA = nil end
			if connB then connB:Disconnect() connB = nil end

			connA = UserInputService.InputChanged:Connect(function(changed)
				if dragging and (changed.UserInputType == Enum.UserInputType.MouseMovement or changed.UserInputType == Enum.UserInputType.Touch) then
					update(changed)
				end
			end)
			connB = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if connA then connA:Disconnect() connA = nil end
					if connB then connB:Disconnect() connB = nil end
				end
			end)
		end
	end)
end

local function CreateParticles(parent)
	local holder = Instance.new("Frame")
	holder.Name = "Particles"
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromScale(1, 1)
	holder.ZIndex = 1
	holder.Parent = parent

	local dots = {}
	for i = 1, 22 do
		local d = Instance.new("Frame")
		d.Name = "Dot"
		d.BackgroundColor3 = THEME.Primary
		d.BackgroundTransparency = 0.92
		d.BorderSizePixel = 0
		local s = math.random(2, 4)
		d.Size = UDim2.fromOffset(s, s)
		d.Position = UDim2.new(math.random(), 0, math.random(), 0)
		d.ZIndex = 1
		AddCorner(d, 999)
		d.Parent = holder
		table.insert(dots, d)
	end

	task.spawn(function()
		while holder.Parent do
			for _, d in ipairs(dots) do
				if not d.Parent then continue end
				local nx = math.clamp(d.Position.X.Scale + (math.random(-35, 35) / 1000), 0, 1)
				local ny = math.clamp(d.Position.Y.Scale + (math.random(-35, 35) / 1000), 0, 1)
				Tween(d, {Position = UDim2.new(nx, 0, ny, 0), BackgroundTransparency = 0.88 + math.random() * 0.08}, 1.8 + math.random() * 1.2)
			end
			task.wait(1.6)
		end
	end)

	return holder
end

function UI:CreateTab(opt)
	opt = opt or {}
	local name = tostring((opt.Name ~= nil) and opt.Name or "Tab")
	local icon = opt.Icon
	if type(icon) ~= "string" then
		icon = nil
	end
	
	local page = Instance.new("ScrollingFrame")
	page.Name = name .. "Page"
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Size = UDim2.fromScale(1, 1)
	page.ScrollBarThickness = 2
	page.ScrollBarImageColor3 = THEME.Primary
	page.Visible = false
	page.ZIndex = 50
	pcall(function()
		page:SetAttribute("UH_TabName", name)
	end)
	page.Parent = self._Pages

	local pageList = Instance.new("UIListLayout")
	pageList.SortOrder = Enum.SortOrder.LayoutOrder
	pageList.Padding = UDim.new(0, 12)
	pageList.Parent = page

	local pagePad = Instance.new("UIPadding")
	pagePad.PaddingTop = UDim.new(0, 2)
	pagePad.PaddingBottom = UDim.new(0, 20)
	pagePad.PaddingLeft = UDim.new(0, 2)
	pagePad.PaddingRight = UDim.new(0, 2)
	pagePad.Parent = page

	AutoCanvas(page, pageList)

	local tabBtn = {
		Name = name,
		Page = page,
	}

	function tabBtn:CreateSection(title)
		local section = Instance.new("Frame")
		section.Name = title or "Section"
		section.BackgroundColor3 = THEME.Panel
		section.BorderSizePixel = 0
		section.Size = UDim2.new(1, 0, 0, ScalePx(54))
		section.ZIndex = 10
		pcall(function()
			section:SetAttribute("UH_SectionTitle", tostring(title or "Section"))
		end)
		AddCorner(section, 12)
		AddGradient(section, THEME.Surface, THEME.Panel, 90)
		section.Parent = page

		local header = Instance.new("Frame")
		header.Name = "Header"
		header.BackgroundTransparency = 1
		header.Size = UDim2.new(1, -28, 0, ScalePx(34))
		header.Position = UDim2.fromOffset(14, 0)
		header.ZIndex = 11
		header.Parent = section

		local t = MakeText(header, title or "Section", 14, "bold")
		t.ZIndex = 12
		t.Size = UDim2.new(1, 0, 1, 0)
		t.Position = UDim2.fromOffset(0, 0)

		local sectionBody = Instance.new("Frame")
		sectionBody.Name = "Body"
		sectionBody.BackgroundTransparency = 1
		sectionBody.ClipsDescendants = true
		sectionBody.Size = UDim2.new(1, 0, 0, 0)
		sectionBody.Position = UDim2.fromOffset(0, ScalePx(34))
		sectionBody.ZIndex = 11
		sectionBody.Parent = section

		local bodyList = Instance.new("UIListLayout")
		bodyList.SortOrder = Enum.SortOrder.LayoutOrder
		bodyList.Padding = UDim.new(0, 8)
		bodyList.Parent = sectionBody

		local bodyPad = Instance.new("UIPadding")
		bodyPad.PaddingTop = UDim.new(0, 0)
		bodyPad.PaddingBottom = UDim.new(0, 14)
		bodyPad.PaddingLeft = UDim.new(0, 0)
		bodyPad.PaddingRight = UDim.new(0, 0)
		bodyPad.Parent = sectionBody

		bodyList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			local h = bodyList.AbsoluteContentSize.Y + bodyPad.PaddingBottom.Offset
			sectionBody.Size = UDim2.new(1, 0, 0, h)
			section.Size = UDim2.new(1, 0, 0, h + ScalePx(34))
		end)

		return {
			Body = sectionBody,
			Section = section
		}
	end

	function tabBtn:CreateLockedSection(title)
		local s = self:CreateSection(title)
		local header = s.Section:FindFirstChild("Header")
		if header then
			local pill = Instance.new("Frame")
			pill.Name = "LockedPill"
			pill.BackgroundColor3 = THEME.BG
			pill.Size = UDim2.fromOffset(60, 18)
			pill.Position = UDim2.new(1, -65, 0.5, -9)
			pill.ZIndex = header.ZIndex + 1
			AddCorner(pill, 8)
			AddStroke(pill, 1, THEME.StrokeSoft, 0.6)
			pill.Parent = header

			local ptxt = MakeText(pill, "LOCKED", 11, "bold")
			ptxt.ZIndex = pill.ZIndex + 1
			ptxt.TextColor3 = THEME.SubText
			ptxt.TextXAlignment = Enum.TextXAlignment.Center
			ptxt.Size = UDim2.fromScale(1, 1)
			ptxt.Parent = pill
		end
		
		local overlay = Instance.new("TextButton")
		overlay.Name = "LockedOverlay"
		overlay.BackgroundTransparency = 1
		overlay.Size = UDim2.fromScale(1, 1)
		overlay.ZIndex = 50
		overlay.Text = ""
		overlay.Parent = s.Section
		
		overlay.MouseButton1Click:Connect(function()
			UI:Notify("Premium", "This section is locked! Redeem a key in the Premium tab.", 3)
		end)
		
		return s
	end

	table.insert(Tabs, tabBtn)
	
	local sidebar = self._Main:FindFirstChild("Sidebar")
	local tabList = sidebar and sidebar:FindFirstChild("TabList")
	
	if tabList then
		local surface = Instance.new("Frame")
		surface.Name = name .. "Tab"
		surface.BackgroundColor3 = THEME.Primary
		surface.BackgroundTransparency = 1
		surface.Size = UDim2.new(1, -12, 0, 32)
		surface.ZIndex = 32
		AddCorner(surface, 8)
		surface.Parent = tabList

		local btn = MakeButtonBase(surface)
		btn.ZIndex = 35
		btn.Size = UDim2.fromScale(1, 1)
		
		if icon then
			local iconLabel = Instance.new("ImageLabel")
			iconLabel.Name = "Icon"
			iconLabel.BackgroundTransparency = 1
			iconLabel.Image = icon
			iconLabel.Size = UDim2.fromOffset(18, 18)
			iconLabel.Position = UDim2.fromOffset(8, 7)
			iconLabel.ZIndex = 34
			iconLabel.Parent = surface
		end

		local textLbl = MakeText(surface, name, 12, "semibold")
		textLbl.ZIndex = 34
		textLbl.Size = UDim2.new(1, icon and -34 or -16, 1, 0)
		textLbl.Position = UDim2.fromOffset(icon and 30 or 12, 0)
		textLbl.Parent = surface

		btn.MouseButton1Click:Connect(function()
			self:SelectTab(name)
		end)
		
		tabBtn.Surface = surface
	end

	self:_YieldBuild()

	return tabBtn
end

function UI:CreateSection(page, title)
	local section = Instance.new("Frame")
	section.Name = "Section"
	section.BackgroundColor3 = THEME.Surface
	section.BackgroundTransparency = 0.05
	section.BorderSizePixel = 0
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.ZIndex = 10
	pcall(function()
		section:SetAttribute("UH_SectionTitle", tostring(title or "Section"))
		section:SetAttribute("UH_SearchText", tostring(title or "Section"))
	end)
	AddCorner(section, 12)
	AddGradient(section, THEME.Surface, THEME.Panel, 90)
	AddShadow(section, 9)
	section.Parent = page
	self:_YieldBuild()

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, -18, 0, ScalePx(42))
	header.Position = UDim2.fromOffset(9, ScalePx(8))
	header.ZIndex = 11
	header.Parent = section

	local t = MakeText(header, title or "Section", 14, "bold")
	t.ZIndex = 12
	t.Size = UDim2.new(1, 0, 1, 0)
	t.Position = UDim2.fromOffset(0, 0)

	local body
	body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.Size = UDim2.new(1, -18, 0, 0)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.Position = UDim2.fromOffset(9, ScalePx(50))
	body.ZIndex = 11
	body.ClipsDescendants = false
	body.Parent = section

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, ScalePx(10))
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = body

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, ScalePx(2))
	pad.PaddingBottom = UDim.new(0, ScalePx(10))
	pad.PaddingLeft = UDim.new(0, ScalePx(2))
	pad.PaddingRight = UDim.new(0, ScalePx(2))
	pad.Parent = body

	local SectionAPI = {}
	SectionAPI.Frame = section
	SectionAPI.Body = body
	
	function SectionAPI:SetTitle(title)
		headerLbl.Text = tostring(title)
	end
	
	self:_YieldBuild()
	return SectionAPI
end

function UI:CreateLockedSection(page, title)
	local sec = self:CreateSection(page, title)
	local section = sec.Frame

	local header = section:FindFirstChild("Header")
	if header then
		local pill = Instance.new("Frame")
		pill.Name = "LockedPill"
		pill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		pill.BackgroundTransparency = 0.88
		pill.BorderSizePixel = 0
		pill.AnchorPoint = Vector2.new(1, 0.5)
		pill.Position = UDim2.new(1, 0, 0.5, 0)
		pill.Size = UDim2.fromOffset(78, ScalePx(22))
		pill.ZIndex = header.ZIndex + 3
		AddCorner(pill, 999)
		AddStroke(pill, 1, THEME.StrokeSoft, 0.6)
		pill.Parent = header

		local ptxt = MakeText(pill, "LOCKED", 11, "bold")
		ptxt.ZIndex = pill.ZIndex + 1
		ptxt.TextColor3 = THEME.SubText
		ptxt.TextXAlignment = Enum.TextXAlignment.Center
		ptxt.Size = UDim2.fromScale(1, 1)
		ptxt.Position = UDim2.fromOffset(0, 0)
	end

	local overlay = Instance.new("TextButton")
	overlay.Name = "LockedOverlay"
	overlay.AutoButtonColor = false
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.55
	overlay.BorderSizePixel = 0
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.Position = UDim2.fromScale(0, 0)
	overlay.ZIndex = section.ZIndex + 200
	overlay.Text = "LOCKED"
	overlay.TextColor3 = THEME.Text
	overlay.TextTransparency = 0.15
	overlay.Font = Enum.Font.GothamBold
	overlay.TextSize = math.floor((18 * TEXT_SCALE) + 0.5)
	overlay.Parent = section
	AddCorner(overlay, 12)

	local api = {}
	api.Frame = sec.Frame
	api.Body = sec.Body
	api.SetLocked = function(_, locked)
		overlay.Visible = locked ~= false
	end
	self:_YieldBuild()
	return api
end

function UI:CreateToggle(sectionBody, opt)
	opt = opt or {}
	local name = opt.Name or "Toggle"
	local default = opt.Default == true
	local cb = opt.Callback or function() end
	local persistKey = self:_GetPersistKey(sectionBody, "Toggle", name)
	if self._UIState and type(self._UIState[persistKey]) == "boolean" then
		default = self._UIState[persistKey] == true
	end

	local row = Instance.new("Frame")
	row.Name = "Toggle"
	row.BackgroundColor3 = THEME.Panel2
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, ScalePx(40))
	row.ZIndex = 20
	pcall(function()
		row:SetAttribute("UH_SearchText", tostring(name))
	end)
	AddCorner(row, 14)
	row.Parent = sectionBody

	local btn = MakeButtonBase(row)
	btn.ZIndex = 21
	btn.Size = UDim2.fromScale(1, 1)
	BindHoverFX(btn, row)
	BindClickFX(btn, row)

	local lbl = MakeText(row, name, 13, "semibold")
	lbl.ZIndex = 22
	lbl.Position = UDim2.fromOffset(14, 0)
	lbl.TextWrapped = true
	lbl.TextYAlignment = Enum.TextYAlignment.Center
	lbl.ClipsDescendants = true
	if IS_MOBILE then
		lbl.Position = UDim2.fromOffset(14, ScalePx(6))
		lbl.TextYAlignment = Enum.TextYAlignment.Top
		lbl.TextSize = math.max(10, math.floor(lbl.TextSize * 0.92))
	end

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.BackgroundColor3 = THEME.StrokeSoft
	track.BackgroundTransparency = 0.55
	track.BorderSizePixel = 0
	track.Size = UDim2.fromOffset(46, 22)
	track.Position = UDim2.new(1, -60, 0.5, -11)
	track.ZIndex = 22
	AddCorner(track, 999)
	local trackStroke = Instance.new("UIStroke")
	trackStroke.Thickness = 1
	trackStroke.Color = THEME.StrokeSoft
	trackStroke.Transparency = 0.45
	trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	trackStroke.Parent = track

	local trackGrad = Instance.new("UIGradient")
	trackGrad.Rotation = 90
	trackGrad.Parent = track
	track.Parent = row

	local rightReserved = 14 + 46 + 14
	if IS_MOBILE then
		lbl.Size = UDim2.new(1, -(14 + rightReserved), 1, -ScalePx(12))
	else
		lbl.Size = UDim2.new(1, -(14 + rightReserved), 1, 0)
	end

	local function updateRowHeight()
		local minH = ScalePx(40)
		local padV = ScalePx(12)
		local needed = math.max(minH, math.floor(lbl.TextBounds.Y + padV + 0.5))
		row.Size = UDim2.new(1, 0, 0, needed)
		track.Position = UDim2.new(1, -60, 0.5, -math.floor(track.Size.Y.Offset / 2))
	end

	lbl:GetPropertyChangedSignal("TextBounds"):Connect(updateRowHeight)
	updateRowHeight()

	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.BackgroundColor3 = THEME.Text
	knob.BackgroundTransparency = 0
	knob.BorderSizePixel = 0
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = UDim2.fromOffset(3, 3)
	knob.ZIndex = 23
	AddCorner(knob, 999)
	knob.Parent = track

	local glow = Instance.new("UIStroke")
	glow.Thickness = 2
	glow.Color = THEME.Text
	glow.Transparency = 1
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.Parent = track

	local value = default
	local function render(anim)
		local on = value
		local tcol = THEME.Text
		local kpos = on and UDim2.fromOffset(27, 3) or UDim2.fromOffset(3, 3)
		local bgCol = on and THEME.Primary or THEME.StrokeSoft
		local bgTr = on and 0.22 or 0.58
		local stCol = on and THEME.Primary or THEME.StrokeSoft
		local stTr = on and 0.12 or 0.50
		local function clamp01(x)
			return math.max(0, math.min(1, x))
		end
		local function shade(c, f)
			return Color3.new(clamp01(c.R * f), clamp01(c.G * f), clamp01(c.B * f))
		end
		local topCol = shade(bgCol, on and 1.10 or 1.06)
		local botCol = shade(bgCol, on and 0.92 or 0.88)
		if anim then
			Tween(knob, {Position = kpos, BackgroundColor3 = tcol}, 0.28)
			Tween(glow, {Transparency = on and 0.6 or 1}, 0.28)
			Tween(track, {BackgroundColor3 = bgCol, BackgroundTransparency = bgTr}, 0.28)
			Tween(trackStroke, {Color = stCol, Transparency = stTr}, 0.28)
			trackGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, topCol),
				ColorSequenceKeypoint.new(1, botCol),
			})
		else
			knob.Position = kpos
			knob.BackgroundColor3 = tcol
			glow.Transparency = on and 0.6 or 1
			track.BackgroundColor3 = bgCol
			track.BackgroundTransparency = bgTr
			trackStroke.Color = stCol
			trackStroke.Transparency = stTr
			trackGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, topCol),
				ColorSequenceKeypoint.new(1, botCol),
			})
		end
	end

	btn.MouseButton1Click:Connect(function()
		value = not value
		render(true)
		self._UIState[persistKey] = value
		task.spawn(function()
			pcall(cb, value)
		end)
	end)

	render(false)

	local api = {}
	api.Frame = row
	api.Get = function() return value end
	api.Set = function(a, b)
		local v = (b == nil) and a or b
		value = (v == true)
		render(true)
		self._UIState[persistKey] = value
		pcall(cb, value)
	end
	self._Controls[persistKey] = api
	self:_YieldBuild()
	return api
end

function UI:CreateBind(sectionBody, opt)
	opt = opt or {}
	local name = opt.Name or "Bind"
	local default = opt.Default
	local onPress = opt.Callback or function() end
	local onChanged = opt.Changed
	local persistKey = self:_GetPersistKey(sectionBody, "Bind", name)

	if self._UIState and self._UIState[persistKey] ~= nil then
		local saved = self._UIState[persistKey]
		if not (type(saved) == "string" and saved == "") then
			default = saved
		end
	end

	local keyCode = nil
	pcall(function()
		if typeof(default) == "EnumItem" and (default.EnumType == Enum.KeyCode or default.EnumType == Enum.UserInputType) then
			keyCode = default
		elseif type(default) == "string" and Enum.KeyCode[default] then
			keyCode = Enum.KeyCode[default]
		elseif type(default) == "string" and Enum.UserInputType[default] then
			keyCode = Enum.UserInputType[default]
		end
	end)

	local row = Instance.new("Frame")
	row.Name = "Bind"
	row.BackgroundColor3 = THEME.Panel2
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, ScalePx(46))
	row.ZIndex = 20
	pcall(function()
		row:SetAttribute("UH_SearchText", tostring(name))
	end)
	AddCorner(row, 14)
	AddStroke(row, 1, THEME.StrokeSoft, 0.5)
	row.Parent = sectionBody

	local lbl = MakeText(row, name, 13, "semibold")
	lbl.ZIndex = 22
	lbl.Size = UDim2.new(1, -160, 1, 0)
	lbl.Position = UDim2.fromOffset(14, 0)
	lbl.TextYAlignment = Enum.TextYAlignment.Center

	local keyBtn = Instance.new("Frame")
	keyBtn.Name = "Key"
	keyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	keyBtn.BackgroundTransparency = 0.92
	keyBtn.BorderSizePixel = 0
	keyBtn.Size = UDim2.fromOffset(132, ScalePx(28))
	keyBtn.Position = UDim2.new(1, -14, 0.5, 0)
	keyBtn.AnchorPoint = Vector2.new(1, 0.5)
	keyBtn.ZIndex = 21
	AddCorner(keyBtn, 10)
	AddStroke(keyBtn, 1, THEME.StrokeSoft, 0.55)
	keyBtn.Parent = row

	local glow = Instance.new("UIStroke")
	glow.Thickness = 2
	glow.Color = THEME.Primary
	glow.Transparency = 1
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.Parent = keyBtn

	local keyLbl = MakeText(keyBtn, "None", 12, "")
	keyLbl.ZIndex = 22
	keyLbl.TextXAlignment = Enum.TextXAlignment.Center
	keyLbl.Size = UDim2.fromScale(1, 1)
	keyLbl.Position = UDim2.fromOffset(0, 0)

	local click = MakeButtonBase(keyBtn)
	click.ZIndex = 23
	click.Size = UDim2.fromScale(1, 1)
	BindHoverFX(click, keyBtn)
	BindClickFX(click, keyBtn)

	local awaiting = false

	local function renderBind()
		if awaiting then
			keyLbl.Text = "Press..."
			keyLbl.TextColor3 = THEME.Primary
		elseif keyCode then
			if keyCode.EnumType == Enum.KeyCode then
				keyLbl.Text = tostring(keyCode.Name)
				keyLbl.TextColor3 = THEME.Text
			elseif keyCode.EnumType == Enum.UserInputType then
				keyLbl.Text = tostring(keyCode.Name):gsub("MouseButton", "Mouse Button")
				keyLbl.TextColor3 = THEME.Text
			end
		else
			keyLbl.Text = "None"
			keyLbl.TextColor3 = THEME.SubText
		end
	end

	local function setKey(kc)
		keyCode = kc
		awaiting = false
		renderBind()
		self._UIState[persistKey] = (typeof(keyCode) == "EnumItem" and keyCode.Name) or ""
		if type(onChanged) == "function" then
			pcall(onChanged, keyCode)
		end
	end

	click.MouseButton1Click:Connect(function()
		awaiting = true
		renderBind()
		Tween(glow, {Transparency = 0.35}, 0.12)
		self._AwaitingBind = {
			Key = persistKey,
			Set = setKey,
			Glow = glow,
		}
	end)

	renderBind()

	local api = {}
	api.Frame = row
	api.Get = function() return keyCode end
	api.Set = function(a, b)
		local v = (b == nil) and a or b
		local kc = nil
		if typeof(v) == "EnumItem" and (v.EnumType == Enum.KeyCode or v.EnumType == Enum.UserInputType) then
			kc = v
		elseif type(v) == "string" and Enum.KeyCode[v] then
			kc = Enum.KeyCode[v]
		elseif type(v) == "string" and Enum.UserInputType[v] then
			kc = Enum.UserInputType[v]
		end
		setKey(kc)
	end
	api.Trigger = function()
		pcall(onPress)
	end
	api._KeyCode = function() return keyCode end

	self._Controls[persistKey] = api
	self._BindControls[persistKey] = api
	return api
end

function UI:CreateBindToggle(sectionBody, opt)
	opt = opt or {}
	local name = opt.Name or "BindToggle"
	local defaultToggle = opt.Default == true
	local defaultBind = opt.BindDefault
	local onChanged = opt.Callback or function() end
	local onBindChanged = opt.Changed
	local persistKeyToggle = self:_GetPersistKey(sectionBody, "BindToggle", name .. "_Toggle")
	local persistKeyBind = self:_GetPersistKey(sectionBody, "BindToggle", name .. "_Bind")

	if self._UIState and type(self._UIState[persistKeyToggle]) == "boolean" then
		defaultToggle = self._UIState[persistKeyToggle] == true
	end
	if self._UIState and self._UIState[persistKeyBind] ~= nil then
		local saved = self._UIState[persistKeyBind]
		if not (type(saved) == "string" and saved == "") then
			defaultBind = saved
		end
	end

	local keyCode = nil
	pcall(function()
		if typeof(defaultBind) == "EnumItem" and (defaultBind.EnumType == Enum.KeyCode or defaultBind.EnumType == Enum.UserInputType) then
			keyCode = defaultBind
		elseif type(defaultBind) == "string" and Enum.KeyCode[defaultBind] then
			keyCode = Enum.KeyCode[defaultBind]
		elseif type(defaultBind) == "string" and Enum.UserInputType[defaultBind] then
			keyCode = Enum.UserInputType[defaultBind]
		end
	end)

	local row = Instance.new("Frame")
	row.Name = "BindToggle"
	row.BackgroundColor3 = THEME.Panel2
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, ScalePx(38))
	row.ZIndex = 20
	pcall(function()
		row:SetAttribute("UH_SearchText", tostring(name))
	end)
	AddCorner(row, 14)
	row.Parent = sectionBody

	local btn = MakeButtonBase(row)
	btn.ZIndex = 21
	btn.Size = UDim2.fromScale(1, 1)
	BindHoverFX(btn, row)
	BindClickFX(btn, row)

	local lbl = MakeText(row, name, 13, "semibold")
	lbl.ZIndex = 22
	lbl.Position = UDim2.fromOffset(14, 0)
	lbl.TextWrapped = true
	lbl.TextYAlignment = Enum.TextYAlignment.Center
	lbl.ClipsDescendants = true
	if IS_MOBILE then
		lbl.Position = UDim2.fromOffset(14, ScalePx(6))
		lbl.TextYAlignment = Enum.TextYAlignment.Top
		lbl.TextSize = math.max(10, math.floor(lbl.TextSize * 0.92))
	end

	local KEY_W = 76
	local KEY_H = ScalePx(24)
	local TRACK_W = 40
	local TRACK_H = 18
	local KNOB = 14
	local GAP = 0

	local rightHolder = Instance.new("Frame")
	rightHolder.Name = "Right"
	rightHolder.BackgroundTransparency = 1
	rightHolder.BorderSizePixel = 0
	rightHolder.Size = UDim2.fromOffset(KEY_W + TRACK_W, math.max(KEY_H, TRACK_H))
	rightHolder.AnchorPoint = Vector2.new(1, 0.5)
	rightHolder.Position = UDim2.new(1, -14, 0.5, 0)
	rightHolder.ZIndex = 22
	rightHolder.Parent = row

	local rightList = Instance.new("UIListLayout")
	rightList.FillDirection = Enum.FillDirection.Horizontal
	rightList.SortOrder = Enum.SortOrder.LayoutOrder
	rightList.Padding = UDim.new(0, GAP)
	rightList.HorizontalAlignment = Enum.HorizontalAlignment.Right
	rightList.VerticalAlignment = Enum.VerticalAlignment.Center
	rightList.Parent = rightHolder

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.BackgroundColor3 = THEME.StrokeSoft
	track.BackgroundTransparency = 0.55
	track.BorderSizePixel = 0
	track.Size = UDim2.fromOffset(TRACK_W, TRACK_H)
	track.LayoutOrder = 2
	track.ZIndex = 22
	AddCorner(track, 999)
	local trackStroke = Instance.new("UIStroke")
	trackStroke.Thickness = 1
	trackStroke.Color = THEME.StrokeSoft
	trackStroke.Transparency = 0.45
	trackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	trackStroke.Parent = track
	local trackGrad = Instance.new("UIGradient")
	trackGrad.Rotation = 90
	trackGrad.Parent = track
	track.Parent = rightHolder

	local keyBtn = Instance.new("Frame")
	keyBtn.Name = "Key"
	keyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	keyBtn.BackgroundTransparency = 0.92
	keyBtn.BorderSizePixel = 0
	keyBtn.Size = UDim2.fromOffset(KEY_W, KEY_H)
	keyBtn.LayoutOrder = 1
	keyBtn.ZIndex = 21
	AddCorner(keyBtn, 10)
	AddStroke(keyBtn, 1, THEME.StrokeSoft, 0.55)
	keyBtn.Parent = rightHolder

	local bindGlow = Instance.new("UIStroke")
	bindGlow.Thickness = 2
	bindGlow.Color = THEME.Primary
	bindGlow.Transparency = 1
	bindGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	bindGlow.Parent = keyBtn

	local keyLbl = MakeText(keyBtn, "None", 12, "")
	keyLbl.ZIndex = 22
	keyLbl.TextXAlignment = Enum.TextXAlignment.Center
	keyLbl.Size = UDim2.fromScale(1, 1)
	keyLbl.Position = UDim2.fromOffset(0, 0)
	keyLbl.TextSize = math.max(10, math.floor(keyLbl.TextSize * 0.92))

	local keyClick = MakeButtonBase(keyBtn)
	keyClick.ZIndex = 23
	keyClick.Size = UDim2.fromScale(1, 1)
	BindHoverFX(keyClick, keyBtn)
	BindClickFX(keyClick, keyBtn)

	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.BackgroundColor3 = THEME.Text
	knob.BackgroundTransparency = 0
	knob.BorderSizePixel = 0
	knob.Size = UDim2.fromOffset(KNOB, KNOB)
	knob.Position = UDim2.fromOffset(2, 2)
	knob.ZIndex = 23
	AddCorner(knob, 999)
	knob.Parent = track

	local toggleClick = MakeButtonBase(track)
	toggleClick.ZIndex = 24
	toggleClick.Size = UDim2.fromScale(1, 1)
	BindHoverFX(toggleClick, track)
	BindClickFX(toggleClick, track)

	local toggleGlow = Instance.new("UIStroke")
	toggleGlow.Thickness = 2
	toggleGlow.Color = THEME.Text
	toggleGlow.Transparency = 1
	toggleGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	toggleGlow.Parent = track

	local rightReserved = 14 + KEY_W + TRACK_W + 14
	if IS_MOBILE then
		lbl.Size = UDim2.new(1, -(14 + rightReserved), 1, -ScalePx(12))
	else
		lbl.Size = UDim2.new(1, -(14 + rightReserved), 1, 0)
	end

	local function updateRowHeight()
		local minH = ScalePx(38)
		local padV = ScalePx(12)
		local needed = math.max(minH, math.floor(lbl.TextBounds.Y + padV + 0.5))
		row.Size = UDim2.new(1, 0, 0, needed)
	end

	lbl:GetPropertyChangedSignal("TextBounds"):Connect(updateRowHeight)
	updateRowHeight()

	local awaiting = false
	local value = defaultToggle

	local function renderBind()
		if awaiting then
			keyLbl.Text = "..."
			keyLbl.TextColor3 = THEME.SubText
			return
		end
		if typeof(keyCode) == "EnumItem" and keyCode.EnumType == Enum.KeyCode and keyCode ~= Enum.KeyCode.Unknown then
			keyLbl.Text = tostring(keyCode.Name)
			keyLbl.TextColor3 = THEME.Text
			return
		end
		if typeof(keyCode) == "EnumItem" and keyCode.EnumType == Enum.UserInputType then
			local nm = tostring(keyCode.Name)
			if nm:find("MouseButton", 1, true) then
				keyLbl.Text = nm:gsub("MouseButton", "MouseButton")
			else
				keyLbl.Text = nm
			end
			keyLbl.TextColor3 = THEME.Text
			return
		else
			keyLbl.Text = "None"
			keyLbl.TextColor3 = THEME.SubText
		end
	end

	local function setKey(kc)
		keyCode = kc
		awaiting = false
		renderBind()
		self._UIState[persistKeyBind] = (typeof(keyCode) == "EnumItem" and keyCode.Name) or ""
		if type(onBindChanged) == "function" then
			pcall(onBindChanged, keyCode)
		end
	end

	keyClick.MouseButton1Click:Connect(function()
		awaiting = true
		renderBind()
		Tween(bindGlow, {Transparency = 0.35}, 0.12)
		self._AwaitingBind = {
			Key = persistKeyBind,
			Set = setKey,
			Glow = bindGlow,
		}
	end)

	local function renderToggle(anim)
		local on = value
		local tcol = THEME.Text
		local kpos = on and UDim2.fromOffset(TRACK_W - KNOB - 2, 2) or UDim2.fromOffset(2, 2)
		local bgCol = on and THEME.Primary or THEME.StrokeSoft
		local bgTr = on and 0.22 or 0.58
		local stCol = on and THEME.Primary or THEME.StrokeSoft
		local stTr = on and 0.12 or 0.50
		local function clamp01(x)
			return math.max(0, math.min(1, x))
		end
		local function shade(c, f)
			return Color3.new(clamp01(c.R * f), clamp01(c.G * f), clamp01(c.B * f))
		end
		local topCol = shade(bgCol, on and 1.10 or 1.06)
		local botCol = shade(bgCol, on and 0.92 or 0.88)
		if anim then
			Tween(knob, {Position = kpos, BackgroundColor3 = tcol}, 0.28)
			Tween(toggleGlow, {Transparency = on and 0.6 or 1}, 0.28)
			Tween(track, {BackgroundColor3 = bgCol, BackgroundTransparency = bgTr}, 0.28)
			Tween(trackStroke, {Color = stCol, Transparency = stTr}, 0.28)
			trackGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, topCol),
				ColorSequenceKeypoint.new(1, botCol),
			})
		else
			knob.Position = kpos
			knob.BackgroundColor3 = tcol
			toggleGlow.Transparency = on and 0.6 or 1
			track.BackgroundColor3 = bgCol
			track.BackgroundTransparency = bgTr
			trackStroke.Color = stCol
			trackStroke.Transparency = stTr
			trackGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, topCol),
				ColorSequenceKeypoint.new(1, botCol),
			})
		end
	end

	local function setToggle(v, anim)
		value = (v == true)
		renderToggle(anim)
		self._UIState[persistKeyToggle] = value
		pcall(onChanged, value)
	end

	btn.MouseButton1Click:Connect(function()
		setToggle(not value, true)
	end)

	toggleClick.MouseButton1Click:Connect(function()
		setToggle(not value, true)
	end)

	renderBind()
	renderToggle(false)

	local api = {}
	api.Frame = row
	api.Get = function() return value end
	api.Set = function(a, b)
		local v = (b == nil) and a or b
		setToggle(v == true, true)
	end
	api.GetKey = function() return keyCode end
	api.SetKey = function(a, b)
		local v = (b == nil) and a or b
		local kc = nil
		if typeof(v) == "EnumItem" and (v.EnumType == Enum.KeyCode or v.EnumType == Enum.UserInputType) then
			kc = v
		elseif type(v) == "string" and Enum.KeyCode[v] then
			kc = Enum.KeyCode[v]
		elseif type(v) == "string" and Enum.UserInputType[v] then
			kc = Enum.UserInputType[v]
		end
		setKey(kc)
	end
	api.Trigger = function()
		setToggle(not value, true)
	end
	api._KeyCode = function() return keyCode end

	self._Controls[persistKeyToggle] = api
	self._BindControls[persistKeyBind] = api
	return api
end

function UI:CreateButton(sectionBody, opt)
	opt = opt or {}
	local name = opt.Name or "Button"
	local cb = opt.Callback or function() end

	local row = Instance.new("Frame")
	row.Name = "Button"
	row.BackgroundColor3 = THEME.Panel2
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, ScalePx(44))
	row.ZIndex = 20
	pcall(function()
		row:SetAttribute("UH_SearchText", tostring(name))
	end)
	AddCorner(row, 14)
	AddStroke(row, 1, THEME.StrokeSoft, 0.5)
	row.Parent = sectionBody

	local btn = MakeButtonBase(row)
	btn.ZIndex = 22
	btn.Size = UDim2.fromScale(1, 1)
	btn.Active = true
	BindHoverFX(btn, row)
	BindClickFX(btn, row)

	local glow = Instance.new("UIStroke")
	glow.Thickness = 2
	glow.Color = THEME.Primary
	glow.Transparency = 1
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.Parent = row

	btn.MouseEnter:Connect(function()
		Tween(glow, {Transparency = 0.45}, 0.22)
	end)
	btn.MouseLeave:Connect(function()
		Tween(glow, {Transparency = 1}, 0.22)
	end)

	local lbl = MakeText(row, name, 13, "semibold")
	lbl.ZIndex = 23
	lbl.Size = UDim2.new(1, -28, 1, 0)
	lbl.Position = UDim2.fromOffset(14, 0)

	btn.Activated:Connect(function()
		task.spawn(function()
			pcall(cb)
		end)
	end)

	local api = {}
	api.Frame = row
	api.Label = lbl
	api.SetText = function(_, text)
		local t = tostring(text)
		lbl.Text = t
		pcall(function()
			row:SetAttribute("UH_SearchText", t)
		end)
	end
	self:_YieldBuild()
	return api
end

function UI:CreateLockedButton(sectionBody, opt)
	opt = opt or {}
	local name = opt.Name or "Locked"

	local row = Instance.new("Frame")
	row.Name = "LockedButton"
	row.BackgroundColor3 = THEME.Panel2
	row.BackgroundTransparency = 0.55
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, ScalePx(44))
	row.ZIndex = 20
	pcall(function()
		row:SetAttribute("UH_SearchText", tostring(name))
	end)
	AddCorner(row, 14)
	AddStroke(row, 1, THEME.StrokeSoft, 0.7)
	row.Parent = sectionBody

	local lbl = MakeText(row, name, 13, "semibold")
	lbl.ZIndex = 23
	lbl.TextColor3 = THEME.SubText
	lbl.Size = UDim2.new(1, -120, 1, 0)
	lbl.Position = UDim2.fromOffset(14, 0)
	lbl.TextYAlignment = Enum.TextYAlignment.Center

	local pill = Instance.new("Frame")
	pill.Name = "LockedPill"
	pill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	pill.BackgroundTransparency = 0.88
	pill.BorderSizePixel = 0
	pill.AnchorPoint = Vector2.new(1, 0.5)
	pill.Position = UDim2.new(1, -14, 0.5, 0)
	pill.Size = UDim2.fromOffset(78, ScalePx(22))
	pill.ZIndex = 23
	AddCorner(pill, 999)
	AddStroke(pill, 1, THEME.StrokeSoft, 0.75)
	pill.Parent = row

	local ptxt = MakeText(pill, "LOCKED", 11, "bold")
	ptxt.ZIndex = pill.ZIndex + 1
	ptxt.TextColor3 = THEME.SubText
	ptxt.TextXAlignment = Enum.TextXAlignment.Center
	ptxt.Size = UDim2.fromScale(1, 1)
	ptxt.Position = UDim2.fromOffset(0, 0)

	local blocker = Instance.new("TextButton")
	blocker.Name = "Blocker"
	blocker.AutoButtonColor = false
	blocker.BackgroundTransparency = 1
	blocker.Text = ""
	blocker.Size = UDim2.fromScale(1, 1)
	blocker.Position = UDim2.fromScale(0, 0)
	blocker.ZIndex = 24
	blocker.Parent = row

	local api = {}
	api.Frame = row
	api.Label = lbl
	api.SetText = function(_, text)
		local t = tostring(text)
		lbl.Text = t
		pcall(function()
			row:SetAttribute("UH_SearchText", t)
		end)
	end
	return api
end

function UI:CreateTextbox(sectionBody, opt)
	opt = opt or {}
	local name = opt.Name or "Input"
	local placeholder = opt.Placeholder or "Type here..."
	local default = opt.Default or ""
	local cb = opt.Callback or function() end
	local persistKey = self:_GetPersistKey(sectionBody, "Textbox", name)
	if self._UIState and type(self._UIState[persistKey]) == "string" then
		default = self._UIState[persistKey]
	end

	local row = Instance.new("Frame")
	row.Name = "Textbox"
	row.BackgroundColor3 = THEME.Panel2
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, 54)
	row.ZIndex = 20
	pcall(function()
		row:SetAttribute("UH_SearchText", tostring(name))
	end)
	AddCorner(row, 14)
	AddStroke(row, 1, THEME.StrokeSoft, 0.5)
	row.Parent = sectionBody

	local lbl = MakeText(row, name, 13, "semibold")
	lbl.ZIndex = 22
	lbl.Size = UDim2.new(1, -120, 0, 18)
	lbl.Position = UDim2.fromOffset(14, 8)

	local sideLbl = MakeText(row, tostring(default), 12, "semibold")
	sideLbl.Name = "SideValue"
	sideLbl.TextColor3 = THEME.Primary
	sideLbl.TextXAlignment = Enum.TextXAlignment.Right
	sideLbl.ZIndex = 22
	sideLbl.Size = UDim2.fromOffset(90, 18)
	sideLbl.Position = UDim2.new(1, -104, 0, 8)

	local boxBg = Instance.new("Frame")
	boxBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	boxBg.BackgroundTransparency = 0.92
	boxBg.BorderSizePixel = 0
	boxBg.Size = UDim2.new(1, -28, 0, 24)
	boxBg.Position = UDim2.fromOffset(14, 26)
	boxBg.ZIndex = 21
	AddCorner(boxBg, 10)
	AddStroke(boxBg, 1, THEME.StrokeSoft, 0.55)
	boxBg.Parent = row

	local glow = Instance.new("UIStroke")
	glow.Thickness = 2
	glow.Color = THEME.Primary
	glow.Transparency = 1
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.Parent = boxBg

	local box = Instance.new("TextBox")
	box.BackgroundTransparency = 1
	box.Text = tostring(default)
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = THEME.SubText
	box.TextColor3 = THEME.Text
	box.TextSize = math.floor((12 * TEXT_SCALE) + 0.5)
	box.Font = Enum.Font.Gotham
	box.ClearTextOnFocus = false
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Size = UDim2.new(1, -12, 1, 0)
	box.Position = UDim2.fromOffset(8, 0)
	box.ZIndex = 22
	box.Parent = boxBg

	box.Focused:Connect(function()
		Tween(glow, {Transparency = 0.35}, 0.22)
	end)
	box.FocusLost:Connect(function(enterPressed)
		Tween(glow, {Transparency = 1}, 0.22)
		self._UIState[persistKey] = box.Text
		task.spawn(function()
			pcall(cb, box.Text, enterPressed)
		end)
	end)

	local api = {}
	api.Frame = row
	api.Get = function() return box.Text end
	api.Set = function(a, b)
		local v = (b == nil) and a or b
		box.Text = tostring(v or "")
		self._UIState[persistKey] = box.Text
		pcall(cb, box.Text, false)
	end
	self._Controls[persistKey] = api
	self:_YieldBuild()
	return api
end

function UI:CreateSlider(sectionBody, opt)
	opt = opt or {}
	local name = opt.Name or "Slider"
	local min = tonumber(opt.Min) or 0
	local max = tonumber(opt.Max) or 100
	local default = tonumber(opt.Default) or min
	local step = tonumber(opt.Step) or 1
	local cb = opt.Callback or function() end
	local function _DecimalsFromStep(s)
		s = tonumber(s) or 1
		if s <= 0 then return 0 end
		local txt = tostring(s)
		local dec = txt:match("%.(%d+)")
		if dec then
			return math.clamp(#dec, 0, 6)
		end
		return 0
	end
	local function _FormatNumber(n)
		n = tonumber(n)
		if n == nil then return "0" end
		local d = _DecimalsFromStep(step)
		local p = 10 ^ d
		n = math.floor((n * p) + 0.5) / p
		local s = string.format("%." .. tostring(d) .. "f", n)
		if d > 0 then
			s = s:gsub("0+$", ""):gsub("%.$", "")
		end
		return s
	end
	local persistKey = self:_GetPersistKey(sectionBody, "Slider", name)
	if self._UIState and type(self._UIState[persistKey]) == "number" then
		default = tonumber(self._UIState[persistKey]) or default
	end

	local row = Instance.new("Frame")
	row.Name = "Slider"
	row.BackgroundColor3 = THEME.Panel2
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, ScalePx(62))
	row.ZIndex = 20
	pcall(function()
		row:SetAttribute("UH_SearchText", tostring(name))
	end)
	AddCorner(row, 14)
	AddStroke(row, 1, THEME.StrokeSoft, 0.5)
	row.Parent = sectionBody

	local lbl = MakeText(row, name, 13, "semibold")
	lbl.ZIndex = 22
	lbl.Size = UDim2.new(1, -120, 0, 18)
	lbl.Position = UDim2.fromOffset(14, 8)

	local bar = Instance.new("Frame")
	bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bar.BackgroundTransparency = 0.92
	bar.BorderSizePixel = 0
	bar.Size = UDim2.new(1, -64, 0, 10)
	bar.Position = UDim2.fromOffset(14, 36)
	bar.ZIndex = 21
	AddCorner(bar, 999)
	AddStroke(bar, 1, THEME.StrokeSoft, 0.6)
	bar.Parent = row

	local sideLbl = MakeText(row, _FormatNumber(default), 11, "semibold")
	sideLbl.Name = "ValueDisplay"
	sideLbl.TextColor3 = THEME.Primary
	sideLbl.TextXAlignment = Enum.TextXAlignment.Right
	sideLbl.Size = UDim2.fromOffset(40, 18)
	sideLbl.Position = UDim2.new(1, -54, 0, 8)
	sideLbl.ZIndex = 22
	sideLbl.Parent = row

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = THEME.Primary
	fill.BackgroundTransparency = 0.0
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.Position = UDim2.fromScale(0, 0)
	fill.ZIndex = 22
	AddCorner(fill, 999)
	fill.Parent = bar
	AddGradient(fill, Color3.fromRGB(160, 120, 255), THEME.Primary, 0)

	local knob = Instance.new("Frame")
	knob.BackgroundColor3 = THEME.Text
	knob.BackgroundTransparency = 0.05
	knob.BorderSizePixel = 0
	knob.Size = UDim2.fromOffset(16, 16)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.ZIndex = 23
	AddCorner(knob, 999)
	knob.Parent = bar

	local glow = Instance.new("UIStroke")
	glow.Thickness = 2
	glow.Color = THEME.Primary
	glow.Transparency = 0.65
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.Parent = knob

	local hit = MakeButtonBase(bar)
	hit.ZIndex = 24
	hit.Size = UDim2.fromScale(1, 1)
	hit.BackgroundTransparency = 1
	BindHoverFX(hit, bar)

	local dragging = false
	local value = default

	local function clampStep(v)
		v = math.clamp(v, min, max)
		local snapped = math.floor(((v - min) / step) + 0.5) * step + min
		snapped = math.clamp(snapped, min, max)
		return snapped
	end

	local function render(anim)
		local alpha = (value - min) / (max - min)
		alpha = math.clamp(alpha, 0, 1)
		sideLbl.Text = _FormatNumber(value)
		if anim then
			Tween(fill, {Size = UDim2.new(alpha, 0, 1, 0)}, 0.22)
			Tween(knob, {Position = UDim2.new(alpha, 0, 0.5, 0)}, 0.22)
		else
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		end
	end

	local function setFromX(x, fire)
		local absX = bar.AbsolutePosition.X
		local w = bar.AbsoluteSize.X
		local alpha = math.clamp((x - absX) / w, 0, 1)
		local raw = min + (max - min) * alpha
		local newVal = clampStep(raw)
		if newVal ~= value then
			value = newVal
			render(true)
			self._UIState[persistKey] = value
			if fire then
				task.spawn(function()
					pcall(cb, value)
				end)
			end
		end
	end

	hit.MouseButton1Down:Connect(function()
		dragging = true
		local pos = UserInputService:GetMouseLocation()
		setFromX(pos.X, true)
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			setFromX(input.Position.X, true)
		end
	end)

	render(false)
	pcall(cb, value)

	local api = {}
	api.Frame = row
	api.Get = function() return value end
	api.Set = function(a, b)
		local v = (b == nil) and a or b
		value = clampStep(tonumber(v) or min)
		render(true)
		self._UIState[persistKey] = value
		pcall(cb, value)
	end
	api.SetText = function(_, text)
		local t = tostring(text)
		lbl.Text = t
		pcall(function()
			row:SetAttribute("UH_SearchText", t)
		end)
	end
	self._Controls[persistKey] = api
	self:_YieldBuild()
	return api
end

function UI:CreateDropdown(sectionBody, opt)
	opt = opt or {}
	local name = opt.Name or "Dropdown"
	local list = opt.List or {"Option A", "Option B", "Option C"}
	local default = opt.Default
	local cb = opt.Callback or function() end
	local persistKey = self:_GetPersistKey(sectionBody, "Dropdown", name)
	if self._UIState and self._UIState[persistKey] ~= nil then
		default = self._UIState[persistKey]
	end

	local row = Instance.new("Frame")
	row.Name = "Dropdown"
	row.BackgroundColor3 = THEME.Panel2
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, ScalePx(54))
	row.ZIndex = 20
	row.ClipsDescendants = true
	pcall(function()
		row:SetAttribute("UH_SearchText", tostring(name))
	end)
	AddCorner(row, 14)
	AddStroke(row, 1, THEME.StrokeSoft, 0.5)
	row.Parent = sectionBody

	local lbl = MakeText(row, name, 13, "semibold")
	lbl.ZIndex = 22
	lbl.Size = UDim2.new(1, -120, 0, 18)
	lbl.Position = UDim2.fromOffset(14, 8)

	local selectBg = Instance.new("Frame")
	selectBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	selectBg.BackgroundTransparency = 0.92
	selectBg.BorderSizePixel = 0
	selectBg.Size = UDim2.new(1, -28, 0, 24)
	selectBg.Position = UDim2.fromOffset(14, 26)
	selectBg.ZIndex = 21
	AddCorner(selectBg, 10)
	AddStroke(selectBg, 1, THEME.StrokeSoft, 0.55)
	selectBg.Parent = row

	local glow = Instance.new("UIStroke")
	glow.Thickness = 2
	glow.Color = THEME.Primary
	glow.Transparency = 1
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.Parent = selectBg

	local valueLbl = MakeText(selectBg, default or "Select...", 12, "")
	valueLbl.TextColor3 = default and THEME.Text or THEME.SubText
	valueLbl.ZIndex = 22
	valueLbl.Size = UDim2.new(1, -28, 1, 0)
	valueLbl.Position = UDim2.fromOffset(8, 0)

	local arrow = MakeText(selectBg, "▲", 14, "bold")
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	arrow.ZIndex = 22
	arrow.Size = UDim2.fromOffset(22, 22)
	arrow.Position = UDim2.new(1, -22, 0.5, -11)
	arrow.Rotation = 180

	local click = MakeButtonBase(selectBg)
	click.ZIndex = 23
	click.Size = UDim2.fromScale(1, 1)
	BindHoverFX(click, selectBg)
	BindClickFX(click, selectBg)

	local BASE_H = ScalePx(54)
	local OPEN_GAP = ScalePx(10)

	local optionsHolder = Instance.new("Frame")
	optionsHolder.Name = "Options"
	optionsHolder.BackgroundColor3 = THEME.Panel
	optionsHolder.BackgroundTransparency = 0.08
	optionsHolder.BorderSizePixel = 0
	optionsHolder.Size = UDim2.new(1, -28, 0, 0)
	optionsHolder.Position = UDim2.fromOffset(14, 26 + 24 + ScalePx(6))
	optionsHolder.ZIndex = row.ZIndex + 10
	optionsHolder.ClipsDescendants = true
	AddCorner(optionsHolder, 12)
	AddStroke(optionsHolder, 1, THEME.StrokeSoft, 0.55)
	optionsHolder.Parent = row

	local optPad = Instance.new("UIPadding")
	optPad.PaddingTop = UDim.new(0, 8)
	optPad.PaddingBottom = UDim.new(0, 8)
	optPad.PaddingLeft = UDim.new(0, 8)
	optPad.PaddingRight = UDim.new(0, 8)
	optPad.Parent = optionsHolder

	local optList = Instance.new("UIListLayout")
	optList.SortOrder = Enum.SortOrder.LayoutOrder
	optList.Padding = UDim.new(0, 8)
	optList.Parent = optionsHolder

	local opened = false
	local value = default
	local openToken = 0

	local function setOpen(state)
		openToken += 1
		local token = openToken
		opened = state == true
		Tween(arrow, {Rotation = opened and 0 or 180}, 0.35)
		Tween(glow, {Transparency = opened and 0.35 or 1}, 0.22)
		local contentH = optList.AbsoluteContentSize.Y
		local h = opened and (contentH + optPad.PaddingTop.Offset + optPad.PaddingBottom.Offset + 4) or 0
		Tween(optionsHolder, {Size = UDim2.new(1, -28, 0, h)}, 0.22)
		Tween(row, {Size = UDim2.new(1, 0, 0, BASE_H + (opened and (h + OPEN_GAP) or 0))}, 0.22)

		if not opened then
			task.delay(0.23, function()
				if token ~= openToken then return end
				optionsHolder.Size = UDim2.new(1, -28, 0, 0)
				row.Size = UDim2.new(1, 0, 0, BASE_H)
			end)
		end
	end

	local function rebuild()
		if not optionsHolder or not optionsHolder.Parent then return end
		
		for _, ch in ipairs(optionsHolder:GetChildren()) do
			if ch:IsA("GuiObject") and not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then 
				ch:Destroy() 
			end
		end
		
		local itemCount = 0
		if type(list) == "table" then
			for i, item in ipairs(list) do
				itemCount = itemCount + 1
				local optRow = Instance.new("Frame")
				optRow.Name = "Option_" .. tostring(i)
				optRow.BackgroundColor3 = THEME.Panel
				optRow.BackgroundTransparency = 0.12
				optRow.BorderSizePixel = 0
				optRow.Size = UDim2.new(1, 0, 0, ScalePx(34))
				optRow.ZIndex = optionsHolder.ZIndex + 1
				AddCorner(optRow, 10)
				AddStroke(optRow, 1, THEME.StrokeSoft, 0.55)
				optRow.Parent = optionsHolder

				local optBtn = MakeButtonBase(optRow)
				optBtn.ZIndex = optRow.ZIndex + 1
				optBtn.Size = UDim2.fromScale(1, 1)
				BindHoverFX(optBtn, optRow)
				BindClickFX(optBtn, optRow)

				local t = MakeText(optRow, tostring(item), 12, "")
				t.ZIndex = optBtn.ZIndex + 1
				t.Size = UDim2.new(1, -18, 1, 0)
				t.Position = UDim2.fromOffset(10, 0)
				t.Parent = optRow

				optBtn.MouseButton1Click:Connect(function()
					value = item
					valueLbl.Text = tostring(item)
					valueLbl.TextColor3 = THEME.Text
					self._UIState[persistKey] = _StripRichText(value)
					task.spawn(function()
						pcall(cb, _StripRichText(value))
					end)
					setOpen(false)
				end)
			end
		end
		
		if opened then
			local contentH = optList.AbsoluteContentSize.Y
			local h = (itemCount > 0) and (contentH + optPad.PaddingTop.Offset + optPad.PaddingBottom.Offset + 4) or 0
			optionsHolder.Size = UDim2.new(1, -28, 0, h)
			row.Size = UDim2.new(1, 0, 0, BASE_H + (h > 0 and (h + OPEN_GAP) or 0))
		end
	end

	optList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if opened then
			local contentH = optList.AbsoluteContentSize.Y
			local h = contentH + optPad.PaddingTop.Offset + optPad.PaddingBottom.Offset + 4
			Tween(optionsHolder, {Size = UDim2.new(1, -28, 0, h)}, 0.18)
			Tween(row, {Size = UDim2.new(1, 0, 0, BASE_H + h + OPEN_GAP)}, 0.18)
		end
	end)

	click.MouseButton1Click:Connect(function()
		setOpen(not opened)
	end)

	local api = {}
	api.Frame = row
	api.Get = function() return value end
	api.Set = function(a, b)
		local v = (b == nil) and a or b
		if type(v) == "table" then
			v = ""
		end
		value = v
		valueLbl.Text = tostring(v)
		valueLbl.TextColor3 = THEME.Text
		self._UIState[persistKey] = _StripRichText(value)
		task.spawn(function()
			pcall(cb, _StripRichText(value))
		end)
	end
	api.UpdateList = function(newList)
		list = newList or {}
		rebuild()
	end
	api.Refresh = function(a, b)
		local newList = b
		if b == nil then
			newList = a
		end
		if type(newList) == "table" then
			list = newList
		end
		rebuild()
		if opened then
			setOpen(true)
		end
	end
	self._Controls[persistKey] = api
	rebuild()
	self:_YieldBuild()
	return api
end

function UI:CreateMultiDropdown(sectionBody, opt)
	opt = opt or {}
	local name = opt.Name or "Multi Dropdown"
	local list = opt.List or {"Option A", "Option B", "Option C"}
	local default = opt.Default
	local cb = opt.Callback or function() end
	local persistKey = self:_GetPersistKey(sectionBody, "MultiDropdown", name)

	if self._UIState and self._UIState[persistKey] ~= nil then
		default = self._UIState[persistKey]
	end

	local selected = {}
	local selectedSet = {}
	local function setSelected(arr)
		selected = {}
		selectedSet = {}
		if type(arr) == "table" then
			for _, v in ipairs(arr) do
				local s = tostring(v)
				if s ~= "" and not selectedSet[s] then
					selectedSet[s] = true
					table.insert(selected, s)
				end
			end
		elseif type(arr) == "string" then
			local ok, decoded = pcall(function()
				return HttpService:JSONDecode(arr)
			end)
			if ok and type(decoded) == "table" then
				for _, v in ipairs(decoded) do
					local s = tostring(v)
					if s ~= "" and not selectedSet[s] then
						selectedSet[s] = true
						table.insert(selected, s)
					end
				end
			end
		end
	end

	setSelected(default)

	local row = Instance.new("Frame")
	row.Name = "MultiDropdown"
	row.BackgroundColor3 = THEME.Panel2
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, ScalePx(54))
	row.ZIndex = 20
	row.ClipsDescendants = true
	pcall(function()
		row:SetAttribute("UH_SearchText", tostring(name))
	end)
	AddCorner(row, 14)
	AddStroke(row, 1, THEME.StrokeSoft, 0.5)
	row.Parent = sectionBody

	local lbl = MakeText(row, name, 13, "semibold")
	lbl.ZIndex = 22
	lbl.Size = UDim2.new(1, -120, 0, 18)
	lbl.Position = UDim2.fromOffset(14, 8)

	local selectBg = Instance.new("Frame")
	selectBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	selectBg.BackgroundTransparency = 0.92
	selectBg.BorderSizePixel = 0
	selectBg.Size = UDim2.new(1, -28, 0, 24)
	selectBg.Position = UDim2.fromOffset(14, 26)
	selectBg.ZIndex = 21
	AddCorner(selectBg, 10)
	AddStroke(selectBg, 1, THEME.StrokeSoft, 0.55)
	selectBg.Parent = row

	local glow = Instance.new("UIStroke")
	glow.Thickness = 2
	glow.Color = THEME.Primary
	glow.Transparency = 1
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.Parent = selectBg

	local valueLbl = MakeText(selectBg, "Select...", 12, "")
	valueLbl.TextColor3 = THEME.SubText
	valueLbl.ZIndex = 22
	valueLbl.Size = UDim2.new(1, -28, 1, 0)
	valueLbl.Position = UDim2.fromOffset(8, 0)
	valueLbl.TextWrapped = true
	valueLbl.TextTruncate = Enum.TextTruncate.AtEnd

	local arrow = MakeText(selectBg, "▲", 14, "bold")
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	arrow.ZIndex = 22
	arrow.Size = UDim2.fromOffset(22, 22)
	arrow.Position = UDim2.new(1, -22, 0.5, -11)
	arrow.Rotation = 180

	local click = MakeButtonBase(selectBg)
	click.ZIndex = 23
	click.Size = UDim2.fromScale(1, 1)
	BindHoverFX(click, selectBg)
	BindClickFX(click, selectBg)

	local BASE_H = ScalePx(54)
	local OPEN_GAP = ScalePx(10)

	local optionsHolder = Instance.new("Frame")
	optionsHolder.Name = "Options"
	optionsHolder.BackgroundColor3 = THEME.Panel
	optionsHolder.BackgroundTransparency = 0.08
	optionsHolder.BorderSizePixel = 0
	optionsHolder.Size = UDim2.new(1, -28, 0, 0)
	optionsHolder.Position = UDim2.fromOffset(14, 26 + 24 + ScalePx(6))
	optionsHolder.ZIndex = row.ZIndex + 10
	optionsHolder.ClipsDescendants = true
	AddCorner(optionsHolder, 12)
	AddStroke(optionsHolder, 1, THEME.StrokeSoft, 0.55)
	optionsHolder.Parent = row

	local optPad = Instance.new("UIPadding")
	optPad.PaddingTop = UDim.new(0, 8)
	optPad.PaddingBottom = UDim.new(0, 8)
	optPad.PaddingLeft = UDim.new(0, 8)
	optPad.PaddingRight = UDim.new(0, 8)
	optPad.Parent = optionsHolder

	local optList = Instance.new("UIListLayout")
	optList.SortOrder = Enum.SortOrder.LayoutOrder
	optList.Padding = UDim.new(0, 8)
	optList.Parent = optionsHolder

	local opened = false
	local openToken = 0

	local function refreshValueText()
		if #selected == 0 then
			valueLbl.Text = "Select..."
			valueLbl.TextColor3 = THEME.SubText
			return
		end
		valueLbl.Text = table.concat(selected, ", ")
		valueLbl.TextColor3 = THEME.Text
	end

	local function persistAndCallback()
		self._UIState[persistKey] = selected
		task.spawn(function()
			pcall(cb, selected)
		end)
	end

	local function setOpen(state)
		openToken += 1
		local token = openToken
		opened = state == true
		Tween(arrow, {Rotation = opened and 0 or 180}, 0.35)
		Tween(glow, {Transparency = opened and 0.35 or 1}, 0.22)
		local contentH = optList.AbsoluteContentSize.Y
		local h = opened and (contentH + optPad.PaddingTop.Offset + optPad.PaddingBottom.Offset + 4) or 0
		Tween(optionsHolder, {Size = UDim2.new(1, -28, 0, h)}, 0.22)
		Tween(row, {Size = UDim2.new(1, 0, 0, BASE_H + (opened and (h + OPEN_GAP) or 0))}, 0.22)

		if not opened then
			task.delay(0.23, function()
				if token ~= openToken then return end
				optionsHolder.Size = UDim2.new(1, -28, 0, 0)
				row.Size = UDim2.new(1, 0, 0, BASE_H)
			end)
		end
	end

	local function rebuild()
		if not optionsHolder or not optionsHolder.Parent then return end

		for _, ch in ipairs(optionsHolder:GetChildren()) do
			if ch:IsA("GuiObject") and not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then
				ch:Destroy()
			end
		end

		if type(list) ~= "table" or #list == 0 then
			list = {}
		end

		for i, item in ipairs(list) do
			local s = tostring(item)
			local optRow = Instance.new("Frame")
			optRow.Name = "Option_" .. tostring(i)
			optRow.BackgroundColor3 = THEME.Panel
			optRow.BackgroundTransparency = 0.12
			optRow.BorderSizePixel = 0
			optRow.Size = UDim2.new(1, 0, 0, ScalePx(34))
			optRow.ZIndex = optionsHolder.ZIndex + 1
			AddCorner(optRow, 10)
			AddStroke(optRow, 1, THEME.StrokeSoft, 0.55)
			optRow.Parent = optionsHolder

			local optBtn = MakeButtonBase(optRow)
			optBtn.ZIndex = optRow.ZIndex + 1
			optBtn.Size = UDim2.fromScale(1, 1)
			BindHoverFX(optBtn, optRow)
			BindClickFX(optBtn, optRow)

			local check = MakeText(optRow, "○", 14, "bold")
			check.ZIndex = optBtn.ZIndex + 1
			check.TextXAlignment = Enum.TextXAlignment.Center
			check.Size = UDim2.fromOffset(18, 18)
			check.Position = UDim2.fromOffset(6, ScalePx(8))

			local t = MakeText(optRow, s, 12, "")
			t.ZIndex = optBtn.ZIndex + 1
			t.Size = UDim2.new(1, -34, 1, 0)
			t.Position = UDim2.fromOffset(28, 0)

			local function renderOption()
				local on = selectedSet[s] == true
				check.Text = on and "●" or "○"
				check.TextColor3 = on and THEME.Primary or THEME.SubText
			end
			renderOption()

			optBtn.MouseButton1Click:Connect(function()
				if selectedSet[s] then
					selectedSet[s] = nil
					for idx = #selected, 1, -1 do
						if selected[idx] == s then
							table.remove(selected, idx)
						end
					end
				else
					selectedSet[s] = true
					table.insert(selected, s)
				end
				renderOption()
				refreshValueText()
				persistAndCallback()
			end)
		end

		refreshValueText()
	end

	rebuild()
	refreshValueText()
	persistAndCallback()

	optList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if opened then
			local contentH = optList.AbsoluteContentSize.Y
			local h = contentH + optPad.PaddingTop.Offset + optPad.PaddingBottom.Offset + 4
			Tween(optionsHolder, {Size = UDim2.new(1, -28, 0, h)}, 0.18)
			Tween(row, {Size = UDim2.new(1, 0, 0, BASE_H + h + OPEN_GAP)}, 0.18)
		end
	end)

	click.MouseButton1Click:Connect(function()
		setOpen(not opened)
	end)

	local api = {}
	api.Frame = row
	api.Get = function() return selected end
	api.Set = function(a, b)
		local v = (b == nil) and a or b
		setSelected(v)
		rebuild()
		refreshValueText()
		persistAndCallback()
	end
	api.Refresh = function(a, b)
		local newList = b
		if b == nil then
			newList = a
		end
		if type(newList) == "table" then
			list = newList
		end
		rebuild()
		if opened then
			setOpen(true)
		end
	end

	self._Controls[persistKey] = api
	rebuild()
	refreshValueText()
	self:_YieldBuild()
	return api
end

function UI:CreateConfigDropdown(parent, config)
	config = config or {}
	local name = config.Name or "Select Config"
	local list = config.List or {}
	local cb = config.Callback or function() end

	local row = Instance.new("Frame")
	row.Name = "ConfigDropdown"
	row.BackgroundColor3 = THEME.Panel2
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, ScalePx(54))
	row.ZIndex = 20
	row.ClipsDescendants = true
	AddCorner(row, 14)
	AddStroke(row, 1, THEME.StrokeSoft, 0.5)
	row.Parent = parent

	local lbl = MakeText(row, name, 13, "semibold")
	lbl.ZIndex = 22
	lbl.Size = UDim2.new(1, -120, 0, 18)
	lbl.Position = UDim2.fromOffset(14, 8)

	local selectBg = Instance.new("Frame")
	selectBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	selectBg.BackgroundTransparency = 0.92
	selectBg.BorderSizePixel = 0
	selectBg.Size = UDim2.new(1, -28, 0, 24)
	selectBg.Position = UDim2.fromOffset(14, 26)
	selectBg.ZIndex = 21
	AddCorner(selectBg, 10)
	AddStroke(selectBg, 1, THEME.StrokeSoft, 0.55)
	selectBg.Parent = row

	local valueLbl = MakeText(selectBg, "Select...", 12, "")
	valueLbl.TextColor3 = THEME.SubText
	valueLbl.ZIndex = 22
	valueLbl.Size = UDim2.new(1, -28, 1, 0)
	valueLbl.Position = UDim2.fromOffset(8, 0)

	local arrow = MakeText(selectBg, "▲", 14, "bold")
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	arrow.ZIndex = 22
	arrow.Size = UDim2.fromOffset(22, 22)
	arrow.Position = UDim2.new(1, -22, 0.5, -11)
	arrow.Rotation = 180

	local click = MakeButtonBase(selectBg)
	click.ZIndex = 23
	click.Size = UDim2.fromScale(1, 1)
	BindHoverFX(click, selectBg)
	BindClickFX(click, selectBg)

	local BASE_H = ScalePx(54)
	local OPEN_GAP = ScalePx(10)

	local optionsHolder = Instance.new("Frame")
	optionsHolder.Name = "Options"
	optionsHolder.BackgroundColor3 = THEME.Panel
	optionsHolder.BackgroundTransparency = 0.08
	optionsHolder.BorderSizePixel = 0
	optionsHolder.Size = UDim2.new(1, -28, 0, 0)
	optionsHolder.Position = UDim2.fromOffset(14, 26 + 24 + ScalePx(6))
	optionsHolder.ZIndex = row.ZIndex + 10
	optionsHolder.ClipsDescendants = true
	AddCorner(optionsHolder, 12)
	AddStroke(optionsHolder, 1, THEME.StrokeSoft, 0.55)
	optionsHolder.Parent = row

	local optPad = Instance.new("UIPadding")
	optPad.PaddingTop = UDim.new(0, 8)
	optPad.PaddingBottom = UDim.new(0, 8)
	optPad.PaddingLeft = UDim.new(0, 8)
	optPad.PaddingRight = UDim.new(0, 8)
	optPad.Parent = optionsHolder

	local optList = Instance.new("UIListLayout")
	optList.SortOrder = Enum.SortOrder.LayoutOrder
	optList.Padding = UDim.new(0, 8)
	optList.Parent = optionsHolder

	local opened = false
	local value = ""
	local openToken = 0

	local function setOpen(state)
		openToken += 1
		local token = openToken
		opened = state == true
		Tween(arrow, {Rotation = opened and 0 or 180}, 0.35)
		
		local function updateSizes()
			local contentH = optList.AbsoluteContentSize.Y
			local h = opened and (contentH + optPad.PaddingTop.Offset + optPad.PaddingBottom.Offset + 4) or 0
			Tween(optionsHolder, {Size = UDim2.new(1, -28, 0, h)}, 0.22)
			Tween(row, {Size = UDim2.new(1, 0, 0, BASE_H + (opened and (h + OPEN_GAP) or 0))}, 0.22)
		end
		
		updateSizes()

		if not opened then
			task.delay(0.23, function()
				if token ~= openToken then return end
				optionsHolder.Size = UDim2.new(1, -28, 0, 0)
				row.Size = UDim2.new(1, 0, 0, BASE_H)
			end)
		end
	end

	optList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if opened then
			local contentH = optList.AbsoluteContentSize.Y
			local h = contentH + optPad.PaddingTop.Offset + optPad.PaddingBottom.Offset + 4
			Tween(optionsHolder, {Size = UDim2.new(1, -28, 0, h)}, 0.18)
			Tween(row, {Size = UDim2.new(1, 0, 0, BASE_H + h + OPEN_GAP)}, 0.18)
		end
	end)

	local function rebuild()
		if not optionsHolder or not optionsHolder.Parent then return end
		
		for _, ch in ipairs(optionsHolder:GetChildren()) do
			if ch:IsA("GuiObject") and not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then 
				ch:Destroy() 
			end
		end
		
		local itemCount = 0
		if type(list) == "table" and #list > 0 then
			for i, item in ipairs(list) do
				itemCount = itemCount + 1
				local optRow = Instance.new("Frame")
				optRow.Name = "Option_" .. tostring(i)
				optRow.BackgroundColor3 = THEME.Panel
				optRow.BackgroundTransparency = 0.12
				optRow.BorderSizePixel = 0
				optRow.Size = UDim2.new(1, 0, 0, ScalePx(34))
				optRow.ZIndex = optionsHolder.ZIndex + 1
				AddCorner(optRow, 10)
				AddStroke(optRow, 1, THEME.StrokeSoft, 0.55)
				optRow.Parent = optionsHolder

				local optBtn = MakeButtonBase(optRow)
				optBtn.ZIndex = optRow.ZIndex + 1
				optBtn.Size = UDim2.fromScale(1, 1)
				BindHoverFX(optBtn, optRow)
				BindClickFX(optBtn, optRow)

				local t = MakeText(optRow, tostring(item), 12, "")
				t.ZIndex = optBtn.ZIndex + 1
				t.Size = UDim2.new(1, -18, 1, 0)
				t.Position = UDim2.fromOffset(10, 0)
t.Parent = optRow

				optBtn.MouseButton1Click:Connect(function()
					value = item
					valueLbl.Text = tostring(item)
					valueLbl.TextColor3 = THEME.Text
					task.spawn(function()
						pcall(cb, value)
					end)
					setOpen(false)
				end)
			end
		else
			itemCount = 1
			local optRow = Instance.new("Frame")
			optRow.Name = "NoConfigs"
			optRow.BackgroundTransparency = 1
			optRow.Size = UDim2.new(1, 0, 0, ScalePx(34))
			optRow.Parent = optionsHolder
			
			local t = MakeText(optRow, "No configs found", 12, "")
			t.TextColor3 = THEME.SubText
			t.TextXAlignment = Enum.TextXAlignment.Center
			t.Size = UDim2.fromScale(1, 1)
			t.Parent = optRow
		end
		
		optList:ApplyLayout()
		
		task.wait()
		local contentH = optList.AbsoluteContentSize.Y
		if opened then
			local h = (itemCount > 0) and (contentH + optPad.PaddingTop.Offset + optPad.PaddingBottom.Offset + 4) or 0
			optionsHolder.Size = UDim2.new(1, -28, 0, h)
			row.Size = UDim2.new(1, 0, 0, BASE_H + (h > 0 and (h + OPEN_GAP) or 0))
		end
	end

	rebuild()

	click.MouseButton1Click:Connect(function()
		setOpen(not opened)
	end)

	local api = {}
	api.Refresh = function(a, b)
		local newList = b
		if b == nil then
			newList = a
		end
		list = (type(newList) == "table") and newList or {}
		rebuild()
	end
	api.Set = function(a, b)
		local v = b
		if b == nil then
			v = a
		end
		value = tostring(v or "")
		valueLbl.Text = (value ~= "") and value or "Select..."
		valueLbl.TextColor3 = (value ~= "") and THEME.Text or THEME.SubText
	end
	self:_YieldBuild()
	return api
end

function UI:CreateTab(tabInfo)
	tabInfo = tabInfo or {}
	local name = tabInfo.Name or "Tab"
	local icon = tabInfo.Icon

	local tabButton = Instance.new("Frame")
	tabButton.Name = "TabButton"
	tabButton.BackgroundTransparency = 1
	pcall(function()
		tabButton:SetAttribute("UH_TabName", tostring(name))
	end)
	if IS_MOBILE then
		tabButton.Size = UDim2.new(1, -12, 0, 44)
	else
		tabButton.Size = UDim2.new(1, -12, 0, 36)
	end
	tabButton.ZIndex = 30
	tabButton.Parent = self._TabsHolder

	local surface = Instance.new("Frame")
	surface.Name = "Surface"
	surface.BackgroundColor3 = THEME.Surface
	surface.BackgroundTransparency = 1
	surface.BorderSizePixel = 0
	surface.Size = UDim2.fromScale(1, 1)
	surface.ZIndex = 31
	AddCorner(surface, 14)
	surface.Parent = tabButton

	local b = MakeButtonBase(surface)
	b.ZIndex = 33
	b.Size = UDim2.fromScale(1, 1)
	BindClickFX(b, surface)

	local iconLabel
	if icon then
		iconLabel = Instance.new("ImageLabel")
		iconLabel.Name = "Icon"
		iconLabel.BackgroundTransparency = 1
		iconLabel.Image = icon
		iconLabel.ImageColor3 = THEME.SubText
		if IS_MOBILE then
			iconLabel.Size = UDim2.fromOffset(20, 20)
			iconLabel.Position = UDim2.new(0, 12, 0.5, 0)
		else
			iconLabel.Size = UDim2.fromOffset(18, 18)
			iconLabel.Position = UDim2.new(0, 10, 0.5, 0)
		end
		iconLabel.AnchorPoint = Vector2.new(0, 0.5)
		iconLabel.ZIndex = 34
		iconLabel.Parent = surface
	end

	local textLbl = MakeText(surface, name, IS_MOBILE and 13 or 12, "semibold")
	textLbl.ZIndex = 34
	if IS_MOBILE then
		textLbl.Size = UDim2.new(1, icon and -48 or -42, 1, 0)
		textLbl.Position = UDim2.fromOffset(icon and 40 or 26, 0)
	else
		textLbl.Size = UDim2.new(1, icon and -44 or -38, 1, 0)
		textLbl.Position = UDim2.fromOffset(icon and 36 or 22, 0)
	end
	textLbl.TextXAlignment = Enum.TextXAlignment.Left

	local page = Instance.new("ScrollingFrame")
	page.Name = name .. "Page"
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 0
	page.ScrollBarImageTransparency = 1
	page.ScrollingEnabled = false
	page.ScrollingDirection = Enum.ScrollingDirection.Y
	page.ElasticBehavior = Enum.ElasticBehavior.Never
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Size = UDim2.fromScale(1, 1)
	page.Visible = false
	page.ZIndex = 50
	pcall(function()
		page:SetAttribute("UH_TabName", tostring(name))
	end)
	page.Parent = self._Pages

	local pagePad = Instance.new("UIPadding")
	pagePad.PaddingTop = UDim.new(0, 14)
	pagePad.PaddingBottom = UDim.new(0, 14)
	pagePad.PaddingLeft = UDim.new(0, 4)
	pagePad.PaddingRight = UDim.new(0, 4)
	pagePad.Parent = page

	local columnsWrap = Instance.new("Frame")
	columnsWrap.Name = "Columns"
	columnsWrap.BackgroundTransparency = 1
	columnsWrap.Size = UDim2.new(1, 0, 1, 0)
	columnsWrap.Position = UDim2.fromOffset(0, 0)
	columnsWrap.ZIndex = 51
	columnsWrap.Parent = page

	local colGap = 12
	local col1 = Instance.new("ScrollingFrame")
	col1.Name = "Col1"
	col1.BackgroundTransparency = 1
	col1.BorderSizePixel = 0
	col1.ScrollBarThickness = 2
	col1.ScrollBarImageColor3 = THEME.Primary
	col1.ScrollBarImageTransparency = 0.45
	col1.ScrollingDirection = Enum.ScrollingDirection.Y
	col1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	col1.CanvasSize = UDim2.new(0, 0, 0, 0)
	col1.Size = UDim2.new(0.5, -math.floor(colGap/2), 1, 0)
	col1.Position = UDim2.new(0, 0, 0, 0)
	col1.ZIndex = 52
	col1.Parent = columnsWrap

	local col2 = Instance.new("ScrollingFrame")
	col2.Name = "Col2"
	col2.BackgroundTransparency = 1
	col2.BorderSizePixel = 0
	col2.ScrollBarThickness = 2
	col2.ScrollBarImageColor3 = THEME.Primary
	col2.ScrollBarImageTransparency = 0.45
	col2.ScrollingDirection = Enum.ScrollingDirection.Y
	col2.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	col2.CanvasSize = UDim2.new(0, 0, 0, 0)
	col2.Size = UDim2.new(0.5, -math.floor(colGap/2), 1, 0)
	col2.Position = UDim2.new(0.5, math.floor(colGap/2), 0, 0)
	col2.ZIndex = 52
	col2.Parent = columnsWrap

	local l1 = Instance.new("UIListLayout")
	l1.SortOrder = Enum.SortOrder.LayoutOrder
	l1.Padding = UDim.new(0, 8)
	l1.Parent = col1

	local l2 = Instance.new("UIListLayout")
	l2.SortOrder = Enum.SortOrder.LayoutOrder
	l2.Padding = UDim.new(0, 8)
	l2.Parent = col2

	AutoCanvas(col1, l1)
	AutoCanvas(col2, l2)

	local function updateColumns()
		local padL = pagePad.PaddingLeft.Offset
		local padR = pagePad.PaddingRight.Offset
		local w = math.max(0, page.AbsoluteSize.X - padL - padR)
		if IS_MOBILE then
			col1.Size = UDim2.new(0, w, 1, 0)
			col2.Visible = false
			col2.ScrollingEnabled = false
		else
			local half = math.floor((w - colGap) / 2)
			col1.Size = UDim2.new(0, half, 1, 0)
			col2.Size = UDim2.new(0, half, 1, 0)
			col2.Position = UDim2.new(0, half + colGap, 0, 0)
			col2.Visible = true
			col2.ScrollingEnabled = true
		end
	end

	page:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateColumns)
	updateColumns()

	local TabAPI = {}
	TabAPI.Name = name
	TabAPI._FullName = name
	TabAPI.Button = tabButton
	TabAPI.Surface = surface
	TabAPI.Page = page
	TabAPI._ColumnsWrap = columnsWrap
	TabAPI._Col1 = col1
	TabAPI._Col2 = col2
	TabAPI._ColIndex = 0
	TabAPI._Button = b
	TabAPI._Text = textLbl
	TabAPI._ActiveGlow = nil
	TabAPI._Active = false

	function TabAPI:CreateSection(title)
		self._ColIndex += 1
		local parentCol = IS_MOBILE and self._Col1 or ((self._ColIndex % 2 == 1) and self._Col1 or self._Col2)
		return UI:CreateSection(parentCol, title)
	end

	function TabAPI:CreateLockedSection(title)
		self._ColIndex += 1
		local parentCol = IS_MOBILE and self._Col1 or ((self._ColIndex % 2 == 1) and self._Col1 or self._Col2)
		return UI:CreateLockedSection(parentCol, title)
	end

	local function setActiveVisual(active)
		TabAPI._Active = active
		Tween(surface, {BackgroundTransparency = active and 0.80 or 1}, 0.22)
		Tween(textLbl, {TextColor3 = active and THEME.Text or THEME.SubText}, 0.22)
		if iconLabel then
			Tween(iconLabel, {ImageColor3 = active and THEME.Primary or THEME.SubText}, 0.22)
		end
	end

	TabAPI._SetActiveVisual = setActiveVisual

	self:_YieldBuild()

	b.MouseEnter:Connect(function()
		if TabAPI._Active then
			Tween(surface, {BackgroundTransparency = 0.75}, 0.18)
		else
			Tween(surface, {BackgroundTransparency = 0.90}, 0.18)
		end
	end)
	b.MouseLeave:Connect(function()
		Tween(surface, {BackgroundTransparency = TabAPI._Active and 0.80 or 1}, 0.18)
	end)

	b.MouseButton1Click:Connect(function()
		UI:SelectTab(name)
	end)

	Tabs[name] = TabAPI
	self:_YieldBuild()
	return TabAPI
end

function UI:SelectTab(name)
	if not self._Alive then return end
	if self._CurrentTab == name then return end
	self._TabSwitchToken += 1
	local token = self._TabSwitchToken

	local prev = self._CurrentTab and Tabs[self._CurrentTab]
	local nextTab = Tabs[name]
	if not nextTab then return end

	self._CurrentTab = name
	for _, t in pairs(Tabs) do
		if t.Page then
			t.Page.Visible = false
		end
	end

	if prev then
		prev._SetActiveVisual(false)
		if prev.Page.Visible then
			local old = prev.Page
			local sc = old:FindFirstChildOfClass("UIScale")
			if not sc then sc = Instance.new("UIScale") sc.Parent = old end
			Tween(sc, {Scale = 0.985}, 0.20)
			Tween(old, {ScrollBarImageTransparency = 0.8}, 0.20)
			task.delay(0.18, function()
				if token ~= UI._TabSwitchToken then return end
				if sc then sc.Scale = 1 end
				if sc then sc.Scale = 1 end
			end)
		end
	end

	nextTab._SetActiveVisual(true)
	nextTab.Page.Visible = true
	local sc2 = nextTab.Page:FindFirstChildOfClass("UIScale")
	if not sc2 then sc2 = Instance.new("UIScale") sc2.Parent = nextTab.Page end
	sc2.Scale = 0.985
	Tween(sc2, {Scale = 1}, 0.28)
	Tween(nextTab.Page, {ScrollBarImageTransparency = 0.45}, 0.25)
end

function UI:SetSidebarCollapsed(collapsed)
	return
end

function UI:SetOpen(state)
	if not self._Alive then return end
	local open = state == true
	if self._Open == open then return end
	self._Open = open

	local root = self._Main
	local container = self._Container
	local shade = self._Shade
	local cg = container

	if self._MaximizeButton then
		self._MaximizeButton.Visible = not open
	end

	local fadeTime = self._Settings and self._Settings.FadeSpeed or 0.35

	if open then
		if shade then shade.Visible = false end
		if container then container.Visible = true end
		root.Visible = true
		if cg then
			cg.GroupTransparency = 1
			Tween(cg, {GroupTransparency = 0}, fadeTime)
		end
	else
		if shade then shade.Visible = false end
		if cg then
			Tween(cg, {GroupTransparency = 1}, fadeTime * 0.85)
		end
		task.delay(fadeTime + 0.02, function()
			if not self._Open and root then
				root.Visible = false
				if container then container.Visible = false end
			end
		end)
	end
end

function UI:Unload()
	if self._Alive == false then
		pcall(function()
			if self.ScreenGui then
				self.ScreenGui:Destroy()
			end
		end)
		self.ScreenGui = nil
		return
	end

	self._Alive = false
	self._Open = false
	pcall(function()
		self._TabSwitchToken += 1
		self._SearchToken += 1
	end)

	pcall(function()
		if self.ScreenGui then
			self.ScreenGui:Destroy()
		end
	end)

	self.ScreenGui = nil
	self._Shade = nil
	self._Container = nil
	self._Main = nil
	self._Sidebar = nil
	self._Right = nil
	self._RightSurface = nil
	self._TabsHolder = nil
	table.clear(self._Pages or {})
	self._Pages = nil
	self._NotifyStacks = nil
	self._NotifyStack = nil
	self._SearchBox = nil
	self._CurrentTab = nil
	self._MaximizeButton = nil

	pcall(function()
		if _G and _G.UnifiedUI == self then
			_G.UnifiedUI = nil
		end
	end)
end

function UI:CreateWindow(config)
	local windowTitle = "Unified.wtf | UI | dsc.gg/unifiedhub"
	if type(config) == "table" and type(config.Title) == "string" then
		windowTitle = config.Title
	end

	if type(config) == "table" then
		if config.ProgressiveBuild ~= nil then
			self._ProgressiveBuild = (config.ProgressiveBuild == true)
		end
		if config.BuildYieldSteps ~= nil then
			self._BuildYieldSteps = tonumber(config.BuildYieldSteps) or self._BuildYieldSteps
		end
		if config.BuildYieldSeconds ~= nil then
			self._BuildYieldSeconds = tonumber(config.BuildYieldSeconds)
			self._AutoBuildYieldSeconds = false
		end
		if config.AutoBuildYieldSeconds ~= nil then
			self._AutoBuildYieldSeconds = (config.AutoBuildYieldSeconds == true)
		end
	end

	local sg = Instance.new("ScreenGui")
	sg.Name = "UnifiedHub"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	pcall(ProtectGui, sg)
	sg.Parent = GetUIParent()
	self:_YieldBuild()

	local shade = Instance.new("Frame")
	shade.Name = "Shade"
	shade.BackgroundColor3 = Color3.new(0, 0, 0)
	shade.BackgroundTransparency = 1
	shade.Size = UDim2.fromScale(1, 1)
	shade.ZIndex = 1
	shade.Parent = sg

	local bgEffect = Instance.new("Frame")
	bgEffect.Name = "BackgroundEffect"
	bgEffect.BackgroundTransparency = 1
	bgEffect.Size = UDim2.fromScale(1, 1)
	bgEffect.ZIndex = -10 -- Force to very bottom
	bgEffect.ClipsDescendants = true
	bgEffect.Parent = sg

	local function CreateGlowShape(pos, size, color)
		local g = Instance.new("ImageLabel")
		g.Name = "GlowShape"
		g.BackgroundTransparency = 1
		g.Image = "rbxassetid://6015667320"
		g.ImageColor3 = color
		g.ImageTransparency = 0.2 -- Much more visible
		g.Position = pos
		g.Size = size
		g.ZIndex = -10
		g.Parent = bgEffect

		task.spawn(function()
			while g and g.Parent do
				local targetPos = UDim2.new(
					pos.X.Scale + math.random(-35, 35)/100, pos.X.Offset + math.random(-150, 150),
					pos.Y.Scale + math.random(-35, 35)/100, pos.Y.Offset + math.random(-150, 150)
				)
				local t = Tween(g, {
					Position = targetPos, 
					ImageTransparency = 0.15 + math.random(0, 30)/100,
					Size = UDim2.fromOffset(size.X.Offset + math.random(-80, 80), size.Y.Offset + math.random(-80, 80))
				}, math.random(10, 20))
				t.Completed:Wait()
			end
		end)
	end

	CreateGlowShape(UDim2.new(0.1, 0, 0.2, 0), UDim2.fromOffset(400, 400), THEME.Primary)
	CreateGlowShape(UDim2.new(0.8, 0, 0.7, 0), UDim2.fromOffset(500, 500), THEME.Primary)
	CreateGlowShape(UDim2.new(0.4, 0, 0.5, 0), UDim2.fromOffset(300, 300), THEME.Panel2)

	local function updateBackgroundGlow()
		bgEffect:ClearAllChildren()
		CreateGlowShape(UDim2.new(0.1, 0, 0.2, 0), UDim2.fromOffset(400, 400), THEME.Primary)
		CreateGlowShape(UDim2.new(0.8, 0, 0.7, 0), UDim2.fromOffset(500, 500), THEME.Primary)
		CreateGlowShape(UDim2.new(0.4, 0, 0.5, 0), UDim2.fromOffset(300, 300), THEME.Panel2)
	end

	local container = Instance.new("CanvasGroup")
	container.Name = "Container"
	container.BackgroundTransparency = 1
	container.Size = UDim2.fromScale(1, 1)
	container.Position = UDim2.fromScale(0, 0)
	container.ZIndex = 2
	container.GroupTransparency = 0
	container.Visible = true
	container.Parent = sg
	self:_YieldBuild()

	local maximizeBtn = nil
	local isMobile = IS_MOBILE
	if isMobile then
		maximizeBtn = Instance.new("ImageButton")
		maximizeBtn.Name = "Maximize"
		maximizeBtn.BackgroundTransparency = 1
		maximizeBtn.AutoButtonColor = false
		maximizeBtn.Image = "rbxassetid://78764031032098"
		maximizeBtn.ImageTransparency = 0
		maximizeBtn.ScaleType = Enum.ScaleType.Fit
		maximizeBtn.ClipsDescendants = true
		maximizeBtn.AnchorPoint = Vector2.new(1, 1)
		maximizeBtn.Position = UDim2.new(1, -14, 1, -14)
		maximizeBtn.Size = UDim2.fromOffset(46, 46)
		maximizeBtn.ZIndex = 9999
		maximizeBtn.Visible = false
		AddCorner(maximizeBtn, 12)
		maximizeBtn.Parent = sg
		pcall(function()
			ContentProvider:PreloadAsync({maximizeBtn})
		end)
	end

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.BackgroundColor3 = THEME.Panel
	main.BackgroundTransparency = 0.10
	main.BorderSizePixel = 0
	main.Size = isMobile and UDim2.fromOffset(620, 420) or UDim2.fromOffset(800, 530)
	main.Position = isMobile and UDim2.new(0.5, -310, 0.5, -210) or UDim2.new(0.5, -400, 0.5, -265)
	main.ZIndex = 10
	main.Visible = true
	AddCorner(main, 12)
	AddGradient(main, THEME.Panel2, THEME.Panel, 90)
	AddShadow(main, 9)
	main.Parent = container
	self:_YieldBuild()

	local mainScale = Instance.new("UIScale")
	mainScale.Scale = isMobile and 0.80 or 1
	mainScale.Parent = main

	local top = Instance.new("Frame")
	top.Name = "Top"
	top.BackgroundTransparency = 1
	top.Size = UDim2.new(1, 0, 0, 56)
	top.Position = UDim2.fromOffset(0, 0)
	top.ZIndex = 11
	top.Parent = main

	local titleWrap = Instance.new("Frame")
	titleWrap.BackgroundTransparency = 1
	titleWrap.Size = UDim2.new(1, -24, 1, 0)
	titleWrap.Position = UDim2.fromOffset(12, 0)
	titleWrap.ZIndex = 12
	titleWrap.Parent = top

	local title = MakeText(titleWrap, windowTitle, 16, "bold")
	title.ZIndex = 13
	title.Size = UDim2.new(1, -140, 1, 0)
	title.Position = UDim2.fromOffset(0, 0)

	local controls = Instance.new("Frame")
	controls.Name = "Controls"
	controls.BackgroundTransparency = 1
	controls.Size = UDim2.fromOffset(86, 34)
	controls.Position = UDim2.new(1, -80, 0.5, -17)
	controls.ZIndex = 14
	controls.Parent = titleWrap

	local function makeTopButton(xPos, glyph)
		local btn = MakeButtonBase(controls)
		btn.ZIndex = 15
		btn.Size = UDim2.fromOffset(34, 34)
		btn.Position = UDim2.fromOffset(xPos, 0)
		local bg = Instance.new("Frame")
		bg.BackgroundColor3 = THEME.Surface
		bg.BackgroundTransparency = 1
		bg.BorderSizePixel = 0
		bg.Size = UDim2.fromScale(1, 1)
		bg.ZIndex = 15
		AddCorner(bg, 12)
		bg.Parent = btn
		local t = MakeText(bg, glyph, 15, "bold")
		t.TextXAlignment = Enum.TextXAlignment.Center
		t.Size = UDim2.fromScale(1, 1)
		t.ZIndex = 16
		t.TextColor3 = THEME.Primary
		t.Font = Enum.Font.GothamBold
		BindHoverFX(btn, nil)
		BindClickFX(btn, bg)
		return btn, bg, t
	end

	local minimizeBtn, minBg, minText = makeTopButton(0, "–")
	local closeBtn = makeTopButton(42, "×")

	MakeDraggable(top, main)

	minimizeBtn.MouseButton1Click:Connect(function()
		self:Close()
	end)

	closeBtn.MouseButton1Click:Connect(function()
		pcall(function()
			self:Unload()
		end)
	end)

	if isMobile then
		local dragging = false
		local dragStart, startPos
		local moved = false

		minimizeBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				moved = false
				dragStart = input.Position
				startPos = minimizeBtn.Position
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
				local delta = input.Position - dragStart
				if delta.Magnitude > 5 then moved = true end
				minimizeBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
				dragging = false
				if not moved then
					local isVisible = container.GroupTransparency < 0.5
					Tween(container, {GroupTransparency = isVisible and 1 or 0}, 0.35)
					SetVisibleRecursive(container, not isVisible)
				end
			end
		end)
	end

	if maximizeBtn then
		local dragging = false
		local dragStart, startPos
		local moved = false

		maximizeBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				moved = false
				dragStart = input.Position
				startPos = maximizeBtn.Position
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
				local delta = input.Position - dragStart
				if delta.Magnitude > 5 then moved = true end
				maximizeBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
				dragging = false
				if not moved then
					self:SetOpen(true)
				end
			end
		end)
	end

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.Size = UDim2.new(1, 0, 1, -56)
	body.Position = UDim2.fromOffset(0, 56)
	body.ZIndex = 11
	body.Parent = main

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sidebar.BackgroundTransparency = 0.92
	sidebar.BorderSizePixel = 0
	sidebar.Size = UDim2.new(0, 180, 1, 0)
	sidebar.Position = UDim2.fromOffset(0, 0)
	sidebar.ZIndex = 12
	AddCorner(sidebar, 12)
	AddGradient(sidebar, Color3.fromRGB(20, 20, 30), Color3.fromRGB(14, 14, 20), 90)
	sidebar.Parent = body
	self:_YieldBuild()

	local sideDivider = Instance.new("Frame")
	sideDivider.Name = "SideDivider"
	sideDivider.BackgroundColor3 = THEME.StrokeSoft
	sideDivider.BackgroundTransparency = 0.55
	sideDivider.BorderSizePixel = 0
	sideDivider.Size = UDim2.new(0, 1, 1, 0)
	sideDivider.Position = UDim2.fromOffset(180, 0)
	sideDivider.ZIndex = 13
	sideDivider.Parent = body

	local sbInner = Instance.new("Frame")
	sbInner.BackgroundTransparency = 1
	sbInner.Size = UDim2.new(1, -12, 1, -12)
	sbInner.Position = UDim2.fromOffset(6, 6)
	sbInner.ZIndex = 13
	sbInner.Parent = sidebar

	local tabsHolder = Instance.new("ScrollingFrame")
	tabsHolder.Name = "Tabs"
	tabsHolder.BackgroundTransparency = 1
	tabsHolder.BorderSizePixel = 0
	tabsHolder.ScrollBarThickness = 2
	tabsHolder.ScrollBarImageColor3 = THEME.Primary
	tabsHolder.ScrollBarImageTransparency = 0.55
	tabsHolder.ScrollingDirection = Enum.ScrollingDirection.Y
	tabsHolder.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	tabsHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabsHolder.Size = UDim2.new(1, 0, 1, -8)
	tabsHolder.Position = UDim2.fromOffset(0, 8)
	tabsHolder.ZIndex = 14
	tabsHolder.ClipsDescendants = true
	tabsHolder.Parent = sbInner

	local tabsList = Instance.new("UIListLayout")
	tabsList.SortOrder = Enum.SortOrder.LayoutOrder
	tabsList.Padding = UDim.new(0, 10)
	tabsList.Parent = tabsHolder

	local tabsPad = Instance.new("UIPadding")
	tabsPad.PaddingLeft = UDim.new(0, 0)
	tabsPad.PaddingRight = UDim.new(0, 0)
	tabsPad.PaddingTop = UDim.new(0, 0)
	tabsPad.PaddingBottom = UDim.new(0, 10)
	tabsPad.Parent = tabsHolder

	AutoCanvas(tabsHolder, tabsList)

	local right = Instance.new("Frame")
	right.Name = "Right"
	right.BackgroundTransparency = 1
	right.Size = UDim2.new(1, -181, 1, 0)
	right.Position = UDim2.fromOffset(181, 0)
	right.ZIndex = 12
	right.Parent = body
	self:_YieldBuild()

	local rightSurface = Instance.new("Frame")
	rightSurface.Name = "Surface"
	rightSurface.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	rightSurface.BackgroundTransparency = 0.93
	rightSurface.BorderSizePixel = 0
	rightSurface.Size = UDim2.fromScale(1, 1)
	rightSurface.ZIndex = 12
	AddCorner(rightSurface, 12)
	AddStroke(rightSurface, 1, THEME.StrokeSoft, 0.45)
	AddGradient(rightSurface, THEME.Surface, THEME.Panel, 90)
	AddShadow(rightSurface, 11)
	rightSurface.Parent = right

	local rightHeader = Instance.new("Frame")
	rightHeader.Name = "Header"
	rightHeader.BackgroundTransparency = 1
	rightHeader.Size = UDim2.new(1, -12, 0, 48)
	rightHeader.Position = UDim2.fromOffset(6, 6)
	rightHeader.ZIndex = 13
	rightHeader.Parent = rightSurface

	local searchWrap = Instance.new("Frame")
	searchWrap.Name = "Search"
	searchWrap.BackgroundColor3 = THEME.Surface
	searchWrap.BackgroundTransparency = 0.10
	searchWrap.BorderSizePixel = 0
	searchWrap.Size = UDim2.new(1, 0, 1, 0)
	searchWrap.Position = UDim2.fromOffset(0, 0)
	searchWrap.ZIndex = 13
	AddCorner(searchWrap, 10)
	AddGradient(searchWrap, THEME.Surface, THEME.Panel, 90)
	searchWrap.Parent = rightHeader

	local searchIcon = Instance.new("ImageLabel")
	searchIcon.Name = "SearchIcon"
	searchIcon.BackgroundTransparency = 1
	searchIcon.Image = "rbxassetid://118685771787843"
	searchIcon.ImageColor3 = THEME.SubText
	searchIcon.ImageTransparency = 0
	searchIcon.ScaleType = Enum.ScaleType.Fit
	searchIcon.Size = UDim2.fromOffset(18, 18)
	searchIcon.Position = UDim2.new(0, 14, 0.5, 0)
	searchIcon.AnchorPoint = Vector2.new(0, 0.5)
	searchIcon.ZIndex = 14
	searchIcon.Parent = searchWrap

	local searchBox = Instance.new("TextBox")
	searchBox.BackgroundTransparency = 1
	searchBox.Text = ""
	searchBox.PlaceholderText = "Search.."
	searchBox.PlaceholderColor3 = THEME.SubText
	searchBox.TextColor3 = THEME.Text
	searchBox.TextSize = math.floor((12 * TEXT_SCALE) + 0.5)
	searchBox.Font = Enum.Font.Gotham
	searchBox.ClearTextOnFocus = false
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.Size = UDim2.new(1, -60, 1, 0)
	searchBox.Position = UDim2.fromOffset(40, 0)
	searchBox.ZIndex = 14
	searchBox.Parent = searchWrap

	local searchBtn = MakeButtonBase(searchWrap)
	searchBtn.ZIndex = 15
	searchBtn.Size = UDim2.fromScale(1, 1)
	BindHoverFX(searchBtn, searchWrap)
	BindClickFX(searchBtn, searchWrap)
	searchBtn.MouseButton1Click:Connect(function()
		searchBox:CaptureFocus()
	end)

	self._SearchBox = searchBox
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		if not self._Alive then return end
		self._SearchToken += 1
		local token = self._SearchToken
		task.delay(0.05, function()
			if not self._Alive then return end
			if token ~= self._SearchToken then return end
			pcall(function()
				self:_ApplySearch(searchBox.Text)
			end)
		end)
	end)

	local pages = Instance.new("Frame")
	pages.Name = "Pages"
	pages.BackgroundTransparency = 1
	pages.Size = UDim2.new(1, -12, 1, -66)
	pages.Position = UDim2.fromOffset(6, 60)
	pages.ZIndex = 13
	pages.Parent = rightSurface
	self:_YieldBuild()

	local function makeNotifyStack(name, anchorPoint, position, hAlign, vAlign, posKey)
		local st = Instance.new("Frame")
		st.Name = name
		st.BackgroundTransparency = 1
		st.Size = UDim2.fromOffset(360, 260)
		st.Position = position
		st.AnchorPoint = anchorPoint
		st.ZIndex = 200
		pcall(function()
			st:SetAttribute("UH_NotifyPos", posKey)
		end)
		st.Parent = sg

		local nList = Instance.new("UIListLayout")
		nList.SortOrder = Enum.SortOrder.LayoutOrder
		nList.Padding = UDim.new(0, 10)
		nList.HorizontalAlignment = hAlign
		nList.VerticalAlignment = vAlign
		nList.Parent = st

		return st
	end

	local notifyStacks = {
		TopLeft = makeNotifyStack("NotifyStackTopLeft", Vector2.new(0, 0), UDim2.new(0, 18, 0, 18), Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, "TopLeft"),
		BottomLeft = makeNotifyStack("NotifyStackBottomLeft", Vector2.new(0, 1), UDim2.new(0, 18, 1, -18), Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Bottom, "BottomLeft"),
		TopRight = makeNotifyStack("NotifyStackTopRight", Vector2.new(1, 0), UDim2.new(1, -18, 0, 18), Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Top, "TopRight"),
		BottomRight = makeNotifyStack("NotifyStackBottomRight", Vector2.new(1, 1), UDim2.new(1, -18, 1, -18), Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom, "BottomRight"),
	}

	self.ScreenGui = sg
	self._Shade = shade
	self._Container = container
	self._Main = main
	self._Sidebar = sidebar
	self._Right = right
	self._RightSurface = rightSurface
	self._TabsHolder = tabsHolder
	self._Pages = pages
	self._NotifyStacks = notifyStacks
	self._NotifyStack = nil
	pcall(function()
		local saved = (self._Settings and self._Settings.NotificationPosition) or "BottomRight"
		if type(self.SetNotificationPosition) == "function" then
			self:SetNotificationPosition(saved)
		else
			self._NotifyStack = notifyStacks[saved] or notifyStacks.BottomRight
		end
	end)
	pcall(function()
		if type(self._Settings) == "table" and type(self._Settings.Theme) == "string" and self._Settings.Theme ~= "" then
			self:SetTheme(self._Settings.Theme)
		end
	end)
	self._TitleText = nil
	self._TitleIcon = nil
	self._CollapseGlyph = nil
	self._MaximizeButton = maximizeBtn
	if maximizeBtn then
		maximizeBtn.MouseButton1Click:Connect(function()
			self:SetOpen(true)
		end)
	end

	function self:_UpdateRightLayout(anim)
		local w = 180
		local props = {Position = UDim2.fromOffset(w + 1, 0), Size = UDim2.new(1, -(w + 1), 1, 0)}
		if anim then
			Tween(right, props, 0.45)
		else
			right.Position = props.Position
			right.Size = props.Size
		end
	end

	container.GroupTransparency = 1
	Tween(container, {GroupTransparency = 0}, 0.55)

	self:_UpdateRightLayout(false)

	UserInputService.InputBegan:Connect(function(input, gpe)
		-- Mouse buttons often arrive as gameProcessed (camera/UI). Allow them.
		if gpe and not (input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.MouseButton2
			or input.UserInputType == Enum.UserInputType.MouseButton3) then
			return
		end
		if UserInputService:GetFocusedTextBox() then return end
		if not self._Alive then return end

		if UI._AwaitingKeybind then
			local kc = input.KeyCode
			if kc and kc ~= Enum.KeyCode.Unknown then
				UI._AwaitingKeybind = false
				UI._Settings.MinimizeKeyCode = kc
				if UI._KeybindLabel then
					UI._KeybindLabel.Text = "Minimize Keybind: " .. tostring(kc.Name)
				end
				pcall(function()
					UI:_SaveSettings()
				end)
			end
			return
		end

		if UI._AwaitingBind ~= nil then
			local pending = UI._AwaitingBind
			local kc = input.KeyCode
			local ut = input.UserInputType
			UI._AwaitingBind = nil
			if pending and type(pending.Set) == "function" then
				if kc == Enum.KeyCode.Escape then
					pcall(pending.Set, nil)
				elseif ut == Enum.UserInputType.MouseButton1 or ut == Enum.UserInputType.MouseButton2 or ut == Enum.UserInputType.MouseButton3 then
					pcall(pending.Set, ut)
				elseif kc and kc ~= Enum.KeyCode.Unknown then
					pcall(pending.Set, kc)
				end
			end
			pcall(function()
				if pending and pending.Glow then
					Tween(pending.Glow, {Transparency = 1}, 0.12)
				end
			end)
			return
		end

		if input.KeyCode == (self._Settings and self._Settings.MinimizeKeyCode) then
			self:Close()
			return
		end

		local binds = UI._BindControls
		if type(binds) == "table" then
			for _, api in pairs(binds) do
				if api and type(api._KeyCode) == "function" then
					local kc = api._KeyCode()
					if kc and ((kc.EnumType == Enum.KeyCode and input.KeyCode == kc) or (kc.EnumType == Enum.UserInputType and input.UserInputType == kc)) then
						if type(api.Trigger) == "function" then
							task.spawn(api.Trigger)
						end
					end
				end
			end
		end
	end)

	return self
end

if _G then
	_G.UnifiedUI = UI
end

if _G and _G.UNIFIED_UI_AUTOBOOT == true then
	UI:CreateWindow()
 
	UI:CreateTab({Name = "Home"})
	UI:SelectTab("Home")
 
 	UI._Settings.AutoLoadEnabled = false
 end

return UI
