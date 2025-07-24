-- DemonHub by GLoCKz
local Players, RS, UIS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService")
local LP, Mouse, Cam = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), workspace.CurrentCamera

local Settings = {
    Aimbot = true,
    SilentAim = true,
    FOV = 30,
    NoClip = true,
    Lock = true,
}

-- Create GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DH_"..math.random(1000, 9999)
local Toggle = Instance.new("TextButton", ScreenGui)
Toggle.Size = UDim2.new(0, 100, 0, 30)
Toggle.Position = UDim2.new(0, 10, 0, 100)
Toggle.Text = "[Toggle]"
Toggle.BackgroundColor3 = Color3.fromRGB(25,25,25)
Toggle.TextColor3 = Color3.fromRGB(255,255,255)

local Lock = Instance.new("TextButton", ScreenGui)
Lock.Size = UDim2.new(0, 100, 0, 30)
Lock.Position = UDim2.new(0, 10, 0, 140)
Lock.Text = "[Lock]"
Lock.BackgroundColor3 = Color3.fromRGB(25,25,25)
Lock.TextColor3 = Color3.fromRGB(255,255,255)

local Menu = Instance.new("Frame", ScreenGui)
Menu.Size = UDim2.new(0, 200, 0, 240)
Menu.Position = UDim2.new(0, 120, 0, 100)
Menu.BackgroundColor3 = Color3.fromRGB(15,15,15)
Menu.Visible = false

local FOVSlider = Instance.new("TextButton", Menu)
FOVSlider.Size = UDim2.new(0, 180, 0, 30)
FOVSlider.Position = UDim2.new(0, 10, 0, 10)
FOVSlider.Text = "FOV: "..Settings.FOV
FOVSlider.BackgroundColor3 = Color3.fromRGB(40,40,40)
FOVSlider.TextColor3 = Color3.fromRGB(255,255,255)

local function makeToggleButton(name, default, posY)
    local btn = Instance.new("TextButton", Menu)
    btn.Size = UDim2.new(0, 180, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Name = name
    btn.Text = name..": "..tostring(default)
    btn.MouseButton1Click:Connect(function()
        Settings[name] = not Settings[name]
        btn.Text = name..": "..tostring(Settings[name])
    end)
end

makeToggleButton("Aimbot", Settings.Aimbot, 50)
makeToggleButton("SilentAim", Settings.SilentAim, 90)
makeToggleButton("NoClip", Settings.NoClip, 130)

FOVSlider.MouseButton1Click:Connect(function()
    Settings.FOV = (Settings.FOV + 10) % 100
    if Settings.FOV < 10 then Settings.FOV = 10 end
    FOVSlider.Text = "FOV: "..Settings.FOV
end)

Toggle.MouseButton1Click:Connect(function()
    Menu.Visible = not Menu.Visible
end)

-- FOV Circle
local circle = Drawing.new("Circle")
circle.Thickness = 1.5
circle.NumSides = 64
circle.Radius = Settings.FOV
circle.Color = Color3.fromRGB(255, 0, 0)
circle.Filled = false
circle.Visible = true

RS.RenderStepped:Connect(function()
    local mousePos = UIS:GetMouseLocation()
    circle.Position = Vector2.new(mousePos.X, mousePos.Y)
    circle.Radius = Settings.FOV
end)

-- Silent Aim / Aimbot Logic
local function getClosestTarget()
    local maxDist = Settings.FOV
    local target = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Cam:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            local dist = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
            if dist < maxDist and onScreen then
                maxDist = dist
                target = player
            end
        end
    end
    return target
end

RS.RenderStepped:Connect(function()
    if Settings.Aimbot then
        local target = getClosestTarget()
        if target and target.Character then
            local part = target.Character:FindFirstChild("Head")
            if part then
                Cam.CFrame = CFrame.new(Cam.CFrame.Position, part.Position)
            end
        end
    end
end)

-- Silent Aim Hook
if Settings.SilentAim then
    local __namecall
    __namecall = hookmetamethod(game, "__namecall", function(...)
        local args = {...}
        local method = getnamecallmethod()
        if tostring(method) == "FireServer" and args[2] and typeof(args[2]) == "Vector3" then
            local target = getClosestTarget()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                args[2] = target.Character.Head.Position
                return __namecall(unpack(args))
            end
        end
        return __namecall(...)
    end)
end

-- NoClip
RS.Stepped:Connect(function()
    if Settings.NoClip and LP.Character then
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)
