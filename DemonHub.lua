-- DemonHub by GLockz | Mobile-Supported Aimbot GUI

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Cam = workspace.CurrentCamera

-- Settings
local Aimbot = true
local FOVEnabled = true
local AimPart = "Head"
local FOVRadius = 100
local TeamCheck = false

-- UI Setup
local Gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
Gui.Name = "DemonHub"

-- Open Button
local Open = Instance.new("TextButton")
Open.Size = UDim2.new(0, 180, 0, 40)
Open.Position = UDim2.new(0, 10, 0, 10)
Open.BackgroundColor3 = Color3.fromRGB(30,30,30)
Open.Text = "🔥 Open DemonHub Menu"
Open.TextColor3 = Color3.new(1,1,1)
Open.Font = Enum.Font.GothamBold
Open.TextSize = 18
Open.Parent = Gui

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 250)
Main.Position = UDim2.new(0, 10, 0, 60)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = Gui

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "DemonHub.lua"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = Main

-- Toggle Buttons
local function MakeToggle(name, default, callback, position)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(0, 260, 0, 35)
	Btn.Position = UDim2.new(0, 20, 0, position)
	Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Btn.TextColor3 = Color3.new(1,1,1)
	Btn.Font = Enum.Font.Gotham
	Btn.TextSize = 16
	Btn.Text = name .. ": " .. (default and "ON" or "OFF")
	Btn.Parent = Main

	local state = default
	Btn.MouseButton1Click:Connect(function()
		state = not state
		Btn.Text = name .. ": " .. (state and "ON" or "OFF")
		callback(state)
	end)

	return Btn
end

-- Toggles
MakeToggle("Aimbot", true, function(val) Aimbot = val end, 50)
MakeToggle("FOV Circle", true, function(val) FOVEnabled = val end, 90)

-- Open Button Logic
Open.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

-- FOV Circle
local FOV = Drawing.new("Circle")
FOV.Color = Color3.fromRGB(255, 0, 0)
FOV.Radius = FOVRadius
FOV.Thickness = 2
FOV.Transparency = 0.5
FOV.Filled = false
FOV.Visible = FOVEnabled

-- Target Finder
local function GetClosest()
	local Max, Target = FOVRadius, nil
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= LP and v.Character and v.Character:FindFirstChild(AimPart) then
			if TeamCheck and v.Team == LP.Team then continue end
			local Pos, OnScreen = Cam:WorldToViewportPoint(v.Character[AimPart].Position)
			if OnScreen then
				local Dist = (Vector2.new(Pos.X, Pos.Y) - UIS:GetMouseLocation()).Magnitude
				if Dist < Max then
					Max = Dist
					Target = v
				end
			end
		end
	end
	return Target
end

-- Aimbot Loop
RS.RenderStepped:Connect(function()
	FOV.Visible = FOVEnabled
	FOV.Position = UIS:GetMouseLocation()

	if Aimbot then
		local Target = GetClosest()
		if Target and Target.Character and Target.Character:FindFirstChild(AimPart) then
			Cam.CFrame = CFrame.new(Cam.CFrame.Position, Target.Character[AimPart].Position)
		end
	end
end)
