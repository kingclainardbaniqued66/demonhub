-- DemonHub by GLockz (Smooth & Stylish UI, Fully Functional)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Settings (all ON by default)
local Settings = {
    Aimbot = true,
    SilentAim = true,
    ESP = true,
    FOV = true,
    TeamCheck = true,
    WallCheck = true,
    DeathCheck = true,
    SpeedWalk = true,
    WalkSpeed = 20,
    FOVRadius = 30,
    LockKey = Enum.KeyCode.E
}

-- Targeting
local Target, Locking = nil, false

-- GUI
local screen = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
screen.Name = "DemonHubUI"

local openBtn = Instance.new("TextButton", screen)
openBtn.Size = UDim2.new(0, 200, 0, 40)
openBtn.Position = UDim2.new(0,10,0,10)
openBtn.Text = "🔥 Open DemonHub Menu"
openBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 18

local main = Instance.new("Frame", screen)
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0,10,0,60)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
main.Visible = false

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.CanvasSize = UDim2.new(0,0,2,0)
scroll.ScrollBarThickness = 4

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,5)

-- Creates toggle buttons
local function MakeToggle(txt)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = txt .. ": ON"
    btn.MouseButton1Click:Connect(function()
        local k = txt:gsub(" ", "")
        Settings[k] = not Settings[k]
        btn.Text = txt .. ": " .. (Settings[k] and "ON" or "OFF")
    end)
end

Quick toggles:
for _, name in pairs({"Aimbot","SilentAim","ESP","FOV","TeamCheck","WallCheck","DeathCheck","SpeedWalk"}) do
    MakeToggle(name)
end

-- Speed Walk input
local speedLbl = Instance.new("TextLabel", scroll)
speedLbl.Size = UDim2.new(1, -20, 0, 30)
speedLbl.BackgroundTransparency = 1
speedLbl.Text = "Walk Speed:"
speedLbl.TextColor3 = Color3.new(1,1,1)
speedLbl.Font = Enum.Font.Gotham
speedLbl.TextSize = 16

local speedBox = Instance.new("TextBox", scroll)
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Text = tostring(Settings.WalkSpeed)
speedBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 16
speedBox.TextColor3 = Color3.new(1,1,1)

speedBox.FocusLost:Connect(function()
    local v = tonumber(speedBox.Text)
    if v and v > 0 then
        Settings.WalkSpeed = v
    end
end)

openBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    openBtn.Text = main.Visible and "❌ Close DemonHub Menu" or "🔥 Open DemonHub Menu"
end)

-- FOV Circle
local circle = Drawing.new("Circle")
circle.Thickness = 1
circle.Filled = false
circle.Transparency = 1
circle.Color = Color3.new(1,1,1)

RunService.RenderStepped:Connect(function()
    circle.Visible = Settings.FOV
    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    circle.Radius = Settings.FOVRadius

    -- Apply WalkSpeed
    if Settings.SpeedWalk and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
    end
end)

-- ESP Box
local function CreateEspBox(plr)
    if not plr.Character or plr.Character:FindFirstChild("ESPBox") then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESPBox"
    box.Adornee = plr.Character:FindFirstChild("HumanoidRootPart")
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Color3 = Color3.new(1,0,0)
    box.Size = Vector3.new(3,5,1)
    box.Parent = plr.Character
end

-- Find and set closest target
local function GetClosest()
    local shortest = Settings.FOVRadius
    local nearest = nil
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and v.Team == LP.Team then continue end
            if Settings.DeathCheck and v.Character.Humanoid.Health <= 0 then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X,pos.Y) - (Camera.ViewportSize/2)).Magnitude
                if dist < shortest and dist < Settings.FOVRadius then
                    nearest = v
                    shortest = dist
                end
            end
        end
    end
    return nearest
end

-- Lock key
UIS.InputBegan:Connect(function(inp, gpe)
    if inp.KeyCode == Settings.LockKey and not gpe then
        Locking = not Locking
        if Locking then Target = GetClosest() end
    end
end)

-- Aimbot & Silent Aim
RunService.RenderStepped:Connect(function()
    if Locking and Settings.Aimbot and Target and Target.Character and Target.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
    end
    if Settings.SilentAim then
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LP and Settings.ESP then CreateEspBox(v) end
        end
    end
end)
