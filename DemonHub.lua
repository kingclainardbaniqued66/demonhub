-- DemonHub by GLockz | Updated Version

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

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
    FOVRadius = 30,
}

-- Variables
local Target = nil
local Locking = false

-- GUI
local ScreenGui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
ScreenGui.Name = "DemonHub"

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Text = "🔥 Open DemonHub Menu"
OpenBtn.Size = UDim2.new(0, 200, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0, 10)
OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 18

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 400)
Main.Position = UDim2.new(0, 10, 0, 70)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Visible = false

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "DemonHub.lua"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Transparency = 1
FOVCircle.Filled = false
FOVCircle.Visible = Settings.FOVEnabled

-- Speed Walk
if Settings.SpeedWalk then
    LP.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").WalkSpeed = 25
    end)
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 25
    end
end

-- ESP (basic box over head)
if Settings.ESP then
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local billboard = Instance.new("BillboardGui", player.Character:WaitForChild("Head"))
            billboard.Size = UDim2.new(0, 100, 0, 40)
            billboard.Adornee = player.Character.Head
            billboard.AlwaysOnTop = true
            local label = Instance.new("TextLabel", billboard)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = player.Name
            label.TextColor3 = Color3.new(1, 0, 0)
            label.TextStrokeTransparency = 0
        end
    end
end

-- Find Closest Target
local function GetClosest()
    local closest, dist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("Head") then
            if Settings.TeamCheck and player.Team == LP.Team then continue end
            if Settings.DeathCheck and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health <= 0 then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < dist and mag <= Settings.FOVRadius then
                    closest = player
                    dist = mag
                end
            end
        end
    end
    return closest
end

-- Lock on Press E
UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.E and not processed then
        Locking = not Locking
        if Locking then
            Target = GetClosest()
        else
            Target = nil
        end
    end
end)

-- Main Aimbot Loop
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.FOVEnabled

    if Settings.Aimbot and Target and Target.Character and Target.Character:FindFirstChild("Head") then
        if not Locking then
            Target = GetClosest()
        end
        if Settings.SilentAim or Settings.BlatantMode then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
        end
    end
end)
