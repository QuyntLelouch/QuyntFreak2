-- Lelouch Script by QuyntLelouch
-- Repository: https://github.com/QuyntLelouch2/BloxFruits, Branch: main
-- Features: Auto-Farm, Teleport, Visual ESP, Waifu-Themed GUI, Xeno Compatible
-- Hotkey: Insert to toggle GUI

-- Initialize Libraries
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Configuration
local Settings = {
    AutoFarm = {
        Enabled = false,
        Target = "Nearest Enemy",
        AttackSpeed = 0.1,
        Magnet = true,
        BossList = {}
    },
    Teleport = {
        Method = "Instant", -- "Instant" or "Tween"
        Speed = 300
    },
    Visual = {
        FruitESP = true,
        PlayerESP = false,
        IslandESP = false,
        FruitDistance = true
    },
    Waifu = {
        Enabled = true,
        ImageId = "rbxassetid://1234567890" -- Replace with your waifu image ID
    }
}

-- Utility Functions
local function Notify(message, duration)
    OrionLib:MakeNotification({
        Name = "Lelouch Script",
        Content = message,
        Image = "rbxassetid://1234567891", -- Replace with your icon ID
        Time = duration or 5
    })
end

local function GetDistance(position)
    return (HumanoidRootPart.Position - position).Magnitude
end

local function TweenTeleport(destination)
    local tweenInfo = TweenInfo.new(
        GetDistance(destination) / Settings.Teleport.Speed,
        Enum.EasingStyle.Linear
    )
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(destination)})
    tween:Play()
    tween.Completed:Wait()
end

-- Auto-Farm Functions
local function GetLiveBosses()
    local bosses = {}
    for _, npc in pairs(Workspace.NPCs:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            if string.find(npc.Name, "Boss") then
                table.insert(bosses, npc.Name)
            end
        end
    end
    return bosses
end

local function MagnetEnemies()
    if not Settings.AutoFarm.Magnet then return end
    for _, enemy in pairs(Workspace.NPCs:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local distance = GetDistance(enemy.HumanoidRootPart.Position)
            if distance < 50 then
                enemy.HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position + Vector3.new(0, 5, 0))
            end
        end
    end
end

local function AutoAttack(target)
    if not target or not target.Parent then return end
    local args = {
        [1] = "Attack",
        [2] = target
    }
    ReplicatedStorage.Remotes.Combat:FireServer(unpack(args))
end

-- ESP Functions
local function CreateESP(instance, color, text)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = instance
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = instance

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextScaled = true
    textLabel.Parent = billboard

    local highlight = Instance.new("Highlight")
    highlight.Adornee = instance
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.Parent = instance

    return billboard
end

local function UpdateFruitESP()
    if not Settings.Visual.FruitESP then return end
    for _, fruit in pairs(Workspace:GetChildren()) do
        if fruit:IsA("Tool") and fruit.Name:find("Fruit") then
            if not fruit:FindFirstChild("BillboardGui") then
                local distance = GetDistance(fruit.Handle.Position)
                local text = Settings.Visual.FruitDistance and string.format("%s (%d studs)", fruit.Name, distance) or fruit.Name
                CreateESP(fruit.Handle, Color3.fromRGB(255, 105, 180), text)
            end
        end
    end
end

local function UpdatePlayerESP()
    if not Settings.Visual.PlayerESP then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not player.Character:FindFirstChild("BillboardGui") then
                CreateESP(player.Character.HumanoidRootPart, Color3.fromRGB(0, 255, 255), player.Name)
            end
        end
    end
end

local function UpdateIslandESP()
    if not Settings.Visual.IslandESP then return end
    for _, island in pairs(Workspace:Islands:GetChildren()) do
        if not island:FindFirstChild("BillboardGui") then
            CreateESP(island:FindFirstChildWhichIsA("BasePart"), Color3.fromRGB(255, 255, 0), island.Name)
        end
    end
end

-- GUI Setup
local Window = OrionLib:MakeWindow({
    Name = "Lelouch Script | Blox Fruits",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "LelouchConfig",
    IntroText = "Lelouch Script by QuyntLelouch",
    IntroIcon = "rbxassetid://1234567891" -- Replace with your icon ID
})

-- Waifu Decoration
if Settings.Waifu.Enabled then
    local waifuGui = Instance.new("ScreenGui")
    waifuGui.Parent = LocalPlayer.PlayerGui
    local waifuFrame = Instance.new("Frame")
    waifuFrame.Size = UDim2.new(0, 200, 0, 300)
    waifuFrame.Position = UDim2.new(0, 10, 0.5, -150)
    waifuFrame.BackgroundTransparency = 1
    waifuFrame.Parent = waifuGui
    local waifuImage = Instance.new("ImageLabel")
    waifuImage.Size = UDim2.new(1, 0, 1, 0)
    waifuImage.BackgroundTransparency = 1
    waifuImage.Image = Settings.Waifu.ImageId
    waifuImage.Parent = waifuFrame
    -- Animation
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local tween = TweenService:Create(waifuImage, tweenInfo, {Position = UDim2.new(0, 0, 0, -10)})
    tween:Play()
end

-- Tabs
local AutoFarmTab = Window:MakeTab({Name = "Auto-Farm", Icon = "rbxassetid://1234567892", PremiumOnly = false})
local TeleportTab = Window:MakeTab({Name = "Teleport", Icon = "rbxassetid://1234567893", PremiumOnly = false})
local VisualTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://1234567894", PremiumOnly = false})
local SettingsTab = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://1234567895", PremiumOnly = false})

-- Auto-Farm Tab
AutoFarmTab:AddToggle({
    Name = "Enable Auto-Farm",
    Default = false,
    Callback = function(value)
        Settings.AutoFarm.Enabled = value
        if value then
            Notify("Auto-Farm Enabled")
            spawn(function()
                while Settings.AutoFarm.Enabled do
                    MagnetEnemies()
                    local target = nil
                    if Settings.AutoFarm.Target == "Nearest Enemy" then
                        for _, enemy in pairs(Workspace.NPCs:GetChildren()) do
                            if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                                local distance = GetDistance(enemy.HumanoidRootPart.Position)
                                if distance < 50 then
                                    target = enemy
                                    break
                                end
                            end
                        end
                    elseif Settings.AutoFarm.Target == "Boss" then
                        for _, boss in pairs(Workspace.NPCs:GetChildren()) do
                            if boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and string.find(boss.Name, "Boss") then
                                target = boss
                                break
                            end
                        end
                    end
                    if target then
                        AutoAttack(target)
                    end
                    wait(Settings.AutoFarm.AttackSpeed)
                end
            end)
        else
            Notify("Auto-Farm Disabled")
        end
    end
})

AutoFarmTab:AddDropdown({
    Name = "Target Type",
    Default = "Nearest Enemy",
    Options = {"Nearest Enemy", "Boss"},
    Callback = function(value)
        Settings.AutoFarm.Target = value
    end
})

AutoFarmTab:AddSlider({
    Name = "Attack Speed",
    Min = 0.1,
    Max = 1,
    Default = 0.1,
    Increment = 0.1,
    Callback = function(value)
        Settings.AutoFarm.AttackSpeed = value
    end
})

AutoFarmTab:AddToggle({
    Name = "Magnet Enemies",
    Default = true,
    Callback = function(value)
        Settings.AutoFarm.Magnet = value
    end
})

AutoFarmTab:AddLabel("Live Bosses:")
AutoFarmTab:AddParagraph("Boss List", table.concat(GetLiveBosses(), ", "))

-- Teleport Tab
local thirdSeaLocations = {
    ["Port Town"] = Vector3.new(-600, 7, 6000),
    ["Hydra Island"] = Vector3.new(5000, 600, 5000),
    ["Great Tree"] = Vector3.new(2000, 500, -4000),
    ["Floating Turtle"] = Vector3.new(-1000, 300, -2000)
}

for name, pos in pairs(thirdSeaLocations) do
    TeleportTab:AddButton({
        Name = "Teleport to " .. name,
        Callback = function()
            if Settings.Teleport.Method == "Instant" then
                HumanoidRootPart.CFrame = CFrame.new(pos)
            else
                TweenTeleport(pos)
            end
            Notify("Teleported to " .. name)
        end
    })
end

TeleportTab:AddDropdown({
    Name = "Teleport Method",
    Default = "Instant",
    Options = {"Instant", "Tween"},
    Callback = function(value)
        Settings.Teleport.Method = value
    end
})

TeleportTab:AddSlider({
    Name = "Tween Speed",
    Min = 100,
    Max = 1000,
    Default = 300,
    Increment = 50,
    Callback = function(value)
        Settings.Teleport.Speed = value
    end
})

-- Visuals Tab
VisualTab:AddToggle({
    Name = "Fruit ESP",
    Default = true,
    Callback = function(value)
        Settings.Visual.FruitESP = value
        if value then
            UpdateFruitESP()
        else
            for _, fruit in pairs(Workspace:GetChildren()) do
                if fruit:IsA("Tool") and fruit:FindFirstChild("BillboardGui") then
                    fruit.BillboardGui:Destroy()
                    fruit:FindFirstChild("Highlight"):Destroy()
                end
            end
        end
    end
})

VisualTab:AddToggle({
    Name = "Show Fruit Distance",
    Default = true,
    Callback = function(value)
        Settings.Visual.FruitDistance = value
        UpdateFruitESP()
    end
})

VisualTab:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(value)
        Settings.Visual.PlayerESP = value
        if value then
            UpdatePlayerESP()
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("BillboardGui") then
                    player.Character.BillboardGui:Destroy()
                    player.Character:FindFirstChild("Highlight"):Destroy()
                end
            end
        end
    end
})

VisualTab:AddToggle({
    Name = "Island ESP",
    Default = false,
    Callback = function(value)
        Settings.Visual.IslandESP = value
        if value then
            UpdateIslandESP()
        else
            for _, island in pairs(Workspace:Islands:GetChildren()) do
                if island:FindFirstChild("BillboardGui") then
                    island.BillboardGui:Destroy()
                    island:FindFirstChild("Highlight"):Destroy()
                end
            end
        end
    end
})

-- Settings Tab
SettingsTab:AddToggle({
    Name = "Enable Waifu",
    Default = true,
    Callback = function(value)
        Settings.Waifu.Enabled = value
        if not value then
            LocalPlayer.PlayerGui:FindFirstChild("ScreenGui"):Destroy()
        else
            Notify("Restart the script to enable Waifu")
        end
    end
})

SettingsTab:AddButton({
    Name = "Update Boss List",
    Callback = function()
        Settings.AutoFarm.BossList = GetLiveBosses()
        AutoFarmTab:UpdateParagraph("Boss List", table.concat(Settings.AutoFarm.BossList, ", "))
        Notify("Boss List Updated")
    end
})

-- Hotkey for GUI
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        OrionLib:Toggle()
    end
end)

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    if Settings.Visual.FruitESP then
        UpdateFruitESP()
    end
    if Settings.Visual.PlayerESP then
        UpdatePlayerESP()
    end
    if Settings.Visual.IslandESP then
        UpdateIslandESP()
    end
end)

-- Third Sea Check
if LocalPlayer.Data.Level.Value < 1500 then
    Notify("Warning: You need to be in the Third Sea (Level 1500+)", 10)
end

-- Initialize
Notify("Lelouch Script Loaded! Press Insert to open GUI")
OrionLib:Init()