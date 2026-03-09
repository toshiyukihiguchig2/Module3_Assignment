-- HighJump
-- 高ジャンプエリア: パーツの上に乗っている間だけJumpHeightを上昇させる
-- パーツ: VentBase1〜4、サイズ(6,1,6)

local Players = game:GetService("Players")

local HIGH_JUMP_HEIGHT    = 25  -- 乗っている間のJumpHeight
local DEFAULT_JUMP_HEIGHT = 7.2 -- 離れたときに戻す値

local HighJump = {}

function HighJump.init(vents: { BasePart })
	-- プレイヤーごとに「どのベントに乗っているか」を管理
	-- { [userId]: { [ventPart]: true } }
	local onVents: { [number]: { [BasePart]: boolean } } = {}

	local function applyHighJump(player: Player, character: Model)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end
		humanoid.JumpHeight = HIGH_JUMP_HEIGHT
		print("[HighJump] ジャンプ力アップ:", player.Name)
	end

	local function restoreJump(player: Player, character: Model)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Parent then
			humanoid.JumpHeight = DEFAULT_JUMP_HEIGHT
			print("[HighJump] ジャンプ力を戻す:", player.Name)
		end
	end

	for _, vent in ipairs(vents) do
		vent.Touched:Connect(function(hit)
			local character = hit.Parent
			local player = Players:GetPlayerFromCharacter(character)
			if not player then return end

			local uid = player.UserId
			if not onVents[uid] then onVents[uid] = {} end

			-- 初めてベントに乗ったとき
			if not next(onVents[uid]) then
				applyHighJump(player, character)
			end
			onVents[uid][vent] = true
		end)

		vent.TouchEnded:Connect(function(hit)
			local character = hit.Parent
			local player = Players:GetPlayerFromCharacter(character)
			if not player then return end

			local uid = player.UserId
			task.delay(0.1, function()
				if onVents[uid] then
					onVents[uid][vent] = nil
					-- どのベントにも乗っていなければ戻す
					if not next(onVents[uid]) then
						restoreJump(player, character)
					end
				end
			end)
		end)
	end

	Players.PlayerRemoving:Connect(function(player)
		onVents[player.UserId] = nil
	end)

	print("[HighJump] init完了")
end

return HighJump
