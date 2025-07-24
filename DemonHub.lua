-- DemonHub by GLockz
local Players, RunService, UIS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService")
local LP, Mouse, Cam = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), workspace.CurrentCamera
local Target, SpeedEnabled = nil, true

-- UI Setup
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "DemonHubUI"

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 200, 0, 40)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.Text = "🔥 Open DemonHub Menu"
openBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 18

local mainFrame = Instance.new("ScrollingFrame", gui)
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0, 10, 0, 60)
mainFrame.CanvasSize = UDim2.new(0,0,3,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
mainFrame.Visible = false

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🎯 DemonHub"
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(40,40,40)

-- Function to make toggles
local y = 50
local Settings = {
    ["Aimbot"] = true,
    ["SilentAim"] = true,
    ["ESP"] = true,
    ["FOV"] = true,
    ["WallCheck"] = true,
    ["TeamCheck"] = true,
    ["BlatantMode"] = true,
    ["SpeedWalk"] = true
}
for name, val in pairs(Settings) do
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = name .. ": Open"
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.MouseButton1Click:Connect(function()
        Settings[name] = not Settings[name]
        btn.Text = name .. ": " .. (Settings[name] and "Open" or "Closed")
    end)
    y = y + 40
end

-- Toggle menu
openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    openBtn.Text = mainFrame.Visible and "❌ Close DemonHub Menu" or "🔥 Open DemonHub Menu"
end)

-- FOV Circle
local circle = Drawing.new("Circle")
circle.Visible = true
circle.Color = Color3.new(1, 1, 1)
circle.Radius = 30
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 1

RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    circle.Position = center
end)

-- Get Closest Player
function GetClosest()
    local maxDist, closest = 1e5, nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if Settings.TeamCheck and p.Team == LP.Team then continue end
            local pos, onScreen = Cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            local dist = (Vector2.new(pos.X, pos.Y) - Cam.ViewportSize/2).Magnitude
            if onScreen and dist < maxDist and dist < circle.Radius then
                if Settings.WallCheck then
                    local ray = Ray.new(Cam.CFrame.Position, (p.Character.Head.Position - Cam.CFrame.Position).Unit * 1000)
                    local part = workspace:FindPartOnRay(ray, LP.Character, false, true)
                    if part and not part:IsDescendantOf(p.Character) then continue end
                end
                maxDist = dist
                closest = p
            end
        end
    end
    return closest
end

-- Lock with E
UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.E and not gameProcessed then
        Target = GetClosest()
    end
end)

-- Aimbot Lock
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and Target and Target.Character and Target.Character:FindFirstChild("Head") then
        Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position, Target.Character.Head.Position), 0.3)
    end
end)

-- Speed Walk
RunService.RenderStepped:Connect(function()
    if Settings.SpeedWalk and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 30
    end
end)

-- Silent Aim (example basic)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(...)
    local args = {...}
    local method = getnamecallmethod()
    if Settings.SilentAim and Target and tostring(method) == "FindPartOnRayWithIgnoreList" then
        local head = Target.Character and Target.Character:FindFirstChild("Head")
        if head then
            args[2] = Ray.new(Cam.CFrame.Position, (head.Position - Cam.CFrame.Position).Unit * 1000)
            return old(unpack(args))
        end
    end
    return old(...)
end)
