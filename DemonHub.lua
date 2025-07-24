-- DemonHub by @kingclainardbaniqued66
-- Mobile Friendly, Modern UI

local Players, RunService, UserInputService = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService")
local Camera, LocalPlayer = workspace.CurrentCamera, Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Target, Locked = nil, false

local Settings = {
    SilentAim = false,
    Aimbot = false,
    Noclip = false,
    FOV = 80
}

-- Create GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DemonHub"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Toggle & Lock
local function createButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 30)
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Parent = MainFrame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
    button.MouseButton1Click:Connect(callback)
    return button
end

local ToggleBtn = createButton("[Toggle Menu]", function()
    MainFrame.Visible = not MainFrame.Visible
end)

local LockBtn = createButton("[Lock Target: Off]", function()
    Locked = not Locked
    LockBtn.Text = "[Lock Target: " .. (Locked and "On" or "Off") .. "]"
end)

-- FOV Slider
local FOVSlider = Instance.new("TextLabel")
FOVSlider.Size = UDim2.new(0, 200, 0, 30)
FOVSlider.Text = "FOV: " .. Settings.FOV
FOVSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FOVSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVSlider.Font = Enum.Font.Gotham
FOVSlider.TextSize = 14
FOVSlider.Parent = MainFrame
Instance.new("UICorner", FOVSlider).CornerRadius = UDim.new(0, 6)

-- Feature toggles
local function addToggle(name)
    local btn = createButton(name .. ": Off", function()
        Settings[name] = not Settings[name]
        btn.Text = name .. ": " .. (Settings[name] and "On" or "Off")
    end)
end

addToggle("SilentAim")
addToggle("Aimbot")
addToggle("Noclip")

-- FOV Circle
local Circle = Drawing.new("Circle")
Circle.Visible = true
Circle.Thickness = 2
Circle.Radius = Settings.FOV
Circle.Color = Color3.fromRGB(255, 0, 0)
Circle.Transparency = 0.5
Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

RunService.RenderStepped:Connect(function()
    Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Noclip
    if Settings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Aimbot Lock
    if Locked and Target and Target:FindFirstChild("Head") then
        local headPos = Target.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPos)
    end
end)

-- Silent Aim (basic)
local function getClosestPlayer()
    local closest, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if mag < Settings.FOV and mag < dist then
                closest = v
                dist = mag
            end
        end
    end
    return closest
end

Mouse.Button2Down:Connect(function()
    if Locked then
        Target = getClosestPlayer()
    end
end)
