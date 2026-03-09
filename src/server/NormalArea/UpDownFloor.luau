-- UpDownFloor
-- 中級エリア: 動く足場（上下）TweenService使用
-- パーツ: UpDownFloorBlock1〜4、サイズ(6,1,6)、Y軸移動幅12studs
--
-- 初動の方向ごとに2つの配列で受け取る
--   downFirst: Block1, Block3（初動：下）
--   upFirst  : Block2, Block4（初動：上）

local TweenService = game:GetService("TweenService")

local UpDownFloor = {}

local TWEEN_TIME    = 2.0  -- 片道の移動時間（秒）
local MOVE_DISTANCE = 12   -- 移動距離（studs）

-- Reverses=true で折り返し、RepeatCount=-1 で無限ループ
local tweenInfo = TweenInfo.new(
	TWEEN_TIME,
	Enum.EasingStyle.Linear,  -- 等速（乗りやすい）
	Enum.EasingDirection.InOut,
	-1,    -- 無限ループ
	true   -- 折り返し
)

local function startBlock(block: BasePart, direction: number)
	-- direction:  1 = 初動が上方向
	--            -1 = 初動が下方向
	assert(block.Anchored, "[UpDownFloor] Anchored = true が必要です: " .. block.Name)

	local targetCFrame = block.CFrame + Vector3.new(0, MOVE_DISTANCE * direction, 0)
	local tween = TweenService:Create(block, tweenInfo, { CFrame = targetCFrame })
	tween:Play()
	print("[UpDownFloor]", block.Name, "開始（初動:", direction == -1 and "下" or "上", "）")
end

-- downFirstBlocks : Block1, Block3（初動：下）
-- upFirstBlocks   : Block2, Block4（初動：上）
function UpDownFloor.init(downFirstBlocks: { BasePart }, upFirstBlocks: { BasePart })
	for _, block in ipairs(downFirstBlocks) do
		startBlock(block, -1)
	end
	for _, block in ipairs(upFirstBlocks) do
		startBlock(block, 1)
	end
end

return UpDownFloor
