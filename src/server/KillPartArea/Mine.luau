-- Mine
-- 死亡パーツエリア: 地雷（MeshPart）
-- 20studs以内でAnchored OFF → 落下
-- 爆発処理（吹き飛び・地形破壊・死亡・削除）は地雷の in-model Script が担当

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local TRIGGER_RADIUS = 20  -- この距離でAnchored OFF（studs）

local Mine = {}

-- grenades: 地雷MeshPartの配列（workspace.KillPartStage.Grenade1 など）
function Mine.init(grenades: { BasePart })
	for _, grenade in ipairs(grenades) do
		-- Proximity detection: 20studs以内でAnchored OFF
		local proximityConnection: RBXScriptConnection
		proximityConnection = RunService.Heartbeat:Connect(function()
			-- 地雷が削除済みまたは既に落下中なら監視終了
			if not grenade or not grenade.Parent then
				proximityConnection:Disconnect()
				return
			end
			if not grenade.Anchored then
				proximityConnection:Disconnect()
				return
			end

			for _, player in ipairs(Players:GetPlayers()) do
				local character = player.Character
				if not character then continue end
				local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
				if not rootPart then continue end

				local distance = (rootPart.Position - grenade.Position).Magnitude
				if distance <= TRIGGER_RADIUS then
					print("[Mine] プレイヤー検知:", player.Name, "/ 距離:", math.floor(distance * 10) / 10, "studs → Anchored OFF")
					grenade.Anchored = false
					proximityConnection:Disconnect()
					break
				end
			end
		end)

		print("[Mine] 地雷セットアップ完了:", grenade.Name, "/ トリガー半径:", TRIGGER_RADIUS, "studs")
	end
end

return Mine
