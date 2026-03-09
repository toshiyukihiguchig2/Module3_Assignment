-- Main Server Script

local ServerScriptService = game:GetService("ServerScriptService")
local Server = ServerScriptService:WaitForChild("Server")

-- SeaDeathHandler: Terrain水、引数不要のため即時有効化
require(Server.Common.SeaDeathHandler).init()

-- CheckpointHandler: 各ステージのチェックポイントパーツを配列で渡す
require(Server.Common.CheckpointHandler).init({
	workspace.EasyStage.EasyCheckPoint,
	workspace.NormalStage.NormalCheckPoint,
	workspace.KillPartStage.KillPartStageCheckPoint,
})

-- FallDeathHandler: 全地形対応（groundPart不要）
require(Server.Common.FallDeathHandler).init()
-- require(Server.EasyArea.EasyAreaSetup).init()
-- UpDownFloor: 初動下（Block1,3） / 初動上（Block2,4）
require(Server.NormalArea.UpDownFloor).init(
	{ workspace.NormalStage.UpDownFloorBlock1, workspace.NormalStage.UpDownFloorBlock3 },
	{ workspace.NormalStage.UpDownFloorBlock2, workspace.NormalStage.UpDownFloorBlock4 }
)
-- SlideFloor: サーキット順（1→2→3→4→5→6→7→8→1→...）で渡す
require(Server.NormalArea.SlideFloor).init({
	workspace.NormalStage.SlideFloorBlock1,
	workspace.NormalStage.SlideFloorBlock2,
	workspace.NormalStage.SlideFloorBlock3,
	workspace.NormalStage.SlideFloorBlock4,
	workspace.NormalStage.SlideFloorBlock5,
	workspace.NormalStage.SlideFloorBlock6,
	workspace.NormalStage.SlideFloorBlock7,
	workspace.NormalStage.SlideFloorBlock8,
})
-- GasTrap: KillPartStage.Gas (Model)
require(Server.KillPartArea.GasTrap).init({ workspace.KillPartStage.Gas })
-- Mine: KillPartStage.Grenade1〜3 (MeshPart)
require(Server.KillPartArea.Mine).init({
	workspace.KillPartStage.Grenade1,
	workspace.KillPartStage.Grenade2,
	workspace.KillPartStage.Grenade3,
})
-- TreasureChest: lever に ProximityPrompt を追加し罠スイッチ取得を管理
require(Server.KillPartArea.TreasureChest).init(
	workspace.KillPartStage.lever,
	workspace.KillPartStage.Gas.Chimeny.ChimneySmoke.ChimneySmoke
)
-- Door: 仕様から削除済み
-- ForceMove: MoveJumpArea.MoveBlock1〜4（一時停止中）
-- require(Server.MoveJumpArea.ForceMove).init({
-- 	workspace.MoveJumpArea.MoveBlock1,
-- 	workspace.MoveJumpArea.MoveBlock2,
-- 	workspace.MoveJumpArea.MoveBlock3,
-- 	workspace.MoveJumpArea.MoveBlock4,
-- })
-- HighJump: MoveJumpArea.VentBase1〜4
require(Server.MoveJumpArea.HighJump).init({
	workspace.MoveJumpArea.VentBase1,
	workspace.MoveJumpArea.VentBase2,
	workspace.MoveJumpArea.VentBase3,
	workspace.MoveJumpArea.VentBase4,
})
-- UpDownPart: MoveJumpArea.UpDownPart
require(Server.MoveJumpArea.UpDownPart).init(workspace.MoveJumpArea.UpDownPart)

-- GoalHandler: ゴール到達時にダンス → LobbyのSpawnLocationへ送還
require(Server.Common.GoalHandler).init(
	workspace.Goal.GoalPart,
	workspace.SpawnLocation
)

print("[Server] 初期化完了")
