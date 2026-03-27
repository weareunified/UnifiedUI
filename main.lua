local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function Library:CreateWindow(title)
    local UI = {}
    
    UI.ScreenGui = Instance.new("ScreenGui")
    UI.ScreenGui.Name = "Unified"
    UI.ScreenGui.ResetOnSpawn = false
    UI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
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
    UI.MainFrame.Position = UDim2.new(0.5, -296, 0.5, -364)
    UI.MainFrame.Size = UDim2.new(0, 593, 0, 728)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(34, 26, 40)
    MainStroke.Thickness = 1.8
    MainStroke.Transparency = 0.1
    MainStroke.Parent = UI.MainFrame

    UI.TopBar = Instance.new("Frame")
    UI.TopBar.Name = "TopBar"
    UI.TopBar.Parent = UI.MainFrame
    UI.TopBar.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
    UI.TopBar.BorderSizePixel = 0
    UI.TopBar.Size = UDim2.new(1, 0, 0, 44)

    local TopStroke = Instance.new("UIStroke")
    TopStroke.Color = Color3.fromRGB(34, 26, 40)
    TopStroke.Thickness = 1.8
    TopStroke.Transparency = 0.1
    TopStroke.Parent = UI.TopBar

    UI.TitleLabel = Instance.new("TextLabel")
    UI.TitleLabel.Name = "TitleLabel"
    UI.TitleLabel.Parent = UI.TopBar
    UI.TitleLabel.BackgroundTransparency = 1
    UI.TitleLabel.Position = UDim2.new(0.01, 0, 0.136, 0)
    UI.TitleLabel.Size = UDim2.new(0, 275, 0, 32)
    UI.TitleLabel.Font = Enum.Font.SourceSans
    UI.TitleLabel.Text = title or "Unified.wtf | UI | dsc.gg/unifiedhub"
    UI.TitleLabel.TextColor3 = Color3.fromRGB(207, 165, 255)
    UI.TitleLabel.TextSize = 21
    UI.TitleLabel.TextStrokeColor3 = Color3.fromRGB(61, 44, 73)
    UI.TitleLabel.TextStrokeTransparency = 0
    UI.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    UI.CloseBtn = Instance.new("TextButton")
    UI.CloseBtn.Name = "CloseBtn"
    UI.CloseBtn.Parent = UI.TopBar
    UI.CloseBtn.BackgroundTransparency = 1
    UI.CloseBtn.Position = UDim2.new(0.934, 0, 0, 0)
    UI.CloseBtn.Size = UDim2.new(0, 39, 0, 38)
    UI.CloseBtn.Font = Enum.Font.SourceSans
    UI.CloseBtn.Text = "×"
    UI.CloseBtn.TextColor3 = Color3.fromRGB(255, 150, 237)
    UI.CloseBtn.TextSize = 41

    UI.CloseBtn.MouseButton1Click:Connect(function()
        UI.ScreenGui:Destroy()
    end)

    UI.TabContainer = Instance.new("Frame")
    UI.TabContainer.Name = "TabContainer"
    UI.TabContainer.Parent = UI.MainFrame
    UI.TabContainer.BackgroundColor3 = Color3.fromRGB(9, 8, 9)
    UI.TabContainer.BorderSizePixel = 0
    UI.TabContainer.Position = UDim2.new(0.013, 0, 0.073, 0)
    UI.TabContainer.Size = UDim2.new(0, 573, 0, 77)

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = UI.TabContainer
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    UI.ContentContainer = Instance.new("Frame")
    UI.ContentContainer.Name = "ContentContainer"
    UI.ContentContainer.Parent = UI.MainFrame
    UI.ContentContainer.BackgroundTransparency = 1
    UI.ContentContainer.Position = UDim2.new(0, 0, 0.18, 0)
    UI.ContentContainer.Size = UDim2.new(1, 0, 0.82, 0)

    local dragging, dragInput, dragStart, startPos
    UI.TopBar.InputBegan:Connect(function(input)
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
    UI.TopBar.InputChanged:Connect(function(input)
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

    UI.Tabs = {}
    function UI:CreateTab(name)
        local Tab = {}
        
        Tab.Button = Instance.new("TextButton")
        Tab.Button.Name = name .. "Tab"
        Tab.Button.Parent = UI.TabContainer
        Tab.Button.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        Tab.Button.Size = UDim2.new(0, 102, 0, 39)
        Tab.Button.Font = Enum.Font.SourceSans
        Tab.Button.Text = name
        Tab.Button.TextColor3 = Color3.fromRGB(207, 165, 255)
        Tab.Button.TextSize = 18

        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = Color3.fromRGB(34, 26, 40)
        TabStroke.Thickness = 1.8
        TabStroke.Transparency = 0.1
        TabStroke.Parent = Tab.Button

        Tab.Page = Instance.new("Frame")
        Tab.Page.Name = name .. "Page"
        Tab.Page.Parent = UI.ContentContainer
        Tab.Page.BackgroundTransparency = 1
        Tab.Page.Size = UDim2.new(1, 0, 1, 0)
        Tab.Page.Visible = false

        local LeftColumn = Instance.new("ScrollingFrame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Parent = Tab.Page
        LeftColumn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        LeftColumn.BorderSizePixel = 0
        LeftColumn.Position = UDim2.new(0.02, 0, 0.02, 0)
        LeftColumn.Size = UDim2.new(0, 262, 0, 580)
        LeftColumn.ScrollBarThickness = 0
        LeftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)

        local RightColumn = Instance.new("ScrollingFrame")
        RightColumn.Name = "RightColumn"
        RightColumn.Parent = Tab.Page
        RightColumn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        RightColumn.BorderSizePixel = 0
        RightColumn.Position = UDim2.new(0.53, 0, 0.02, 0)
        RightColumn.Size = UDim2.new(0, 262, 0, 580)
        RightColumn.ScrollBarThickness = 0
        RightColumn.CanvasSize = UDim2.new(0, 0, 0, 0)

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Parent = LeftColumn
        LeftLayout.Padding = UDim.new(0, 5)
        LeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Parent = RightColumn
        RightLayout.Padding = UDim.new(0, 5)
        RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        Tab.Button.MouseButton1Click:Connect(function()
            for _, t in pairs(UI.Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
            end
            Tab.Page.Visible = true
            Tab.Button.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
        end)

        if #UI.Tabs == 0 then
            Tab.Page.Visible = true
            Tab.Button.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
        end

        function Tab:CreateSection(title, side)
            local Section = {}
            local parent = (side == "Right" and RightColumn or LeftColumn)
            
            Section.Frame = Instance.new("Frame")
            Section.Frame.Name = title .. "Section"
            Section.Frame.Parent = parent
            Section.Frame.BackgroundTransparency = 1
            Section.Frame.Size = UDim2.new(0.95, 0, 0, 40)

            Section.Title = Instance.new("TextLabel")
            Section.Title.Name = "Title"
            Section.Title.Parent = Section.Frame
            Section.Title.BackgroundTransparency = 1
            Section.Title.Size = UDim2.new(1, 0, 0, 32)
            Section.Title.Font = Enum.Font.SourceSans
            Section.Title.Text = title:upper()
            Section.Title.TextColor3 = Color3.fromRGB(207, 165, 255)
            Section.Title.TextSize = 19
            Section.Title.TextXAlignment = Enum.TextXAlignment.Left

            local TitleStroke = Instance.new("UIStroke")
            TitleStroke.Color = Color3.fromRGB(34, 26, 40)
            TitleStroke.Thickness = 1.8
            TitleStroke.Transparency = 0.1
            TitleStroke.Parent = Section.Title

            local Container = Instance.new("Frame")
            Container.Name = "Container"
            Container.Parent = Section.Frame
            Container.BackgroundTransparency = 1
            Container.Position = UDim2.new(0, 0, 0, 35)
            Container.Size = UDim2.new(1, 0, 0, 0)

            local ContainerLayout = Instance.new("UIListLayout")
            ContainerLayout.Parent = Container
            ContainerLayout.Padding = UDim.new(0, 5)

            ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y)
                Section.Frame.Size = UDim2.new(0.95, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 40)
            end)

            function Section:CreateButton(text, callback)
                local Button = Instance.new("TextButton")
                Button.Name = text .. "Button"
                Button.Parent = Container
                Button.BackgroundColor3 = Color3.fromRGB(20, 18, 20)
                Button.Size = UDim2.new(1, 0, 0, 30)
                Button.Font = Enum.Font.SourceSans
                Button.Text = text
                Button.TextColor3 = Color3.fromRGB(200, 200, 200)
                Button.TextSize = 16

                local ButtonStroke = Instance.new("UIStroke")
                ButtonStroke.Color = Color3.fromRGB(40, 30, 50)
                ButtonStroke.Thickness = 1
                ButtonStroke.Parent = Button

                Button.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)
            end

            return Section
        end

        table.insert(UI.Tabs, Tab)
        return Tab
    end

    return UI
end

return Library
