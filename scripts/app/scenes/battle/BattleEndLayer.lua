local BattleEndLayer = class("BattleEndLayer", function(params)
	return display.newLayer()
end)

function BattleEndLayer:ctor(params)

	params = params or {}
	self.musicOn = true
	self:initUI()
	self.sceneId = params.sceneId
	print(params.sceneId)
end

function BattleEndLayer:initUI()
	self:setTouchEnabled(true)
	display.newScale9Sprite(BattleUIRes .. "battle_puseBg.png",0, 0, CCSize(1280, 720))
				:pos(display.cx, display.cy)
				:addTo(self)

	cc.ui.UIPushButton.new(BattleUIRes .. "battle_Continue.png")
			:addTo(self):pos(display.cx,display.cy,12)
			:onButtonClicked(function()
				CCDirector:sharedDirector():resume()
				switchScene("carbon",{index = tonumber(string.sub(self.sceneId,1,3))})
			end)
	ui.newTTFLabel({ text = "继续", size = 30, color = display.COLOR_WHITE})
		:pos(display.cx, display.cy-100):addTo(self)

end

return BattleEndLayer