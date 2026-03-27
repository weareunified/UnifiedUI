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

function Library:CreateWindow(options)
    options = options or {}
    local windowTitle = options.Name or "UNIFIED"
    local accentColor = options.AccentColor or Color3.fromRGB(207, 165, 255)
    
    local UI = {
        CurrentTab = nil,
        Tabs = {}
    }
    
    UI.ScreenGui = Instance.new("ScreenGui")
    UI.ScreenGui.Name = "Unified_V4"
    UI.ScreenGui.ResetOnSpawn = false
    UI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    
    if gethui then
        UI.ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(UI.ScreenGui)
        UI.ScreenGui.Parent = game:GetService("CoreGui")
    else
        UI.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    UI.MainFrame = Instance.new("Frame")
    UI.MainFrame.Name = "MainFrame"
    UI.MainFrame.Parent = UI.ScreenGui
    UI.MainFrame.BackgroundColor3 = Color3.fromRGB(9, 8, 9)
    UI.MainFrame.BorderSizePixel = 0
    UI.MainFrame.Position = UDim2.new(0.5, -315, 0.5, -210)
    UI.MainFrame.Size = UDim2.new(0, 630, 0, 420)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(34, 26, 40)
    MainStroke.Thickness = 1.5
    MainStroke.Parent = UI.MainFrame

    UI.LeftPanel = Instance.new("Frame")
    UI.LeftPanel.Name = "LeftPanel"
    UI.LeftPanel.Parent = UI.MainFrame
    UI.LeftPanel.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
    UI.LeftPanel.BorderSizePixel = 0
    UI.LeftPanel.Size = UDim2.new(0, 180, 1, 0)

    local LeftStroke = Instance.new("UIStroke")
    LeftStroke.Color = Color3.fromRGB(34, 26, 40)
    LeftStroke.Thickness = 1.5
    LeftStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
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

    local UserStroke = Instance.new("UIStroke")
    UserStroke.Color = Color3.fromRGB(34, 26, 40)
    UserStroke.Thickness = 1
    UserStroke.Parent = UI.UserPanel

    UI.UserName = Instance.new("TextLabel")
    UI.UserName.Name = "UserName"
    UI.UserName.Parent = UI.UserPanel
    UI.UserName.BackgroundTransparency = 1
    UI.UserName.Position = UDim2.new(0, 10, 0, 0)
    UI.UserName.Size = UDim2.new(1, -20, 1, 0)
    UI.UserName.Font = Enum.Font.SourceSans
    UI.UserName.Text = LocalPlayer.Name:lower()
    UI.UserName.TextColor3 = Color3.fromRGB(180, 180, 180)
    UI.UserName.TextSize = 14
    UI.UserName.TextXAlignment = Enum.TextXAlignment.Left

    UI.MainContent = Instance.new("Frame")
    UI.MainContent.Name = "MainContent"
    UI.MainContent.Parent = UI.MainFrame
    UI.MainContent.BackgroundTransparency = 1
    UI.MainContent.Position = UDim2.new(0, 180, 0, 0)
    UI.MainContent.Size = UDim2.new(1, -180, 1, 0)

    local dragging, dragInput, dragStart, startPos
    UI.MainFrame.InputBegan:Connect(function(input)
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
    end)
    UI.MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            UI.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    function UI:CreateTab(name)
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
        Tab.Button.Text = name
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

        Tab.Page = Instance.new("ScrollingFrame")
        Tab.Page.Name = name .. "Page"
        Tab.Page.Parent = UI.MainContent
        Tab.Page.BackgroundTransparency = 1
        Tab.Page.BorderSizePixel = 0
        Tab.Page.Size = UDim2.new(1, 0, 1, 0)
        Tab.Page.Visible = false
        Tab.Page.ScrollBarThickness = 0
        Tab.Page.CanvasSize = UDim2.new(0, 0, 0, 0)

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 20)
        PagePadding.PaddingLeft = UDim.new(0, 20)
        PagePadding.PaddingRight = UDim.new(0, 20)
        PagePadding.Parent = Tab.Page

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Tab.Page
        PageLayout.Padding = UDim.new(0, 12)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 40)
        end)

        Tab.Button.MouseButton1Click:Connect(function()
            if UI.CurrentTab == Tab then return end
            
            if UI.CurrentTab then
                UI.CurrentTab.Page.Visible = false
                Tween(UI.CurrentTab.Button, 0.3, {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1})
                Tween(UI.CurrentTab.Button.Indicator, 0.3, {BackgroundTransparency = 1})
            end
            
            Tab.Page.Visible = true
            UI.CurrentTab = Tab
            Tween(Tab.Button, 0.3, {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92})
            Tween(TabIndicator, 0.3, {BackgroundTransparency = 0})
        end)

        if #UI.Tabs == 0 then
            Tab.Page.Visible = true
            UI.CurrentTab = Tab
            Tab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Tab.Button.BackgroundTransparency = 0.92
            TabIndicator.BackgroundTransparency = 0
        end

        function Tab:CreateSection(title)
            local Section = {}
            
            Section.Frame = Instance.new("Frame")
            Section.Frame.Name = title .. "Section"
            Section.Frame.Parent = Tab.Page
            Section.Frame.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
            Section.Frame.BorderSizePixel = 0
            Section.Frame.Size = UDim2.new(1, 0, 0, 40)

            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = Color3.fromRGB(34, 26, 40)
            SectionStroke.Thickness = 1.2
            SectionStroke.Parent = Section.Frame

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

            return Section
        end

        table.insert(UI.Tabs, Tab)
        return Tab
    end

    return UI
end

return Library
