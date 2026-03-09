-- Door
-- 死亡パーツエリア: 扉
-- 鍵を持っている場合のみクリックで開く（1回のみ）

local Players = game:GetService("Players")

local Door = {}

local KEY_ATTRIBUTE = "HasKey" -- プレイヤーに付与するAttribute名

function Door.init(door: Model)
	local clickDetector = door:FindFirstChildWhichIsA("ClickDetector", true)
	if not clickDetector then
		warn("[Door] ClickDetectorが見つかりません: " .. door.Name)
		return
	end

	local opened = false

	clickDetector.MouseClick:Connect(function(player)
		if opened then return end
		if not player:GetAttribute(KEY_ATTRIBUTE) then return end

		opened = true
		-- TODO: 扉を開くアニメーション再生
	end)
end

return Door
