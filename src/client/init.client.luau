-- Main Client Script

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local localPlayer = Players.LocalPlayer
local ANIM_ID         = "rbxassetid://77831000639022"
local SLIDE_TAG       = "SlideFloor"

-- ----------------------------------------------------------------
-- BGM: ゲーム開始時から再生（ループ）
-- ----------------------------------------------------------------
local MAIN_BGM_ID = "rbxassetid://134815678473969"
local GOAL_BGM_ID = "rbxassetid://139459913407146"

local bgm = Instance.new("Sound")
bgm.SoundId  = MAIN_BGM_ID
bgm.Looped   = true
bgm.Volume   = 0.5
bgm.Parent   = game:GetService("SoundService")
bgm:Play()
print("[Client] BGM再生開始:", bgm.SoundId)

-- ----------------------------------------------------------------
-- SeaDeath: 溺死アニメーション
-- ----------------------------------------------------------------
local seaDeathEvent = ReplicatedStorage:WaitForChild("SeaDeathAnim")
print("[Client] SeaDeathAnim RemoteEvent 待機完了")

seaDeathEvent.OnClientEvent:Connect(function()
	print("[Client] 溺死アニメーション再生開始")

	local character = localPlayer.Character
	if not character then warn("[Client] キャラクターが存在しません") return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then warn("[Client] Humanoidが見つかりません") return end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then warn("[Client] Animatorが見つかりません") return end

	local animInstance = Instance.new("Animation")
	animInstance.AnimationId = ANIM_ID

	local track = animator:LoadAnimation(animInstance)
	track.Priority = Enum.AnimationPriority.Action4
	track:Play()
	print("[Client] アニメーション再生:", ANIM_ID, "Priority: Action4")
end)

-- ----------------------------------------------------------------
-- SlideFloor: プレイヤー追従（クライアント側で完結）
-- CollectionServiceタグ "SlideFloor" でブロックを識別し、
-- クライアントでTouchedを検知するためネットワーク遅延ゼロ
-- ----------------------------------------------------------------
local currentBlock: BasePart?  = nil
local prevBlockCFrame: CFrame? = nil

local function setupSlideTracking(character: Model)
	-- CollectionServiceでタグ付きブロックを取得
	-- サーバーがタグを付与するまで少し待機
	task.wait(1)
	local slideBlocks = CollectionService:GetTagged(SLIDE_TAG)
	print("[Client] SlideFloor ブロック数:", #slideBlocks)

	for _, block in ipairs(slideBlocks) do
		-- キャラクターのいずれかのパーツがブロックに触れたら追従開始
		block.Touched:Connect(function(hit)
			if not hit:IsDescendantOf(character) then return end
			if currentBlock == block then return end
			currentBlock = block
			prevBlockCFrame = block.CFrame
			print("[Client] SlideFloor追従開始:", block.Name)
		end)

		block.TouchEnded:Connect(function(hit)
			if not hit:IsDescendantOf(character) then return end
			task.delay(0.1, function()
				-- 追従解除（他ブロックに乗り換えていなければ）
				if currentBlock == block then
					currentBlock = nil
					prevBlockCFrame = nil
					print("[Client] SlideFloor追従解除:", block.Name)
				end
			end)
		end)
	end
end

-- キャラクタースポーン時にトラッキング設定
localPlayer.CharacterAdded:Connect(function(character)
	currentBlock = nil
	prevBlockCFrame = nil
	setupSlideTracking(character)
end)

-- 既にキャラクターが存在する場合にも対応
if localPlayer.Character then
	setupSlideTracking(localPlayer.Character)
end


-- ----------------------------------------------------------------
-- GoalDanceAnim: ゴール到達時のダンスアニメーション
-- Robloxデフォルトダンス（R15 Dance）を使用
-- ----------------------------------------------------------------
local GOAL_DANCE_ID = "rbxassetid://507771019" -- Roblox標準ダンス（R15 Dance）

local goalDanceEvent = ReplicatedStorage:WaitForChild("GoalDanceAnim")
print("[Client] GoalDanceAnim RemoteEvent 待機完了")

goalDanceEvent.OnClientEvent:Connect(function()
	print("[Client] ゴールダンス開始")

	local character = localPlayer.Character
	if not character then warn("[Client] キャラクターが存在しません") return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then warn("[Client] Humanoidが見つかりません") return end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then warn("[Client] Animatorが見つかりません") return end

	-- BGMをゴール用に切り替え
	bgm:Stop()
	bgm.SoundId = GOAL_BGM_ID
	bgm:Play()
	print("[Client] ゴールBGM再生:", GOAL_BGM_ID)

	local animInstance = Instance.new("Animation")
	animInstance.AnimationId = GOAL_DANCE_ID

	local track = animator:LoadAnimation(animInstance)
	track.Priority = Enum.AnimationPriority.Action4
	track.Looped   = true
	track:Play()
	print("[Client] ゴールダンス再生:", GOAL_DANCE_ID)

	task.wait(9.0)

	track:Stop()

	-- BGMをメインに戻す
	bgm:Stop()
	bgm.SoundId = MAIN_BGM_ID
	bgm:Play()
	print("[Client] メインBGMに戻す:", MAIN_BGM_ID)
end)

-- Heartbeat: ブロックのCFrame差分をキャラクターに加算（遅延ゼロ）
RunService.Heartbeat:Connect(function()
	if not currentBlock or not prevBlockCFrame then return end

	local character = localPlayer.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
	if not rootPart then return end

	local currentCFrame = currentBlock.CFrame
	local delta = currentCFrame.Position - prevBlockCFrame.Position
	prevBlockCFrame = currentCFrame

	if delta.Magnitude < 0.0001 then return end

	rootPart.CFrame = rootPart.CFrame + delta
end)
