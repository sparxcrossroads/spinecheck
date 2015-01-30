ZOrder = {}
ZOrder.background = -20
ZOrder.effect1 = 1	-- 技能特效下层 1-10
ZOrder.soldierBegin = 10 --soldier 10-2700 子弹跟soldier一致
ZOrder.effect0 = 27000	-- 技能特效上层 2700+
ZOrder.skillMask = 32000
ZOrder.battleUI = 33000
ZOrder.plot = 35000 --剧情
ZOrder.pause = 40000 --暂停
--local BattleConstants = require("logic.battle.BattleConstants")
-- 从左到右，从上到下 二维递增
local anchScale = 0.1--z轴对anchPoint的敏感度
function ZOrder:anchZorder(anchPoint)
	local XCount = ( BattleConstants.ColMax * 2 ) / anchScale + 1
	local YCount = ( BattleConstants.RowMax * 2 ) / anchScale + 1
	local anchX = math.floor(anchPoint.x / anchScale)
	local anchY = math.floor(anchPoint.y / anchScale)
	local gridValue = XCount * ( YCount - 1 ) / 2 + ( XCount - 1 ) / 2 - ( anchX + XCount * anchY )
	return self.soldierBegin + gridValue
end

return ZOrder
