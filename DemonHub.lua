-- DemonHub by GLockz
-- Full Aimbot GUI with default settings set to TRUE

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Cam = workspace.CurrentCamera

-- Settings
local Settings = {
    Aimbot = true,
    TeamCheck = true,
    DeathCheck = true,
    WallCheck = true,
    FOVEnabled = true,
    BlatantMode = true,
    SilentAim = true,
    ESP = true,
    SpeedWalk = true,
    FOV = 30,
    LockKey = Enum.KeyCode.E
}

-- GUI Setup
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "DemonHubUI"

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 200, 0, 50)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.Text = "🔥 Open DemonHub Menu"
openBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 18

local frame = Instance.new("Frame", gui)
frame.Visible = false
frame.Position = UDim2.new(0, 10, 0, 70)
frame.Size = UDim2.new(0, 300, 0, 400)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

openBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

local function createToggle(name, y, default)
    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, y)
    button.Text = name .. ": " .. tostring(Settings[name])
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.MouseButton1Click:Connect(function()
        Settings[name] = not Settings[name]
        button.Text = name .. ": " .. tostring(Settings[name])
    end)
end

local toggles = {"Aimbot", "FOVEnabled", "WallCheck", "TeamCheck", "DeathCheck", "BlatantMode", "SilentAim", "ESP", "SpeedWalk"}
for i, name in ipairs(toggles) do
    createToggle(name, 30 + ((i-1) * 35), true)
end

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = Settings.FOV
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Transparency = 0.4
FOVCircle.Filled = false
FOVCircle.Visible = Settings.FOVEnabled

RunService.RenderStepped:Connect(function()
    if Settings.FOVEnabled then
        FOVCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
        FOVCircle.Visible = true
        FOVCircle.Radius = Settings.FOV
    else
        FOVCircle.Visible = false
    end
end)

-- SpeedWalk
if Settings.SpeedWalk then
    LP.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").WalkSpeed = 30
    end)
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 30
    end
end

-- Target lock function
local function getClosest()
    local maxDist = Settings.FOV
    local closest = nil

    for _,v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Head") then
            if Settings.TeamCheck and v.Team == LP.Team then continue end
            if Settings.DeathCheck and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health <= 0 then continue end

            local screenPos, onScreen = Cam:WorldToViewportPoint(v.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)).Magnitude
                if dist < maxDist then
                    maxDist = dist
                    closest = v
                end
            end
        end
    end

    return closest
end

-- Lock onto player
local CurrentTarget = nil
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.LockKey then
        CurrentTarget = getClosest()
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
        Cam.CFrame = CFrame.new(Cam.CFrame.Position, CurrentTarget.Character.Head.Position)
    end
end)
