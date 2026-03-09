-- TreasureChest
-- 死亡パーツエリア: lever（Model）に ProximityPrompt を追加
-- プレイヤーが「E」1秒長押しで罠スイッチ取得
-- → ChimneySmoke 停止 + HasTrapSwitch 属性付与 + lever 削除

local TreasureChest = {}

function TreasureChest.init(leverModel: Model, chimneySmokePart: BasePart)
	-- lever の BasePart を再帰検索
	local basePart = leverModel.PrimaryPart
		or leverModel:FindFirstChildWhichIsA("BasePart", true)

	if not basePart then
		warn("[TreasureChest] lever の BasePart が見つかりません:", leverModel:GetFullName())
		return
	end
	print("[TreasureChest] ProximityPrompt 設定先:", basePart:GetFullName())

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "取得"
	prompt.ObjectText = "罠スイッチ"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 1.0
	prompt.MaxActivationDistance = 20
	prompt.RequiresLineOfSight = false
	prompt.Enabled = false  -- 宝箱を開けるまで非表示
	prompt.Parent = basePart
	print("[TreasureChest] ProximityPrompt 作成完了（初期非表示）")

	-- 宝箱が開かれたら（Unlocked 属性が true になったら）プロンプトを有効化
	leverModel:GetAttributeChangedSignal("Unlocked"):Connect(function()
		if leverModel:GetAttribute("Unlocked") then
			prompt.Enabled = true
			print("[TreasureChest] 宝箱オープン検知 → ProximityPrompt 有効化")
		end
	end)

	prompt.Triggered:Connect(function(player)
		print("[TreasureChest] 罠スイッチ取得:", player.Name)

		-- ガス罠のスモークを停止
		local smokeObj = chimneySmokePart and chimneySmokePart:FindFirstChildOfClass("Smoke")
		if smokeObj then
			smokeObj.Enabled = false
			print("[TreasureChest] ChimneySmoke 停止完了")
		end

		-- 色を赤→青に変更（安全無効化を視覚的に示す）
		-- chimneySmokePart = Gas.Chimeny.ChimneySmoke.ChimneySmoke
		-- .Parent = ChimneySmoke(Model), .Parent.Parent = Chimeny(Model), .Parent.Parent.Parent = Gas(Model)
		local chimeny = chimneySmokePart and chimneySmokePart.Parent and chimneySmokePart.Parent.Parent
		local gasModel = chimeny and chimeny.Parent

		local union = chimeny and chimeny:FindFirstChild("Union")
		if union and union:IsA("BasePart") then
			union.Color = Color3.fromRGB(0, 0, 151)
			print("[TreasureChest] Chimeny.Union 色変更完了 → (0, 0, 151)")
		end

		local redblob = gasModel and gasModel:FindFirstChild("redblob")
		local body = redblob and redblob:FindFirstChild("Body")
		if body and body:IsA("BasePart") then
			body.Color = Color3.fromRGB(0, 0, 151)
			print("[TreasureChest] redblob.Body 色変更完了 → (0, 0, 151)")
		end

		-- プレイヤーに罠スイッチ属性を付与（GasTrap が無効化される）
		player:SetAttribute("HasTrapSwitch", true)
		print("[TreasureChest] HasTrapSwitch 付与:", player.Name)

		-- lever を削除
		leverModel:Destroy()
		print("[TreasureChest] lever 削除完了")
	end)
end

return TreasureChest
