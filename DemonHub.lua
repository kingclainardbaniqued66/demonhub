-- DemonHub by GLockz / kingclainardbaniqued66

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = workspace.CurrentCamera

local Gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
Gui.Name = "DemonHub"
Gui.ResetOnSpawn = false

-- UI FRAME
local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 300, 0, 360)
Main.Position = UDim2.new(0.5, -150, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Visible = false
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Active = true
Main.Draggable = true

-- UI Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "DemonHub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- Toggle Button
local ToggleBtn = Instance.new("TextButton", Gui)
ToggleBtn.Size = UDim2.new(0, 60, 0, 30)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.Text = "[Toggle]"
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

ToggleBtn.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

-- Lock Button
local LockBtn = Instance.new("TextButton", Gui)
LockBtn.Size = UDim2.new(0, 60, 0, 30)
LockBtn.Position = UDim2.new(0, 80, 0, 10)
LockBtn.Text = "[Lock]"
LockBtn.Font = Enum.Font.GothamBold
LockBtn.TextSize = 14
LockBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Feature Toggles
local function CreateToggle(name, y, default)
	local toggle = Instance.new("TextButton", Main)
	toggle.Size = UDim2.new(0, 260, 0, 30)
	toggle.Position = UDim2.new(0, 20, 0, y)
	toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	toggle.Font = Enum.Font.Gotham
	toggle.TextSize = 14
	toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggle.Text = name .. ": Off"

	local state = false

	toggle.MouseButton1Click:Connect(function()
		state = not state
		toggle.Text = name .. ": " .. (state and "On" or "Off")
	end)

	return function()
		return state
	end
end

local getSilentAim = CreateToggle("Silent Aim", 40, false)
local getAimbot = CreateToggle("Aimbot", 80, false)
local getNoclip = CreateToggle("Noclip", 120, false)

-- FOV Slider
local FOVLabel = Instance.new("TextLabel", Main)
FOVLabel.Size = UDim2.new(0, 260, 0, 20)
FOVLabel.Position = UDim2.new(0, 20, 0, 160)
FOVLabel.Text = "FOV Radius: 100"
FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVLabel.Font = Enum.Font.Gotham
FOVLabel.TextSize = 14
FOVLabel.BackgroundTransparency = 1

local FOVSlider = Instance.new("TextButton", Main)
FOVSlider.Size = UDim2.new(0, 260, 0, 20)
FOVSlider.Position = UDim2.new(0, 20, 0, 190)
FOVSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FOVSlider.Text = ""
FOVSlider.AutoButtonColor = false

local circle = Drawing.new("Circle")
circle.Color = Color3.fromRGB(255, 0, 0)
circle.Thickness = 1
circle.NumSides = 100
circle.Filled = false
circle.Radius = 100
circle.Visible = false

local showFOV = false

FOVSlider.MouseButton1Click:Connect(function()
	showFOV = not showFOV
	circle.Visible = showFOV
end)

RunService.RenderStepped:Connect(function()
	circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- Aimbot + SilentAim Target
local function getClosestPlayer()
	local closest, distance = nil, math.huge
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= LP and v.Character and v.Character:FindFirstChild("Head") then
			local screenPoint, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
			if onScreen then
				local mag = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
				if mag < circle.Radius then
					if mag < distance then
						closest = v
						distance = mag
					end
				end
			end
		end
	end
	return closest
end

-- Aimbot behavior
RunService.RenderStepped:Connect(function()
	if getAimbot() then
		local target = getClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
		end
	end
end)

-- Noclip
RunService.Stepped:Connect(function()
	if getNoclip() and LP.Character then
		for _, part in pairs(LP.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- Silent Aim (anti-detect logic handled elsewhere if needed)

-- Lock Button Target
local lockedTarget = nil
LockBtn.MouseButton1Click:Connect(function()
	if lockedTarget then
		lockedTarget = nil
		LockBtn.Text = "[Lock]"
	else
		lockedTarget = getClosestPlayer()
		LockBtn.Text = "[Locked]"
	end
end)

-- Load with everything OFF
Main.Visible = false
circle.Visible = false

print("✅ DemonHub Loaded")
