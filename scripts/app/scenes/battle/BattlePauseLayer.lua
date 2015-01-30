local BattlePauseLayer = class("BattlePauseLayer", function(params)
	return display.newLayer()
end)

function BattlePauseLayer:ctor(params)

	params = params or {}
	self.musicOn = game.musicOn
	self:initUI()
	self.sceneId = params.sceneId
	print(params.sceneId)
end

function BattlePauseLayer:initUI()
	self:setTouchEnabled(true)
	display.newScale9Sprite(BattleUIRes .. "battle_puseBg.png",0, 0, CCSize(1280, 720))
				:pos(display.cx, display.cy)
				:addTo(self)

	local exitBtn = cc.ui.UIPushButton.new(BattleUIRes .. "battle_exit.png")
			:addTo(self):pos(display.cx - 300,display.cy,12)
			:onButtonClicked(function()
				CCDirector:sharedDirector():resume()
				switchScene("carbon",{index = self.sceneId})
			end)
	ui.newTTFLabel({ text = "退出战斗", size = 30, color = display.COLOR_WHITE})
		:pos(display.cx - 300, display.cy - 100):addTo(self)

	local btnBg = self.musicOn and "battle_sound_on.png" or "battle_sound_off.png"
	self.soundBtn = cc.ui.UIPushButton.new(BattleUIRes .. btnBg)
			:addTo(self):pos(display.cx,display.cy,12)
			:onButtonClicked(function()
				self:switchMusic()
				local btnBg = self.musicOn and "battle_sound_on.png" or "battle_sound_off.png"
				self.soundBtn:setButtonImage("normal", BattleUIRes .. btnBg, true)
					
			end)
	local textStr = self.musicOn and "声音:开" or "声音:关"

	self.soundLabel = ui.newTTFLabel({ text = textStr, size = 30, color = display.COLOR_WHITE})
		:pos(display.cx, display.cy - 100):addTo(self)

	local continueBtn = cc.ui.UIPushButton.new(BattleUIRes .. "battle_Continue.png")
			:addTo(self):pos(display.cx + 300,display.cy,12)
			:onButtonClicked(function()
				CCDirector:sharedDirector():resume()
				self:removeSelf()					
			end)
	ui.newTTFLabel({ text = "继续战斗", size = 30, color = display.COLOR_WHITE})
		:pos(display.cx + 300, display.cy - 100):addTo(self)
end

function BattlePauseLayer:switchMusic()

	game.musicOn = not game.musicOn
	GameData.controlInfo.musicOn = game.musicOn
	GameState.save(GameData)
	self.musicOn = game.musicOn
	self.soundLabel:setString(self.musicOn and "声音:关" or "声音:开")

	if game.musicOn == false then
		if audio.isMusicPlaying() then
			audio.pauseMusic()
		end
		audio.stopAllSounds()
	else
		if not audio.isMusicPlaying() then
			playUiMusic(uiData.battleMusic, true)
		else
			audio.resumeMusic()
		end
	end
end

return BattlePauseLayer