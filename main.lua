local Library = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local function SafeExecute(f, ...)
    local s, e = pcall(f, ...)
    if not s then warn("[Unified UI Error]: " .. tostring(e)) end
    return s, e
end

local function ThrottledLoop(interval, f)
    task.spawn(function()
        while true do
            local start = tick()
            SafeExecute(f)
            local elapsed = tick() - start
            task.wait(math.max(interval - elapsed, 0.01))
            if elapsed > 0.1 then task.wait(0.1) end
        end
    end)
end

local function Tween(obj, info, goal)
    if not obj or not obj.Parent then return end
    return SafeExecute(function()
        local tween = TweenService:Create(obj, TweenInfo.new(info, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal)
        tween:Play()
        return tween
    end)
end

ThrottledLoop(30, function()
    if gcinfo then gcinfo() end
end)

local function RandomString(length)
    math.randomseed(os.clock() ^ 2)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local res = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        res = res .. string.sub(chars, rand, rand)
    end
    return res
end

local function GetInputLabel(key)
    local name = key.Name
    local mapping = {
        ["MouseButton1"] = "LMB",
        ["MouseButton2"] = "RMB",
        ["MouseButton3"] = "MOUSEWHEEL"
    }
    return mapping[name] or name:upper()
end

function Library:Rejoin()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

function Library:ServerHop()
    local Servers = {}
    local Success, Error = pcall(function()
        local Response = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
        for _, v in pairs(Response.data) do
            if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
                table.insert(Servers, v.id)
            end
        end
    end)
    
    if Success and #Servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, Servers[math.random(1, #Servers)], LocalPlayer)
    end
end

function Library:CreateWindow(options)
    if not game:IsLoaded() then
        repeat task.wait() until game:IsLoaded()
    end
    
    options = options or {}
    local windowTitle = options.Name or "UNIFIED"
    local accentColor = options.AccentColor or Color3.fromRGB(207, 165, 255)
    
    local UI = {
        CurrentTab = nil,
        OpenedElement = nil,
        Tabs = {},
        LoadQueue = 0,
        TabDebounce = false,
        Flags = {},
        DefaultFlags = {},
        FlagTypes = {},
        IgnoredFlags = {},
        Components = {},
        Folder = "Unified",
        ConfigFolder = "Unified/Configs",
        Colors = {
            Accent = accentColor,
            MainBackground = Color3.fromRGB(9, 8, 9),
            SidebarBackground = Color3.fromRGB(7, 7, 7),
            SectionBackground = Color3.fromRGB(7, 7, 7),
            ElementBackground = Color3.fromRGB(11, 10, 11),
            MainText = Color3.fromRGB(200, 200, 200),
            SubText = Color3.fromRGB(150, 150, 150)
        }
    }

    local function GetHoverColor(color)
        local h, s, v = Color3.toHSV(color)
        return Color3.fromHSV(h, s, v > 0.5 and v - 0.05 or v + 0.05)
    end

    local function CloneValue(value)
        if typeof(value) == "Color3" then
            return Color3.new(value.R, value.G, value.B)
        end

        if type(value) == "table" then
            local copy = {}
            for key, innerValue in pairs(value) do
                copy[key] = CloneValue(innerValue)
            end
            return copy
        end

        return value
    end

    local function SequentialLoad(obj, group)
        UI.LoadQueue = UI.LoadQueue + 1
        local delayTime = math.min(UI.LoadQueue * 0.05, 1)
        
        if obj:IsA("GuiObject") then
            obj.Visible = false
            task.delay(delayTime, function()
                SafeExecute(function()
                    obj.Visible = true
                    if group then
                        group.GroupTransparency = 1
                        Tween(group, 0.3, {GroupTransparency = 0})
                    else
                        local oldSize = obj.Size
                        obj.Size = UDim2.new(oldSize.X.Scale, oldSize.X.Offset, 0, 0)
                        Tween(obj, 0.3, {Size = oldSize})
                    end
                end)
            end)
        end
    end

    local function SetInitialFlag(flagName, value, flagType)
        UI.Flags[flagName] = CloneValue(value)
        if flagType then
            UI.FlagTypes[flagName] = flagType
        end
        if UI.DefaultFlags[flagName] == nil then
            UI.DefaultFlags[flagName] = {
                Value = CloneValue(value)
            }
        end
    end

    local function SerializeConfigValue(flagName, value)
        local flagType = UI.FlagTypes[flagName]

        if flagType == "colorpicker" and typeof(value) == "Color3" then
            return {
                Type = "Color3",
                Value = {value.R, value.G, value.B}
            }
        end

        if flagType == "multidropdown" and type(value) == "table" then
            return {
                Type = "MultiDropdown",
                Value = CloneValue(value)
            }
        end

        if flagType == "togglebind" and type(value) == "table" then
            return {
                Type = "ToggleBind",
                Value = CloneValue(value)
            }
        end

        if typeof(value) == "Color3" then
            return {
                Type = "Color3",
                Value = {value.R, value.G, value.B}
            }
        end

        return CloneValue(value)
    end

    local function DeserializeConfigValue(flagName, value)
        local flagType = UI.FlagTypes[flagName]

        if type(value) == "table" and value.Type and value.Value ~= nil then
            if value.Type == "Color3" and type(value.Value) == "table" and #value.Value == 3 then
                return Color3.new(unpack(value.Value))
            end

            if value.Type == "MultiDropdown" or value.Type == "ToggleBind" then
                return CloneValue(value.Value)
            end

            return CloneValue(value.Value)
        end

        if flagType == "colorpicker" and type(value) == "table" and #value == 3 and type(value[1]) == "number" then
            return Color3.new(unpack(value))
        end

        if (flagType == "multidropdown" or flagType == "togglebind") and type(value) == "table" then
            return CloneValue(value)
        end

        return value
    end

    local function ApplyFlagValue(flagName, value)
        if UI.Components and UI.Components[flagName] then
            pcall(function()
                UI.Components[flagName]:Update(CloneValue(value))
            end)
        else
            UI.Flags[flagName] = CloneValue(value)
        end
    end

    local function RestoreDefaultFlags()
        for flagName, data in pairs(UI.DefaultFlags) do
            if not UI.IgnoredFlags[flagName] then
                ApplyFlagValue(flagName, data.Value)
            end
        end
    end

    local function BuildConfigData(sourceTable)
        local config = {}
        for flag, value in pairs(sourceTable) do
            if not UI.IgnoredFlags[flag] then
                config[flag] = SerializeConfigValue(flag, value)
            end
        end
        return config
    end

    function UI:UpdateColor(type, color)
        if UI.Colors[type] then
            UI.Colors[type] = color
            
            if type == "Accent" then
                accentColor = color
                UI.TitleLabel.TextColor3 = color
                UI.AccentBar.BackgroundColor3 = color
                for _, tab in pairs(UI.Tabs) do
                    if UI.CurrentTab == tab then
                        tab.Button.BackgroundColor3 = color
                        if tab.Indicator then tab.Indicator.BackgroundColor3 = color end
                    end
                    if tab.Content then
                        tab.Content.ScrollBarImageColor3 = color
                    end
                    for _, section in pairs(tab.Sections) do
                        section.TitleLabel.TextColor3 = color
                        -- Update all elements accent color if needed
                    end
                end
            elseif type == "MainBackground" then
                UI.MainFrame.BackgroundColor3 = color
            elseif type == "SidebarBackground" then
                 UI.LeftPanel.BackgroundColor3 = color
             elseif type == "SectionBackground" then
                 for _, tab in pairs(UI.Tabs) do
                     for _, section in pairs(tab.Sections) do
                         section.Frame.BackgroundColor3 = color
                     end
                 end
             elseif type == "ElementBackground" then
                 for _, tab in pairs(UI.Tabs) do
                     for _, section in pairs(tab.Sections) do
                         for _, element in pairs(section.Elements) do
                             if element.Frame then
                                 element.Frame.BackgroundColor3 = color
                             end
                             if element.Box then
                                 element.Box.BackgroundColor3 = color
                             end
                             if element.Btn then
                                 element.Btn.BackgroundColor3 = color
                             end
                             if element.PickerFrame then
                                 element.PickerFrame.BackgroundColor3 = color
                             end
                             -- For dropdowns/multidropdowns options
                             if element.List then
                                 for _, opt in pairs(element.List:GetChildren()) do
                                     if opt:IsA("TextButton") then
                                         opt.BackgroundColor3 = color
                                     end
                                 end
                             end
                         end
                     end
                 end
             elseif type == "MainText" then
                -- This would require iterating through many elements
            end
        end
    end

    if isfolder and makefolder then
        if not isfolder(UI.Folder) then makefolder(UI.Folder) end
        if not isfolder(UI.ConfigFolder) then makefolder(UI.ConfigFolder) end
    end

    function UI:SetFlagIgnored(flagName, ignored)
        if flagName then
            UI.IgnoredFlags[flagName] = ignored and true or nil
        end
    end

    function UI:SaveConfig(name)
        if not name or name == "" or name == "No Configs" then return end
        local config = BuildConfigData(UI.Flags)
        local success, err = pcall(function()
            if writefile then
                if not isfolder(UI.ConfigFolder) then makefolder(UI.ConfigFolder) end
                writefile(UI.ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(config))
            end
        end)
        if not success then warn("UI Error (SaveConfig): " .. tostring(err)) end
    end

    function UI:SaveDefaultConfig()
        local configSource = {}
        for flag, data in pairs(UI.DefaultFlags) do
            configSource[flag] = CloneValue(data.Value)
        end

        local config = BuildConfigData(configSource)
        local success, err = pcall(function()
            if writefile then
                if not isfolder(UI.ConfigFolder) then makefolder(UI.ConfigFolder) end
                writefile(UI.ConfigFolder .. "/default.json", HttpService:JSONEncode(config))
            end
        end)
        if not success then warn("UI Error (SaveDefaultConfig): " .. tostring(err)) end
    end

    local function CreateDefaultConfig()
        task.spawn(function()
            task.wait(1)
            pcall(function()
                if writefile and isfile and not isfile(UI.ConfigFolder .. "/default.json") then
                    UI:SaveDefaultConfig()
                end
            end)
        end)
    end
    CreateDefaultConfig()

    function UI:LoadConfig(name)
        if not name or name == "" or name == "No Configs" then return end
        local path = UI.ConfigFolder .. "/" .. name .. ".json"
        
        local success, err = pcall(function()
            if name == "default" and next(UI.DefaultFlags) ~= nil then
                RestoreDefaultFlags()
                return
            end

            if isfile and readfile and isfile(path) then
                local decodeSuccess, config = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
                if decodeSuccess and type(config) == "table" then
                    RestoreDefaultFlags()
                    for flag, value in pairs(config) do
                        ApplyFlagValue(flag, DeserializeConfigValue(flag, value))
                    end
                end
            end
        end)
        if not success then warn("UI Error (LoadConfig): " .. tostring(err)) end
    end

    function UI:DeleteConfig(name)
        if not name or name == "" or name == "No Configs" then return end
        local success, err = pcall(function()
            if delfile and isfile and isfile(UI.ConfigFolder .. "/" .. name .. ".json") then
                delfile(UI.ConfigFolder .. "/" .. name .. ".json")
            end
        end)
        if not success then warn("UI Error (DeleteConfig): " .. tostring(err)) end
    end

    function UI:GetConfigs()
        local configs = {}
        local success, err = pcall(function()
            if listfiles and isfolder and isfolder(UI.ConfigFolder) then
                local files = listfiles(UI.ConfigFolder)
                if files then
                    for _, v in pairs(files) do
                        -- Robust extraction: handle paths, separators, and extensions
                        local name = v:match("([^/\\]+)%.json$") or v:match("([^/\\]+)$")
                        if name and name ~= "" then 
                            table.insert(configs, name) 
                        end
                    end
                end
            end
        end)
        if not success then warn("UI Error (GetConfigs): " .. tostring(err)) end
        if #configs == 0 then table.insert(configs, "No Configs") end
        return configs
    end

    function UI:SetFlag(flag, value)
        for _, tab in pairs(UI.Tabs) do
            for _, section in pairs(tab.Sections) do
                for _, element in pairs(section.Elements) do
                    if element.Flag == flag and element.Update then
                        element.Update(value)
                        return
                    end
                end
            end
        end
    end

    UI.ScreenGui = Instance.new("ScreenGui")
    UI.ScreenGui.Name = RandomString(16)
    UI.ScreenGui.ResetOnSpawn = false
    UI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local coreGui = game:GetService("CoreGui")
    if gethui then
        UI.ScreenGui.Parent = gethui()
    elseif coreGui:FindFirstChild("RobloxGui") then
        UI.ScreenGui.Parent = coreGui.RobloxGui
    else
        UI.ScreenGui.Parent = coreGui
    end

    UI.MainFrame = Instance.new("Frame")
    UI.MainFrame.Name = "MainFrame"
    UI.MainFrame.Parent = UI.ScreenGui
    UI.MainFrame.BackgroundColor3 = UI.Colors.MainBackground
    UI.MainFrame.BorderSizePixel = 0
    UI.MainFrame.Position = UDim2.new(0.5, -315, 0.5, -210)
    UI.MainFrame.Size = UDim2.new(0, 630, 0, 420)
    UI.MainFrame.ClipsDescendants = false
    UI.MainFrame.BackgroundTransparency = 0

    UI.AccentBar = Instance.new("Frame")
    UI.AccentBar.Name = "AccentBar"
    UI.AccentBar.Parent = UI.MainFrame
    UI.AccentBar.BackgroundColor3 = accentColor
    UI.AccentBar.BorderSizePixel = 0
    UI.AccentBar.Position = UDim2.new(1, 5, 0, 0)
    UI.AccentBar.Size = UDim2.new(0, 3, 1, 0)
    UI.AccentBar.Visible = true

    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 2)
    AccentCorner.Parent = UI.AccentBar

    local AccentStroke = Instance.new("UIStroke")
    AccentStroke.Color = Color3.fromRGB(34, 26, 40)
    AccentStroke.Thickness = 1
    AccentStroke.Parent = UI.AccentBar

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(34, 26, 40)
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0
    MainStroke.Parent = UI.MainFrame

    UI.LeftPanel = Instance.new("Frame")
    UI.LeftPanel.Name = "LeftPanel"
    UI.LeftPanel.Parent = UI.MainFrame
    UI.LeftPanel.BackgroundColor3 = UI.Colors.SidebarBackground
    UI.LeftPanel.BorderSizePixel = 0
    UI.LeftPanel.Size = UDim2.new(0, 180, 1, 0)
    UI.LeftPanel.BackgroundTransparency = 0

    local LeftStroke = Instance.new("UIStroke")
    LeftStroke.Color = Color3.fromRGB(34, 26, 40)
    LeftStroke.Thickness = 1.5
    LeftStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    LeftStroke.Transparency = 0
    LeftStroke.Parent = UI.LeftPanel

    UI.LogoContainer = Instance.new("Frame")
    UI.LogoContainer.Name = "LogoContainer"
    UI.LogoContainer.Parent = UI.LeftPanel
    UI.LogoContainer.BackgroundTransparency = 1
    UI.LogoContainer.Size = UDim2.new(1, 0, 0, 60)

    UI.TitleLabel = Instance.new("TextLabel")
    UI.TitleLabel.Name = "TitleLabel"
    UI.TitleLabel.Parent = UI.LogoContainer
    UI.TitleLabel.BackgroundTransparency = 1
    UI.TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    UI.TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    UI.TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    UI.TitleLabel.Font = Enum.Font.SourceSansBold
    UI.TitleLabel.Text = windowTitle
    UI.TitleLabel.TextColor3 = accentColor
    UI.TitleLabel.TextSize = 22
    UI.TitleLabel.TextTransparency = 0

    UI.TabContainer = Instance.new("ScrollingFrame")
    UI.TabContainer.Name = "TabContainer"
    UI.TabContainer.Parent = UI.LeftPanel
    UI.TabContainer.BackgroundTransparency = 1
    UI.TabContainer.BorderSizePixel = 0
    UI.TabContainer.Position = UDim2.new(0, 10, 0, 60)
    UI.TabContainer.Size = UDim2.new(1, -20, 1, -120)
    UI.TabContainer.ScrollBarThickness = 0
    UI.TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = UI.TabContainer
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    UI.UserPanel = Instance.new("Frame")
    UI.UserPanel.Name = "UserPanel"
    UI.UserPanel.Parent = UI.LeftPanel
    UI.UserPanel.BackgroundColor3 = Color3.fromRGB(11, 10, 11)
    UI.UserPanel.Position = UDim2.new(0, 10, 1, -50)
    UI.UserPanel.Size = UDim2.new(1, -20, 0, 40)
    UI.UserPanel.BackgroundTransparency = 0

    local UserStroke = Instance.new("UIStroke")
    UserStroke.Color = Color3.fromRGB(34, 26, 40)
    UserStroke.Thickness = 1
    UserStroke.Transparency = 0
    UserStroke.Parent = UI.UserPanel

    UI.UserImage = Instance.new("ImageLabel")
    UI.UserImage.Name = "UserImage"
    UI.UserImage.Parent = UI.UserPanel
    UI.UserImage.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    UI.UserImage.Position = UDim2.new(0, 5, 0.5, -12)
    UI.UserImage.Size = UDim2.new(0, 24, 0, 24)
    pcall(function()
        UI.UserImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    UI.UserImage.BackgroundTransparency = 1
    UI.UserImage.ImageTransparency = 0

    local UserImageCorner = Instance.new("UICorner")
    UserImageCorner.CornerRadius = UDim.new(1, 0)
    UserImageCorner.Parent = UI.UserImage

    UI.UserName = Instance.new("TextLabel")
    UI.UserName.Name = "UserName"
    UI.UserName.Parent = UI.UserPanel
    UI.UserName.BackgroundTransparency = 1
    UI.UserName.Position = UDim2.new(0, 35, 0, 0)
    UI.UserName.Size = UDim2.new(1, -35, 1, 0)
    UI.UserName.Font = Enum.Font.SourceSans
    UI.UserName.Text = " <font color=\"rgb(150, 150, 150)\"> • </font> <i>Thanks for using!</i>"
    UI.UserName.TextColor3 = Color3.fromRGB(180, 180, 180)
    UI.UserName.TextSize = 13
    UI.UserName.TextXAlignment = Enum.TextXAlignment.Left
    UI.UserName.RichText = true
    UI.UserName.TextTransparency = 0
    UI.UserName.ClipsDescendants = false

    local function StartUserPanelLoop()
        local isThanks = true
        while true do
            task.wait(10)
            local nextText = isThanks and (" <font color=\"rgb(150, 150, 150)\"> • </font> " .. LocalPlayer.Name:lower()) or " <font color=\"rgb(150, 150, 150)\"> • </font> <i>Thanks for using!</i>"
            isThanks = not isThanks
            Tween(UI.UserName, 0.5, {Position = UDim2.new(0, 35, 0, 15), TextTransparency = 1})
            task.delay(0.5, function()
                UI.UserName.Text = nextText
                UI.UserName.Position = UDim2.new(0, 35, 0, -15)
                Tween(UI.UserName, 0.5, {Position = UDim2.new(0, 35, 0, 0), TextTransparency = 0})
            end)
        end
    end
    task.spawn(StartUserPanelLoop)

    UI.MainContent = Instance.new("Frame")
    UI.MainContent.Name = "MainContent"
    UI.MainContent.Parent = UI.MainFrame
    UI.MainContent.BackgroundTransparency = 1
    UI.MainContent.Position = UDim2.new(0, 180, 0, 0)
    UI.MainContent.Size = UDim2.new(1, -180, 1, 0)
    UI.MainContent.ClipsDescendants = true

    local activeNotifications = {}

    function UI:Notify(title, text)
        local NotifyFrame = Instance.new("Frame")
        NotifyFrame.Name = "Notification"
        NotifyFrame.Parent = UI.ScreenGui
        NotifyFrame.BackgroundColor3 = Color3.fromRGB(11, 10, 11)
        NotifyFrame.BorderSizePixel = 0
        NotifyFrame.Position = UDim2.new(1, 40, 1, -100)
        NotifyFrame.Size = UDim2.new(0, 280, 0, 85)
        NotifyFrame.ZIndex = 100
        NotifyFrame.ClipsDescendants = true
        
        local NotifyStroke = Instance.new("UIStroke")
        NotifyStroke.Color = Color3.fromRGB(34, 26, 40)
        NotifyStroke.Thickness = 1.2
        NotifyStroke.Parent = NotifyFrame
        
        local AccentBar = Instance.new("Frame")
        AccentBar.Name = "AccentBar"
        AccentBar.Parent = NotifyFrame
        AccentBar.BackgroundColor3 = accentColor
        AccentBar.BorderSizePixel = 0
        AccentBar.Size = UDim2.new(0, 3, 1, 0)
        
        local NotifyTitle = Instance.new("TextLabel")
        NotifyTitle.Parent = NotifyFrame
        NotifyTitle.BackgroundTransparency = 1
        NotifyTitle.Position = UDim2.new(0, 15, 0, 10)
        NotifyTitle.Size = UDim2.new(1, -30, 0, 22)
        NotifyTitle.Font = Enum.Font.SourceSansBold
        NotifyTitle.Text = title:upper()
        NotifyTitle.TextColor3 = accentColor
        NotifyTitle.TextSize = 16 -- Increased
        NotifyTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        local NotifyText = Instance.new("TextLabel")
        NotifyText.Parent = NotifyFrame
        NotifyText.BackgroundTransparency = 1
        NotifyText.Position = UDim2.new(0, 15, 0, 35)
        NotifyText.Size = UDim2.new(1, -30, 0, 40)
        NotifyText.Font = Enum.Font.SourceSans
        NotifyText.Text = text
        NotifyText.TextColor3 = Color3.fromRGB(200, 200, 200)
        NotifyText.TextSize = 15 -- Increased
        NotifyText.TextXAlignment = Enum.TextXAlignment.Left
        NotifyText.TextWrapped = true
        NotifyText.TextYAlignment = Enum.TextYAlignment.Top
        
        local TimerBarContainer = Instance.new("Frame")
        TimerBarContainer.Name = "TimerBarContainer"
        TimerBarContainer.Parent = NotifyFrame
        TimerBarContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        TimerBarContainer.BorderSizePixel = 0
        TimerBarContainer.Position = UDim2.new(0, 0, 1, -3)
        TimerBarContainer.Size = UDim2.new(1, 0, 0, 3) -- Slightly thicker for better visibility
        
        local TimerBar = Instance.new("Frame")
        TimerBar.Name = "TimerBar"
        TimerBar.Parent = TimerBarContainer
        TimerBar.BackgroundColor3 = accentColor
        TimerBar.BorderSizePixel = 0
        TimerBar.Size = UDim2.new(1, 0, 1, 0)
        
        local function UpdatePositions()
            for i, v in pairs(activeNotifications) do
                local targetY = -120 - ((#activeNotifications - i) * 95)
                Tween(v, 0.4, {Position = UDim2.new(1, -300, 1, targetY)})
            end
        end

        NotifyFrame.BackgroundTransparency = 1
        NotifyTitle.TextTransparency = 1
        NotifyText.TextTransparency = 1
        NotifyStroke.Transparency = 1
        AccentBar.BackgroundTransparency = 1
        
        table.insert(activeNotifications, NotifyFrame)
        UpdatePositions()
        
        -- Entrance animations (0.4s)
        Tween(NotifyFrame, 0.4, {BackgroundTransparency = 0})
        Tween(NotifyTitle, 0.4, {TextTransparency = 0})
        Tween(NotifyText, 0.4, {TextTransparency = 0})
        Tween(NotifyStroke, 0.4, {Transparency = 0})
        Tween(AccentBar, 0.4, {BackgroundTransparency = 0})

        -- Wait for entrance to complete before starting the timer
        task.delay(0.4, function()
            local timerTween = TweenService:Create(TimerBar, TweenInfo.new(4, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
            timerTween:Play()

            timerTween.Completed:Connect(function()
                local index = table.find(activeNotifications, NotifyFrame)
                if index then
                    table.remove(activeNotifications, index)
                    -- Exit animations (0.4s)
                    Tween(NotifyFrame, 0.4, {Position = UDim2.new(1, 40, 1, NotifyFrame.Position.Y.Offset), BackgroundTransparency = 1})
                    Tween(NotifyTitle, 0.4, {TextTransparency = 1})
                    Tween(NotifyText, 0.4, {TextTransparency = 1})
                    Tween(NotifyStroke, 0.4, {Transparency = 1})
                    Tween(AccentBar, 0.4, {BackgroundTransparency = 1})
                    task.delay(0.4, function() 
                        NotifyFrame:Destroy()
                    end)
                    UpdatePositions()
                end
            end)
        end)
    end

    local dragging, dragInput, dragStart, startPos
    local function UpdateDrag(input)
        local delta = input.Position - dragStart
        UI.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    local function StartDragging(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = UI.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end

    UI.LeftPanel.InputBegan:Connect(StartDragging)
    UI.LogoContainer.InputBegan:Connect(StartDragging)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateDrag(input)
        end
    end)

    function UI:CreateChangelog(logs)
        local logString = table.concat(logs, "\n")
        local logHash = 0
        for i = 1, #logString do
            logHash = (logHash * 31 + string.byte(logString, i)) % 2^31
        end
        
        local hashFile = "Unified/LastChangelog.txt"
        if isfile and readfile and isfile(hashFile) then
            if readfile(hashFile) == tostring(logHash) then
                return
            end
        end
        if writefile then
            writefile(hashFile, tostring(logHash))
        end

        local ChangelogFrame = Instance.new("Frame")
        ChangelogFrame.Name = "Changelog"
        ChangelogFrame.Parent = UI.MainFrame.Parent
        ChangelogFrame.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
        ChangelogFrame.BorderSizePixel = 0
        ChangelogFrame.Position = UDim2.new(UI.MainFrame.Position.X.Scale, UI.MainFrame.Position.X.Offset + 640, UI.MainFrame.Position.Y.Scale, UI.MainFrame.Position.Y.Offset)
        ChangelogFrame.Size = UDim2.new(0, 200, 0, 0)
        ChangelogFrame.BackgroundTransparency = 1
        ChangelogFrame.ClipsDescendants = true
        
        local ClCorner = Instance.new("UICorner")
        ClCorner.CornerRadius = UDim.new(0, 6)
        ClCorner.Parent = ChangelogFrame
        
        local ClStroke = Instance.new("UIStroke")
        ClStroke.Color = Color3.fromRGB(34, 26, 40)
        ClStroke.Thickness = 1.2
        ClStroke.Transparency = 1
        ClStroke.Parent = ChangelogFrame

        local ClTitle = Instance.new("TextLabel")
        ClTitle.Parent = ChangelogFrame
        ClTitle.BackgroundTransparency = 1
        ClTitle.Position = UDim2.new(0, 12, 0, 10)
        ClTitle.Size = UDim2.new(1, -24, 0, 20)
        ClTitle.Font = Enum.Font.SourceSansBold
        ClTitle.Text = "Changelog"
        ClTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
        ClTitle.TextSize = 16
        ClTitle.TextXAlignment = Enum.TextXAlignment.Left
        ClTitle.TextTransparency = 1

        local ClContent = Instance.new("ScrollingFrame")
        ClContent.Parent = ChangelogFrame
        ClContent.BackgroundTransparency = 1
        ClContent.BorderSizePixel = 0
        ClContent.Position = UDim2.new(0, 12, 0, 35)
        ClContent.Size = UDim2.new(1, -24, 1, -45)
        ClContent.ScrollBarThickness = 2
        ClContent.ScrollBarImageColor3 = accentColor
        ClContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local ClLayout = Instance.new("UIListLayout")
        ClLayout.Parent = ClContent
        ClLayout.Padding = UDim.new(0, 6)
        ClLayout.SortOrder = Enum.SortOrder.LayoutOrder

        ClLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ClContent.CanvasSize = UDim2.new(0, 0, 0, ClLayout.AbsoluteContentSize.Y)
        end)

        for _, log in pairs(logs) do
            local LogLabel = Instance.new("TextLabel")
            LogLabel.Parent = ClContent
            LogLabel.BackgroundTransparency = 1
            LogLabel.Size = UDim2.new(1, 0, 0, 0)
            LogLabel.Font = Enum.Font.SourceSans
            LogLabel.Text = log
            LogLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
            LogLabel.TextSize = 14
            LogLabel.TextXAlignment = Enum.TextXAlignment.Left
            LogLabel.TextWrapped = true
            LogLabel.AutomaticSize = Enum.AutomaticSize.Y
            LogLabel.TextTransparency = 1
            
            if log:find("^%[%+%]") then
                LogLabel.RichText = true
                LogLabel.Text = '<font color="#98C379">[+]</font>' .. log:sub(4)
            elseif log:find("^%[%-%]") then
                LogLabel.RichText = true
                LogLabel.Text = '<font color="#E06C75">[-]</font>' .. log:sub(4)
            elseif log:find("^%[%/%]") then
                LogLabel.RichText = true
                LogLabel.Text = '<font color="#61AFEF">[/]</font>' .. log:sub(4)
            end
            
            task.delay(0.6, function() Tween(LogLabel, 0.5, {TextTransparency = 0}) end)
        end

        UI.MainFrame:GetPropertyChangedSignal("Position"):Connect(function()
            ChangelogFrame.Position = UDim2.new(UI.MainFrame.Position.X.Scale, UI.MainFrame.Position.X.Offset + 640, UI.MainFrame.Position.Y.Scale, UI.MainFrame.Position.Y.Offset)
        end)

        UI.AccentBar.Visible = false

        Tween(ChangelogFrame, 0.6, {BackgroundTransparency = 0, Size = UDim2.new(0, 200, 0, 300)})
        Tween(ClStroke, 0.6, {Transparency = 0})
        Tween(ClTitle, 0.8, {TextTransparency = 0})

        task.delay(5, function()
            Tween(ClTitle, 0.5, {TextTransparency = 1})
            Tween(ClStroke, 0.5, {Transparency = 1})
            Tween(ChangelogFrame, 0.6, {BackgroundTransparency = 1, Size = UDim2.new(0, 200, 0, 0)})
            task.delay(0.6, function()
                ChangelogFrame:Destroy()
                UI.AccentBar.Visible = true
            end)
        end)
        
        return ChangelogFrame
    end

    function UI:CreateTab(name, iconId)
        local Tab = {
            Name = name,
            Sections = {},
            Button = nil,
            Page = nil,
            Content = nil,
            Indicator = nil,
            Icon = nil,
            Rendered = false,
            RenderQueue = {}
        }
        table.insert(UI.Tabs, Tab)

        local function ResetAllZIndex()
            for _, s in pairs(Tab.Sections) do
                s.Frame.ZIndex = 1
                for _, e in pairs(s.Elements) do
                    if e.Frame and (e.Frame.Name:find("Dropdown") or e.Frame.Name:find("MultiDropdown") or e.Frame.Name:find("Colorpicker")) then
                        e.Frame.ZIndex = 5
                    end
                end
            end
        end

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tostring(name) .. "Tab"
        TabBtn.Parent = UI.TabContainer
        TabBtn.BackgroundColor3 = accentColor
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(1, 0, 0, 34)
        TabBtn.Font = Enum.Font.SourceSans
        TabBtn.Text = iconId and "      " .. tostring(name) or tostring(name)
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.TextSize = 15
        TabBtn.AutoButtonColor = false
        Tab.Button = TabBtn
        
        TabBtn.Visible = false
        UI.LoadQueue = UI.LoadQueue + 1
        task.delay(UI.LoadQueue * 1, function()
            TabBtn.Visible = true
            TabBtn.TextTransparency = 1
            Tween(TabBtn, 0.5, {TextTransparency = 0})
        end)

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabBtn

        local TabIndicator = Instance.new("Frame")
        TabIndicator.Name = "Indicator"
        TabIndicator.Parent = TabBtn
        TabIndicator.BackgroundColor3 = accentColor
        TabIndicator.Position = UDim2.new(0, 0, 0, 0)
        TabIndicator.Size = UDim2.new(0, 2, 1, 0)
        TabIndicator.BackgroundTransparency = 1
        Tab.Indicator = TabIndicator

        local TabIndicatorCorner = Instance.new("UICorner")
        TabIndicatorCorner.CornerRadius = UDim.new(0, 4)
        TabIndicatorCorner.Parent = TabIndicator

        if iconId then
            local TabIcon = Instance.new("ImageLabel")
            TabIcon.Name = "Icon"
            TabIcon.Parent = TabBtn
            TabIcon.BackgroundTransparency = 1
            TabIcon.Position = UDim2.new(0, 8, 0.5, -8)
            TabIcon.Size = UDim2.new(0, 16, 0, 16)
            TabIcon.Image = iconId
            TabIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
            Tab.Icon = TabIcon
        end

        local TabPage = Instance.new("Frame")
        TabPage.Name = tostring(name) .. "Page"
        TabPage.Parent = UI.MainContent
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.Visible = false
        TabPage.ClipsDescendants = false
        Tab.Page = TabPage

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = "Content"
        TabContent.Parent = TabPage
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Position = UDim2.new(0, 10, 0, 10)
        TabContent.Size = UDim2.new(1, -20, 1, -20)
        TabContent.ScrollBarThickness = 2
        TabContent.ScrollBarImageColor3 = accentColor
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ClipsDescendants = true
        TabContent.ZIndex = 10
        Tab.Content = TabContent

        local function RefreshCanvasSize()
            pcall(function()
                local targetHeight = 20

                for _, section in pairs(Tab.Sections) do
                    local sectionBottom = (section.Frame.AbsolutePosition.Y - TabContent.AbsolutePosition.Y) + TabContent.CanvasPosition.Y + section.Frame.AbsoluteSize.Y
                    targetHeight = math.max(targetHeight, sectionBottom + 20)

                    for _, element in pairs(section.Elements) do
                        if element.Opened and element.Frame then
                            local popup = element.List or element.PickerFrame
                            if popup and popup.Visible then
                                local popupBottom = (popup.AbsolutePosition.Y - TabContent.AbsolutePosition.Y) + TabContent.CanvasPosition.Y + popup.AbsoluteSize.Y
                                targetHeight = math.max(targetHeight, popupBottom + 20)
                            end
                        end
                    end
                end

                TabContent.CanvasSize = UDim2.new(0, 0, 0, targetHeight)
            end)
        end

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = TabContent
        ContentLayout.Padding = UDim.new(0, 12)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            RefreshCanvasSize()
        end)

        TabBtn.MouseEnter:Connect(function()
            if UI.CurrentTab ~= Tab then
                Tween(TabBtn, 0.2, {TextColor3 = Color3.fromRGB(200, 200, 200), BackgroundTransparency = 0.96})
            end
        end)

        TabBtn.MouseLeave:Connect(function()
            if UI.CurrentTab ~= Tab then
                Tween(TabBtn, 0.2, {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1})
            end
        end)

        local function Render()
            if Tab.Rendered then return end
            Tab.Rendered = true
            for _, renderFunc in pairs(Tab.RenderQueue) do
                SafeExecute(renderFunc)
            end
        end

        TabBtn.MouseButton1Click:Connect(function()
            if UI.TabDebounce then return end
            UI.TabDebounce = true
            task.delay(0.45, function() UI.TabDebounce = false end)
            
            Render()
            
            if UI.CurrentTab == Tab then return end
            
            if UI.CurrentTab then
                local oldTab = UI.CurrentTab
                Tween(oldTab.Button, 0.3, {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1})
                if oldTab.Indicator then Tween(oldTab.Indicator, 0.3, {BackgroundTransparency = 1}) end
                if oldTab.Icon then Tween(oldTab.Icon, 0.3, {ImageColor3 = Color3.fromRGB(150, 150, 150)}) end
                
                local oldGroup = Instance.new("CanvasGroup", oldTab.Page)
                oldGroup.Name = "TransitionGroup"
                oldGroup.Size = UDim2.new(1, 0, 1, 0)
                oldGroup.BackgroundTransparency = 1
                for _, child in pairs(oldTab.Page:GetChildren()) do
                    if child ~= oldGroup then child.Parent = oldGroup end
                end
                
                Tween(oldGroup, 0.3, {GroupTransparency = 1, Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10)})
                task.delay(0.3, function() 
                    oldTab.Page.Visible = false 
                    for _, child in pairs(oldGroup:GetChildren()) do
                        child.Parent = oldTab.Page
                    end
                    oldGroup:Destroy()
                end)
            end
            
            UI.CurrentTab = Tab
            TabPage.Visible = true
            
            local newGroup = Instance.new("CanvasGroup", TabPage)
            newGroup.Name = "TransitionGroup"
            newGroup.Size = UDim2.new(1, 40, 1, 40)
            newGroup.Position = UDim2.new(0, -20, 0, -20)
            newGroup.BackgroundTransparency = 1
            newGroup.GroupTransparency = 1
            
            for _, child in pairs(TabPage:GetChildren()) do
                if child ~= newGroup then child.Parent = newGroup end
            end
            
            Tween(newGroup, 0.4, {GroupTransparency = 0, Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)})
            task.delay(0.4, function()
                for _, child in pairs(newGroup:GetChildren()) do
                    child.Parent = TabPage
                end
                newGroup:Destroy()
            end)
            
            Tween(TabBtn, 0.3, {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92})
            if Tab.Indicator then Tween(Tab.Indicator, 0.3, {BackgroundTransparency = 0}) end
            if Tab.Icon then Tween(Tab.Icon, 0.3, {ImageColor3 = Color3.fromRGB(255, 255, 255)}) end
        end)

        if #UI.Tabs == 1 then
            task.spawn(function()
                repeat task.wait() until UI.LoadQueue == 0 or task.wait(0.5)
                Render()
                TabPage.Visible = true
                UI.CurrentTab = Tab
                TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                TabBtn.BackgroundTransparency = 0.92
                TabIndicator.BackgroundTransparency = 0
                if Tab.Icon then Tab.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255) end
            end)
        end

        function Tab:CreateSection(title)
            local Section = { Elements = {} }
            table.insert(Tab.Sections, Section)
            
            local function Build()
                local parent = Tab.Content
                Section.Frame = Instance.new("Frame")
                Section.Frame.Name = tostring(title) .. "Section"
                Section.Frame.Parent = parent
                Section.Frame.BackgroundColor3 = UI.Colors.SectionBackground
                Section.Frame.BorderSizePixel = 0
                Section.Frame.Size = UDim2.new(1, 0, 0, 40)
                Section.Frame.ClipsDescendants = false
                
                Section.Frame.Visible = true
                Section.Frame.BackgroundTransparency = 1
                Tween(Section.Frame, 0.5, {BackgroundTransparency = 0})

                local SectionStroke = Instance.new("UIStroke")
                SectionStroke.Color = Color3.fromRGB(34, 26, 40)
                SectionStroke.Thickness = 1.2
                SectionStroke.Transparency = 0.5
                SectionStroke.Parent = Section.Frame
                Section.Frame.MouseEnter:Connect(function() Tween(SectionStroke, 0.3, {Color = accentColor, Transparency = 0.2}) end)
                Section.Frame.MouseLeave:Connect(function() Tween(SectionStroke, 0.3, {Color = Color3.fromRGB(34, 26, 40), Transparency = 0.5}) end)
                Section.TitleLabel = Instance.new("TextLabel")
                Section.TitleLabel.Name = "Title"
                Section.TitleLabel.Parent = Section.Frame
                Section.TitleLabel.BackgroundTransparency = 1
                Section.TitleLabel.Position = UDim2.new(0, 12, 0, 8)
                Section.TitleLabel.Size = UDim2.new(1, -24, 0, 20)
                Section.TitleLabel.Font = Enum.Font.SourceSansBold
                Section.TitleLabel.Text = title:upper()
                Section.TitleLabel.TextColor3 = accentColor
                Section.TitleLabel.TextSize = 13
                Section.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local Container = Instance.new("Frame")
                Container.Name = "Container"
                Container.Parent = Section.Frame
                Container.BackgroundTransparency = 1
                Container.Position = UDim2.new(0, 12, 0, 35)
                Container.Size = UDim2.new(1, -24, 0, 0)
                Container.ClipsDescendants = false
                
                local ContainerLayout = Instance.new("UIListLayout")
                ContainerLayout.Parent = Container
                ContainerLayout.Padding = UDim.new(0, 6)
                ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
                
                ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    Container.Size = UDim2.new(1, -24, 0, ContainerLayout.AbsoluteContentSize.Y + 10)
                    Section.Frame.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 45)
                end)
            end

            if Tab.Rendered then
                Build()
            else
                table.insert(Tab.RenderQueue, Build)
            end

            function Section:CreateButton(text, callback)
                local Button = { Callback = callback or function() end }
                table.insert(Section.Elements, Button)
                Button.Frame = Instance.new("TextButton")
                Button.Frame.Name = text .. "Button"
                Button.Frame.Parent = Container
                Button.Frame.BackgroundColor3 = UI.Colors.ElementBackground
                Button.Frame.BorderSizePixel = 0
                Button.Frame.Size = UDim2.new(1, 0, 0, 28)
                Button.Frame.Font = Enum.Font.SourceSans
                Button.Frame.Text = text
                Button.Frame.TextColor3 = Color3.fromRGB(200, 200, 200)
                Button.Frame.TextSize = 14
                Button.Frame.AutoButtonColor = false
                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Color3.fromRGB(34, 26, 40)
                BtnStroke.Thickness = 1
                BtnStroke.Parent = Button.Frame
                Button.Frame.MouseEnter:Connect(function() 
                    Tween(Button.Frame, 0.2, {BackgroundColor3 = GetHoverColor(UI.Colors.ElementBackground)}) 
                    Tween(BtnStroke, 0.2, {Color = Color3.fromRGB(50, 40, 60)}) 
                end)
                Button.Frame.MouseLeave:Connect(function() 
                    Tween(Button.Frame, 0.2, {BackgroundColor3 = UI.Colors.ElementBackground}) 
                    Tween(BtnStroke, 0.2, {Color = Color3.fromRGB(34, 26, 40)}) 
                end)
                Button.Frame.MouseButton1Click:Connect(function()
                    if UserInputService:GetFocusedTextBox() then return end
                    local ripple = Instance.new("Frame")
                    ripple.Name = "Ripple"
                    ripple.Parent = Button.Frame
                    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    ripple.BackgroundTransparency = 0.9
                    ripple.BorderSizePixel = 0
                    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
                    ripple.Size = UDim2.new(0, 0, 0, 0)
                    Tween(ripple, 0.4, {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
                    task.delay(0.4, function() ripple:Destroy() end)
                    pcall(Button.Callback)
                end)
                return Button
            end

            function Section:CreateToggle(text, flag, default, callback)
                local Toggle = { State = default or false, Flag = flag, Callback = callback or function() end }
                table.insert(Section.Elements, Toggle)
                SetInitialFlag(flag or text, Toggle.State, "toggle")
                Toggle.Frame = Instance.new("Frame")
                Toggle.Frame.Name = text .. "ToggleContainer"
                Toggle.Frame.Parent = Container
                Toggle.Frame.BackgroundTransparency = 1
                Toggle.Frame.Size = UDim2.new(1, 0, 0, 28)
                
                local ToggleLayout = Instance.new("UIListLayout")
                ToggleLayout.Parent = Toggle.Frame
                ToggleLayout.Padding = UDim.new(0, 6)
                ToggleLayout.SortOrder = Enum.SortOrder.LayoutOrder

                ToggleLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    Toggle.Frame.Size = UDim2.new(1, 0, 0, ToggleLayout.AbsoluteContentSize.Y)
                end)

                Toggle.ButtonFrame = Instance.new("TextButton")
                Toggle.ButtonFrame.Name = "ButtonFrame"
                Toggle.ButtonFrame.Parent = Toggle.Frame
                Toggle.ButtonFrame.BackgroundTransparency = 1
                Toggle.ButtonFrame.Size = UDim2.new(1, 0, 0, 28)
                Toggle.ButtonFrame.Text = ""
                Toggle.Label = Instance.new("TextLabel")
                Toggle.Label.Parent = Toggle.ButtonFrame
                Toggle.Label.BackgroundTransparency = 1
                Toggle.Label.Size = UDim2.new(1, -40, 1, 0)
                Toggle.Label.Font = Enum.Font.SourceSans
                Toggle.Label.Text = text
                Toggle.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                Toggle.Label.TextSize = 14
                Toggle.Label.TextXAlignment = Enum.TextXAlignment.Left
                Toggle.Box = Instance.new("Frame")
                Toggle.Box.Name = "Box"
                Toggle.Box.Parent = Toggle.ButtonFrame
                Toggle.Box.BackgroundColor3 = UI.Colors.ElementBackground
                Toggle.Box.Position = UDim2.new(1, -30, 0.5, -8)
                Toggle.Box.Size = UDim2.new(0, 30, 0, 16)
                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = Color3.fromRGB(34, 26, 40)
                BoxStroke.Thickness = 1
                BoxStroke.Parent = Toggle.Box
                Toggle.Indicator = Instance.new("Frame")
                Toggle.Indicator.Name = "Indicator"
                Toggle.Indicator.Parent = Toggle.Box
                Toggle.Indicator.BackgroundColor3 = accentColor
                Toggle.Indicator.Position = Toggle.State and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                Toggle.Indicator.Size = UDim2.new(0, 12, 0, 12)
                Toggle.Indicator.BackgroundTransparency = Toggle.State and 0 or 1
                local function Update(manually)
                    if not manually then Toggle.State = not Toggle.State end
                    UI.Flags[flag or text] = Toggle.State
                    if Toggle.State then
                        Tween(Toggle.Indicator, 0.2, {Position = UDim2.new(1, -14, 0.5, -6), BackgroundTransparency = 0})
                        Tween(BoxStroke, 0.2, {Color = accentColor})
                    else
                        Tween(Toggle.Indicator, 0.2, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundTransparency = 1})
                        Tween(BoxStroke, 0.2, {Color = Color3.fromRGB(34, 26, 40)})
                    end
                    pcall(Toggle.Callback, Toggle.State)
                end
                Toggle.Update = function(val) Toggle.State = val Update(true) end
                UI.Components[flag or text] = Toggle
                Toggle.ButtonFrame.MouseButton1Click:Connect(function() 
                    if UserInputService:GetFocusedTextBox() then return end
                    Update() 
                end)

                function Toggle:CreateSlider(sText, sFlag, min, max, default, sCallback)
                    local sliderObj = Section:CreateSlider(sText, sFlag, min, max, default, sCallback)
                    sliderObj.Frame.Parent = Toggle.Frame
                    sliderObj.Frame.Size = UDim2.new(1, -15, 0, 40)
                    local pad = Instance.new("UIPadding", sliderObj.Frame)
                    pad.PaddingLeft = UDim.new(0, 15)
                    return sliderObj
                end
                
                function Toggle:CreateColorpicker(cpText, cpFlag, defaultCol, cpCallback)
                    local cpObj = Section:CreateColorpicker(cpText, cpFlag, defaultCol, cpCallback)
                    cpObj.Frame.Parent = Toggle.Frame
                    cpObj.Frame.Size = UDim2.new(1, -15, 0, 28)
                    local pad = Instance.new("UIPadding", cpObj.Frame)
                    pad.PaddingLeft = UDim.new(0, 15)
                    return cpObj
                end
                
                function Toggle:CreateDropdown(dText, dFlag, items, default, dCallback)
                    local dObj = Section:CreateDropdown(dText, dFlag, items, default, dCallback)
                    dObj.Frame.Parent = Toggle.Frame
                    dObj.Frame.Size = UDim2.new(1, -15, 0, 32)
                    local pad = Instance.new("UIPadding", dObj.Frame)
                    pad.PaddingLeft = UDim.new(0, 15)
                    return dObj
                end

                return Toggle
            end

            function Section:CreateSlider(text, flag, min, max, default, callback)
                local Slider = { Value = default or min, Min = min, Max = max, Flag = flag, Callback = callback or function() end }
                table.insert(Section.Elements, Slider)
                SetInitialFlag(flag or text, Slider.Value, "slider")
                Slider.Frame = Instance.new("Frame")
                Slider.Frame.Name = text .. "Slider"
                Slider.Frame.Parent = Container
                Slider.Frame.BackgroundTransparency = 1
                Slider.Frame.Size = UDim2.new(1, 0, 0, 40)
                Slider.Label = Instance.new("TextLabel")
                Slider.Label.Parent = Slider.Frame
                Slider.Label.BackgroundTransparency = 1
                Slider.Label.Size = UDim2.new(1, 0, 0, 20)
                Slider.Label.Font = Enum.Font.SourceSans
                Slider.Label.Text = text
                Slider.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                Slider.Label.TextSize = 14
                Slider.Label.TextXAlignment = Enum.TextXAlignment.Left
                Slider.ValueLabel = Instance.new("TextBox")
                Slider.ValueLabel.Parent = Slider.Frame
                Slider.ValueLabel.BackgroundTransparency = 1
                Slider.ValueLabel.Position = UDim2.new(1, -50, 0, 0)
                Slider.ValueLabel.Size = UDim2.new(0, 50, 0, 20)
                Slider.ValueLabel.Font = Enum.Font.SourceSans
                Slider.ValueLabel.Text = tostring(Slider.Value)
                Slider.ValueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                Slider.ValueLabel.TextSize = 13
                Slider.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                Slider.ValueLabel.ClearTextOnFocus = false
                Slider.ValueLabel.FocusLost:Connect(function()
                    local val = tonumber(Slider.ValueLabel.Text)
                    if val then
                        val = math.clamp(math.floor(val), min, max)
                        Update(val, true)
                    else
                        Slider.ValueLabel.Text = tostring(Slider.Value)
                    end
                end)
                Slider.Bar = Instance.new("Frame")
                Slider.Bar.Parent = Slider.Frame
                Slider.Bar.BackgroundColor3 = UI.Colors.ElementBackground
                Slider.Bar.Position = UDim2.new(0, 0, 0, 25)
                Slider.Bar.Size = UDim2.new(1, 0, 0, 6)
                local BarStroke = Instance.new("UIStroke")
                BarStroke.Color = Color3.fromRGB(34, 26, 40)
                BarStroke.Parent = Slider.Bar
                Slider.Fill = Instance.new("Frame")
                Slider.Fill.Parent = Slider.Bar
                Slider.Fill.BackgroundColor3 = accentColor
                Slider.Fill.BorderSizePixel = 0
                Slider.Fill.Size = UDim2.new((Slider.Value - min) / (max - min), 0, 1, 0)
                local function Update(input, manually)
                    local pos
                    if manually then
                        pos = math.clamp((input - min) / (max - min), 0, 1)
                        Slider.Value = input
                    else
                        pos = math.clamp((input.Position.X - Slider.Bar.AbsolutePosition.X) / Slider.Bar.AbsoluteSize.X, 0, 1)
                        Slider.Value = math.floor(min + (max - min) * pos)
                    end
                    UI.Flags[flag or text] = Slider.Value
                    Slider.Fill.Size = UDim2.new(pos, 0, 1, 0)
                    Slider.ValueLabel.Text = tostring(Slider.Value)
                    pcall(Slider.Callback, Slider.Value)
                end
                Slider.Update = function(val) Update(val, true) end
                UI.Components[flag or text] = Slider
                local sliding = false
                Slider.Bar.InputBegan:Connect(function(input) 
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                        if UserInputService:GetFocusedTextBox() then return end
                        sliding = true Update(input) 
                    end 
                end)
                UserInputService.InputChanged:Connect(function(input) if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
                return Slider
            end

            function Section:CreateTextbox(text, flag, placeholder, callback)
                local Textbox = { Flag = flag, Callback = callback or function() end }
                table.insert(Section.Elements, Textbox)
                SetInitialFlag(flag or text, "", "textbox")
                Textbox.Frame = Instance.new("Frame")
                Textbox.Frame.Name = text .. "Textbox"
                Textbox.Frame.Parent = Container
                Textbox.Frame.BackgroundColor3 = UI.Colors.ElementBackground
                Textbox.Frame.Size = UDim2.new(1, 0, 0, 30)
                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = Color3.fromRGB(34, 26, 40)
                BoxStroke.Parent = Textbox.Frame
                Textbox.Input = Instance.new("TextBox")
                Textbox.Input.Parent = Textbox.Frame
                Textbox.Input.BackgroundTransparency = 1
                Textbox.Input.Position = UDim2.new(0, 8, 0, 0)
                Textbox.Input.Size = UDim2.new(1, -16, 1, 0)
                Textbox.Input.Font = Enum.Font.SourceSans
                Textbox.Input.PlaceholderText = placeholder or "Type here..."
                Textbox.Input.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
                Textbox.Input.Text = ""
                Textbox.Input.TextColor3 = Color3.fromRGB(200, 200, 200)
                Textbox.Input.TextSize = 14
                Textbox.Input.TextXAlignment = Enum.TextXAlignment.Left
                Textbox.Update = function(val) Textbox.Input.Text = val UI.Flags[flag or text] = val pcall(Textbox.Callback, val) end
                UI.Components[flag or text] = Textbox
                Textbox.Input.FocusLost:Connect(function() UI.Flags[flag or text] = Textbox.Input.Text pcall(Textbox.Callback, Textbox.Input.Text) end)
                return Textbox
            end

            function Section:CreateBind(text, flag, default, callback)
                local Bind = { Key = default or Enum.KeyCode.F, Flag = flag, Callback = callback or function() end, Waiting = false }
                table.insert(Section.Elements, Bind)
                SetInitialFlag(flag or text, Bind.Key.Name, "bind")
                Bind.Frame = Instance.new("Frame")
                Bind.Frame.Name = text .. "Bind"
                Bind.Frame.Parent = Container
                Bind.Frame.BackgroundTransparency = 1
                Bind.Frame.Size = UDim2.new(1, 0, 0, 28)
                Bind.Label = Instance.new("TextLabel")
                Bind.Label.Parent = Bind.Frame
                Bind.Label.BackgroundTransparency = 1
                Bind.Label.Size = UDim2.new(1, -60, 1, 0)
                Bind.Label.Font = Enum.Font.SourceSans
                Bind.Label.Text = text
                Bind.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                Bind.Label.TextSize = 14
                Bind.Label.TextXAlignment = Enum.TextXAlignment.Left
                Bind.Btn = Instance.new("TextButton")
                Bind.Btn.Parent = Bind.Frame
                Bind.Btn.BackgroundColor3 = UI.Colors.ElementBackground
                Bind.Btn.Position = UDim2.new(1, -50, 0.5, -10)
                Bind.Btn.Size = UDim2.new(0, 50, 0, 20)
                Bind.Btn.Font = Enum.Font.SourceSans
                Bind.Btn.Text = GetInputLabel(Bind.Key)
                Bind.Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                Bind.Btn.TextSize = 12
                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Color3.fromRGB(34, 26, 40)
                BtnStroke.Parent = Bind.Btn
                Bind.Update = function(val)
                    if typeof(val) == "string" then
                        Bind.Key = Enum.KeyCode[val]
                    else
                        Bind.Key = val
                    end
                    Bind.Btn.Text = GetInputLabel(Bind.Key)
                    UI.Flags[flag or text] = Bind.Key.Name
                end
                UI.Components[flag or text] = Bind
                Bind.Btn.MouseButton1Click:Connect(function() Bind.Waiting = true Bind.Btn.Text = "..." end)
                UserInputService.InputBegan:Connect(function(input)
                    if Bind.Waiting then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Bind.Key = input.KeyCode
                            Bind.Btn.Text = GetInputLabel(Bind.Key)
                            Bind.Waiting = false
                            UI.Flags[flag or text] = Bind.Key.Name
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                            Bind.Key = input.UserInputType
                            Bind.Btn.Text = GetInputLabel(Bind.Key)
                            Bind.Waiting = false
                            UI.Flags[flag or text] = Bind.Key.Name
                        end
                    elseif not Bind.Waiting then
                        if (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Bind.Key) or (input.UserInputType == Bind.Key) then
                            pcall(Bind.Callback)
                        end
                    end
                end)
                return Bind
            end

            function Section:CreateToggleBind(text, flag, defaultState, defaultKey, callback)
                local ToggleBind = { State = defaultState or false, Key = defaultKey or Enum.KeyCode.F, Flag = flag, Callback = callback or function() end, Waiting = false }
                table.insert(Section.Elements, ToggleBind)
                SetInitialFlag(flag or text, {ToggleBind.State, ToggleBind.Key.Name}, "togglebind")
                ToggleBind.Frame = Instance.new("Frame")
                ToggleBind.Frame.Name = text .. "ToggleBind"
                ToggleBind.Frame.Parent = Container
                ToggleBind.Frame.BackgroundTransparency = 1
                ToggleBind.Frame.Size = UDim2.new(1, 0, 0, 28)
                ToggleBind.Label = Instance.new("TextLabel")
                ToggleBind.Label.Parent = ToggleBind.Frame
                ToggleBind.Label.BackgroundTransparency = 1
                ToggleBind.Label.Size = UDim2.new(1, -100, 1, 0)
                ToggleBind.Label.Font = Enum.Font.SourceSans
                ToggleBind.Label.Text = text
                ToggleBind.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                ToggleBind.Label.TextSize = 14
                ToggleBind.Label.TextXAlignment = Enum.TextXAlignment.Left
                ToggleBind.Box = Instance.new("TextButton")
                ToggleBind.Box.Name = "Box"
                ToggleBind.Box.Parent = ToggleBind.Frame
                ToggleBind.Box.BackgroundColor3 = UI.Colors.ElementBackground
                ToggleBind.Box.Position = UDim2.new(1, -30, 0.5, -8)
                ToggleBind.Box.Size = UDim2.new(0, 30, 0, 16)
                ToggleBind.Box.Text = ""
                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = Color3.fromRGB(34, 26, 40)
                BoxStroke.Thickness = 1
                BoxStroke.Parent = ToggleBind.Box
                ToggleBind.Indicator = Instance.new("Frame")
                ToggleBind.Indicator.Name = "Indicator"
                ToggleBind.Indicator.Parent = ToggleBind.Box
                ToggleBind.Indicator.BackgroundColor3 = accentColor
                ToggleBind.Indicator.Position = ToggleBind.State and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                ToggleBind.Indicator.Size = UDim2.new(0, 12, 0, 12)
                ToggleBind.Indicator.BackgroundTransparency = ToggleBind.State and 0 or 1
                ToggleBind.Btn = Instance.new("TextButton")
                ToggleBind.Btn.Parent = ToggleBind.Frame
                ToggleBind.Btn.BackgroundColor3 = UI.Colors.ElementBackground
                ToggleBind.Btn.Position = UDim2.new(1, -90, 0.5, -10)
                ToggleBind.Btn.Size = UDim2.new(0, 50, 0, 20)
                ToggleBind.Btn.Font = Enum.Font.SourceSans
                ToggleBind.Btn.Text = GetInputLabel(ToggleBind.Key)
                ToggleBind.Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                ToggleBind.Btn.TextSize = 12
                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Color3.fromRGB(34, 26, 40)
                BtnStroke.Parent = ToggleBind.Btn
                local function Update(manually)
                    pcall(function()
                        if ToggleBind.State then
                            Tween(ToggleBind.Indicator, 0.2, {Position = UDim2.new(1, -14, 0.5, -6), BackgroundTransparency = 0})
                            Tween(BoxStroke, 0.2, {Color = accentColor})
                        else
                            Tween(ToggleBind.Indicator, 0.2, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundTransparency = 1})
                            Tween(BoxStroke, 0.2, {Color = Color3.fromRGB(34, 26, 40)})
                        end
                        UI.Flags[flag or text] = {ToggleBind.State, ToggleBind.Key.Name}
                        pcall(ToggleBind.Callback, ToggleBind.State, ToggleBind.Key)
                    end)
                end
                ToggleBind.Update = function(val)
                    if type(val) == "table" then
                        ToggleBind.State = val[1]
                        if typeof(val[2]) == "string" then ToggleBind.Key = Enum.KeyCode[val[2]] else ToggleBind.Key = val[2] end
                    else
                        ToggleBind.State = val
                    end
                    ToggleBind.Btn.Text = GetInputLabel(ToggleBind.Key)
                    Update(true)
                end
                UI.Components[flag or text] = ToggleBind
                ToggleBind.Box.MouseButton1Click:Connect(function() ToggleBind.State = not ToggleBind.State Update() end)
                ToggleBind.Btn.MouseButton1Click:Connect(function() ToggleBind.Waiting = true ToggleBind.Btn.Text = "..." end)
                UserInputService.InputBegan:Connect(function(input)
                    if ToggleBind.Waiting then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            ToggleBind.Key = input.KeyCode
                            ToggleBind.Btn.Text = GetInputLabel(ToggleBind.Key)
                            ToggleBind.Waiting = false
                            Update()
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                            ToggleBind.Key = input.UserInputType
                            ToggleBind.Btn.Text = GetInputLabel(ToggleBind.Key)
                            ToggleBind.Waiting = false
                            Update()
                        end
                    elseif not ToggleBind.Waiting then
                        if (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == ToggleBind.Key) or (input.UserInputType == ToggleBind.Key) then
                            ToggleBind.State = not ToggleBind.State
                            Update()
                        end
                    end
                end)
                return ToggleBind
            end

            function Section:CreateCodeblock(text, code)
                local Codeblock = {}
                local rawCode = tostring(code):gsub("<[^>]+>", "")
                
                Codeblock.Frame = Instance.new("Frame")
                Codeblock.Frame.Name = text .. "Codeblock"
                Codeblock.Frame.Parent = Container
                Codeblock.Frame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
                Codeblock.Frame.Size = UDim2.new(1, 0, 0, 120)
                Codeblock.Frame.ClipsDescendants = true
                local CodeStroke = Instance.new("UIStroke")
                CodeStroke.Color = Color3.fromRGB(25, 20, 30)
                CodeStroke.Parent = Codeblock.Frame
                
                local CodeScroll = Instance.new("ScrollingFrame")
                CodeScroll.Name = "CodeScroll"
                CodeScroll.Parent = Codeblock.Frame
                CodeScroll.BackgroundTransparency = 1
                CodeScroll.BorderSizePixel = 0
                CodeScroll.Position = UDim2.new(0, 8, 0, 30)
                CodeScroll.Size = UDim2.new(1, -16, 1, -38)
                CodeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                CodeScroll.ScrollBarThickness = 2
                CodeScroll.ScrollBarImageColor3 = accentColor
                CodeScroll.BottomImage = ""
                CodeScroll.TopImage = ""
                
                Codeblock.Label = Instance.new("TextLabel")
                Codeblock.Label.Parent = CodeScroll
                Codeblock.Label.BackgroundTransparency = 1
                Codeblock.Label.Size = UDim2.new(1, 0, 0, 0)
                Codeblock.Label.Font = Enum.Font.Code
                Codeblock.Label.RichText = true
                Codeblock.Label.Text = rawCode:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
                Codeblock.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                Codeblock.Label.TextSize = 12
                Codeblock.Label.TextXAlignment = Enum.TextXAlignment.Left
                Codeblock.Label.TextYAlignment = Enum.TextYAlignment.Top
                Codeblock.Label.AutomaticSize = Enum.AutomaticSize.Y

                Codeblock.Label:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    CodeScroll.CanvasSize = UDim2.new(0, 0, 0, Codeblock.Label.AbsoluteSize.Y)
                end)
                
                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Parent = Codeblock.Frame
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Position = UDim2.new(0, 10, 0, 5)
                TitleLabel.Size = UDim2.new(1, -70, 0, 20)
                TitleLabel.Font = Enum.Font.SourceSansBold
                TitleLabel.Text = text
                TitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                TitleLabel.TextSize = 13
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

                Codeblock.CopyBtn = Instance.new("TextButton")
                Codeblock.CopyBtn.Name = "CopyBtn"
                Codeblock.CopyBtn.Parent = Codeblock.Frame
                Codeblock.CopyBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                Codeblock.CopyBtn.Position = UDim2.new(1, -60, 0, 5)
                Codeblock.CopyBtn.Size = UDim2.new(0, 55, 0, 20)
                Codeblock.CopyBtn.Font = Enum.Font.SourceSansBold
                Codeblock.CopyBtn.Text = "COPY"
                Codeblock.CopyBtn.TextColor3 = accentColor
                Codeblock.CopyBtn.TextSize = 12
                Codeblock.CopyBtn.AutoButtonColor = false
                local CopyStroke = Instance.new("UIStroke")
                CopyStroke.Color = Color3.fromRGB(35, 30, 45)
                CopyStroke.Parent = Codeblock.CopyBtn
                local CopyCorner = Instance.new("UICorner")
                CopyCorner.CornerRadius = UDim.new(0, 4)
                CopyCorner.Parent = Codeblock.CopyBtn
                Codeblock.CopyBtn.MouseEnter:Connect(function() 
                    Tween(Codeblock.CopyBtn, 0.2, {BackgroundColor3 = GetHoverColor(Color3.fromRGB(15, 15, 15))}) 
                    Tween(CopyStroke, 0.2, {Color = accentColor}) 
                end)
                Codeblock.CopyBtn.MouseLeave:Connect(function() 
                    Tween(Codeblock.CopyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}) 
                    Tween(CopyStroke, 0.2, {Color = Color3.fromRGB(35, 30, 45)}) 
                end)
                Codeblock.CopyBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(rawCode) UI:Notify("UNIFIED", "Code copied to clipboard!") Codeblock.CopyBtn.Text = "COPIED" task.delay(2, function() Codeblock.CopyBtn.Text = "COPY" end) else UI:Notify("ERROR", "Exploit does not support setclipboard!") end end)
                return Codeblock
            end

            function Section:CreateImage(text, id, isLink)
                local Image = {}
                Image.Frame = Instance.new("Frame")
                Image.Frame.Name = text .. "Image"
                Image.Frame.Parent = Container
                Image.Frame.BackgroundTransparency = 1
                Image.Frame.Size = UDim2.new(1, 0, 0, 120)
                Image.Label = Instance.new("TextLabel")
                Image.Label.Parent = Image.Frame
                Image.Label.BackgroundTransparency = 1
                Image.Label.Size = UDim2.new(1, 0, 0, 20)
                Image.Label.Font = Enum.Font.SourceSans
                Image.Label.Text = text
                Image.Label.TextColor3 = Color3.fromRGB(150, 150, 150)
                Image.Label.TextSize = 12
                Image.Img = Instance.new("ImageLabel")
                Image.Img.Parent = Image.Frame
                Image.Img.BackgroundTransparency = 1
                Image.Img.Position = UDim2.new(0.5, -45, 0, 25)
                Image.Img.Size = UDim2.new(0, 90, 0, 90)
                Image.Img.Image = id
                return Image
            end

            function Section:CreateColorpicker(text, flag, default, callback)
                local Colorpicker = { Color = default or Color3.fromRGB(255, 255, 255), Flag = flag, Callback = callback or function() end, Opened = false }
                table.insert(Section.Elements, Colorpicker)
                SetInitialFlag(flag or text, Colorpicker.Color, "colorpicker")
                
                local h, s, v = Color3.toHSV(Colorpicker.Color)
                Colorpicker.H, Colorpicker.S, Colorpicker.V = h, s, v

                Colorpicker.Frame = Instance.new("TextButton")
                Colorpicker.Frame.Name = text .. "Colorpicker"
                Colorpicker.Frame.Parent = Container
                Colorpicker.Frame.BackgroundTransparency = 1
                Colorpicker.Frame.Size = UDim2.new(1, 0, 0, 28)
                Colorpicker.Frame.Text = ""
                
                Colorpicker.Label = Instance.new("TextLabel")
                Colorpicker.Label.Parent = Colorpicker.Frame
                Colorpicker.Label.BackgroundTransparency = 1
                Colorpicker.Label.Size = UDim2.new(1, -40, 1, 0)
                Colorpicker.Label.Font = Enum.Font.SourceSans
                Colorpicker.Label.Text = text
                Colorpicker.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                Colorpicker.Label.TextSize = 14
                Colorpicker.Label.TextXAlignment = Enum.TextXAlignment.Left

                Colorpicker.Box = Instance.new("Frame")
                Colorpicker.Box.Name = "Box"
                Colorpicker.Box.Parent = Colorpicker.Frame
                Colorpicker.Box.BackgroundColor3 = Colorpicker.Color
                Colorpicker.Box.Position = UDim2.new(1, -30, 0.5, -8)
                Colorpicker.Box.Size = UDim2.new(0, 30, 0, 16)
                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = Color3.fromRGB(34, 26, 40)
                BoxStroke.Thickness = 1
                BoxStroke.Parent = Colorpicker.Box

                Colorpicker.ToggleButton = Instance.new("TextButton")
                Colorpicker.ToggleButton.Name = "ToggleButton"
                Colorpicker.ToggleButton.Parent = Colorpicker.Frame
                Colorpicker.ToggleButton.BackgroundTransparency = 1
                Colorpicker.ToggleButton.Size = UDim2.new(1, 0, 0, 28)
                Colorpicker.ToggleButton.Text = ""
                Colorpicker.ToggleButton.AutoButtonColor = false
                Colorpicker.ToggleButton.ZIndex = 6
                
                Colorpicker.PickerFrame = Instance.new("Frame")
                Colorpicker.PickerFrame.Name = "PickerFrame"
                Colorpicker.PickerFrame.Parent = Colorpicker.Frame
                Colorpicker.PickerFrame.BackgroundColor3 = UI.Colors.ElementBackground
                Colorpicker.PickerFrame.BackgroundTransparency = 1
                Colorpicker.PickerFrame.Position = UDim2.new(0, 0, 1, 5)
                Colorpicker.PickerFrame.Size = UDim2.new(1, 0, 0, 0)
                Colorpicker.PickerFrame.Visible = false
                Colorpicker.PickerFrame.Active = true
                Colorpicker.PickerFrame.ZIndex = 100
                local PickerStroke = Instance.new("UIStroke")
                PickerStroke.Color = Color3.fromRGB(34, 26, 40)
                PickerStroke.Transparency = 1
                PickerStroke.Parent = Colorpicker.PickerFrame

                Colorpicker.InputBlocker = Instance.new("TextButton")
                Colorpicker.InputBlocker.Name = "InputBlocker"
                Colorpicker.InputBlocker.Parent = Colorpicker.PickerFrame
                Colorpicker.InputBlocker.BackgroundTransparency = 1
                Colorpicker.InputBlocker.BorderSizePixel = 0
                Colorpicker.InputBlocker.Size = UDim2.new(1, 0, 1, 0)
                Colorpicker.InputBlocker.Text = ""
                Colorpicker.InputBlocker.AutoButtonColor = false
                Colorpicker.InputBlocker.ZIndex = 100

                Colorpicker.SatVal = Instance.new("ImageLabel")
                Colorpicker.SatVal.Name = "SatVal"
                Colorpicker.SatVal.Parent = Colorpicker.PickerFrame
                Colorpicker.SatVal.Active = true
                Colorpicker.SatVal.BackgroundColor3 = Color3.fromHSV(Colorpicker.H, 1, 1)
                Colorpicker.SatVal.BackgroundTransparency = 1
                Colorpicker.SatVal.Position = UDim2.new(0, 10, 0, 10)
                Colorpicker.SatVal.Size = UDim2.new(1, -50, 0, 130)
                Colorpicker.SatVal.Image = "rbxassetid://4155801252"
                Colorpicker.SatVal.ImageTransparency = 1
                Colorpicker.SatVal.ZIndex = 101

                Colorpicker.SatValCursor = Instance.new("Frame")
                Colorpicker.SatValCursor.Name = "Cursor"
                Colorpicker.SatValCursor.Parent = Colorpicker.SatVal
                Colorpicker.SatValCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Colorpicker.SatValCursor.Position = UDim2.new(Colorpicker.S, -2, 1 - Colorpicker.V, -2)
                Colorpicker.SatValCursor.Size = UDim2.new(0, 4, 0, 4)
                Colorpicker.SatValCursor.ZIndex = 102
                local CursorStroke = Instance.new("UIStroke")
                CursorStroke.Color = Color3.fromRGB(0, 0, 0)
                CursorStroke.Parent = Colorpicker.SatValCursor

                Colorpicker.Hue = Instance.new("ImageLabel")
                Colorpicker.Hue.Name = "Hue"
                Colorpicker.Hue.Parent = Colorpicker.PickerFrame
                Colorpicker.Hue.Active = true
                Colorpicker.Hue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Colorpicker.Hue.BackgroundTransparency = 1
                Colorpicker.Hue.Position = UDim2.new(1, -30, 0, 10)
                Colorpicker.Hue.Size = UDim2.new(0, 20, 0, 130)
                Colorpicker.Hue.Image = ""
                Colorpicker.Hue.ZIndex = 101
                local HueGradient = Instance.new("UIGradient")
                HueGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })
                HueGradient.Rotation = 90
                HueGradient.Parent = Colorpicker.Hue

                Colorpicker.HueCursor = Instance.new("Frame")
                Colorpicker.HueCursor.Name = "Cursor"
                Colorpicker.HueCursor.Parent = Colorpicker.Hue
                Colorpicker.HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Colorpicker.HueCursor.Position = UDim2.new(0, -2, Colorpicker.H, -1)
                Colorpicker.HueCursor.Size = UDim2.new(1, 4, 0, 2)
                Colorpicker.HueCursor.ZIndex = 102
                local HueCursorStroke = Instance.new("UIStroke")
                HueCursorStroke.Color = Color3.fromRGB(0, 0, 0)
                HueCursorStroke.Parent = Colorpicker.HueCursor

                Colorpicker.Darkness = Instance.new("Frame")
                Colorpicker.Darkness.Name = "Darkness"
                Colorpicker.Darkness.Parent = Colorpicker.PickerFrame
                Colorpicker.Darkness.Active = true
                Colorpicker.Darkness.BackgroundTransparency = 1
                Colorpicker.Darkness.Position = UDim2.new(0, 10, 0, 150)
                Colorpicker.Darkness.Size = UDim2.new(1, -20, 0, 15)
                Colorpicker.Darkness.ZIndex = 101
                local DarknessGradient = Instance.new("UIGradient")
                DarknessGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                })
                DarknessGradient.Parent = Colorpicker.Darkness
                local DarknessStroke = Instance.new("UIStroke")
                DarknessStroke.Color = Color3.fromRGB(34, 26, 40)
                DarknessStroke.Parent = Colorpicker.Darkness

                Colorpicker.DarknessCursor = Instance.new("Frame")
                Colorpicker.DarknessCursor.Name = "Cursor"
                Colorpicker.DarknessCursor.Parent = Colorpicker.Darkness
                Colorpicker.DarknessCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Colorpicker.DarknessCursor.Position = UDim2.new(1 - Colorpicker.V, -1, 0, -2)
                Colorpicker.DarknessCursor.Size = UDim2.new(0, 2, 1, 4)
                Colorpicker.DarknessCursor.ZIndex = 102
                local DarknessCursorStroke = Instance.new("UIStroke")
                DarknessCursorStroke.Color = Color3.fromRGB(0, 0, 0)
                DarknessCursorStroke.Parent = Colorpicker.DarknessCursor

                Colorpicker.InputBlocker.MouseButton1Click:Connect(function()
                end)

                local function UpdateColor()
                    Colorpicker.Color = Color3.fromHSV(Colorpicker.H, Colorpicker.S, Colorpicker.V)
                    Colorpicker.Box.BackgroundColor3 = Colorpicker.Color
                    Colorpicker.SatVal.BackgroundColor3 = Color3.fromHSV(Colorpicker.H, 1, 1)
                    DarknessGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(Colorpicker.H, Colorpicker.S, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                    })
                    UI.Flags[flag or text] = Colorpicker.Color
                    pcall(Colorpicker.Callback, Colorpicker.Color)
                end

                local function UpdateSatVal(input)
                    local pos = math.clamp((input.Position.X - Colorpicker.SatVal.AbsolutePosition.X) / Colorpicker.SatVal.AbsoluteSize.X, 0, 1)
                    local pos2 = 1 - math.clamp((input.Position.Y - Colorpicker.SatVal.AbsolutePosition.Y) / Colorpicker.SatVal.AbsoluteSize.Y, 0, 1)
                    Colorpicker.S = pos
                    Colorpicker.V = pos2
                    Colorpicker.SatValCursor.Position = UDim2.new(pos, -2, 1 - pos2, -2)
                    Colorpicker.DarknessCursor.Position = UDim2.new(1 - pos2, -1, 0, -2)
                    UpdateColor()
                end

                local function UpdateHue(input)
                    local pos = math.clamp((input.Position.Y - Colorpicker.Hue.AbsolutePosition.Y) / Colorpicker.Hue.AbsoluteSize.Y, 0, 1)
                    Colorpicker.H = pos
                    Colorpicker.HueCursor.Position = UDim2.new(0, -2, pos, -1)
                    UpdateColor()
                end

                local function UpdateDarkness(input)
                    local pos = math.clamp((input.Position.X - Colorpicker.Darkness.AbsolutePosition.X) / Colorpicker.Darkness.AbsoluteSize.X, 0, 1)
                    Colorpicker.V = 1 - pos
                    Colorpicker.DarknessCursor.Position = UDim2.new(pos, -1, 0, -2)
                    Colorpicker.SatValCursor.Position = UDim2.new(Colorpicker.S, -2, pos, -2)
                    UpdateColor()
                end

                local function SetOpened(opened)
                    if opened then
                        if UI.OpenedElement and UI.OpenedElement ~= Colorpicker and UI.OpenedElement.SetOpened then
                            UI.OpenedElement.SetOpened(false)
                        end
                        UI.OpenedElement = Colorpicker
                    elseif UI.OpenedElement == Colorpicker then
                        UI.OpenedElement = nil
                    end

                    Colorpicker.Opened = opened
                    if opened then
                        ResetAllZIndex()
                        Colorpicker.Frame.ZIndex = 100
                        Section.Frame.ZIndex = 10
                        Colorpicker.PickerFrame.Visible = true
                        Colorpicker.PickerFrame.Position = UDim2.new(0, 0, 1, 0)
                        Tween(Colorpicker.PickerFrame, 0.22, {Size = UDim2.new(1, 0, 0, 180), BackgroundTransparency = 0, Position = UDim2.new(0, 0, 1, 5)})
                        Tween(PickerStroke, 0.22, {Transparency = 0})
                        Tween(Colorpicker.SatVal, 0.22, {BackgroundTransparency = 0, ImageTransparency = 0})
                        Tween(Colorpicker.Hue, 0.22, {BackgroundTransparency = 0})
                        Tween(Colorpicker.Darkness, 0.22, {BackgroundTransparency = 0})
                    else
                        Tween(Colorpicker.SatVal, 0.18, {BackgroundTransparency = 1, ImageTransparency = 1})
                        Tween(Colorpicker.Hue, 0.18, {BackgroundTransparency = 1})
                        Tween(Colorpicker.Darkness, 0.18, {BackgroundTransparency = 1})
                        Tween(PickerStroke, 0.18, {Transparency = 1})
                        Tween(Colorpicker.PickerFrame, 0.22, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Position = UDim2.new(0, 0, 1, 0)})
                        task.delay(0.22, function() if not Colorpicker.Opened then Colorpicker.PickerFrame.Visible = false end end)
                    end
                    RefreshCanvasSize()
                    task.delay(0.35, RefreshCanvasSize)
                end

                Colorpicker.ToggleButton.MouseButton1Click:Connect(function() 
                    if UserInputService:GetFocusedTextBox() then return end
                    SetOpened(not Colorpicker.Opened) 
                end)

                local satvalDragging = false
                Colorpicker.SatVal.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then satvalDragging = true UpdateSatVal(input) end end)
                UserInputService.InputChanged:Connect(function(input) if satvalDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateSatVal(input) end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then satvalDragging = false end end)

                local hueDragging = false
                Colorpicker.Hue.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = true UpdateHue(input) end end)
                UserInputService.InputChanged:Connect(function(input) if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateHue(input) end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then hueDragging = false end end)

                local darknessDragging = false
                Colorpicker.Darkness.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then darknessDragging = true UpdateDarkness(input) end end)
                UserInputService.InputChanged:Connect(function(input) if darknessDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateDarkness(input) end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then darknessDragging = false end end)

                Colorpicker.Update = function(val)
                    if typeof(val) == "table" then
                        Colorpicker.Color = Color3.new(unpack(val))
                    else
                        Colorpicker.Color = val
                    end
                    local h, s, v = Color3.toHSV(Colorpicker.Color)
                    Colorpicker.H, Colorpicker.S, Colorpicker.V = h, s, v
                    Colorpicker.SatValCursor.Position = UDim2.new(s, -2, 1 - v, -2)
                    Colorpicker.HueCursor.Position = UDim2.new(0, -2, h, -1)
                    Colorpicker.DarknessCursor.Position = UDim2.new(1 - v, -1, 0, -2)
                    UpdateColor()
                end
                Colorpicker.SetOpened = SetOpened
                UI.Components[flag or text] = Colorpicker
                return Colorpicker
            end

            function Section:CreateDropdown(text, flag, options, default, callback)
                local Dropdown = { Options = options or {}, Selected = default, Flag = flag, Callback = callback or function() end, Opened = false }
                table.insert(Section.Elements, Dropdown)
                SetInitialFlag(flag or text, Dropdown.Selected, "dropdown")
                Dropdown.Frame = Instance.new("Frame")
                Dropdown.Frame.Name = text .. "Dropdown"
                Dropdown.Frame.Parent = Container
                Dropdown.Frame.BackgroundColor3 = UI.Colors.ElementBackground
                Dropdown.Frame.Size = UDim2.new(1, 0, 0, 30)
                Dropdown.Frame.ZIndex = 5
                
                local DropStroke = Instance.new("UIStroke")
                DropStroke.Color = Color3.fromRGB(34, 26, 40)
                DropStroke.Parent = Dropdown.Frame
                Dropdown.Label = Instance.new("TextLabel")
                Dropdown.Label.Parent = Dropdown.Frame
                Dropdown.Label.BackgroundTransparency = 1
                Dropdown.Label.Position = UDim2.new(0, 10, 0, 0)
                Dropdown.Label.Size = UDim2.new(1, -30, 1, 0)
                Dropdown.Label.Font = Enum.Font.SourceSans
                Dropdown.Label.Text = text .. ": " .. (Dropdown.Selected or "None")
                Dropdown.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                Dropdown.Label.TextSize = 14
                Dropdown.Label.TextXAlignment = Enum.TextXAlignment.Left
                Dropdown.Icon = Instance.new("TextLabel")
                Dropdown.Icon.Parent = Dropdown.Frame
                Dropdown.Icon.BackgroundTransparency = 1
                Dropdown.Icon.Position = UDim2.new(1, -25, 0, 0)
                Dropdown.Icon.Size = UDim2.new(0, 20, 1, 0)
                Dropdown.Icon.Font = Enum.Font.SourceSansBold
                Dropdown.Icon.Text = "+"
                Dropdown.Icon.TextColor3 = accentColor
                Dropdown.Icon.TextSize = 18
                Dropdown.List = Instance.new("Frame")
                Dropdown.List.Parent = Dropdown.Frame
                Dropdown.List.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
                Dropdown.List.Position = UDim2.new(0, 0, 1, 5)
                Dropdown.List.Size = UDim2.new(1, 0, 0, 0)
                Dropdown.List.Visible = false
                Dropdown.List.ClipsDescendants = true
                Dropdown.List.ZIndex = 100
                local ListStroke = Instance.new("UIStroke")
                ListStroke.Color = Color3.fromRGB(34, 26, 40)
                ListStroke.Parent = Dropdown.List
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Parent = Dropdown.List
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

                local function SetOpened(opened)
                    if opened then
                        if UI.OpenedElement and UI.OpenedElement ~= Dropdown and UI.OpenedElement.SetOpened then
                            UI.OpenedElement.SetOpened(false)
                        end
                        UI.OpenedElement = Dropdown
                    elseif UI.OpenedElement == Dropdown then
                        UI.OpenedElement = nil
                    end

                    Dropdown.Opened = opened
                    if opened then
                        ResetAllZIndex()
                        Dropdown.Frame.ZIndex = 100
                        Section.Frame.ZIndex = 10
                        Dropdown.List.Visible = true
                        local targetSize = math.max(#Dropdown.Options, 1) * 25
                        Tween(Dropdown.List, 0.3, {Size = UDim2.new(1, 0, 0, targetSize)})
                        Dropdown.Icon.Text = "-"
                    else
                        ResetAllZIndex()
                        Tween(Dropdown.List, 0.3, {Size = UDim2.new(1, 0, 0, 0)})
                        task.delay(0.3, function() 
                            if not Dropdown.Opened then 
                                Dropdown.List.Visible = false 
                            end 
                        end)
                        Dropdown.Icon.Text = "+"
                    end
                    RefreshCanvasSize()
                    task.delay(0.35, RefreshCanvasSize)
                end

                local function CreateOptions()
                    for _, child in pairs(Dropdown.List:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    for _, option in ipairs(Dropdown.Options) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Name = tostring(option)
                        OptBtn.Parent = Dropdown.List
                        OptBtn.BackgroundColor3 = UI.Colors.ElementBackground
                        OptBtn.BorderSizePixel = 0
                        OptBtn.Size = UDim2.new(1, 0, 0, 25)
                        OptBtn.Font = Enum.Font.SourceSans
                        OptBtn.Text = "  " .. tostring(option)
                        OptBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
                        OptBtn.TextSize = 14
                        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                        OptBtn.ZIndex = 110
                        OptBtn.AutoButtonColor = false

                        OptBtn.MouseEnter:Connect(function()
                            Tween(OptBtn, 0.2, {BackgroundColor3 = GetHoverColor(UI.Colors.ElementBackground)})
                        end)
                        OptBtn.MouseLeave:Connect(function()
                            Tween(OptBtn, 0.2, {BackgroundColor3 = UI.Colors.ElementBackground})
                        end)

                        OptBtn.MouseButton1Click:Connect(function() 
                            Dropdown.Update(option) 
                            SetOpened(false)
                        end)
                    end
                end

                local function Update(val, isOptions)
                    pcall(function()
                        if val == Dropdown then
                            val = isOptions
                            isOptions = true
                        end

                        if isOptions and type(val) == "table" then
                            Dropdown.Options = val
                            CreateOptions()

                            local exists = false
                            for _, opt in ipairs(Dropdown.Options) do
                                if opt == Dropdown.Selected then exists = true break end
                            end
                            if not exists then 
                                Dropdown.Selected = nil
                                Dropdown.Label.Text = text .. ": None"
                            end

                            if Dropdown.Opened then
                                local targetSize = math.max(#Dropdown.Options, 1) * 25
                                Tween(Dropdown.List, 0.3, {Size = UDim2.new(1, 0, 0, targetSize)})
                                RefreshCanvasSize()
                                task.delay(0.35, RefreshCanvasSize)
                            end
                            return
                        end

                        if val ~= nil and not isOptions then
                            Dropdown.Selected = val
                        end
                        
                        UI.Flags[flag or text] = Dropdown.Selected
                        Dropdown.Label.Text = text .. ": " .. (Dropdown.Selected or "None")
                        pcall(Dropdown.Callback, Dropdown.Selected)
                    end)
                end

                Dropdown.Update = Update
                Dropdown.SetOpened = SetOpened
                UI.Components[flag or text] = Dropdown

                CreateOptions()
                Dropdown.Frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if UserInputService:GetFocusedTextBox() then return end
                        SetOpened(not Dropdown.Opened)
                    end
                end)
                return Dropdown
            end

            function Section:CreateMultiDropdown(text, flag, options, default, callback)
                local Dropdown = { Options = options or {}, Selected = default or {}, Flag = flag, Callback = callback or function() end, Opened = false }
                table.insert(Section.Elements, Dropdown)
                SetInitialFlag(flag or text, Dropdown.Selected, "multidropdown")
                Dropdown.Frame = Instance.new("Frame")
                Dropdown.Frame.Name = text .. "MultiDropdown"
                Dropdown.Frame.Parent = Container
                Dropdown.Frame.BackgroundColor3 = UI.Colors.ElementBackground
                Dropdown.Frame.Size = UDim2.new(1, 0, 0, 30)
                Dropdown.Frame.ZIndex = 5
                
                local DropStroke = Instance.new("UIStroke")
                DropStroke.Color = Color3.fromRGB(34, 26, 40)
                DropStroke.Parent = Dropdown.Frame
                Dropdown.Label = Instance.new("TextLabel")
                Dropdown.Label.Parent = Dropdown.Frame
                Dropdown.Label.BackgroundTransparency = 1
                Dropdown.Label.Position = UDim2.new(0, 10, 0, 0)
                Dropdown.Label.Size = UDim2.new(1, -30, 1, 0)
                Dropdown.Label.Font = Enum.Font.SourceSans
                Dropdown.Label.Text = text .. ": ..."
                Dropdown.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                Dropdown.Label.TextSize = 14
                Dropdown.Label.TextXAlignment = Enum.TextXAlignment.Left
                Dropdown.Icon = Instance.new("TextLabel")
                Dropdown.Icon.Parent = Dropdown.Frame
                Dropdown.Icon.BackgroundTransparency = 1
                Dropdown.Icon.Position = UDim2.new(1, -25, 0, 0)
                Dropdown.Icon.Size = UDim2.new(0, 20, 1, 0)
                Dropdown.Icon.Font = Enum.Font.SourceSansBold
                Dropdown.Icon.Text = "+"
                Dropdown.Icon.TextColor3 = accentColor
                Dropdown.Icon.TextSize = 18
                Dropdown.List = Instance.new("Frame")
                Dropdown.List.Parent = Dropdown.Frame
                Dropdown.List.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
                Dropdown.List.Position = UDim2.new(0, 0, 1, 5)
                Dropdown.List.Size = UDim2.new(1, 0, 0, 0)
                Dropdown.List.Visible = false
                Dropdown.List.ClipsDescendants = true
                Dropdown.List.ZIndex = 100
                local ListStroke = Instance.new("UIStroke")
                ListStroke.Color = Color3.fromRGB(34, 26, 40)
                ListStroke.Parent = Dropdown.List
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Parent = Dropdown.List
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

                local function SetOpened(opened)
                    if opened then
                        if UI.OpenedElement and UI.OpenedElement ~= Dropdown and UI.OpenedElement.SetOpened then
                            UI.OpenedElement.SetOpened(false)
                        end
                        UI.OpenedElement = Dropdown
                    elseif UI.OpenedElement == Dropdown then
                        UI.OpenedElement = nil
                    end

                    Dropdown.Opened = opened
                    if opened then
                        ResetAllZIndex()
                        Dropdown.Frame.ZIndex = 100
                        Section.Frame.ZIndex = 10
                        Dropdown.List.Visible = true
                        local targetSize = #Dropdown.Options * 25
                        Tween(Dropdown.List, 0.3, {Size = UDim2.new(1, 0, 0, targetSize)})
                        Dropdown.Icon.Text = "-"
                    else
                        ResetAllZIndex()
                        Tween(Dropdown.List, 0.3, {Size = UDim2.new(1, 0, 0, 0)})
                        task.delay(0.3, function() 
                            if not Dropdown.Opened then 
                                Dropdown.List.Visible = false 
                            end 
                        end)
                        Dropdown.Icon.Text = "+"
                    end
                    RefreshCanvasSize()
                    task.delay(0.35, RefreshCanvasSize)
                end

                local function CreateOptions()
                    for _, child in pairs(Dropdown.List:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, option in pairs(Dropdown.Options) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Name = option
                        OptBtn.Parent = Dropdown.List
                        OptBtn.BackgroundColor3 = UI.Colors.ElementBackground
                        OptBtn.BorderSizePixel = 0
                        OptBtn.Size = UDim2.new(1, 0, 0, 25)
                        OptBtn.Font = Enum.Font.SourceSans
                        OptBtn.Text = "  " .. option
                        OptBtn.TextColor3 = table.find(Dropdown.Selected, option) and accentColor or Color3.fromRGB(150, 150, 150)
                        OptBtn.TextSize = 14
                        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                        OptBtn.ZIndex = 110
                        OptBtn.AutoButtonColor = false

                        OptBtn.MouseEnter:Connect(function()
                            Tween(OptBtn, 0.2, {BackgroundColor3 = GetHoverColor(UI.Colors.ElementBackground)})
                        end)
                        OptBtn.MouseLeave:Connect(function()
                            Tween(OptBtn, 0.2, {BackgroundColor3 = UI.Colors.ElementBackground})
                        end)

                        OptBtn.MouseButton1Click:Connect(function()
                            local index = table.find(Dropdown.Selected, option)
                            if index then table.remove(Dropdown.Selected, index) Tween(OptBtn, 0.2, {TextColor3 = Color3.fromRGB(150, 150, 150)}) else table.insert(Dropdown.Selected, option) Tween(OptBtn, 0.2, {TextColor3 = accentColor}) end
                            Dropdown.Update()
                        end)
                    end
                end

                local function Update(val, isOptions)
                    if val == Dropdown then
                        val = isOptions
                        isOptions = true
                    end

                    if isOptions and type(val) == "table" then
                        Dropdown.Options = val
                        CreateOptions()
                        if Dropdown.Opened then
                            Tween(Dropdown.List, 0.3, {Size = UDim2.new(1, 0, 0, #Dropdown.Options * 25)})
                            RefreshCanvasSize()
                            task.delay(0.35, RefreshCanvasSize)
                        end
                        return
                    end

                    if type(val) == "table" and not isOptions then
                        Dropdown.Selected = val
                        for _, btn in pairs(Dropdown.List:GetChildren()) do
                            if btn:IsA("TextButton") then
                                Tween(btn, 0.2, {TextColor3 = table.find(Dropdown.Selected, btn.Name) and accentColor or Color3.fromRGB(150, 150, 150)})
                            end
                        end
                    end
                    
                    UI.Flags[flag or text] = Dropdown.Selected
                    local selectedCount = #Dropdown.Selected
                    if selectedCount == 0 then
                        Dropdown.Label.Text = text .. ": ..."
                    else
                        Dropdown.Label.Text = text .. ": (" .. selectedCount .. ") selected"
                    end
                    pcall(Dropdown.Callback, Dropdown.Selected)
                end

                Update()
                Dropdown.Update = Update
                Dropdown.SetOpened = SetOpened
                UI.Components[flag or text] = Dropdown

                CreateOptions()
                Dropdown.Frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        SetOpened(not Dropdown.Opened)
                    end
                end)
                return Dropdown
            end
            return Section
        end
        return Tab
    end
    return UI
end
return Library
