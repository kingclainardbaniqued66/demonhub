-- DemonHub by GLockz

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = workspace.CurrentCamera

-- Settings
local AimbotEnabled = false
local FOVEnabled = false
local FOVRadius = 100
local AimPart = "Head"

-- Create GUI
local ScreenGui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
ScreenGui.Name = "DemonHubUI"

-- Open Button
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Text = "🔥 Open DemonHub Menu"
OpenButton.Size = UDim2.new(0, 200, 0, 50)
OpenButton.Position = UDim2.new(0, 10, 0, 10)
OpenButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OpenButton.TextColor3 = Color3.new(1, 1, 1)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 18
OpenButton.Parent = ScreenGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 200)
MainFrame.Position = UDim2.new(0, 10, 0, 70)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "DemonHub.lua"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22

-- Aimbot Toggle Button
local AimbotToggle = Instance.new("TextButton", MainFrame)
AimbotToggle.Position = UDim2.new(0, 10, 0, 50)
AimbotToggle.Size = UDim2.new(0, 230, 0, 40)
AimbotToggle.Text = "Aimbot: OFF"
AimbotToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AimbotToggle.TextColor3 = Color3.new(1, 1, 1)
AimbotToggle.Font = Enum.Font.Gotham
AimbotToggle.TextSize = 18

-- FOV Toggle Button
local FOVToggle = Instance.new("TextButton", MainFrame)
FOVToggle.Position = UDim2.new(0, 10, 0, 100)
FOVToggle.Size = UDim2.new(0, 230, 0, 40)
FOVToggle.Text = "FOV Circle: OFF"
FOVToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FOVToggle.TextColor3 = Color3.new(1, 1, 1)
FOVToggle.Font = Enum.Font.Gotham
FOVToggle.TextSize = 18

-- Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = FOVRadius
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Transparency = 1
FOVCircle.Visible = false
FOVCircle.Filled = false

-- Toggle visibility
OpenButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

-- Toggle Aimbot
AimbotToggle.MouseButton1Click:Connect(function()
	AimbotEnabled = not AimbotEnabled
	AimbotToggle.Text = "Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
end)

-- Toggle FOV
FOVToggle.MouseButton1Click:Connect(function()
	FOVEnabled = not FOVEnabled
	FOVCircle.Visible = FOVEnabled
	FOVToggle.Text = "FOV Circle: " .. (FOVEnabled and "ON" or "OFF")
end)

-- Get Closest Player
local function GetClosest()
	local closestPlayer = nil
	local shortestDistance = FOVRadius

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LP and player.Character and player.Character:FindFirstChild(AimPart) then
			local screenPoint, onScreen = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
			if onScreen then
				local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					closestPlayer = player
				end
			end
		end
	end
	return closestPlayer
end

-- Aimbot Logic
RunService.RenderStepped:Connect(function()
	if FOVEnabled then
		FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
	end

	if AimbotEnabled then
		local target = GetClosest()
		if target and target.Character and target.Character:FindFirstChild(AimPart) then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[AimPart].Position)
		end
	end
end)
