local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
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

function Library:CreateWindow(options)
    options = options or {}
    local windowTitle = options.Name or "UNIFIED"
    local accentColor = options.AccentColor or Color3.fromRGB(207, 165, 255)
    
    local UI = {
        CurrentTab = nil,
        Tabs = {}
    }
    
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
    UI.MainFrame.BackgroundColor3 = Color3.fromRGB(9, 8, 9)
    UI.MainFrame.BorderSizePixel = 0
    UI.MainFrame.Position = UDim2.new(0.5, -315, 0.5, -210)
    UI.MainFrame.Size = UDim2.new(0, 630, 0, 420)
    UI.MainFrame.ClipsDescendants = true
    UI.MainFrame.BackgroundTransparency = 1
    UI.MainFrame.Size = UDim2.new(0, 600, 0, 400)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(34, 26, 40)
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 1
    MainStroke.Parent = UI.MainFrame

    UI.LeftPanel = Instance.new("Frame")
    UI.LeftPanel.Name = "LeftPanel"
    UI.LeftPanel.Parent = UI.MainFrame
    UI.LeftPanel.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
    UI.LeftPanel.BorderSizePixel = 0
    UI.LeftPanel.Size = UDim2.new(0, 180, 1, 0)
    UI.LeftPanel.BackgroundTransparency = 1

    local LeftStroke = Instance.new("UIStroke")
    LeftStroke.Color = Color3.fromRGB(34, 26, 40)
    LeftStroke.Thickness = 1.5
    LeftStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    LeftStroke.Transparency = 1
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
    UI.TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    UI.TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    UI.TitleLabel.Font = Enum.Font.SourceSansBold
    UI.TitleLabel.Text = windowTitle
    UI.TitleLabel.TextColor3 = accentColor
    UI.TitleLabel.TextSize = 22
    UI.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    UI.TitleLabel.TextTransparency = 1

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
    UI.UserPanel.BackgroundTransparency = 1

    local UserStroke = Instance.new("UIStroke")
    UserStroke.Color = Color3.fromRGB(34, 26, 40)
    UserStroke.Thickness = 1
    UserStroke.Transparency = 1
    UserStroke.Parent = UI.UserPanel

    UI.UserImage = Instance.new("ImageLabel")
    UI.UserImage.Name = "UserImage"
    UI.UserImage.Parent = UI.UserPanel
    UI.UserImage.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    UI.UserImage.Position = UDim2.new(0, 5, 0.5, -12)
    UI.UserImage.Size = UDim2.new(0, 24, 0, 24)
    UI.UserImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    UI.UserImage.BackgroundTransparency = 1
    UI.UserImage.ImageTransparency = 1

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
    UI.UserName.TextTransparency = 1
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

    task.spawn(function()
        Tween(UI.MainFrame, 0.6, {Size = UDim2.new(0, 630, 0, 420), Position = UDim2.new(0.5, -315, 0.5, -210), BackgroundTransparency = 0})
        Tween(MainStroke, 0.6, {Transparency = 0})
        Tween(UI.LeftPanel, 0.6, {BackgroundTransparency = 0})
        Tween(LeftStroke, 0.6, {Transparency = 0})
        Tween(UI.TitleLabel, 0.8, {TextTransparency = 0})
        Tween(UI.UserPanel, 0.8, {BackgroundTransparency = 0})
        Tween(UserStroke, 0.8, {Transparency = 0})
        Tween(UI.UserName, 0.8, {TextTransparency = 0})
        Tween(UI.UserImage, 0.8, {ImageTransparency = 0})
    end)

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

    function UI:CreateTab(name, iconId)
        local Tab = {
            Sections = {}
        }
        
        Tab.Button = Instance.new("TextButton")
        Tab.Button.Name = name .. "Tab"
        Tab.Button.Parent = UI.TabContainer
        Tab.Button.BackgroundColor3 = accentColor
        Tab.Button.BackgroundTransparency = 1
        Tab.Button.Size = UDim2.new(1, 0, 0, 34)
        Tab.Button.Font = Enum.Font.SourceSans
        Tab.Button.Text = iconId and "      " .. name or name
        Tab.Button.TextColor3 = Color3.fromRGB(150, 150, 150)
        Tab.Button.TextSize = 15
        Tab.Button.AutoButtonColor = false

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = Tab.Button

        local TabIndicator = Instance.new("Frame")
        TabIndicator.Name = "Indicator"
        TabIndicator.Parent = Tab.Button
        TabIndicator.BackgroundColor3 = accentColor
        TabIndicator.Position = UDim2.new(0, 0, 0, 0)
        TabIndicator.Size = UDim2.new(0, 2, 1, 0)
        TabIndicator.BackgroundTransparency = 1

        local TabIndicatorCorner = Instance.new("UICorner")
        TabIndicatorCorner.CornerRadius = UDim.new(0, 4)
        TabIndicatorCorner.Parent = TabIndicator

        if iconId then
            local TabIcon = Instance.new("ImageLabel")
            TabIcon.Name = "Icon"
            TabIcon.Parent = Tab.Button
            TabIcon.BackgroundTransparency = 1
            TabIcon.Position = UDim2.new(0, 8, 0.5, -8)
            TabIcon.Size = UDim2.new(0, 16, 0, 16)
            TabIcon.Image = iconId
            TabIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
            Tab.Icon = TabIcon
        end

        Tab.Page = Instance.new("Frame")
        Tab.Page.Name = name .. "Page"
        Tab.Page.Parent = UI.MainContent
        Tab.Page.BackgroundTransparency = 1
        Tab.Page.BorderSizePixel = 0
        Tab.Page.Size = UDim2.new(1, 0, 1, 0)
        Tab.Page.Visible = false
        Tab.Page.ClipsDescendants = true 

        Tab.Content = Instance.new("ScrollingFrame")
        Tab.Content.Name = "Content"
        Tab.Content.Parent = Tab.Page
        Tab.Content.BackgroundTransparency = 1
        Tab.Content.BorderSizePixel = 0
        Tab.Content.Position = UDim2.new(0, 10, 0, 10)
        Tab.Content.Size = UDim2.new(1, -20, 1, -20)
        Tab.Content.ScrollBarThickness = 2
        Tab.Content.ScrollBarImageColor3 = accentColor
        Tab.Content.CanvasSize = UDim2.new(0, 0, 0, 0)
        Tab.Content.ClipsDescendants = false

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = Tab.Content
        ContentLayout.Padding = UDim.new(0, 12)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
        end)

        Tab.Button.MouseEnter:Connect(function()
            if UI.CurrentTab ~= Tab then
                Tween(Tab.Button, 0.2, {TextColor3 = Color3.fromRGB(200, 200, 200), BackgroundTransparency = 0.96})
            end
        end)

        Tab.Button.MouseLeave:Connect(function()
            if UI.CurrentTab ~= Tab then
                Tween(Tab.Button, 0.2, {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1})
            end
        end)

        Tab.Button.MouseButton1Click:Connect(function()
            if UI.CurrentTab == Tab then return end
            
            if UI.CurrentTab then
                local oldTab = UI.CurrentTab
                Tween(oldTab.Button, 0.3, {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1})
                Tween(oldTab.Button.Indicator, 0.3, {BackgroundTransparency = 1})
                if oldTab.Icon then
                    Tween(oldTab.Icon, 0.3, {ImageColor3 = Color3.fromRGB(150, 150, 150)})
                end
                
                local oldGroup = oldTab.Page:FindFirstChild("CanvasGroup")
                if oldGroup then
                    Tween(oldGroup, 0.3, {GroupTransparency = 1, Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10)})
                    task.delay(0.3, function() oldTab.Page.Visible = false end)
                else
                    oldTab.Page.Visible = false
                end
            end
            
            UI.CurrentTab = Tab
            Tab.Page.Visible = true
            
            local canvasGroup = Tab.Page:FindFirstChild("CanvasGroup")
            if not canvasGroup then
                canvasGroup = Instance.new("CanvasGroup", Tab.Page)
                canvasGroup.Name = "CanvasGroup"
                canvasGroup.Size = UDim2.new(1, 0, 1, 0)
                canvasGroup.BackgroundTransparency = 1
                for _, child in pairs(Tab.Page:GetChildren()) do
                    if child ~= canvasGroup then child.Parent = canvasGroup end
                end
            end
            
            canvasGroup.GroupTransparency = 1
            canvasGroup.Size = UDim2.new(1, 40, 1, 40)
            canvasGroup.Position = UDim2.new(0, -20, 0, -20)
            
            Tween(canvasGroup, 0.4, {GroupTransparency = 0, Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)})

            Tween(Tab.Button, 0.3, {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92})
            Tween(TabIndicator, 0.3, {BackgroundTransparency = 0})
            if Tab.Icon then
                Tween(Tab.Icon, 0.3, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
            end
        end)

        if #UI.Tabs == 0 then
            Tab.Page.Visible = true
            UI.CurrentTab = Tab
            Tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Tab.Button.BackgroundTransparency = 0.92
            TabIndicator.BackgroundTransparency = 0
            if Tab.Icon then
                Tab.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
        end

        function Tab:CreateSection(title)
            local Section = {}
            local parent = Tab.Content
            
            Section.Frame = Instance.new("Frame")
            Section.Frame.Name = title .. "Section"
            Section.Frame.Parent = parent
            Section.Frame.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
            Section.Frame.BorderSizePixel = 0
            Section.Frame.Size = UDim2.new(1, 0, 0, 40)
            Section.Frame.ClipsDescendants = false

            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = Color3.fromRGB(34, 26, 40)
            SectionStroke.Thickness = 1.2
            SectionStroke.Transparency = 0.5
            SectionStroke.Parent = Section.Frame

            Section.Frame.MouseEnter:Connect(function()
                Tween(SectionStroke, 0.3, {Color = accentColor, Transparency = 0.2})
            end)

            Section.Frame.MouseLeave:Connect(function()
                Tween(SectionStroke, 0.3, {Color = Color3.fromRGB(34, 26, 40), Transparency = 0.5})
            end)

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
                local Button = {
                    Callback = callback or function() end
                }
                
                Button.Frame = Instance.new("TextButton")
                Button.Frame.Name = text .. "Button"
                Button.Frame.Parent = Container
                Button.Frame.BackgroundColor3 = Color3.fromRGB(11, 10, 11)
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
                    Tween(Button.Frame, 0.2, {BackgroundColor3 = Color3.fromRGB(16, 15, 16)})
                    Tween(BtnStroke, 0.2, {Color = Color3.fromRGB(50, 40, 60)})
                end)

                Button.Frame.MouseLeave:Connect(function()
                    Tween(Button.Frame, 0.2, {BackgroundColor3 = Color3.fromRGB(11, 10, 11)})
                    Tween(BtnStroke, 0.2, {Color = Color3.fromRGB(34, 26, 40)})
                end)

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

            function Section:CreateToggle(text, default, callback)
                local Toggle = {
                    State = default or false,
                    Callback = callback or function() end
                }
                
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
                Toggle.Box.BackgroundColor3 = Color3.fromRGB(11, 10, 11)
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

                local function Update()
                    if Toggle.State then
                        Tween(Toggle.Indicator, 0.2, {Position = UDim2.new(1, -14, 0.5, -6), BackgroundTransparency = 0})
                        Tween(BoxStroke, 0.2, {Color = accentColor})
                    else
                        Tween(Toggle.Indicator, 0.2, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundTransparency = 1})
                        Tween(BoxStroke, 0.2, {Color = Color3.fromRGB(34, 26, 40)})
                    end
                    pcall(Toggle.Callback, Toggle.State)
                end

                Toggle.Frame.MouseButton1Click:Connect(function()
                    Toggle.State = not Toggle.State
                    Update()
                end)

                return Toggle
            end

            function Section:CreateSlider(text, min, max, default, callback)
                local Slider = {
                    Value = default or min,
                    Min = min,
                    Max = max,
                    Callback = callback or function() end
                }

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
                Slider.Bar.BackgroundColor3 = Color3.fromRGB(11, 10, 11)
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

                local function Update(input)
                    local pos = math.clamp((input.Position.X - Slider.Bar.AbsolutePosition.X) / Slider.Bar.AbsoluteSize.X, 0, 1)
                    Slider.Value = math.floor(min + (max - min) * pos)
                    Slider.Fill.Size = UDim2.new(pos, 0, 1, 0)
                    Slider.ValueLabel.Text = tostring(Slider.Value)
                    pcall(Slider.Callback, Slider.Value)
                end

                local sliding = false
                Slider.Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        Update(input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        Update(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)

                return Slider
            end

            function Section:CreateTextbox(text, placeholder, callback)
                local Textbox = {
                    Callback = callback or function() end
                }

                Textbox.Frame = Instance.new("Frame")
                Textbox.Frame.Name = text .. "Textbox"
                Textbox.Frame.Parent = Container
                Textbox.Frame.BackgroundColor3 = Color3.fromRGB(11, 10, 11)
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

                Textbox.Input.FocusLost:Connect(function(enter)
                    if enter then
                        pcall(Textbox.Callback, Textbox.Input.Text)
                    end
                end)

                return Textbox
            end

            function Section:CreateBind(text, default, callback)
                local Bind = {
                    Key = default or Enum.KeyCode.F,
                    Callback = callback or function() end,
                    Waiting = false
                }

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
                Bind.Btn.BackgroundColor3 = Color3.fromRGB(11, 10, 11)
                Bind.Btn.Position = UDim2.new(1, -50, 0.5, -10)
                Bind.Btn.Size = UDim2.new(0, 50, 0, 20)
                Bind.Btn.Font = Enum.Font.SourceSans
                Bind.Btn.Text = Bind.Key.Name:upper()
                Bind.Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                Bind.Btn.TextSize = 12

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Color3.fromRGB(34, 26, 40)
                BtnStroke.Parent = Bind.Btn

                Bind.Btn.MouseButton1Click:Connect(function()
                    Bind.Waiting = true
                    Bind.Btn.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if Bind.Waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                        Bind.Key = input.KeyCode
                        Bind.Btn.Text = Bind.Key.Name:upper()
                        Bind.Waiting = false
                    elseif not Bind.Waiting and input.KeyCode == Bind.Key then
                        pcall(Bind.Callback)
                    end
                end)

                return Bind
            end

            function Section:CreateToggleBind(text, defaultState, defaultKey, callback)
                local ToggleBind = {
                    State = defaultState or false,
                    Key = defaultKey or Enum.KeyCode.F,
                    Callback = callback or function() end,
                    Waiting = false
                }

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
                ToggleBind.Box.BackgroundColor3 = Color3.fromRGB(11, 10, 11)
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
                ToggleBind.Btn.BackgroundColor3 = Color3.fromRGB(11, 10, 11)
                ToggleBind.Btn.Position = UDim2.new(1, -90, 0.5, -10)
                ToggleBind.Btn.Size = UDim2.new(0, 50, 0, 20)
                ToggleBind.Btn.Font = Enum.Font.SourceSans
                ToggleBind.Btn.Text = ToggleBind.Key.Name:upper()
                ToggleBind.Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                ToggleBind.Btn.TextSize = 12

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Color3.fromRGB(34, 26, 40)
                BtnStroke.Parent = ToggleBind.Btn

                local function Update()
                    if ToggleBind.State then
                        Tween(ToggleBind.Indicator, 0.2, {Position = UDim2.new(1, -14, 0.5, -6), BackgroundTransparency = 0})
                        Tween(BoxStroke, 0.2, {Color = accentColor})
                    else
                        Tween(ToggleBind.Indicator, 0.2, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundTransparency = 1})
                        Tween(BoxStroke, 0.2, {Color = Color3.fromRGB(34, 26, 40)})
                    end
                    pcall(ToggleBind.Callback, ToggleBind.State, ToggleBind.Key)
                end

                ToggleBind.Box.MouseButton1Click:Connect(function()
                    ToggleBind.State = not ToggleBind.State
                    Update()
                end)

                ToggleBind.Btn.MouseButton1Click:Connect(function()
                    ToggleBind.Waiting = true
                    ToggleBind.Btn.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if ToggleBind.Waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                        ToggleBind.Key = input.KeyCode
                        ToggleBind.Btn.Text = ToggleBind.Key.Name:upper()
                        ToggleBind.Waiting = false
                        Update()
                    elseif not ToggleBind.Waiting and input.KeyCode == ToggleBind.Key then
                        ToggleBind.State = not ToggleBind.State
                        Update()
                    end
                end)

                return ToggleBind
            end

            function Section:CreateCodeblock(text, code)
                local Codeblock = {}
                local rawCode = code:gsub("<font.->", ""):gsub("</font>", "")

                Codeblock.Frame = Instance.new("Frame")
                Codeblock.Frame.Name = text .. "Codeblock"
                Codeblock.Frame.Parent = Container
                Codeblock.Frame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
                Codeblock.Frame.Size = UDim2.new(1, 0, 0, 100)

                local CodeStroke = Instance.new("UIStroke")
                CodeStroke.Color = Color3.fromRGB(25, 20, 30)
                CodeStroke.Parent = Codeblock.Frame

                Codeblock.Label = Instance.new("TextLabel")
                Codeblock.Label.Parent = Codeblock.Frame
                Codeblock.Label.BackgroundTransparency = 1
                Codeblock.Label.Position = UDim2.new(0, 8, 0, 8)
                Codeblock.Label.Size = UDim2.new(1, -16, 1, -16)
                Codeblock.Label.Font = Enum.Font.Code
                Codeblock.Label.RichText = true
                Codeblock.Label.Text = code or ""
                Codeblock.Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                Codeblock.Label.TextSize = 12
                Codeblock.Label.TextXAlignment = Enum.TextXAlignment.Left
                Codeblock.Label.TextYAlignment = Enum.TextYAlignment.Top

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
                    Tween(Codeblock.CopyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
                    Tween(CopyStroke, 0.2, {Color = accentColor})
                end)

                Codeblock.CopyBtn.MouseLeave:Connect(function()
                    Tween(Codeblock.CopyBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(15, 15, 15)})
                    Tween(CopyStroke, 0.2, {Color = Color3.fromRGB(35, 30, 45)})
                end)

                Codeblock.CopyBtn.MouseButton1Click:Connect(function()
                    if setclipboard then
                        setclipboard(rawCode)
                        UI:Notify("UNIFIED", "Code copied to clipboard!")
                        
                        Codeblock.CopyBtn.Text = "COPIED"
                        task.delay(2, function()
                            Codeblock.CopyBtn.Text = "COPY"
                        end)
                    else
                        UI:Notify("ERROR", "Exploit does not support setclipboard!")
                    end
                end)

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

            function Section:CreateDropdown(text, options, default, callback)
                local Dropdown = {
                    Options = options or {},
                    Selected = default,
                    Callback = callback or function() end,
                    Opened = false
                }

                Dropdown.Frame = Instance.new("Frame")
                Dropdown.Frame.Name = text .. "Dropdown"
                Dropdown.Frame.Parent = Container
                Dropdown.Frame.BackgroundColor3 = Color3.fromRGB(11, 10, 11)
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

                local function Update()
                    Dropdown.Label.Text = text .. ": " .. (Dropdown.Selected or "None")
                    pcall(Dropdown.Callback, Dropdown.Selected)
                end

                for _, option in pairs(Dropdown.Options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Name = option
                    OptBtn.Parent = Dropdown.List
                    OptBtn.BackgroundColor3 = Color3.fromRGB(11, 10, 11)
                    OptBtn.BorderSizePixel = 0
                    OptBtn.Size = UDim2.new(1, 0, 0, 25)
                    OptBtn.Font = Enum.Font.SourceSans
                    OptBtn.Text = "  " .. option
                    OptBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
                    OptBtn.TextSize = 14
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.ZIndex = 110

                    OptBtn.MouseButton1Click:Connect(function()
                        Dropdown.Selected = option
                        Update()
                        Dropdown.Opened = false
                        Dropdown.Frame.ZIndex = 5
                        Section.Frame.ZIndex = 1
                        Tween(Dropdown.List, 0.3, {Size = UDim2.new(1, 0, 0, 0)})
                        task.delay(0.3, function() Dropdown.List.Visible = false end)
                        Dropdown.Icon.Text = "+"
                    end)
                end

                Dropdown.Frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dropdown.Opened = not Dropdown.Opened
                        if Dropdown.Opened then
                            Dropdown.Frame.ZIndex = 100
                            Section.Frame.ZIndex = 10
                            Dropdown.List.Visible = true
                            Tween(Dropdown.List, 0.3, {Size = UDim2.new(1, 0, 0, #Dropdown.Options * 25)})
                            Dropdown.Icon.Text = "-"
                        else
                            Dropdown.Frame.ZIndex = 5
                            Tween(Dropdown.List, 0.3, {Size = UDim2.new(1, 0, 0, 0)})
                            task.delay(0.3, function() 
                                Dropdown.List.Visible = false 
                                if not Dropdown.Opened then Section.Frame.ZIndex = 1 end
                            end)
                            Dropdown.Icon.Text = "+"
                        end
                    end
                end)

                return Dropdown
            end

            function Section:CreateMultiDropdown(text, options, default, callback)
                local Dropdown = {
                    Options = options or {},
                    Selected = default or {},
                    Callback = callback or function() end,
                    Opened = false
                }

                Dropdown.Frame = Instance.new("Frame")
                Dropdown.Frame.Name = text .. "MultiDropdown"
                Dropdown.Frame.Parent = Container
                Dropdown.Frame.BackgroundColor3 = Color3.fromRGB(11, 10, 11)
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

                local function Update()
                    pcall(Dropdown.Callback, Dropdown.Selected)
                end

                for _, option in pairs(Dropdown.Options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Name = option
                    OptBtn.Parent = Dropdown.List
                    OptBtn.BackgroundColor3 = Color3.fromRGB(11, 10, 11)
                    OptBtn.BorderSizePixel = 0
                    OptBtn.Size = UDim2.new(1, 0, 0, 25)
                    OptBtn.Font = Enum.Font.SourceSans
                    OptBtn.Text = "  " .. option
                    OptBtn.TextColor3 = table.find(Dropdown.Selected, option) and accentColor or Color3.fromRGB(150, 150, 150)
                    OptBtn.TextSize = 14
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.ZIndex = 110

                    OptBtn.MouseButton1Click:Connect(function()
                        local index = table.find(Dropdown.Selected, option)
                        if index then
                            table.remove(Dropdown.Selected, index)
                            Tween(OptBtn, 0.2, {TextColor3 = Color3.fromRGB(150, 150, 150)})
                        else
                            table.insert(Dropdown.Selected, option)
                            Tween(OptBtn, 0.2, {TextColor3 = accentColor})
                        end
                        Update()
                    end)
                end

                Dropdown.Frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dropdown.Opened = not Dropdown.Opened
                        if Dropdown.Opened then
                            Dropdown.Frame.ZIndex = 100
                            Section.Frame.ZIndex = 10
                            Dropdown.List.Visible = true
                            Tween(Dropdown.List, 0.3, {Size = UDim2.new(1, 0, 0, #Dropdown.Options * 25)})
                            Dropdown.Icon.Text = "-"
                        else
                            Dropdown.Frame.ZIndex = 5
                            Tween(Dropdown.List, 0.3, {Size = UDim2.new(1, 0, 0, 0)})
                            task.delay(0.3, function() 
                                Dropdown.List.Visible = false 
                                if not Dropdown.Opened then Section.Frame.ZIndex = 1 end
                            end)
                            Dropdown.Icon.Text = "+"
                        end
                    end
                end)

                return Dropdown
            end

            return Section
        end

        table.insert(UI.Tabs, Tab)
        return Tab
    end

    return UI
end

return Library
