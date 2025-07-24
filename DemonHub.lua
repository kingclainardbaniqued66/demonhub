-- DemonHub by GLockz (Improved UI with Color Picker + FOV Size)
-- Features: Aimbot, Silent Aim, ESP, Speed Walk, FOV Circle, Keybind, Scrollable UI

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Camera = workspace.CurrentCamera

-- SETTINGS
local Settings = {
	Aimbot = true,
	SilentAim = true,
	ESP = true,
	WallCheck = true,
	TeamCheck = true,
	DeathCheck = true,
	Blatant = true,
	FOV = true,
	FOVSize = 30,
	FOVColor = Color3.fromRGB(255, 0, 0),
	SpeedWalk = true,
	SpeedValue = 35,
}

-- GUI
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "DemonHubUI"

local openBtn = Instance.new("TextButton")
openBtn.Parent = gui
openBtn.Text = "🔥 Open DemonHub Menu"
openBtn.Size = UDim2.new(0, 180, 0, 40)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 16

local main = Instance.new("ScrollingFrame", gui)
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0, 10, 0, 60)
main.CanvasSize = UDim2.new(0, 0, 3, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Visible = false
main.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", main)
layout.Padding = UDim.new(0, 5)

local function CreateToggle(txt, val)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Text = txt .. ": " .. (Settings[val] and "ON" or "OFF")
	btn.MouseButton1Click:Connect(function()
		Settings[val] = not Settings[val]
		btn.Text = txt .. ": " .. (Settings[val] and "ON" or "OFF")
	end)
	btn.Parent = main
end

local function CreateSlider(txt, val, min, max)
	local lbl = Instance.new("TextLabel", main)
	lbl.Size = UDim2.new(1, -10, 0, 20)
	lbl.BackgroundTransparency = 1
	lbl.Text = txt .. ": " .. tostring(Settings[val])
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 14

	local slider = Instance.new("TextButton", main)
	slider.Size = UDim2.new(1, -10, 0, 20)
	slider.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	slider.Text = "Slide to adjust"
	slider.TextColor3 = Color3.new(1, 1, 1)
	slider.Font = Enum.Font.Gotham
	slider.TextSize = 12
	slider.MouseButton1Down:Connect(function()
		local con
		con = RS.RenderStepped:Connect(function()
			local mpos = UIS:GetMouseLocation().X
			local guiX = slider.AbsolutePosition.X
			local percent = math.clamp((mpos - guiX) / slider.AbsoluteSize.X, 0, 1)
			local valnum = math.floor(min + (max - min) * percent)
			Settings[val] = valnum
			lbl.Text = txt .. ": " .. valnum
		end)
		UIS.InputEnded:Wait()
		con:Disconnect()
	end)
end

local function CreateColorPicker()
	local label = Instance.new("TextLabel", main)
	label.Size = UDim2.new(1, -10, 0, 20)
	label.BackgroundTransparency = 1
	label.Text = "FOV Color"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14

	local colorBtn = Instance.new("TextButton", main)
	colorBtn.Size = UDim2.new(1, -10, 0, 30)
	colorBtn.BackgroundColor3 = Settings.FOVColor
	colorBtn.Text = "Change FOV Color"
	colorBtn.TextColor3 = Color3.new(1, 1, 1)
	colorBtn.Font = Enum.Font.Gotham
	colorBtn.TextSize = 12

	colorBtn.MouseButton1Click:Connect(function()
		local r, g, b = math.random(100,255), math.random(100,255), math.random(100,255)
		Settings.FOVColor = Color3.fromRGB(r, g, b)
		colorBtn.BackgroundColor3 = Settings.FOVColor
	end)
end

-- Add UI toggles
CreateToggle("Aimbot", "Aimbot")
CreateToggle("Silent Aim", "SilentAim")
CreateToggle("ESP", "ESP")
CreateToggle("Wall Check", "WallCheck")
CreateToggle("Team Check", "TeamCheck")
CreateToggle("Death Check", "DeathCheck")
CreateToggle("Blatant Mode", "Blatant")
CreateToggle("Speed Walk", "SpeedWalk")
CreateSlider("FOV Size", "FOVSize", 10, 100)
CreateColorPicker()

-- FOV Circle
local circle = Drawing.new("Circle")
circle.Radius = Settings.FOVSize
circle.Color = Settings.FOVColor
circle.Filled = false
circle.Thickness = 2

RS.RenderStepped:Connect(function()
	circle.Visible = Settings.FOV
	circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	circle.Radius = Settings.FOVSize
	circle.Color = Settings.FOVColor

	if Settings.SpeedWalk then
		LP.Character:FindFirstChildWhichIsA("Humanoid").WalkSpeed = Settings.SpeedValue
	end
end)

-- Open GUI Toggle
openBtn.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)

-- Lock Keybind (E)
UIS.InputBegan:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.E and Settings.Aimbot then
		-- Target lock behavior placeholder
	end
end)
