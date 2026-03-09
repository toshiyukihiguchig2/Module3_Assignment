-- GasTrap
-- 死亡パーツエリア: ガス罠（Model）
-- HasTrapSwitch属性がない場合のみ起動。4studs以内で溺死（4.1.2 海 の仕様）
-- 検知はRunService.Heartbeatによる近接距離判定（Touchedは不使用）

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DETECTION_RADIUS = 4       -- 検知半径（studs）
local DEATH_DELAY      = 1.0     -- アニメーション後の死亡ディレイ（秒）
local SEA_SOUND_ID     = "rbxassetid://120043778768093"  -- 溺死サウンド（SeaDeathHandlerと同じ）
local TRAP_SWITCH_ATTR = "HasTrapSwitch"

local seaDeathEvent = ReplicatedStorage:WaitForChild("SeaDeathAnim")

local GasTrap = {}

-- SeaDeathHandlerと同じ死亡処理（アニメーション・サウンド・透明化・死亡）
local function triggerGasDeath(player: Player, character: Model, humanoid: Humanoid, rootPart: BasePart)
	print("[GasTrap] ガス罠発動:", player.Name)

	local sound = Instance.new("Sound")
	sound.SoundId = SEA_SOUND_ID
	sound.Parent = rootPart
	sound:Play()
	print("[GasTrap] サウンド再生:", SEA_SOUND_ID)

	seaDeathEvent:FireClient(player)
	print("[GasTrap] RemoteEvent送信 → 溺死アニメーション再生依頼")

	task.wait(DEATH_DELAY)
	if humanoid.Health > 0 then
		humanoid.BreakJointsOnDeath = false
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				part.Transparency = 1
			end
		end
		humanoid.Health = 0
		print("[GasTrap] 死亡処理完了:", player.Name)
	end
end

-- gasModels: ガス罠のModelの配列（workspace.KillPartStage.Gas など）
function GasTrap.init(gasModels: { Model })
	local debounce: { [number]: boolean } = {}

	-- キャラクター再スポーン時にdebounceをリセット
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			debounce[player.UserId] = nil
		end)
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		player.CharacterAdded:Connect(function()
			debounce[player.UserId] = nil
		end)
	end

	print("[GasTrap] 初期化完了 / 検知半径:", DETECTION_RADIUS, "studs")

	RunService.Heartbeat:Connect(function()
		for _, gasModel in ipairs(gasModels) do
			local gasPos = gasModel:GetPivot().Position

			for _, player in ipairs(Players:GetPlayers()) do
				if debounce[player.UserId] then continue end
				-- HasTrapSwitch を持っていればガスは停止（安全）
				if player:GetAttribute(TRAP_SWITCH_ATTR) then continue end

				local character = player.Character
				if not character then continue end
				local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
				if not rootPart then continue end
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if not humanoid or humanoid.Health <= 0 then continue end

				local distance = (rootPart.Position - gasPos).Magnitude
				if distance <= DETECTION_RADIUS then
					debounce[player.UserId] = true
					print("[GasTrap] プレイヤー検知:", player.Name, "/ 距離:", math.floor(distance * 10) / 10, "studs")
					task.spawn(function()
						triggerGasDeath(player, character, humanoid, rootPart)
					end)
				end
			end
		end
	end)
end

return GasTrap
