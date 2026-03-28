local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/weareunified/UnifiedUI/refs/heads/main/main.lua", true))()

local Window = Library:CreateWindow({
    Name = "Unified.wtf",
    AccentColor = Color3.fromRGB(207, 165, 255)
})

Window:CreateChangelog({
    "[/] Fixed ui",
    "[+] Added syntax highlighting",
    "[+] Added Changelog feature",
    "[-] Removed old execute logic"
})

local PlaceholderTab = Window:CreateTab("Placeholder", "rbxassetid://4483345998")
local ImageTab = Window:CreateTab("Image Tab", "rbxassetid://4483362458")
local SettingsTab = Window:CreateTab("Settings", "rbxassetid://4483362748")

local MainSection = PlaceholderTab:CreateSection("Main Elements")

MainSection:CreateToggle("Toggle Button", "Toggle1", false, function(state)
end)

MainSection:CreateButton("Test Notification", function()
    Window:Notify("Unified", "This is a test notification triggered by button!")
end)

MainSection:CreateButton("Button (Action)", function()
end)

MainSection:CreateSlider("Speed Slider", "Slider1", 16, 500, 16, function(value)
end)

MainSection:CreateTextbox("Username Input", "Text1", "Enter name...", function(text)
end)

MainSection:CreateBind("Toggle Bind", "Bind1", Enum.KeyCode.F, function()
end)

MainSection:CreateToggleBind("Toggle + Bind", "ToggleBind1", false, Enum.KeyCode.G, function(state, key)
end)

local DropdownSection = PlaceholderTab:CreateSection("Dropdowns")

local Dropdown1 = DropdownSection:CreateDropdown("Single Dropdown", "Drop1", {"Option 1", "Option 2", "Option 3", "Option 4"}, "Option 1", function(selected)
end)

DropdownSection:CreateMultiDropdown("Multi Dropdown", "Multi1", {"Item A", "Item B", "Item C", "Item D"}, {"Item A"}, function(selectedTable)
end)

DropdownSection:CreateButton("Update Dropdown", function()
    Dropdown1:Update({"New Option 1", "New Option 2", "New Option 3"}, true)
end)

local CodeSection = PlaceholderTab:CreateSection("Code Examples")

CodeSection:CreateCodeblock("Lua Code", [[local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/weareunified/UnifiedUI/refs/heads/main/main.lua"))()

function Test()
    print("Auto Highlighting!")
end]])

local ImgSection = ImageTab:CreateSection("Image Preview")
ImgSection:CreateImage("Asset Image", "rbxassetid://4483345998", false)
ImgSection:CreateImage("Web Image Link", "rbxassetid://4483362458", true)

local ConfigSection = SettingsTab:CreateSection("Config System")

local ConfigDropdown = ConfigSection:CreateDropdown("Select Config", nil, Window:GetConfigs(), nil, function(selected)
end)

ConfigSection:CreateTextbox("Config Name", nil, "config_name", function(text)
end)

ConfigSection:CreateButton("Save Config", function()
    local name = ConfigSection.Elements[2].Input.Text
    if name ~= "" then
        Window:SaveConfig(name)
        ConfigDropdown:Update(Window:GetConfigs(), true)
    end
end)

ConfigSection:CreateButton("Load Config", function()
    local name = ConfigDropdown.Selected
    if name then
        Window:LoadConfig(name)
    end
end)

local GameSection = SettingsTab:CreateSection("Game Settings")

GameSection:CreateButton("Rejoin Game", function()
    Library:Rejoin()
end)

GameSection:CreateButton("Server Hop", function()
    Library:ServerHop()
end)

local UISection = SettingsTab:CreateSection("UI Settings")
UISection:CreateButton("Unload UI", function()
    Window.ScreenGui:Destroy()
end)
