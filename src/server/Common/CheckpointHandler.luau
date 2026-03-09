-- CheckpointHandler
-- チェックポイント通過時にCFrameを保存し、
-- キャラクタースポーン直後にその位置へテレポートする
-- Player.RespawnLocationはSpawnLocation以外受け付けないため不使用

local Players = game:GetService("Players")

local SOUND_ID     = "rbxassetid://4698018252"
local SPAWN_OFFSET = Vector3.new(0, 4, 0) -- 足場の上に立たせるオフセット

local DECAL_FLASH_COLOR   = Color3.fromRGB(255, 170, 255) -- 変色後
local DECAL_ORIGIN_COLOR  = Color3.fromRGB(255, 255, 255) -- 元の色
local DECAL_FLASH_HOLD    = 0.3  -- 変色を維持する秒数
local DECAL_RETURN_DELAY  = 2.0  -- 元に戻るまでの秒数（変色維持後）

local function flashDecals(part: BasePart)
	-- パーツ直下のDecalを全て変色 → 数秒後に戻す
	local decals: { Decal } = {}
	for _, child in ipairs(part:GetChildren()) do
		if child:IsA("Decal") then
			table.insert(decals, child)
		end
	end
	if #decals == 0 then return end

	for _, decal in ipairs(decals) do
		decal.Color3 = DECAL_FLASH_COLOR
	end
	task.delay(DECAL_FLASH_HOLD + DECAL_RETURN_DELAY, function()
		for _, decal in ipairs(decals) do
			if decal and decal.Parent then
				decal.Color3 = DECAL_ORIGIN_COLOR
			end
		end
	end)
end

local CheckpointHandler = {}

-- プレイヤーごとのチェックポイントCFrameを保存
-- { [userId]: CFrame }
local savedCFrames: { [number]: CFrame } = {}

-- プレイヤーごとに通過済みチェックポイントを永続記録
-- { [userId]: { [checkpointName]: true } }
local activated: { [number]: { [string]: boolean } } = {}

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(function(character)
		local savedCFrame = savedCFrames[player.UserId]
		if not savedCFrame then return end

		-- HumanoidRootPartの生成を待ってからテレポート
		local rootPart = character:WaitForChild("HumanoidRootPart")
		task.wait(0.1) -- Robloxのスポーン処理が完了するまで待機
		rootPart.CFrame = savedCFrame
		print("[CheckpointHandler]", player.Name, "をチェックポイントへテレポート")
	end)
end

function CheckpointHandler.init(checkpoints: { BasePart })
	-- 既に入室済みのプレイヤーにも対応
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)

	Players.PlayerRemoving:Connect(function(player)
		savedCFrames[player.UserId] = nil
		activated[player.UserId]   = nil
	end)

	for _, checkpoint in ipairs(checkpoints) do
		local sound = Instance.new("Sound")
		sound.SoundId = SOUND_ID
		sound.Parent = checkpoint

		checkpoint.Touched:Connect(function(hit)
			local character = hit.Parent
			local player = Players:GetPlayerFromCharacter(character)
			if not player then return end

			if not activated[player.UserId] then
				activated[player.UserId] = {}
			end
			if activated[player.UserId][checkpoint.Name] then return end

			activated[player.UserId][checkpoint.Name] = true
			savedCFrames[player.UserId] = checkpoint.CFrame + SPAWN_OFFSET
			print("[CheckpointHandler]", player.Name, "がチェックポイント通過:", checkpoint.Name)

			sound:Play()
			flashDecals(checkpoint)
			print("[CheckpointHandler] チェックポイント保存 & サウンド再生完了")
		end)
	end
end

return CheckpointHandler
