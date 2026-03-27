local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function Tween(obj, info, goal)
    local tween = TweenService:Create(obj, TweenInfo.new(info, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tween:Play()
    return tween
end

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
    UI.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    UI.MainFrame.Size = UDim2.new(0, 600, 0, 400)
    UI.MainFrame.ClipsDescendants = true

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = UI.MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(34, 26, 40)
    MainStroke.Thickness = 1.5
    MainStroke.Parent = UI.MainFrame

    UI.Sidebar = Instance.new("Frame")
    UI.Sidebar.Name = "Sidebar"
    UI.Sidebar.Parent = UI.MainFrame
    UI.Sidebar.BackgroundColor3 = Color3.fromRGB(7, 7, 7)
    UI.Sidebar.BorderSizePixel = 0
    UI.Sidebar.Size = UDim2.new(0, 160, 1, 0)

    local SidebarStroke = Instance.new("UIStroke")
    SidebarStroke.Color = Color3.fromRGB(34, 26, 40)
    SidebarStroke.Thickness = 1.5
    SidebarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SidebarStroke.Parent = UI.Sidebar

    UI.TitleLabel = Instance.new("TextLabel")
    UI.TitleLabel.Name = "TitleLabel"
    UI.TitleLabel.Parent = UI.Sidebar
    UI.TitleLabel.BackgroundTransparency = 1
    UI.TitleLabel.Position = UDim2.new(0, 10, 0, 15)
    UI.TitleLabel.Size = UDim2.new(1, -20, 0, 30)
    UI.TitleLabel.Font = Enum.Font.SourceSansBold
    UI.TitleLabel.Text = "UNIFIED"
    UI.TitleLabel.TextColor3 = Color3.fromRGB(207, 165, 255)
    UI.TitleLabel.TextSize = 24
    UI.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    UI.TabContainer = Instance.new("ScrollingFrame")
    UI.TabContainer.Name = "TabContainer"
    UI.TabContainer.Parent = UI.Sidebar
    UI.TabContainer.BackgroundTransparency = 1
    UI.TabContainer.BorderSizePixel = 0
    UI.TabContainer.Position = UDim2.new(0, 5, 0, 60)
    UI.TabContainer.Size = UDim2.new(1, -10, 1, -110)
    UI.TabContainer.ScrollBarThickness = 0
    UI.TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = UI.TabContainer
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    UI.Footer = Instance.new("Frame")
    UI.Footer.Name = "Footer"
    UI.Footer.Parent = UI.Sidebar
    UI.Footer.BackgroundTransparency = 1
    UI.Footer.Position = UDim2.new(0, 0, 1, -40)
    UI.Footer.Size = UDim2.new(1, 0, 0, 40)

    UI.CloseBtn = Instance.new("TextButton")
    UI.CloseBtn.Name = "CloseBtn"
    UI.CloseBtn.Parent = UI.Footer
    UI.CloseBtn.BackgroundTransparency = 1
    UI.CloseBtn.Position = UDim2.new(0, 10, 0, 0)
    UI.CloseBtn.Size = UDim2.new(1, -20, 1, 0)
    UI.CloseBtn.Font = Enum.Font.SourceSans
    UI.CloseBtn.Text = "Exit System"
    UI.CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    UI.CloseBtn.TextSize = 16
    UI.CloseBtn.TextXAlignment = Enum.TextXAlignment.Left

    UI.CloseBtn.MouseButton1Click:Connect(function()
        UI.ScreenGui:Destroy()
    end)

    UI.ContentContainer = Instance.new("Frame")
    UI.ContentContainer.Name = "ContentContainer"
    UI.ContentContainer.Parent = UI.MainFrame
    UI.ContentContainer.BackgroundTransparency = 1
    UI.ContentContainer.Position = UDim2.new(0, 160, 0, 0)
    UI.ContentContainer.Size = UDim2.new(1, -160, 1, 0)

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

    UI.Tabs = {}
    function UI:CreateTab(name)
        local Tab = {}
        
        Tab.Button = Instance.new("TextButton")
        Tab.Button.Name = name .. "Tab"
        Tab.Button.Parent = UI.TabContainer
        Tab.Button.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        Tab.Button.BackgroundTransparency = 1
        Tab.Button.Size = UDim2.new(1, 0, 0, 32)
        Tab.Button.Font = Enum.Font.SourceSans
        Tab.Button.Text = "  " .. name
        Tab.Button.TextColor3 = Color3.fromRGB(150, 150, 150)
        Tab.Button.TextSize = 18
        Tab.Button.TextXAlignment = Enum.TextXAlignment.Left

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 4)
        TabBtnCorner.Parent = Tab.Button

        Tab.Page = Instance.new("ScrollingFrame")
        Tab.Page.Name = name .. "Page"
        Tab.Page.Parent = UI.ContentContainer
        Tab.Page.BackgroundTransparency = 1
        Tab.Page.BorderSizePixel = 0
        Tab.Page.Size = UDim2.new(1, 0, 1, 0)
        Tab.Page.Visible = false
        Tab.Page.ScrollBarThickness = 2
        Tab.Page.ScrollBarImageColor3 = Color3.fromRGB(34, 26, 40)

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 15)
        PagePadding.PaddingLeft = UDim.new(0, 15)
        PagePadding.PaddingRight = UDim.new(0, 15)
        PagePadding.Parent = Tab.Page

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Tab.Page
        PageLayout.Padding = UDim.new(0, 15)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30)
        end)

        Tab.Button.MouseButton1Click:Connect(function()
            for _, t in pairs(UI.Tabs) do
                t.Page.Visible = false
                Tween(t.Button, 0.2, {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundTransparency = 1})
            end
            Tab.Page.Visible = true
            Tween(Tab.Button, 0.2, {TextColor3 = Color3.fromRGB(207, 165, 255), BackgroundTransparency = 0.8})
        end)

        if #UI.Tabs == 0 then
            Tab.Page.Visible = true
            Tab.Button.TextColor3 = Color3.fromRGB(207, 165, 255)
            Tab.Button.BackgroundTransparency = 0.8
        end

        function Tab:CreateSection(title)
            local Section = {}
            
            Section.Frame = Instance.new("Frame")
            Section.Frame.Name = title .. "Section"
            Section.Frame.Parent = Tab.Page
            Section.Frame.BackgroundColor3 = Color3.fromRGB(12, 11, 12)
            Section.Frame.Size = UDim2.new(1, 0, 0, 40)

            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 4)
            SectionCorner.Parent = Section.Frame

            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = Color3.fromRGB(25, 20, 30)
            SectionStroke.Thickness = 1
            SectionStroke.Parent = Section.Frame

            Section.Title = Instance.new("TextLabel")
            Section.Title.Name = "Title"
            Section.Title.Parent = Section.Frame
            Section.Title.BackgroundTransparency = 1
            Section.Title.Position = UDim2.new(0, 10, 0, 5)
            Section.Title.Size = UDim2.new(1, -20, 0, 25)
            Section.Title.Font = Enum.Font.SourceSansBold
            Section.Title.Text = title:upper()
            Section.Title.TextColor3 = Color3.fromRGB(207, 165, 255)
            Section.Title.TextSize = 14
            Section.Title.TextXAlignment = Enum.TextXAlignment.Left

            local Container = Instance.new("Frame")
            Container.Name = "Container"
            Container.Parent = Section.Frame
            Container.BackgroundTransparency = 1
            Container.Position = UDim2.new(0, 10, 0, 35)
            Container.Size = UDim2.new(1, -20, 0, 0)

            local ContainerLayout = Instance.new("UIListLayout")
            ContainerLayout.Parent = Container
            ContainerLayout.Padding = UDim.new(0, 5)

            ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, -20, 0, ContainerLayout.AbsoluteContentSize.Y + 10)
                Section.Frame.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 45)
            end)

            function Section:CreateButton(text, callback)
                local Button = Instance.new("TextButton")
                Button.Name = text .. "Button"
                Button.Parent = Container
                Button.BackgroundColor3 = Color3.fromRGB(18, 16, 18)
                Button.Size = UDim2.new(1, 0, 0, 30)
                Button.Font = Enum.Font.SourceSans
                Button.Text = text
                Button.TextColor3 = Color3.fromRGB(200, 200, 200)
                Button.TextSize = 16
                Button.AutoButtonColor = false

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 4)
                BtnCorner.Parent = Button

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Color3.fromRGB(34, 26, 40)
                BtnStroke.Thickness = 1
                BtnStroke.Parent = Button

                Button.MouseEnter:Connect(function()
                    Tween(Button, 0.2, {BackgroundColor3 = Color3.fromRGB(25, 22, 25)})
                    Tween(BtnStroke, 0.2, {Color = Color3.fromRGB(50, 40, 60)})
                end)

                Button.MouseLeave:Connect(function()
                    Tween(Button, 0.2, {BackgroundColor3 = Color3.fromRGB(18, 16, 18)})
                    Tween(BtnStroke, 0.2, {Color = Color3.fromRGB(34, 26, 40)})
                end)

                Button.MouseButton1Down:Connect(function()
                    Tween(Button, 0.1, {Size = UDim2.new(0.98, 0, 0, 28)})
                end)

                Button.MouseButton1Up:Connect(function()
                    Tween(Button, 0.1, {Size = UDim2.new(1, 0, 0, 30)})
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
