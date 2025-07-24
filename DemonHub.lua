-- DemonHub by GLockz
-- All features ON by default, GUI toggles, FOV, Silent Aim, ESP, Speed Walk.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Settings
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

local Target, Locking = nil, false

-- GUI Setup
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "DemonHubUI"

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 200, 0, 40)
openBtn.Position = UDim2.new(0,10,0,10)
openBtn.Text = "🔥 Open DemonHub Menu"
openBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 18

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0,10,0,60)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Visible = false
main.Active = true
main.Draggable = true

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1,0,1,0)
scroll.CanvasSize = UDim2.new(0,0,2,0)
scroll.ScrollBarThickness = 4

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,5)

-- Helper to create toggles
local function MakeToggle(name)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = name .. ": ON"
    btn.MouseButton1Click:Connect(function()
        local key = name:gsub(" ", "")
        Settings[key] = not Settings[key]
        btn.Text = name .. ": " .. (Settings[key] and "ON" or "OFF")
    end)
end

for _, name in ipairs({"Aimbot","SilentAim","ESP","FOV","TeamCheck","WallCheck","DeathCheck","SpeedWalk"}) do
    MakeToggle(name)
end

-- Speed input
local speedLbl = Instance.new("TextLabel", scroll)
speedLbl.Size = UDim2.new(1, -20, 0, 30)
speedLbl.BackgroundTransparency = 1
speedLbl.Text = "Walk Speed:"
speedLbl.Font = Enum.Font.Gotham
speedLbl.TextSize = 16
speedLbl.TextColor3 = Color3.new(1,1,1)

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

    if Settings.SpeedWalk and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
    end
end)

-- ESP creation
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

-- Get nearest target
local function GetClosest()
    local shortest = Settings.FOVRadius
    local nearest = nil
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
            if Settings.DeathCheck and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health <= 0 then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X,pos.Y) - (Camera.ViewportSize/2)).Magnitude
                if dist < shortest then
                    nearest = v
                    shortest = dist
                end
            end
        end
    end
    return nearest
end

-- Lock on E
UIS.InputBegan:Connect(function(inp, gpe)
    if inp.KeyCode == Settings.LockKey and not gpe then
        Locking = not Locking
        if Locking then Target = GetClosest() end
    end
end)

-- Main Loop: Aimbot + ESP + Silent Aim
RunService.RenderStepped:Connect(function()
    if Settings.ESP then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer then CreateEspBox(p) end
        end
    end

    if Target and Settings.Aimbot then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
    end
end)
