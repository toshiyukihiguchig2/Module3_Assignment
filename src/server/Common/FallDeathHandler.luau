-- FallDeathHandler
-- 全プレイヤーの HumanoidRootPart.Touched を監視
-- 落下速度50超で地面に接触したら即死（バラバラ演出: Roblox デフォルト死亡）

local Players = game:GetService("Players")

local FALL_SPEED_THRESHOLD = 100
local FALL_SOUND_ID        = "rbxassetid://85081675651690"

local FallDeathHandler = {}

local function setupCharacter(player: Player, character: Model)
	local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid

	local debounced = false

	rootPart.Touched:Connect(function(hit)
		if hit:IsDescendantOf(character) then return end  -- キャラクター自身は無視
		if debounced then return end
		if humanoid.Health <= 0 then return end

		local fallSpeed = -rootPart.AssemblyLinearVelocity.Y
		if fallSpeed > FALL_SPEED_THRESHOLD then
			debounced = true
			print("[FallDeathHandler] 落下死:", player.Name, "/ 速度:", math.floor(fallSpeed * 10) / 10, "studs/s")

			local sound = Instance.new("Sound")
			sound.SoundId = FALL_SOUND_ID
			sound.Parent = rootPart
			sound:Play()

			-- BreakJointsOnDeath=true（デフォルト）のままバラバラ演出
			humanoid.Health = 0
		end
	end)
end

function FallDeathHandler.init()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			setupCharacter(player, character)
		end)
	end)

	-- 既にインゲームにいるプレイヤーにも対応
	for _, player in ipairs(Players:GetPlayers()) do
		player.CharacterAdded:Connect(function(character)
			setupCharacter(player, character)
		end)
		if player.Character then
			setupCharacter(player, player.Character)
		end
	end

	print("[FallDeathHandler] 初期化完了 / 落下速度閾値:", FALL_SPEED_THRESHOLD, "studs/s")
end

return FallDeathHandler
