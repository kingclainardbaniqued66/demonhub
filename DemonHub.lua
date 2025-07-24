-- DemonHub by GLockz
-- Modern Mobile-Friendly Aimbot UI with Silent Aim, Aimbot, FOV, and Noclip

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- Settings
local Settings = {
    Aimbot = false,
    SilentAim = false,
    Noclip = false,
    Lock = false,
    FOV = 100,
    Target = nil
}

-- Anti-detection stub
getgenv().DemonHub = true

-- UI Creation
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DemonHub"

local Toggle = Instance.new("TextButton", ScreenGui)
Toggle.Position = UDim2.new(0, 10, 0.5, -25)
Toggle.Size = UDim2.new(0, 60, 0, 50)
Toggle.Text = "Toggle"
Toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.BorderSizePixel = 0
Toggle.AutoButtonColor = true
Toggle.ZIndex = 2

local LockBtn = Instance.new("TextButton", ScreenGui)
LockBtn.Position = UDim2.new(0, 80, 0.5, -25)
LockBtn.Size = UDim2.new(0, 60, 0, 50)
LockBtn.Text = "Lock"
LockBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LockBtn.TextColor3 = Color3.new(1,1,1)
LockBtn.BorderSizePixel = 0
LockBtn.AutoButtonColor = true
LockBtn.ZIndex = 2

-- Main Menu
local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.3, 0, 0.2, 0)
Frame.Size = UDim2.new(0, 300, 0, 250)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Visible = false
Frame.Active = true
Frame.Draggable = true

-- UI Title
local Title = Instance.new("TextLabel", Frame)
Title.Text = "DemonHub"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

-- Toggle Buttons
local function createToggle(name, yPos, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = name..": Off"

    btn.MouseButton1Click:Connect(function()
        Settings[name] = not Settings[name]
        btn.Text = name..": "..(Settings[name] and "On" or "Off")
        if callback then callback(Settings[name]) end
    end)
end

createToggle("Aimbot", 40)
createToggle("SilentAim", 80)
createToggle("Noclip", 120)

-- FOV Slider
local FOVLabel = Instance.new("TextLabel", Frame)
FOVLabel.Text = "FOV: 100"
FOVLabel.Position = UDim2.new(0, 10, 0, 160)
FOVLabel.Size = UDim2.new(1, -20, 0, 20)
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextColor3 = Color3.new(1,1,1)
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextSize = 14
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left

local Slider = Instance.new("TextButton", Frame)
Slider.Position = UDim2.new(0, 10, 0, 185)
Slider.Size = UDim2.new(1, -20, 0, 20)
Slider.BackgroundColor3 = Color3.fromRGB(50,50,50)
Slider.Text = ""
Slider.AutoButtonColor = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Radius = Settings.FOV
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.4

Slider.MouseButton1Down:Connect(function()
	local moveConn
	moveConn = Mouse.Move:Connect(function()
		local relX = math.clamp((Mouse.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
		Settings.FOV = math.floor(relX * 300)
		FOVLabel.Text = "FOV: "..Settings.FOV
		FOVCircle.Radius = Settings.FOV
	end)
	UserInput.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if moveConn then moveConn:Disconnect() end
		end
	end)
end)

-- Toggle GUI visibility
Toggle.MouseButton1Click:Connect(function()
	Frame.Visible = not Frame.Visible
end)

-- Lock Functionality
LockBtn.MouseButton1Click:Connect(function()
	Settings.Lock = not Settings.Lock
	LockBtn.Text = Settings.Lock and "Locked" or "Lock"
end)

-- Get closest player
local function getClosest()
	local maxDist, closest = Settings.FOV, nil
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).magnitude
				if dist < maxDist then
					maxDist = dist
					closest = v
				end
			end
		end
	end
	return closest
end

-- Aimbot and Lock Loop
RunService.RenderStepped:Connect(function()
	FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	if Settings.Aimbot or Settings.Lock then
		local target = getClosest()
		if target and target.Character then
			local part = target.Character:FindFirstChild("Head")
			if part then
				if Settings.Aimbot then
					Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
				end
				if Settings.Lock then
					if not Settings.Target then
						Settings.Target = target
					end
				end
			end
		end
	end

	if Settings.Lock and Settings.Target then
		local part = Settings.Target.Character and Settings.Target.Character:FindFirstChild("Head")
		if part then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
		end
	end
end)

-- Silent Aim Hook (basic example)
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
	local args = {...}
	if Settings.SilentAim and tostring(self) == "Raycast" and Settings.Target then
		local targetPart = Settings.Target.Character and Settings.Target.Character:FindFirstChild("Head")
		if targetPart then
			args[2] = targetPart.Position - Camera.CFrame.Position
			return old(self, unpack(args))
		end
	end
	return old(self, ...)
end)

-- Noclip
RunService.Stepped:Connect(function()
	if Settings.Noclip then
		for _, v in pairs(LP.Character:GetDescendants()) do
			if v:IsA("BasePart") and v.CanCollide then
				v.CanCollide = false
			end
		end
	end
end)

setreadonly(mt, true)
