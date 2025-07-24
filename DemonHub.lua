-- DemonHub by GLockz
-- GUI Aimbot with FOV Circle

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Create GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "DemonHubUI"

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Text = "🔥 Open DemonHub Menu"
OpenButton.Size = UDim2.new(0, 200, 0, 50)
OpenButton.Position = UDim2.new(0, 10, 0, 10)
OpenButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OpenButton.TextColor3 = Color3.new(1, 1, 1)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 18
OpenButton.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0, 10, 0, 70)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "DemonHub.lua"
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22

-- Aimbot / FOV toggles
local AimbotEnabled = false
local FOVEnabled = false
local FOVRadius = 120
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 2
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Radius = FOVRadius

local function UpdateFOV()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Visible = FOVEnabled
end

RunService.RenderStepped:Connect(UpdateFOV)

-- Find Closest Player
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = FOVRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
            if onScreen and dist < shortestDistance then
                shortestDistance = dist
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

-- Aimbot Logic
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- Buttons
local AimbotButton = Instance.new("TextButton", MainFrame)
AimbotButton.Size = UDim2.new(0, 260, 0, 40)
AimbotButton.Position = UDim2.new(0, 20, 0, 60)
AimbotButton.Text = "Toggle Aimbot: OFF"
AimbotButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AimbotButton.TextColor3 = Color3.new(1, 1, 1)
AimbotButton.Font = Enum.Font.Gotham
AimbotButton.TextSize = 18
AimbotButton.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotButton.Text = "Toggle Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
end)

local FOVButton = Instance.new("TextButton", MainFrame)
FOVButton.Size = UDim2.new(0, 260, 0, 40)
FOVButton.Position = UDim2.new(0, 20, 0, 110)
FOVButton.Text = "FOV Circle: OFF"
FOVButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FOVButton.TextColor3 = Color3.new(1, 1, 1)
FOVButton.Font = Enum.Font.Gotham
FOVButton.TextSize = 18
FOVButton.MouseButton1Click:Connect(function()
    FOVEnabled = not FOVEnabled
    FOVButton.Text = "FOV Circle: " .. (FOVEnabled and "ON" or "OFF")
end)

-- Toggle GUI
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
