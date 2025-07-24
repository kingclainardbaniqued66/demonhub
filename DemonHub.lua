-- DemonHub by GLockz
local Players, UIS, RS = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService")
local LP, Mouse, Cam = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), workspace.CurrentCamera
local Settings = {
    Aimbot = true, SilentAim = true, ESP = true, FOVEnabled = true, BlatantMode = true,
    TeamCheck = true, DeathCheck = true, WallCheck = true, SpeedWalk = false,
    FOVRadius = 30
}
local Locked, Target = false, nil
local WalkSpeedOn, NormalSpeed = 40, 16

-- GUI
local Gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui")) Gui.Name = "DemonHub"
local Open = Instance.new("TextButton", Gui) Open.Size = UDim2.new(0, 180, 0, 35)
Open.Position = UDim2.new(0, 10, 0, 10) Open.Text = "🔥 Open DemonHub"
Open.BackgroundColor3 = Color3.fromRGB(30,30,30) Open.TextColor3 = Color3.new(1,1,1)

local Main = Instance.new("Frame", Gui) Main.Size = UDim2.new(0, 260, 0, 330)
Main.Position = UDim2.new(0, 10, 0, 55) Main.Visible = false
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
local List = Instance.new("UIListLayout", Main) List.Padding = UDim.new(0, 5)

local function Toggle(text, setting)
	local btn = Instance.new("TextButton", Main)
	btn.Size = UDim2.new(0, 240, 0, 28) btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1) btn.Font = Enum.Font.Gotham btn.TextSize = 14
	btn.Text = text..": "..tostring(Settings[setting])
	btn.MouseButton1Click:Connect(function()
		Settings[setting] = not Settings[setting]
		btn.Text = text..": "..tostring(Settings[setting])
	end)
end

for _, opt in pairs({"Aimbot","SilentAim","ESP","FOVEnabled","BlatantMode","TeamCheck","DeathCheck","WallCheck","SpeedWalk"}) do
	Toggle(opt, opt)
end

Open.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

-- ESP
function CreateESP(plr)
	if not plr.Character or plr == LP or plr.Character:FindFirstChild("ESP") then return end
	local esp = Instance.new("Highlight", plr.Character) esp.Name = "ESP"
	esp.FillColor = Color3.new(1, 0, 0) esp.FillTransparency = 0.5 esp.OutlineTransparency = 1
end

-- FOV Circle
local FOV = Drawing.new("Circle")
FOV.Color = Color3.fromRGB(255, 0, 0)
FOV.Thickness = 2 FOV.NumSides = 100 FOV.Radius = Settings.FOVRadius
FOV.Filled = false FOV.Visible = true
RS.RenderStepped:Connect(function()
	FOV.Position = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
	FOV.Visible = Settings.FOVEnabled
end)

-- Find Target
function GetClosest()
	local closest, dist = nil, math.huge
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and (not Settings.TeamCheck or plr.Team ~= LP.Team) then
			local hum = plr.Character:FindFirstChild("Humanoid")
			if not hum or (Settings.DeathCheck and hum.Health <= 0) then continue end
			local pos, onScreen = Cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
			local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)).Magnitude
			if onScreen and mag < Settings.FOVRadius and mag < dist then
				dist = mag
				closest = plr
			end
		end
	end
	return closest
end

-- Aimbot Logic
RS.RenderStepped:Connect(function()
	if Settings.ESP then
		for _, p in pairs(Players:GetPlayers()) do p ~= LP and CreateESP(p) end
	end

	if Settings.SpeedWalk then
		LP.Character.Humanoid.WalkSpeed = WalkSpeedOn
	else
		LP.Character.Humanoid.WalkSpeed = NormalSpeed
	end

	if Settings.Aimbot and Locked and Target and Target.Character and Target.Character:FindFirstChild("Head") then
		local pos = Target.Character.Head.Position
		local screenPos, visible = Cam:WorldToViewportPoint(pos)
		if visible then
			Cam.CFrame = CFrame.new(Cam.CFrame.Position, pos)
		end
	end
end)

-- Lock on E
UIS.InputBegan:Connect(function(i,g)
	if i.KeyCode == Enum.KeyCode.E and not g then
		if Locked then
			Locked = false
			Target = nil
		else
			Target = GetClosest()
			Locked = Target ~= nil
		end
	end
end)

-- Silent Aim hook
local __namecall
__namecall = hookmetamethod(game, "__namecall", function(...)
	local args = {...}
	local method = getnamecallmethod()
	if Settings.SilentAim and Locked and Target and method == "FireServer" and tostring(args[1]) == "HitPart" then
		if Target.Character and Target.Character:FindFirstChild("Head") then
			args[2] = Target.Character.Head
			return __namecall(unpack(args))
		end
	end
	return __namecall(...)
end)
