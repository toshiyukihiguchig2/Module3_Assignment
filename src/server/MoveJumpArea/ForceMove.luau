-- ForceMove
-- 強制移動エリア: LinearVelocityで一定方向に強制移動
-- パーツ: MoveBlock1〜4、サイズ(10,1,20)

local Players = game:GetService("Players")

local ForceMove = {}

local FORCE_SPEED = 10

function ForceMove.init(blocks: { BasePart })
	for _, block in ipairs(blocks) do
		local debounce = {}

		block.Touched:Connect(function(hit)
			local character = hit.Parent
			local player = Players:GetPlayerFromCharacter(character)
			if not player then return end
			if debounce[player.UserId] then return end

			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if not rootPart then return end

			debounce[player.UserId] = true

			local lv = Instance.new("LinearVelocity")
			lv.MaxForce = math.huge
			lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
			lv.VectorVelocity = block.CFrame.LookVector * FORCE_SPEED
			lv.Attachment0 = rootPart:FindFirstChildWhichIsA("Attachment")
			lv.Parent = rootPart

			task.wait(0.5)
			lv:Destroy()
			task.wait(0.5)
			debounce[player.UserId] = nil
		end)
	end
end

return ForceMove
