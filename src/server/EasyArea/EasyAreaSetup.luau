-- EasyAreaSetup
-- 初級エリア（海の上）の初期化
-- 足場サイズ(12,1,12)、間隔X軸2studs/Y軸3studs
-- パーツ: EasyFloorBlock1〜4 + EasyCheckPoint

local EasyAreaSetup = {}

function EasyAreaSetup.init()
	-- 初級エリアはスタティックな足場のみ
	-- ギミックなし、チェックポイント設定はCheckpointHandlerに委譲
end

return EasyAreaSetup
