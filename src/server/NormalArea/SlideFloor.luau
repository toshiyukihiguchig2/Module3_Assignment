-- SlideFloor
-- 中級エリア: 動く足場（スライド）カルーセル運動
-- パーツ: SlideFloorBlock1〜8（サーキット順に配列で渡す）
--
-- プレイヤー追従はクライアント側で完結（init.client.luau）
-- CollectionServiceタグ "SlideFloor" でブロックを識別する
-- RemoteEvent不要のためネットワーク遅延ゼロ

local TweenService        = game:GetService("TweenService")
local CollectionService   = game:GetService("CollectionService")

local SlideFloor = {}

local SPEED      = 8             -- 移動速度（studs/秒）
local TAG_NAME   = "SlideFloor"  -- CollectionServiceタグ名

local function startCarousel(blocks: { BasePart }, waypoints: { CFrame })
	local n = #blocks

	local function moveToNext(block: BasePart, currentIndex: number)
		local nextIndex = (currentIndex % n) + 1
		local targetCFrame = waypoints[nextIndex]
		local distance = (targetCFrame.Position - block.Position).Magnitude
		local tweenTime = math.max(distance / SPEED, 0.01)

		local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
		local tween = TweenService:Create(block, tweenInfo, { CFrame = targetCFrame })

		tween.Completed:Connect(function(state)
			if state == Enum.PlaybackState.Completed then
				moveToNext(block, nextIndex)
			end
		end)

		tween:Play()
	end

	for i, block in ipairs(blocks) do
		moveToNext(block, i)
		print("[SlideFloor]", block.Name, "カルーセル開始")
	end
end

function SlideFloor.init(blocks: { BasePart })
	local waypoints: { CFrame } = {}
	for _, block in ipairs(blocks) do
		assert(block.Anchored, "[SlideFloor] Anchored = true が必要です: " .. block.Name)
		-- クライアントが識別できるようにタグを付与
		CollectionService:AddTag(block, TAG_NAME)
		table.insert(waypoints, block.CFrame)
	end

	print("[SlideFloor] ブロック数:", #blocks, "/ 速度:", SPEED, "studs/秒 / タグ:", TAG_NAME)

	startCarousel(blocks, waypoints)
end

return SlideFloor
