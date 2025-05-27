local Items = workspace.Item_Spawns.Items
local TweenService = loadstring(game:HttpGet("https://raw.githubusercontent.com/MildilyAcidic/MLua/refs/heads/main/TweenService.lua",true))()

local function TweenAndClickOnInstance(inst)
	local tweenInfo =  TweenService.TweenInfo.new(4, "Quad", "Out", 0, false, 0)
	local Tween = TweenService:Create(game.Players.LocalPlayer.Character.HumanoidRootPart, tweenInfo, {
    	Position = inst.Position
	})
	Tween:Play()
	Tween.Completed:Connect(function()
		mouse1click()
		wait(1.5)
	end)
    while TweenService.ManualUpdate() do
		workspace.Camera:SetRotation(inst.Position)
		mouse1click()
        wait(0.001)
    end
end

for _, Item in ipairs(Items:GetChildren()) do
	if Item:FindFirstChild('Base') then
		TweenAndClickOnInstance(Item:FindFirstChild('Base'))
	end
end
