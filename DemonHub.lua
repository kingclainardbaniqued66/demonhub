-- DemonHub by GLockz
-- Aimbot GUI with default toggles ON and visible FOV circle

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- Settings
local Aimbot = true
local TeamCheck = true
local DeathCheck = true
local WallCheck = true
local FOVEnabled = true
local BlatantMode = true
local FOVRadius = 100
local AimPart = "Head"

-- UI
local ScreenGui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
ScreenGui.Name = "DemonHubUI"

-- Open Button
local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Text = "🔥 Open DemonHub Menu"
OpenButton.Position = UDim2.new(0, 10, 0, 10)
OpenButton.Size = UDim2.new(0, 200, 0, 40)
OpenButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OpenButton.TextColor3 = Color3.new(1, 1, 1)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 16

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Position = UDim2.new(0, 10, 0, 60)
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false

-- Toggle Function
local function createToggle(name, default, posY)
	local toggle = Instance.new("TextButton", MainFrame)
	toggle.Name = name
	toggle.Text = name .. ": " .. tostring(default)
	toggle.Position = UDim2.new(0, 10, 0, posY)
	toggle.Size = UDim2.new(0, 230, 0, 30)
	toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	toggle.TextColor3 = Color3.new(1, 1, 1)
	toggle.Font = Enum.Font.SourceSansBold
	toggle.TextSize = 18

	toggle.MouseButton1Click:Connect(function()
		_G[name] = not _G[name]
		toggle.Text = name .. ": " .. tostring(_G[name])
	end)

	_G[name] = default
end

-- Create toggles
createToggle("Aimbot", true, 10)
createToggle("FOVEnabled", true, 50)
createToggle("TeamCheck", true, 90)
createToggle("DeathCheck", true, 130)
createToggle("WallCheck", true, 170)
createToggle("BlatantMode", true, 210)

-- Toggle Main GUI
OpenButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

-- FOV Circle
local circle = Drawing.new("Circle")
circle.Color = Color3.fromRGB(255, 0, 0)
circle.Thickness = 2
circle.Filled = false
circle.NumSides = 64
circle.Radius = FOVRadius
circle.Visible = true

RS.RenderStepped:Connect(function()
	local mouseLocation = UIS:GetMouseLocation()
	circle.Position = Vector2.new(mouseLocation.X, mouseLocation.Y + 36) -- +36 fixes offset
	circle.Visible = _G.FOVEnabled and _G.Aimbot
end)
