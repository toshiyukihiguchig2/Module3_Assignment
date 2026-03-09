-- SeaDeathHandler
-- Terrain（地形）の水に入ったら溺死させる
-- 死亡判定はサーバー、アニメーション再生はRemoteEventでクライアントに委譲
-- Swimming状態になった後、頭のvoxelが水(Terrain Water)になった時点で溺死を発動する

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SOUND_ID        = "rbxassetid://120043778768093"
local DEATH_DELAY     = 1.0  -- アニメーションを見せてから死亡させるまでの秒数
local HEAD_CHECK_RATE = 0.05 -- 頭の位置チェック間隔（秒）
local VOXEL_SIZE      = 4    -- Terrain voxelの最小解像度（変更不要）

-- RemoteEvent作成（なければ生成）
local remoteEvent = ReplicatedStorage:FindFirstChild("SeaDeathAnim")
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "SeaDeathAnim"
	remoteEvent.Parent = ReplicatedStorage
end

-- 頭の位置のTerrainがWaterかどうかを判定する
-- Terrain:ReadVoxelsでvoxel素材を取得するため、Y座標の手動設定不要
local function isHeadInWater(head: BasePart): boolean
	local pos = head.Position
	local x = math.floor(pos.X / VOXEL_SIZE) * VOXEL_SIZE
	local y = math.floor(pos.Y / VOXEL_SIZE) * VOXEL_SIZE
	local z = math.floor(pos.Z / VOXEL_SIZE) * VOXEL_SIZE
	local region = Region3.new(
		Vector3.new(x, y, z),
		Vector3.new(x + VOXEL_SIZE, y + VOXEL_SIZE, z + VOXEL_SIZE)
	)
	local ok, materials = pcall(function()
		return workspace.Terrain:ReadVoxels(region, VOXEL_SIZE)
	end)
	if not ok then return false end
	return materials[1][1][1] == Enum.Material.Water
end

local SeaDeathHandler = {}

local function triggerDrown(character: Model, humanoid: Humanoid, rootPart: BasePart)
	print("[SeaDeathHandler] 頭が水中 → 溺死処理開始")

	-- サウンド再生
	local sound = Instance.new("Sound")
	sound.SoundId = SOUND_ID
	sound.Parent = rootPart
	sound:Play()
	print("[SeaDeathHandler] サウンド再生:", SOUND_ID)

	-- アニメーション再生をクライアントに依頼
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		remoteEvent:FireClient(player)
		print("[SeaDeathHandler] RemoteEvent送信 → クライアントにアニメーション再生を依頼")
	end

	-- アニメーション終了を待ってからキャラクターを透明化 → 死亡
	task.wait(DEATH_DELAY)
	if humanoid.Health > 0 then
		print("[SeaDeathHandler] キャラクター透明化 → 死亡処理開始")
		humanoid.BreakJointsOnDeath = false
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				part.Transparency = 1
			end
		end
		humanoid.Health = 0
		print("[SeaDeathHandler] 死亡処理完了")
	end
end

local function onCharacterAdded(character: Model)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart
	local head     = character:WaitForChild("Head") :: BasePart
	local debounce = false

	print("[SeaDeathHandler] キャラクター準備完了:", character.Name)

	humanoid.StateChanged:Connect(function(_, newState: Enum.HumanoidStateType)
		if newState ~= Enum.HumanoidStateType.Swimming then return end
		if debounce then return end

		print("[SeaDeathHandler] Swimming検知 → 頭のvoxel監視開始")

		-- Swimming状態が続く間、頭voxelが水かどうかを監視する
		while not debounce
			and humanoid.Health > 0
			and humanoid:GetState() == Enum.HumanoidStateType.Swimming
		do
			if isHeadInWater(head) then
				debounce = true
				triggerDrown(character, humanoid, rootPart)
				break
			end
			task.wait(HEAD_CHECK_RATE)
		end

		if not debounce then
			print("[SeaDeathHandler] Swimming終了（頭は水中でなかった）")
		end
	end)
end

local function onPlayerAdded(player: Player)
	print("[SeaDeathHandler] プレイヤー入室:", player.Name)
	player.CharacterAdded:Connect(onCharacterAdded)
end

function SeaDeathHandler.init()
	print("[SeaDeathHandler] init開始")
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	print("[SeaDeathHandler] init完了")
end

return SeaDeathHandler
