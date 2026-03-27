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

function Library:CreateWindow(title)
    local UI = {}
    
    UI.ScreenGui = Instance.new("ScreenGui")
    UI.ScreenGui.Name = "Unified_V3"
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
    UI.MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    UI.MainFrame.Size = UDim2.new(0, 550, 0, 350)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(34, 26, 40)
    MainStroke.Thickness = 2
    MainStroke.Parent = UI.MainFrame

    UI.TopBar = Instance.new("Frame")
    UI.TopBar.Name = "TopBar"
    UI.TopBar.Parent = UI.MainFrame
    UI.TopBar.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
    UI.TopBar.BorderSizePixel = 0
    UI.TopBar.Size = UDim2.new(1, 0, 0, 35)

    local TopStroke = Instance.new("UIStroke")
    TopStroke.Color = Color3.fromRGB(34, 26, 40)
    TopStroke.Thickness = 1
    TopStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    TopStroke.Parent = UI.TopBar

    UI.TitleLabel = Instance.new("TextLabel")
    UI.TitleLabel.Name = "TitleLabel"
    UI.TitleLabel.Parent = UI.TopBar
    UI.TitleLabel.BackgroundTransparency = 1
    UI.TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    UI.TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    UI.TitleLabel.Font = Enum.Font.SourceSansBold
    UI.TitleLabel.Text = title:upper()
    UI.TitleLabel.TextColor3 = Color3.fromRGB(207, 165, 255)
    UI.TitleLabel.TextSize = 14
    UI.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    UI.TabSelection = Instance.new("Frame")
    UI.TabSelection.Name = "TabSelection"
    UI.TabSelection.Parent = UI.MainFrame
    UI.TabSelection.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
    UI.TabSelection.BorderSizePixel = 0
    UI.TabSelection.Position = UDim2.new(0, 0, 0, 35)
    UI.TabSelection.Size = UDim2.new(1, 0, 0, 30)

    local SelectionStroke = Instance.new("UIStroke")
    SelectionStroke.Color = Color3.fromRGB(34, 26, 40)
    SelectionStroke.Thickness = 1
    SelectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SelectionStroke.Parent = UI.TabSelection

    UI.TabList = Instance.new("UIListLayout")
    UI.TabList.Parent = UI.TabSelection
    UI.TabList.FillDirection = Enum.FillDirection.Horizontal
    UI.TabList.SortOrder = Enum.SortOrder.LayoutOrder
    UI.TabList.Padding = UDim.new(0, 0)

    UI.Container = Instance.new("Frame")
    UI.Container.Name = "Container"
    UI.Container.Parent = UI.MainFrame
    UI.Container.BackgroundTransparency = 1
    UI.Container.Position = UDim2.new(0, 10, 0, 75)
    UI.Container.Size = UDim2.new(1, -20, 1, -85)

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
        Tab.Button.Parent = UI.TabSelection
        Tab.Button.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        Tab.Button.BorderSizePixel = 0
        Tab.Button.Size = UDim2.new(0, 100, 1, 0)
        Tab.Button.Font = Enum.Font.SourceSans
        Tab.Button.Text = name
        Tab.Button.TextColor3 = Color3.fromRGB(150, 150, 150)
        Tab.Button.TextSize = 14
        Tab.Button.AutoButtonColor = false

        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = Color3.fromRGB(34, 26, 40)
        TabStroke.Thickness = 1
        TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        TabStroke.Parent = Tab.Button

        Tab.Page = Instance.new("ScrollingFrame")
        Tab.Page.Name = name .. "Page"
        Tab.Page.Parent = UI.Container
        Tab.Page.BackgroundTransparency = 1
        Tab.Page.BorderSizePixel = 0
        Tab.Page.Size = UDim2.new(1, 0, 1, 0)
        Tab.Page.Visible = false
        Tab.Page.ScrollBarThickness = 0
        Tab.Page.CanvasSize = UDim2.new(0, 0, 0, 0)

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Tab.Page
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y)
        end)

        Tab.Button.MouseButton1Click:Connect(function()
            for _, t in pairs(UI.Tabs) do
                t.Page.Visible = false
                Tween(t.Button, 0.2, {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundColor3 = Color3.fromRGB(14, 14, 14)})
            end
            Tab.Page.Visible = true
            Tween(Tab.Button, 0.2, {TextColor3 = Color3.fromRGB(207, 165, 255), BackgroundColor3 = Color3.fromRGB(9, 8, 9)})
        end)

        if #UI.Tabs == 0 then
            Tab.Page.Visible = true
            Tab.Button.TextColor3 = Color3.fromRGB(207, 165, 255)
            Tab.Button.BackgroundColor3 = Color3.fromRGB(9, 8, 9)
        end

        function Tab:CreateSection(title)
            local Section = {}
            
            Section.Frame = Instance.new("Frame")
            Section.Frame.Name = title .. "Section"
            Section.Frame.Parent = Tab.Page
            Section.Frame.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
            Section.Frame.BorderSizePixel = 0
            Section.Frame.Size = UDim2.new(1, 0, 0, 30)

            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = Color3.fromRGB(34, 26, 40)
            SectionStroke.Thickness = 1
            SectionStroke.Parent = Section.Frame

            Section.Title = Instance.new("TextLabel")
            Section.Title.Name = "Title"
            Section.Title.Parent = Section.Frame
            Section.Title.BackgroundTransparency = 1
            Section.Title.Position = UDim2.new(0, 8, 0, 0)
            Section.Title.Size = UDim2.new(1, -16, 0, 25)
            Section.Title.Font = Enum.Font.SourceSansBold
            Section.Title.Text = title
            Section.Title.TextColor3 = Color3.fromRGB(207, 165, 255)
            Section.Title.TextSize = 13
            Section.Title.TextXAlignment = Enum.TextXAlignment.Left

            local Container = Instance.new("Frame")
            Container.Name = "Container"
            Container.Parent = Section.Frame
            Container.BackgroundTransparency = 1
            Container.Position = UDim2.new(0, 8, 0, 25)
            Container.Size = UDim2.new(1, -16, 0, 0)

            local ContainerLayout = Instance.new("UIListLayout")
            ContainerLayout.Parent = Container
            ContainerLayout.Padding = UDim.new(0, 4)

            ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, -16, 0, ContainerLayout.AbsoluteContentSize.Y + 5)
                Section.Frame.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 30)
            end)

            function Section:CreateButton(text, callback)
                local Button = Instance.new("TextButton")
                Button.Name = text .. "Button"
                Button.Parent = Container
                Button.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
                Button.BorderSizePixel = 0
                Button.Size = UDim2.new(1, 0, 0, 22)
                Button.Font = Enum.Font.SourceSans
                Button.Text = text
                Button.TextColor3 = Color3.fromRGB(200, 200, 200)
                Button.TextSize = 13
                Button.AutoButtonColor = false

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Color3.fromRGB(34, 26, 40)
                BtnStroke.Thickness = 1
                BtnStroke.Parent = Button

                Button.MouseEnter:Connect(function()
                    Tween(BtnStroke, 0.2, {Color = Color3.fromRGB(207, 165, 255)})
                end)

                Button.MouseLeave:Connect(function()
                    Tween(BtnStroke, 0.2, {Color = Color3.fromRGB(34, 26, 40)})
                end)

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
