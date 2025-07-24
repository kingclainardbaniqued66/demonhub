-- DemonHub by Glockz | Fixed GUI, All Features Enabled
local Players, RS, UIS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService")
local LP, Mouse, Cam = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), workspace.CurrentCamera
local Target = nil
local Speed = 30 -- Default walk speed

-- Settings (ALL TRUE by default)
local Settings = {
    Aimbot = true,
    SilentAim = true,
    ESP = true,
    TeamCheck = true,
    WallCheck = true,
    DeathCheck = true,
    FOVEnabled = true,
    BlatantMode = true,
    SpeedEnabled = true,
    FOVRadius = 30
}

-- FOV Drawing (locked to screen center, not draggable)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Settings.FOVEnabled
FOVCircle.Transparency = 1
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.new(1, 0, 0)
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)

-- Find Closest Target Function
function GetClosest()
    local closest, dist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and plr.Team == LP.Team then continue end
            if Settings.DeathCheck and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health <= 0 then continue end
            local pos, onScreen = Cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if not onScreen then continue end
            local mag = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude
            if mag < dist and mag < Settings.FOVRadius then
                dist = mag
                closest = plr
            end
        end
    end
    return closest
end

-- ESP Setup
if Settings.ESP then
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP then
            local tag = Instance.new("BillboardGui", plr.Character:WaitForChild("Head"))
            tag.Size = UDim2.new(0, 100, 0, 20)
            tag.AlwaysOnTop = true
            local txt = Instance.new("TextLabel", tag)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.Text = plr.Name
            txt.TextColor3 = Color3.new(1, 0, 0)
            txt.BackgroundTransparency = 1
        end
    end
end

-- Aimbot Loop
RS.RenderStepped:Connect(function()
    if Settings.Aimbot then
        Target = GetClosest()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, Target.Character.Head.Position)
        end
    end
    if Settings.FOVEnabled then
        FOVCircle.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    end
end)

-- E Key Lock Target
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        Target = GetClosest()
    end
end)

-- Speed Walk
if Settings.SpeedEnabled then
    LP.Character:WaitForChild("Humanoid").WalkSpeed = Speed
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("ScrollingFrame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.CanvasSize = UDim2.new(0, 0, 2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Frame.ScrollBarThickness = 6

function createToggle(name, settingName)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, #Frame:GetChildren()*35)
    btn.Text = name .. ": ON"
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        btn.Text = name .. ": " .. (Settings[settingName] and "ON" or "OFF")
    end)
end

-- Add Toggles
createToggle("Aimbot", "Aimbot")
createToggle("Silent Aim", "SilentAim")
createToggle("ESP", "ESP")
createToggle("Team Check", "TeamCheck")
createToggle("Wall Check", "WallCheck")
createToggle("Death Check", "DeathCheck")
createToggle("FOV Circle", "FOVEnabled")
createToggle("Blatant Mode", "BlatantMode")
createToggle("Speed Walk", "SpeedEnabled")

-- Speed Input
local speedBox = Instance.new("TextBox", Frame)
speedBox.Size = UDim2.new(1, -10, 0, 30)
speedBox.Position = UDim2.new(0, 5, 0, (#Frame:GetChildren()) * 35)
speedBox.PlaceholderText = "Enter Speed (default 30)"
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val then
        Speed = val
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = Speed
        end
    end
end)

print("✅ DemonHub Loaded | Made by GLockz")
