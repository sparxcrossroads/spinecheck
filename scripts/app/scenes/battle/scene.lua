require "logic.battle.BattleConstants"



local spinecheck = import(".spinecheck")
local check = 1

local scene = class("scene", function(params)
	return display.newScene("scene")
end)

function scene:ctor(params)
	
end


function scene:onEnter()
	if check then
		self.battleView =spinecheck.new()
		self.battleView:pos(0, 0):addTo(self)
		print("--feng-- onEnter()")
		return
	end

	-- -- 注册帧事件
	-- self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
	-- 	if self.logicRunning then
	-- 		self.battleLogic:update()
	-- 		-- 取消以下代码注释可加速
	-- 		-- self.battleLogic:update()			
	-- 		-- self.battleLogic:update()
	-- 		-- self.battleLogic:update()
	-- 		-- self.battleLogic:update()
	-- 		-- self.battleLogic:update()
	-- 	end
	-- end)
	-- self:scheduleUpdate()


	--音乐
	local musicRandom = math.random(0,1)
	uiData.battleMusic = SOUND_PATH.battle1
	if musicRandom > 0.5 then
		uiData.battleMusic = SOUND_PATH.battle2
	end
	playUiMusic(uiData.battleMusic, true)

end

function scene:onExit()
	print("scene:onExit")
	self:unscheduleUpdate()
end

return scene