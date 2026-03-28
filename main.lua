local Library = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local function Tween(obj, info, goal)
    local tween = TweenService:Create(obj, TweenInfo.new(info, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal)
    tween:Play()
    return tween
end

local function RandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local res = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        res = res .. string.sub(chars, rand, rand)
    end
    return res
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
        Tabs = {},
        Flags = {},
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
                             if element.Frame and not (element.Frame.Name:find("Dropdown") or element.Frame.Name:find("MultiDropdown")) then
                                 element.Frame.BackgroundColor3 = color
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

    function UI:SaveConfig(name)
        local config = {}
        for flag, value in pairs(UI.Flags) do
            if typeof(value) == "Color3" then
                config[flag] = {value.R, value.G, value.B}
            elseif typeof(value) == "EnumItem" then
                config[flag] = {tostring(value)}
            else
                config[flag] = value
            end
        end
        for flag, component in pairs(UI.Components) do
            if component.Opened ~= nil then
                config[flag .. "_Opened"] = component.Opened
            end
        end
        if writefile then
            writefile(UI.ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(config))
        end
    end

    local function CreateDefaultConfig()
        task.spawn(function()
            task.wait(1)
            if writefile and not isfile(UI.ConfigFolder .. "/default.json") then
                UI:SaveConfig("default")
            end
        end)
    end
    CreateDefaultConfig()

    function UI:LoadConfig(name)
        local path = UI.ConfigFolder .. "/" .. name .. ".json"
        
        if isfile and readfile and isfile(path) then
            local success, config = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
            if success and type(config) == "table" then
                for flag, value in pairs(config) do
                    if UI.Components[flag] then
                        UI.Components[flag]:Update(value)
                    else
                        if type(value) == "table" and #value == 3 then
                            UI.Flags[flag] = Color3.new(unpack(value))
                        else
                            UI.Flags[flag] = value
                        end
                    end
                end
                for flag, component in pairs(UI.Components) do
                    if config[flag .. "_Opened"] ~= nil and component.SetOpened then
                        component:SetOpened(config[flag .. "_Opened"])
                    end
                end
            end
        end
    end

    function UI:DeleteConfig(name)
        if delfile and isfile and isfile(UI.ConfigFolder .. "/" .. name .. ".json") then
            delfile(UI.ConfigFolder .. "/" .. name .. ".json")
        end
    end

    function UI:GetConfigs()
        local configs = {}
        if listfiles and isfolder and isfolder(UI.ConfigFolder) then
            for _, v in pairs(listfiles(UI.ConfigFolder)) do
                local name = v:match("([^/]+)%.json$") or v:match("([^\\]+)%.json$")
                if name then table.insert(configs, name) end
            end
        end
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
    UI.UserImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
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
        NotifyFrame.Position = UDim2.new(1, 20, 1, -100)
        NotifyFrame.Size = UDim2.new(0, 250, 0, 80)
        NotifyFrame.ZIndex = 100

        local NotifyStroke = Instance.new("UIStroke")
        NotifyStroke.Color = accentColor
        NotifyStroke.Thickness = 1.5
        NotifyStroke.Parent = NotifyFrame

        local NotifyTitle = Instance.new("TextLabel")
        NotifyTitle.Parent = NotifyFrame
        NotifyTitle.BackgroundTransparency = 1
        NotifyTitle.Position = UDim2.new(0, 12, 0, 10)
        NotifyTitle.Size = UDim2.new(1, -24, 0, 20)
NotifyTitle.Font = Enum.Font.SourceSansBold
        NotifyTitle.Text = title:upper()
        NotifyTitle.TextColor3 = accentColor
        NotifyTitle.TextSize = 14
        NotifyTitle.TextXAlignment = Enum.TextXAlignment.Left

        local NotifyText = Instance.new("TextLabel")
        NotifyText.Parent = NotifyFrame
        NotifyText.BackgroundTransparency = 1
        NotifyText.Position = UDim2.new(0, 12, 0, 35)
        NotifyText.Size = UDim2.new(1, -24, 0, 35)
        NotifyText.Font = Enum.Font.SourceSans
        NotifyText.Text = text
        NotifyText.TextColor3 = Color3.fromRGB(200, 200, 200)
        NotifyText.TextSize = 14
        NotifyText.TextXAlignment = Enum.TextXAlignment.Left
        NotifyText.TextWrapped = true

        local function UpdatePositions()
            for i, v in pairs(activeNotifications) do
                local targetY = -100 - ((#activeNotifications - i) * 90)
                Tween(v, 0.4, {Position = UDim2.new(1, -260, 1, targetY)})
            end
        end

        table.insert(activeNotifications, NotifyFrame)
        UpdatePositions()

        task.delay(4, function()
            local index = table.find(activeNotifications, NotifyFrame)
            if index then
                table.remove(activeNotifications, index)
                Tween(NotifyFrame, 0.4, {Position = UDim2.new(1, 20, 1, NotifyFrame.Position.Y.Offset), BackgroundTransparency = 1})
                task.delay(0.4, function() 
                    NotifyFrame:Destroy()
                end)
                UpdatePositions()
            end
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
            Sections = {},
            Button = nil,
            Page = nil,
            Content = nil,
            Indicator = nil,
            Icon = nil
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

        TabBtn.MouseButton1Click:Connect(function()
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
            TabPage.Visible = true
            UI.CurrentTab = Tab
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabBtn.BackgroundTransparency = 0.92
            TabIndicator.BackgroundTransparency = 0
            if Tab.Icon then Tab.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255) end
        end

        function Tab:CreateSection(title)
            local Section = { Elements = {} }
            table.insert(Tab.Sections, Section)
            local parent = Tab.Content
            Section.Frame = Instance.new("Frame")
            Section.Frame.Name = tostring(title) .. "Section"
            Section.Frame.Parent = parent
            Section.Frame.BackgroundColor3 = UI.Colors.SectionBackground
            Section.Frame.BorderSizePixel = 0
            Section.Frame.Size = UDim2.new(1, 0, 0, 40)
            Section.Frame.ClipsDescendants = false
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
            ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, -24, 0, ContainerLayout.AbsoluteContentSize.Y + 10)
                Section.Frame.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 45)
            end)

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
                Button.Frame.MouseEnter:Connect(function() Tween(Button.Frame, 0.2, {BackgroundColor3 = Color3.fromRGB(16, 15, 16)}) Tween(BtnStroke, 0.2, {Color = Color3.fromRGB(50, 40, 60)}) end)
                Button.Frame.MouseLeave:Connect(function() Tween(Button.Frame, 0.2, {BackgroundColor3 = Color3.fromRGB(11, 10, 11)}) Tween(BtnStroke, 0.2, {Color = Color3.fromRGB(34, 26, 40)}) end)
                Button.Frame.MouseButton1Click:Connect(function()
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
                UI.Flags[flag or text] = Toggle.State
                Toggle.Frame = Instance.new("TextButton")
                Toggle.Frame.Name = text .. "Toggle"
                Toggle.Frame.Parent = Container
                Toggle.Frame.BackgroundTransparency = 1
                Toggle.Frame.Size = UDim2.new(1, 0, 0, 28)
                Toggle.Frame.Text = ""
                Toggle.Label = Instance.new("TextLabel")
                Toggle.Label.Parent = Toggle.Frame
                Toggle.Label.BackgroundTransparency = 1
                Toggle.Label.Size = UDim2.new(1, -40, 1, 0)
                Toggle.Label.Font = Enum.Font.SourceSans
                Toggle.Label.Text = text
                Toggle.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                Toggle.Label.TextSize = 14
                Toggle.Label.TextXAlignment = Enum.TextXAlignment.Left
                Toggle.Box = Instance.new("Frame")
                Toggle.Box.Name = "Box"
                Toggle.Box.Parent = Toggle.Frame
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
                Toggle.Frame.MouseButton1Click:Connect(function() Update() end)
                return Toggle
            end

            function Section:CreateSlider(text, flag, min, max, default, callback)
                local Slider = { Value = default or min, Min = min, Max = max, Flag = flag, Callback = callback or function() end }
                table.insert(Section.Elements, Slider)
                UI.Flags[flag or text] = Slider.Value
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
                Slider.ValueLabel = Instance.new("TextLabel")
                Slider.ValueLabel.Parent = Slider.Frame
                Slider.ValueLabel.BackgroundTransparency = 1
                Slider.ValueLabel.Position = UDim2.new(1, -40, 0, 0)
                Slider.ValueLabel.Size = UDim2.new(0, 40, 0, 20)
                Slider.ValueLabel.Font = Enum.Font.SourceSans
                Slider.ValueLabel.Text = tostring(Slider.Value)
                Slider.ValueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                Slider.ValueLabel.TextSize = 13
                Slider.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
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
                Slider.Bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true Update(input) end end)
                UserInputService.InputChanged:Connect(function(input) if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
                return Slider
            end

            function Section:CreateTextbox(text, flag, placeholder, callback)
                local Textbox = { Flag = flag, Callback = callback or function() end }
                table.insert(Section.Elements, Textbox)
                UI.Flags[flag or text] = ""
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
            end

            function Section:CreateDropdown(text, flag, list, default, callback)
                local Dropdown = { Value = default or list[1], Flag = flag, Callback = callback or function() end, Opened = false }
                table.insert(Section.Elements, Dropdown)
                UI.Flags[flag or text] = Dropdown.Value
                Dropdown.Frame = Instance.new("Frame")
                Dropdown.Frame.Name = text .. "Dropdown"
                Dropdown.Frame.Parent = Container
                Dropdown.Frame.BackgroundColor3 = UI.Colors.ElementBackground
                Dropdown.Frame.Size = UDim2.new(1, 0, 0, 30)
                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = Color3.fromRGB(34, 26, 40)
                BoxStroke.Parent = Dropdown.Frame
                Dropdown.Label = Instance.new("TextLabel")
                Dropdown.Label.Parent = Dropdown.Frame
                Dropdown.Label.BackgroundTransparency = 1
                Dropdown.Label.Position = UDim2.new(0, 8, 0, 0)
                Dropdown.Label.Size = UDim2.new(1, -16, 1, 0)
                Dropdown.Label.Font = Enum.Font.SourceSans
                Dropdown.Label.Text = text .. ": " .. tostring(Dropdown.Value)
                Dropdown.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                Dropdown.Label.TextSize = 14
                Dropdown.Label.TextXAlignment = Enum.TextXAlignment.Left
                Dropdown.Arrow = Instance.new("ImageLabel")
                Dropdown.Arrow.Parent = Dropdown.Frame
                Dropdown.Arrow.BackgroundTransparency = 1
                Dropdown.Arrow.Position = UDim2.new(1, -20, 0.5, -4)
                Dropdown.Arrow.Size = UDim2.new(0, 8, 0, 8)
                Dropdown.Arrow.Image = "rbxassetid://3926305904"
                Dropdown.Arrow.ImageColor3 = Color3.fromRGB(150, 150, 150)
                Dropdown.List = Instance.new("Frame")
                Dropdown.List.Name = "List"
                Dropdown.List.Parent = Dropdown.Frame
                Dropdown.List.BackgroundColor3 = UI.Colors.ElementBackground
                Dropdown.List.BorderSizePixel = 0
                Dropdown.List.Position = UDim2.new(0, 0, 1, 5)
                Dropdown.List.Size = UDim2.new(1, 0, 0, 0)
                Dropdown.List.ZIndex = 2
                Dropdown.List.ClipsDescendants = true
                Dropdown.List.Visible = false
                local ListStroke = Instance.new("UIStroke")
                ListStroke.Color = Color3.fromRGB(34, 26, 40)
                ListStroke.Parent = Dropdown.List
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Parent = Dropdown.List
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                local function SetOpened(state)
                    Dropdown.Opened = state
                    Dropdown.List.Visible = state
                    if state then
                        Tween(Dropdown.Arrow, 0.2, {Rotation = 180})
                        Tween(Dropdown.List, 0.2, {Size = UDim2.new(1, 0, 0, #list * 20 + (#list - 1) * 2)})
                    else
                        Tween(Dropdown.Arrow, 0.2, {Rotation = 0})
                        Tween(Dropdown.List, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                    end
                    RefreshCanvasSize()
                end
                Dropdown.SetOpened = SetOpened
                for _, item in pairs(list) do
                    local ItemButton = Instance.new("TextButton")
                    ItemButton.Parent = Dropdown.List
                    ItemButton.BackgroundColor3 = UI.Colors.ElementBackground
                    ItemButton.BackgroundTransparency = 1
                    ItemButton.Size = UDim2.new(1, 0, 0, 20)
                    ItemButton.Font = Enum.Font.SourceSans
                    ItemButton.Text = tostring(item)
                    ItemButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                    ItemButton.TextSize = 14
                    ItemButton.AutoButtonColor = false
                    ItemButton.TextXAlignment = Enum.TextXAlignment.Left
                    ItemButton.TextScaled = false
                    ItemButton.TextWrapped = true
                    ItemButton.MouseEnter:Connect(function() Tween(ItemButton, 0.2, {BackgroundTransparency = 0.8}) end)
                    ItemButton.MouseLeave:Connect(function() Tween(ItemButton, 0.2, {BackgroundTransparency = 1}) end)
                    ItemButton.MouseButton1Click:Connect(function()
                        Dropdown.Value = item
                        Dropdown.Label.Text = text .. ": " .. tostring(Dropdown.Value)
                        UI.Flags[flag or text] = Dropdown.Value
                        SetOpened(false)
                        pcall(Dropdown.Callback, Dropdown.Value)
                    end)
                end
                Dropdown.Frame.MouseButton1Click:Connect(function() SetOpened(not Dropdown.Opened) end)
                Dropdown.Update = function(newList, keepOpened)
                    for _, child in pairs(Dropdown.List:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    for _, item in pairs(newList) do
                        local ItemButton = Instance.new("TextButton")
                        ItemButton.Parent = Dropdown.List
                        ItemButton.BackgroundColor3 = UI.Colors.ElementBackground
                        ItemButton.BackgroundTransparency = 1
                        ItemButton.Size = UDim2.new(1, 0, 0, 20)
                        ItemButton.Font = Enum.Font.SourceSans
                        ItemButton.Text = tostring(item)
                        ItemButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                        ItemButton.TextSize = 14
                        ItemButton.AutoButtonColor = false
                        ItemButton.TextXAlignment = Enum.TextXAlignment.Left
                        ItemButton.TextScaled = false
                        ItemButton.TextWrapped = true
                        ItemButton.MouseEnter:Connect(function() Tween(ItemButton, 0.2, {BackgroundTransparency = 0.8}) end)
                        ItemButton.MouseLeave:Connect(function() Tween(ItemButton, 0.2, {BackgroundTransparency = 1}) end)
                        ItemButton.MouseButton1Click:Connect(function()
                            Dropdown.Value = item
                            Dropdown.Label.Text = text .. ": " .. tostring(Dropdown.Value)
                            UI.Flags[flag or text] = Dropdown.Value
                            SetOpened(false)
                            pcall(Dropdown.Callback, Dropdown.Value)
                        end)
                    end
                    if not keepOpened then
                        SetOpened(false)
                    end
                    RefreshCanvasSize()
                end
                UI.Components[flag or text] = Dropdown
                return Dropdown
            end

            function Section:CreateMultiDropdown(text, flag, list, default, callback)
                local MultiDropdown = { Values = default or {}, Flag = flag, Callback = callback or function() end, Opened = false }
                table.insert(Section.Elements, MultiDropdown)
                UI.Flags[flag or text] = MultiDropdown.Values
                MultiDropdown.Frame = Instance.new("Frame")
                MultiDropdown.Frame.Name = text .. "MultiDropdown"
                MultiDropdown.Frame.Parent = Container
                MultiDropdown.Frame.BackgroundColor3 = UI.Colors.ElementBackground
                MultiDropdown.Frame.Size = UDim2.new(1, 0, 0, 30)
                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = Color3.fromRGB(34, 26, 40)
                BoxStroke.Parent = MultiDropdown.Frame
                MultiDropdown.Label = Instance.new("TextLabel")
                MultiDropdown.Label.Parent = MultiDropdown.Frame
                MultiDropdown.Label.BackgroundTransparency = 1
                MultiDropdown.Label.Position = UDim2.new(0, 8, 0, 0)
                MultiDropdown.Label.Size = UDim2.new(1, -16, 1, 0)
                MultiDropdown.Label.Font = Enum.Font.SourceSans
                MultiDropdown.Label.Text = text .. ": " .. (#MultiDropdown.Values > 0 and table.concat(MultiDropdown.Values, ", ") or "None")
                MultiDropdown.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                MultiDropdown.Label.TextSize = 14
                MultiDropdown.Label.TextXAlignment = Enum.TextXAlignment.Left
                MultiDropdown.Arrow = Instance.new("ImageLabel")
                MultiDropdown.Arrow.Parent = MultiDropdown.Frame
                MultiDropdown.Arrow.BackgroundTransparency = 1
                MultiDropdown.Arrow.Position = UDim2.new(1, -20, 0.5, -4)
                MultiDropdown.Arrow.Size = UDim2.new(0, 8, 0, 8)
                MultiDropdown.Arrow.Image = "rbxassetid://3926305904"
                MultiDropdown.Arrow.ImageColor3 = Color3.fromRGB(150, 150, 150)
                MultiDropdown.List = Instance.new("Frame")
                MultiDropdown.List.Name = "List"
                MultiDropdown.List.Parent = MultiDropdown.Frame
                MultiDropdown.List.BackgroundColor3 = UI.Colors.ElementBackground
                MultiDropdown.List.BorderSizePixel = 0
                MultiDropdown.List.Position = UDim2.new(0, 0, 1, 5)
                MultiDropdown.List.Size = UDim2.new(1, 0, 0, 0)
                MultiDropdown.List.ZIndex = 2
                MultiDropdown.List.ClipsDescendants = true
                MultiDropdown.List.Visible = false
                local ListStroke = Instance.new("UIStroke")
                ListStroke.Color = Color3.fromRGB(34, 26, 40)
                ListStroke.Parent = MultiDropdown.List
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Parent = MultiDropdown.List
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                local function SetOpened(state)
                    MultiDropdown.Opened = state
                    MultiDropdown.List.Visible = state
                    if state then
                        Tween(MultiDropdown.Arrow, 0.2, {Rotation = 180})
                        Tween(MultiDropdown.List, 0.2, {Size = UDim2.new(1, 0, 0, #list * 20 + (#list - 1) * 2)})
                    else
                        Tween(MultiDropdown.Arrow, 0.2, {Rotation = 0})
                        Tween(MultiDropdown.List, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                    end
                    RefreshCanvasSize()
                end
                MultiDropdown.SetOpened = SetOpened
                for _, item in pairs(list) do
                    local ItemButton = Instance.new("TextButton")
                    ItemButton.Parent = MultiDropdown.List
                    ItemButton.BackgroundColor3 = UI.Colors.ElementBackground
                    ItemButton.BackgroundTransparency = 1
                    ItemButton.Size = UDim2.new(1, 0, 0, 20)
                    ItemButton.Font = Enum.Font.SourceSans
                    ItemButton.Text = tostring(item)
                    ItemButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                    ItemButton.TextSize = 14
                    ItemButton.AutoButtonColor = false
                    ItemButton.TextXAlignment = Enum.TextXAlignment.Left
                    ItemButton.TextScaled = false
                    ItemButton.TextWrapped = true
                    ItemButton.MouseEnter:Connect(function() Tween(ItemButton, 0.2, {BackgroundTransparency = 0.8}) end)
                    ItemButton.MouseLeave:Connect(function() Tween(ItemButton, 0.2, {BackgroundTransparency = 1}) end)
                    ItemButton.MouseButton1Click:Connect(function()
                        local index = table.find(MultiDropdown.Values, item)
                        if index then
                            table.remove(MultiDropdown.Values, index)
                        else
                            table.insert(MultiDropdown.Values, item)
                        end
                        MultiDropdown.Label.Text = text .. ": " .. (#MultiDropdown.Values > 0 and table.concat(MultiDropdown.Values, ", ") or "None")
                        UI.Flags[flag or text] = MultiDropdown.Values
                        pcall(MultiDropdown.Callback, MultiDropdown.Values)
                    end)
                end
                MultiDropdown.Frame.MouseButton1Click:Connect(function() SetOpened(not MultiDropdown.Opened) end)
                MultiDropdown.Update = function(newList, keepOpened)
                    for _, child in pairs(MultiDropdown.List:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    for _, item in pairs(newList) do
                        local ItemButton = Instance.new("TextButton")
                        ItemButton.Parent = MultiDropdown.List
                        ItemButton.BackgroundColor3 = UI.Colors.ElementBackground
                        ItemButton.BackgroundTransparency = 1
                        ItemButton.Size = UDim2.new(1, 0, 0, 20)
                        ItemButton.Font = Enum.Font.SourceSans
                        ItemButton.Text = tostring(item)
                        ItemButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                        ItemButton.TextSize = 14
                        ItemButton.AutoButtonColor = false
                        ItemButton.TextXAlignment = Enum.TextXAlignment.Left
                        ItemButton.TextScaled = false
                        ItemButton.TextWrapped = true
                        ItemButton.MouseEnter:Connect(function() Tween(ItemButton, 0.2, {BackgroundTransparency = 0.8}) end)
                        ItemButton.MouseLeave:Connect(function() Tween(ItemButton, 0.2, {BackgroundTransparency = 1}) end)
                        ItemButton.MouseButton1Click:Connect(function()
                            local index = table.find(MultiDropdown.Values, item)
                            if index then
                                table.remove(MultiDropdown.Values, index)
                            else
                                table.insert(MultiDropdown.Values, item)
                            end
                            MultiDropdown.Label.Text = text .. ": " .. (#MultiDropdown.Values > 0 and table.concat(MultiDropdown.Values, ", ") or "None")
                            UI.Flags[flag or text] = MultiDropdown.Values
                            pcall(MultiDropdown.Callback, MultiDropdown.Values)
                        end)
                    end
                    if not keepOpened then
                        SetOpened(false)
                    end
                    RefreshCanvasSize()
                end
                UI.Components[flag or text] = MultiDropdown
                return MultiDropdown
            end

            function Section:CreateColorpicker(text, flag, default, callback)
                local Colorpicker = { Value = default or Color3.fromRGB(255, 255, 255), Flag = flag, Callback = callback or function() end, Opened = false }
                table.insert(Section.Elements, Colorpicker)
                UI.Flags[flag or text] = Colorpicker.Value
                Colorpicker.Frame = Instance.new("Frame")
                Colorpicker.Frame.Name = text .. "Colorpicker"
                Colorpicker.Frame.Parent = Container
                Colorpicker.Frame.BackgroundColor3 = UI.Colors.ElementBackground
                Colorpicker.Frame.Size = UDim2.new(1, 0, 0, 30)
                local BoxStroke = Instance.new("UIStroke")
                BoxStroke.Color = Color3.fromRGB(34, 26, 40)
                BoxStroke.Parent = Colorpicker.Frame
                Colorpicker.Label = Instance.new("TextLabel")
                Colorpicker.Label.Parent = Colorpicker.Frame
                Colorpicker.Label.BackgroundTransparency = 1
                Colorpicker.Label.Position = UDim2.new(0, 8, 0, 0)
                Colorpicker.Label.Size = UDim2.new(1, -40, 1, 0)
                Colorpicker.Label.Font = Enum.Font.SourceSans
                Colorpicker.Label.Text = text
                Colorpicker.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                Colorpicker.Label.TextSize = 14
                Colorpicker.Label.TextXAlignment = Enum.TextXAlignment.Left
                Colorpicker.ColorDisplay = Instance.new("Frame")
                Colorpicker.ColorDisplay.Parent = Colorpicker.Frame
                Colorpicker.ColorDisplay.BackgroundColor3 = Colorpicker.Value
                Colorpicker.ColorDisplay.Position = UDim2.new(1, -25, 0.5, -8)
                Colorpicker.ColorDisplay.Size = UDim2.new(0, 16, 0, 16)
                local ColorDisplayStroke = Instance.new("UIStroke")
                ColorDisplayStroke.Color = Color3.fromRGB(34, 26, 40)
                ColorDisplayStroke.Parent = Colorpicker.ColorDisplay
                Colorpicker.PickerFrame = Instance.new("Frame")
                Colorpicker.PickerFrame.Name = "PickerFrame"
                Colorpicker.PickerFrame.Parent = Colorpicker.Frame
                Colorpicker.PickerFrame.BackgroundColor3 = UI.Colors.ElementBackground
                Colorpicker.PickerFrame.BorderSizePixel = 0
                Colorpicker.PickerFrame.Position = UDim2.new(0, 0, 1, 5)
                Colorpicker.PickerFrame.Size = UDim2.new(1, 0, 0, 0)
                Colorpicker.PickerFrame.ZIndex = 2
                Colorpicker.PickerFrame.ClipsDescendants = true
                Colorpicker.PickerFrame.Visible = false
                local PickerFrameStroke = Instance.new("UIStroke")
                PickerFrameStroke.Color = Color3.fromRGB(34, 26, 40)
                PickerFrameStroke.Parent = Colorpicker.PickerFrame
                local ColorWheel = Instance.new("ImageLabel")
                ColorWheel.Parent = Colorpicker.PickerFrame
                ColorWheel.Image = "rbxassetid://507652100"
                ColorWheel.Size = UDim2.new(1, -20, 1, -20)
                ColorWheel.Position = UDim2.new(0, 10, 0, 10)
                ColorWheel.BackgroundTransparency = 1
                local Selector = Instance.new("ImageLabel")
                Selector.Parent = ColorWheel
                Selector.Image = "rbxassetid://3926305904"
                Selector.Size = UDim2.new(0, 10, 0, 10)
                Selector.BackgroundTransparency = 1
                Selector.ImageColor3 = Color3.fromRGB(0, 0, 0)
                local function SetOpened(state)
                    Colorpicker.Opened = state
                    Colorpicker.PickerFrame.Visible = state
                    if state then
                        Tween(Colorpicker.PickerFrame, 0.2, {Size = UDim2.new(1, 0, 0, 150)})
                    else
                        Tween(Colorpicker.PickerFrame, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                    end
                    RefreshCanvasSize()
                end
                Colorpicker.SetOpened = SetOpened
                local function UpdateColor(input)
                    local x = math.clamp(input.Position.X - ColorWheel.AbsolutePosition.X, 0, ColorWheel.AbsoluteSize.X) / ColorWheel.AbsoluteSize.X
                    local y = math.clamp(input.Position.Y - ColorWheel.AbsolutePosition.Y, 0, ColorWheel.AbsoluteSize.Y) / ColorWheel.AbsoluteSize.Y
                    local color = ColorWheel:GetPixel(x * ColorWheel.ImageSize.X, y * ColorWheel.ImageSize.Y)
                    Colorpicker.Value = color
                    Colorpicker.ColorDisplay.BackgroundColor3 = color
                    Selector.Position = UDim2.new(x, -5, y, -5)
                    UI.Flags[flag or text] = color
                    pcall(Colorpicker.Callback, color)
                end
                Colorpicker.Frame.MouseButton1Click:Connect(function() SetOpened(not Colorpicker.Opened) end)
                local picking = false
                ColorWheel.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then picking = true UpdateColor(input) end end)
                UserInputService.InputChanged:Connect(function(input) if picking and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then picking = false end end)
                Colorpicker.Update = function(val) Colorpicker.Value = val Colorpicker.ColorDisplay.BackgroundColor3 = val UI.Flags[flag or text] = val pcall(Colorpicker.Callback, val) end
                UI.Components[flag or text] = Colorpicker
                return Colorpicker
            end
        end

        return Tab
    end

    local isThanks = false

    local function PopulateTab(tab)
        if tab.Name == "Settings" then
            local uiSec = tab:CreateSection("UI")
            uiSec:CreateToggle("Enable Notifications", "NotificationsEnabled", true, function(v)
                UI:Notify("Notifications", "Notifications " .. (v and "enabled" or "disabled"), 2)
            end)
            uiSec:CreateSlider("UI Opacity", "UIOpacity", 0, 100, 90, function(v)
                local transparency = 1 - (v / 100)
                UI.MainFrame.BackgroundTransparency = transparency
            end)

            local cfgSec = tab:CreateSection("Config")
            local selectedCfg = "default"
            local nameInput = "default"
            local cfgDropdown
            cfgDropdown = cfgSec:CreateDropdown("Select Config", "SelectedConfig", UI:GetConfigs(), selectedCfg, function(v)
                selectedCfg = tostring(v or "default")
                nameInput = selectedCfg
            end)
            cfgSec:CreateTextbox("Config Name", "ConfigNameInput", "default", function(text)
                nameInput = tostring(text or "")
            end)
            cfgSec:CreateButton("Load Config", function()
                local name = (nameInput ~= "" and nameInput) or selectedCfg or "default"
                UI:LoadConfig(name)
                UI:Notify("Config", "Loaded: " .. tostring(name), 2.5)
				pcall(function()
					if cfgDropdown and cfgDropdown.Update then
						cfgDropdown:Update(UI:GetConfigs(), true)
						cfgDropdown:SetOpened(cfgDropdown.Opened)
					end
				end)
            end)
            cfgSec:CreateButton("Save Config", function()
                local name = (nameInput ~= "" and nameInput) or selectedCfg or "default"
                UI:SaveConfig(name)
                UI:Notify("Config", "Saved: " .. tostring(name), 2.5)
				pcall(function()
					if cfgDropdown and cfgDropdown.Update then
						cfgDropdown:Update(UI:GetConfigs(), true)
						cfgDropdown:SetOpened(cfgDropdown.Opened)
					end
				end)
            end)
            cfgSec:CreateButton("Delete Config", function()
                local name = (nameInput ~= "" and nameInput) or selectedCfg or "default"
                if name == "default" then
                    UI:Notify("Config", "Cannot delete default config", 2.5)
                    return
                end
                UI:DeleteConfig(name)
                UI:Notify("Config", "Deleted: " .. tostring(name), 2.5)
                selectedCfg = "default"
                nameInput = "default"
				pcall(function()
					if cfgDropdown and cfgDropdown.Update then
						cfgDropdown:Update(UI:GetConfigs(), true)
						cfgDropdown:Set("default")
						cfgDropdown:SetOpened(cfgDropdown.Opened)
					end
				end)
            end)
        end
    end

    _G.UnifiedUI = UI

    if not (_G and _G.UNIFIED_UI_NO_BOOT) then
        Library:CreateWindow()

        local tabOrder = {
            {Name = "Settings"},
        }

        for _, info in ipairs(tabOrder) do
            local t = UI:CreateTab(info.Name, info.Icon)
            PopulateTab(t)
        end

        UI:SelectTab("Settings")
    end

    return UI
end

return Library
