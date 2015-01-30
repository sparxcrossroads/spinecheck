-- BattleBottomBar上的soldier
local SoldierUnit = class("SoldierUnit", function()
	return display.newSprite(BattleUIRes.."battle_cardbottom.png")
end)

function SoldierUnit:ctor(params)
	self.soldierView = params
	local soldier = params.csvData

	local curInfo = nil
	if BATTLE_LOCATION then
		curInfo = { grade = 10, starLevel =5}
	else
		for k,v in pairs(game.master.heros) do
			if v.type == params.csvData.typeId then
				curInfo = v
				break
			end
		end
	end

	if curInfo == nil then
		print("hero type not found!!!")
		return
	end

	self.proxy = cc.EventProxy.new(self.soldierView, self)
	self.proxy:addEventListener(self.soldierView.HP_EVENT,   	handler(self, self.refreshHP		))
    self.proxy:addEventListener(self.soldierView.ENERGE_EVENT, 	handler(self, self.refreshAnerge	))
    self.proxy:addEventListener(self.soldierView.DEATH_EVENT, 	handler(self, self.death 			))
    self.proxy:addEventListener(self.soldierView.SKILL_EVENT, 	handler(self, self.setSkillEnable	))

	local bW,bH = self:getContentSize().width,self:getContentSize().height
	-- 底框
	local cardbottom = display.newSprite(BattleUIRes.."battle_cardbottom01.png")
	local cW,cH = cardbottom:getContentSize().width,cardbottom:getContentSize().height
	cardbottom:addTo(self):pos(bW/2+1,bH-cH/2-1)
	-- 头像
	self.unit = display.newSprite(RES.."icon_hero/hero_"..tostring(soldier.typeId)..".png")
	self.unit:addTo(cardbottom):pos(cW/2+1,cH/2+6,10)
	-- 品阶
	local resName = string.format(BattleUIRes.."battle_grade%02d.png",curInfo.grade)
	local grade = display.newSprite(resName)
	grade:addTo(cardbottom):pos(cW/2,cH/2+7,11)
	-- star
	local starWidth = 22
	local xBegin = cW/2 - (curInfo.starLevel - 1) * starWidth / 2
	for index = 1, curInfo.starLevel do
		display.newSprite(BattleUIRes .. "battle_star.png")
			:align(display.CENTER_BOTTOM,xBegin + starWidth * (index - 1), 0)
			:addTo(cardbottom)
	end
	-- hp
	self.hpProgress = display.newProgressTimer(BattleUIRes .. "battle_HP.png", display.PROGRESS_TIMER_BAR)
	self.hpProgress:setMidpoint(ccp(0, 0))
	self.hpProgress:setBarChangeRate(ccp(1,0))
	self.hpProgress:setPercentage(params.curhp*100/params.maxhp)
	local hpSlot = display.newSprite(BattleUIRes .. "battle_energybottom.png")
	self.hpProgress:pos(hpSlot:getContentSize().width / 2, hpSlot:getContentSize().height / 2):addTo(hpSlot)
	hpSlot:pos(bW/2,35):addTo(self)
	-- angry
	self.energyProgress = display.newProgressTimer(BattleUIRes .. "battle_energy.png", display.PROGRESS_TIMER_BAR)
	self.energyProgress:setMidpoint(ccp(0, 0))
	self.energyProgress:setBarChangeRate(ccp(1,0))
	self.energyProgress:setPercentage(params.curenergy*100/1000)
	local energySlot = display.newSprite(BattleUIRes .. "battle_energybottom.png")
	self.energyProgress:pos(energySlot:getContentSize().width / 2 , energySlot:getContentSize().height / 2):addTo(energySlot)
	energySlot:pos(bW/2,15):addTo(self)
	
end

function SoldierUnit:refreshHP(event)
	self.hpProgress:setPercentage(event.params.newhp*100/ event.params.maxhp)
	-- 危险时处理  红框

end

function SoldierUnit:refreshAnerge(event)
	self.energyProgress:setPercentage(event.params.curValue*100/1000)
end

-- 切换场景时，有大招可放，但要等到走到可攻击位置后才能释放
function SoldierUnit:setSkillEnable(event)
	local enable = event.params
	if enable then
		local actions = {CCScaleTo:create(0.5,1.0),CCScaleTo:create(0.5,0.95)}
		self.skillAlert = cc.ui.UIPushButton.new(BattleUIRes .. "battle_Bigrecruit.png")
			:addTo(self):pos(67,130,12)
			:onButtonClicked(function()
					self.soldierView:releaseTalentSkill()
				end)
		self.skillAlert:runAction(CCRepeatForever:create(transition.sequence(actions)))
	else
		if self.skillAlert then
			self.skillAlert:removeSelf()
			self.skillAlert = nil
		end
		-- 怒气条变为红色
	end
end

function SoldierUnit:death(event)
	-- 头像变灰
	self.unit:setColor(ccc3(100, 100, 100))
	self.energyProgress:setPercentage(0)

	-- 去除放大提示
	if self.skillAlert then
		self.skillAlert:removeSelf()
		self.skillAlert = nil
	end
end

return SoldierUnit