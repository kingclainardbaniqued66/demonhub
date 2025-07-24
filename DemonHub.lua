-- DemonHub by KingclainardBaniqued66
-- Modern, clean, mobile-friendly silent aim & aimbot GUI

local Players, UIS, RS = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService")
local LP, Mouse, Cam = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), workspace.CurrentCamera

local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "DemonHub"
Gui.ResetOnSpawn = false

local FOV = 50
local Locked = false
local Target = nil
local SilentAim = false
local Aimbot = false
local ShowFOV = false

-- FOV Circle
local circle = Drawing.new("Circle")
circle.Thickness = 2
circle.Radius = FOV
circle.Filled = false
circle.Visible = false
circle.Color = Color3.fromRGB(255, 0, 0)

RS.RenderStepped:Connect(function()
	circle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
	circle.Radius = FOV
	circle.Visible = ShowFOV
end)

-- GUI
local Frame = Instance.new("Frame", Gui)
Frame.Size = UDim2.new(0, 260, 0, 300)
Frame.Position = UDim2.new(0.01, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Name = "MainUI"

local function createButton(name, y, callback)
	local b = Instance.new("TextButton", Frame)
	b.Text = name .. ": Off"
	b.Size = UDim2.new(0, 240, 0, 30)
	b.Position = UDim2.new(0, 10, 0, y)
	b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.MouseButton1Click:Connect(function()
		local new = callback()
		b.Text = name .. ": " .. (new and "On" or "Off")
	end)
	return b
end

-- Toggle Silent Aim
createButton("Silent Aim", 40, function()
	SilentAim = not SilentAim
	return SilentAim
end)

-- Toggle Aimbot
createButton("Aimbot", 80, function()
	Aimbot = not Aimbot
	return Aimbot
end)

-- Toggle Noclip
createButton("Noclip", 120, function()
	local state = false
	local conn
	state = not state
	if state then
		conn = RS.Stepped:Connect(function()
			for _, part in ipairs(LP.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	else
		if conn then conn:Disconnect() end
	end
	return state
end)

-- FOV Toggle
createButton("FOV Circle", 160, function()
	ShowFOV = not ShowFOV
	return ShowFOV
end)

-- Lock Button
local LockBtn = createButton("Lock", 200, function()
	Locked = not Locked
	if not Locked then Target = nil end
	return Locked
end)

-- Speed Slider
local SpeedLabel = Instance.new("TextLabel", Frame)
SpeedLabel.Text = "WalkSpeed: 16"
SpeedLabel.Size = UDim2.new(0, 240, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 240)
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextSize = 14

local SpeedSlider = Instance.new("TextButton", Frame)
SpeedSlider.Text = "Change Speed"
SpeedSlider.Size = UDim2.new(0, 240, 0, 30)
SpeedSlider.Position = UDim2.new(0, 10, 0, 260)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedSlider.TextColor3 = Color3.new(1, 1, 1)
SpeedSlider.Font = Enum.Font.GothamBold
SpeedSlider.TextSize = 14
SpeedSlider.MouseButton1Click:Connect(function()
	local speed = tonumber(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SpeedInput") or "24")
	if speed then
		LP.Character.Humanoid.WalkSpeed = speed
		SpeedLabel.Text = "WalkSpeed: " .. speed
	end
end)

-- Silent Aim/Aimbot Logic
function getClosest()
	local closest = nil
	local maxDist = FOV
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= LP and v.Character and v.Character:FindFirstChild("Head") then
			local pos, visible = Cam:WorldToViewportPoint(v.Character.Head.Position)
			if visible then
				local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)).Magnitude
				if dist < maxDist then
					maxDist = dist
					closest = v
				end
			end
		end
	end
	return closest
end

RS.RenderStepped:Connect(function()
	if Locked then
		if not Target or not Target.Character or not Target.Character:FindFirstChild("Head") then
			Target = getClosest()
		end
		if Target and Target.Character and Target.Character:FindFirstChild("Head") then
			if Aimbot then
				Cam.CFrame = CFrame.new(Cam.CFrame.Position, Target.Character.Head.Position)
			end
		end
	elseif SilentAim then
		Target = getClosest()
	end
end)

print("✅ DemonHub Loaded by KingclainardBaniqued66")
