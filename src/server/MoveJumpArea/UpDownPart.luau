-- UpDownPart
-- 高ジャンプエリア: 上下移動プラットフォーム（TweenService使用）
-- パーツ: UpDownPart、サイズ(12,1,12)

local TweenService = game:GetService("TweenService")

local UpDownPart = {}

local TWEEN_TIME = 3
local MOVE_DISTANCE = 20

local tweenInfo = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)

function UpDownPart.init(part: BasePart)
	assert(part.Anchored, "[UpDownPart] Anchored = true が必要です")

	local targetCFrame = part.CFrame + Vector3.new(0, MOVE_DISTANCE, 0)
	local tween = TweenService:Create(part, tweenInfo, { CFrame = targetCFrame })
	tween:Play()
end

return UpDownPart
