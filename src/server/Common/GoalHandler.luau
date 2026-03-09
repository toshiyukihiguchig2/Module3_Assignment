-- GoalHandler
-- GoalPartに接触したらクライアントにダンスアニメーションを依頼し、
-- 終了後にLobbyのSpawnLocationへテレポートする

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DANCE_DURATION  = 10.0 -- クライアント側 9.0秒 + バッファ
local TURN_DURATION   = 0.3  -- 振り返りにかける秒数（ステップ数）
local TURN_STEPS      = 6    -- 振り返りを何ステップに分割するか

-- RemoteEvent作成（なければ生成）
local remoteEvent = ReplicatedStorage:FindFirstChild("GoalDanceAnim")
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "GoalDanceAnim"
	remoteEvent.Parent = ReplicatedStorage
end

local GoalHandler = {}

function GoalHandler.init(goalPart: BasePart, lobbySpawn: SpawnLocation)
	-- プレイヤーごとの多重発火防止
	local debounce: { [number]: boolean } = {}

	goalPart.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end
		if debounce[player.UserId] then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end

		debounce[player.UserId] = true
		print("[GoalHandler]", player.Name, "がゴールに到達！")

		local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart

		-- ダンス中は移動・ジャンプ禁止
		humanoid.WalkSpeed  = 0
		humanoid.JumpHeight = 0

		-- 振り返り（180度回転をTURN_STEPSに分割してなめらかに回す）
		if rootPart then
			local stepAngle = math.pi / TURN_STEPS
			local stepWait  = TURN_DURATION / TURN_STEPS
			for _ = 1, TURN_STEPS do
				rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, stepAngle, 0)
				task.wait(stepWait)
			end
		end

		-- クライアントにダンス開始を通知
		remoteEvent:FireClient(player)
		print("[GoalHandler] GoalDanceAnim イベント送信 →", player.Name)

		-- ダンス終了まで待機
		task.wait(DANCE_DURATION)

		-- LobbyのSpawnLocationへテレポート
		if rootPart and character.Parent then
			rootPart.CFrame = lobbySpawn.CFrame + Vector3.new(0, 4, 0)
			print("[GoalHandler]", player.Name, "を Lobby SpawnLocation へテレポート完了")
		end

		-- 移動速度を元に戻す
		task.wait(0.1)
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed  = 16
			humanoid.JumpHeight = 7.2
		end

		-- 少し後にdebounce解除（連続ゴール防止のため1秒待つ）
		task.delay(1, function()
			debounce[player.UserId] = nil
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		debounce[player.UserId] = nil
	end)

	print("[GoalHandler] init完了 - GoalPart:", goalPart.Name)
end

return GoalHandler
