-- DemonHub by GLockz
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = workspace.CurrentCamera

-- Settings
local AimbotEnabled = true
local FOVEnabled = true
local FOVRadius = 100
local TargetPart = "Head"

-- Create GUI
local ScreenGui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
ScreenGui.Name = "DemonHubUI"

-- Open Button
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 200, 0, 50)
OpenButton.Position = UDim2.new(0, 10, 0, 10)
OpenButton.Text = "🔥 Open DemonHub Menu"
OpenButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OpenButton.TextColor3 = Color3.new(1,1,1)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 18
OpenButton.Parent = ScreenGui

-- Main Menu
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0, 10, 0, 70)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "DemonHub.lua"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.Parent = MainFrame

-- Aimbot Toggle
local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Size = UDim2.new(1, -20, 0, 40)
AimbotToggle.Position = UDim2.new(0, 10, 0, 60)
AimbotToggle.Text = "Aimbot: ON"
AimbotToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AimbotToggle.TextColor3 = Color3.new(1,1,1)
AimbotToggle.Font = Enum.Font.Gotham
AimbotToggle.TextSize = 18
AimbotToggle.Parent = MainFrame

-- FOV Toggle
local FOVToggle = Instance.new("TextButton")
FOVToggle.Size = UDim2.new(1, -20, 0, 40)
FOVToggle.Position = UDim2.new(0, 10, 0, 110)
FOVToggle.Text = "FOV Circle: ON"
FOVToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FOVToggle.TextColor3 = Color3.new(1,1,1)
FOVToggle.Font = Enum.Font.Gotham
FOVToggle.TextSize = 18
FOVToggle.Parent = MainFrame

-- FOV Circle
local Circle = Drawing.new("Circle")
Circle.Color = Color3.fromRGB(255, 0, 0)
Circle.Thickness = 2
Circle.NumSides = 64
Circle.Radius = FOVRadius
Circle.Filled = false
Circle.Visible = FOVEnabled

-- Functions
local function getClosestPlayer()
    local closest, distance = nil, FOVRadius
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild(TargetPart) then
            local pos, onscreen = Camera:WorldToViewportPoint(v.Character[TargetPart].Position)
            if onscreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < distance then
                    closest = v
                    distance = mag
                end
            end
        end
    end
    return closest
end

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    -- Center the FOV circle
    Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    Circle.Visible = FOVEnabled

    if AimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(TargetPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[TargetPart].Position)
        end
    end
end)

-- Toggles
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

AimbotToggle.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotToggle.Text = "Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
end)

FOVToggle.MouseButton1Click:Connect(function()
    FOVEnabled = not FOVEnabled
    FOVToggle.Text = "FOV Circle: " .. (FOVEnabled and "ON" or "OFF")
end)

-- Mobile support: tap to open menu
UIS.TouchTap:Connect(function()
    if not MainFrame.Visible then
        MainFrame.Visible = true
    end
end)
