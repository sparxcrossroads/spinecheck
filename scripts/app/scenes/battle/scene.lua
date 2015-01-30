require "logic.battle.BattleConstants"

local PVEBattleView = import(".PVEBattleView")
local PVPBattleView = import(".PVPBattleView")

local spinecheck = import(".spinecheck")
local check = 1

local BattleScene = class("BattleScene", function(params)
	return display.newScene("BattleScene")
end)

function BattleScene:ctor(params)
	print("BattleScene @@@@@@@@@@!!!!!!!!!!!!!")
	self.params = params
	self.pbData = params.pbData
	self.logicRunning = false
end



local function initDataFromPb(battleLogic, pbData)
	local function getParams(params)
		local ret = {}
		ret.str = params.str
		ret.agi = params.agi
		ret.intl = params.intl
		ret.hprec = params.hprec
		ret.mprec = params.mprec
		ret.maxhp = params.hp
		ret.curhp = params.curHp
		ret.curenergy = params.curMana
		ret.dc = params.dc
		ret.mc = params.mc
		ret.def = params.def
		ret.mdef = params.mdef
		ret.crit = params.crit
		ret.mcrit = params.mcrit
		ret.idef = params.idef
		ret.imdef = params.imdef
		ret.hit = params.hit
		ret.eva = params.eva
		ret.suck = params.suck
		ret.treatAddition = params.treatAddition
		ret.level = params.level
		ret.csvData = unitCsv:getUnitByTypeId(params.type)
		--print("ret.csvData="..tostring(ret.csvData))
		ret.skillLevel = {}
		ret.id = params.id
		for i = 1, #params.skills do
			ret.skillLevel[params.skills[i].id] = params.skills[i].level
		end
		--普攻技能
		ret.skillLevel[ret.csvData.normalSkillId] = 1
		return ret
	end

	--左军数据
	for i = 1, #pbData.heros do
		local params = getParams(pbData.heros[i])
		params.moveSpeed = 1 / 6
		params.attackSpeed = 1 / 60
		params.index = i
		params.camp = "left"
		battleLogic:addSoldier(params)
	end

	--右军数据
	for i = 1, #pbData.enemies do
		local params = getParams(pbData.enemies[i])
		params.moveSpeed = 1 / 6
		params.attackSpeed = 1 / 60
		params.index = i
		params.camp = "right"
		battleLogic:addSoldier(params)
	end
end


--region 临时填充数据用作调试
local function initfakeData(battleLogic)
	local function getFakeParams()
		local params = {}
		params.str = 1214
		params.agi = 621
		params.intl = 1233
		params.hprec = 2355
		params.mprec = 277
		params.maxhp = 24555
		params.curhp = 24555
		params.curenergy = 0
		params.dc = 2761
		params.mc = 1490
		params.def = 3820
		params.mdef = 144
		params.crit = 786
		params.mcrit = 1200
		params.idef = 29
		params.imdef = 0
		params.hit = 8
		params.eva = 30
		params.suck = 118
		params.treatAddition = 0
		params.level = 90
		params.moveSpeed = 1 / 6
		params.attackSpeed = 1 / 60
		return params
	end

	local function getFakeSkillLevel(heroid)
		local skillLevel = {} 
		for i=1, 5 do
			skillLevel[heroid* 100 +i] = 1
		end
		return skillLevel
	end

	if false then	--将所有英雄放置到战场测试
		--测试所有英雄
		local allHeros = {1001, 1002, 1003, 1004, 1005, 1008, 1009, 1010, 1011, 1012, 1013, 1015, 1017, 1019, 1021, 1023, 1024, 1025, 1027, 1028, 1029}
		--测试所有小怪
		--local allHeros = {2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016}
		for _, camp in pairs({"left", "right"}) do
			for i=1, #allHeros do
				local params = getFakeParams()
				params.index = i
				params.camp = camp
				params.csvData = unitCsv:getUnitByTypeId(allHeros[i])
				params.maxhp = params.maxhp * 100--100倍生命
				params.curhp = params.curhp * 100
				params.skillLevel = getFakeSkillLevel(params.csvData.typeId)
				battleLogic:addSoldier(params)
			end
		end
	else
		local leftTypeId = {
			[1] = 1002,	
			[2] = 1003, 
			[3] = 1010,
			[4] = 1008, 
			[5] = 1009,
		}

		local rightTypeId = {
			[1] = 1004,	
			[2] = 1007, 
			[3] = 1010,
			[4] = 1011, 
			[5] = 1006,
		}

		for i = 1, 5 do
			local params = getFakeParams()
			params.index = i
			params.camp = "left"
			params.csvData = unitCsv:getUnitByTypeId(leftTypeId[i])
			params.skillLevel = getFakeSkillLevel(params.csvData.typeId)
			battleLogic:addSoldier(params)
		end

		for i = 1,5 do
			local params = getFakeParams()
			params.index = i
			params.camp = "right"
			params.csvData = unitCsv:getUnitByTypeId(rightTypeId[i])
			params.skillLevel = getFakeSkillLevel(params.csvData.typeId)
			battleLogic:addSoldier(params)
		end
	end

end
--endregion




function BattleScene:onEnter()
	if check then
		self.battleView =spinecheck.new()
		self.battleView:pos(0, 0):addTo(self)
		print("--feng-- onEnter()")
		return
	end

	--单机测试
	if BATTLE_LOCATION then
		local pbData = {}
		self.battleView = PVEBattleView.new({battleType = "PVE",pbData = {sceneId = 101010,fightNo = 1},sceneBg = {["1"] = "8001"}})
		self.battleLogic = require("logic.battle.BattleLogic").new({battleView = self.battleView, randSeed = 1234})
		initfakeData(self.battleLogic)
	else
		if self.params.battleType == "PVE" then
			self.battleView = PVEBattleView.new(self.params)
		elseif self.params.battleType == "PVP" then
			self.battleView = PVPBattleView.new(self.params)
		end
		self.battleLogic = require("logic.battle.BattleLogic").new({battleView = self.battleView, randSeed = self.pbData.seed})
		initDataFromPb(self.battleLogic, self.pbData)
	end

	self.battleView:pos(0, 0):addTo(self)

	--将放大招的接口暴露给BattleView
	self.battleView.super.releaseTalentSkill = function (camp, index)	
		self.battleLogic:releaseTalentSkill(camp, index)
	end
	
	-- 视图层放大招暂停通知
	self.battleView.super.skillPause = function (camp, index)
		self.logicRunning = false
	end
	self.battleView.super.skillResume = function (camp, index)
		self.logicRunning = true
	end

	-- 自动战斗开关
	self.battleView.super.setAutoTalentSkill = function(auto)
		game.autoBattle = auto
		self.battleLogic:setAutoTalentSkill(auto)
		if self.params.battleType == "PVE" then
			self.battleView:nextBattle()
		end
	end

	self.battleView.super.setAutoTalentSkill(game.autoBattle)

	if BATTLE_LOCATION or self.params.battleType == "PVP" then
		self.logicRunning = true
	else
		-- TODO 加剧情
		local isStory = true
		for v,k in pairs(game.master.sceneProgress) do
			if self.pbData.sceneId  ==  v then
				isStory = false
			end
		end
		if self.pbData.fightNo == 1  and talkCsv:getById(self.pbData.sceneId) and 
						isStory == true then
				self.battleView.topBar:pauseTime()
				require("app.scenes.story.StoryLayer").new(self.pbData.sceneId,function (  )
					self.battleView.topBar:resumeTime()
					self.logicRunning = true
				end):addTo(self, 10)
		else
			self.logicRunning = true
		end
	end 

	-- 注册帧事件
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
		if self.logicRunning then
			self.battleLogic:update()
			-- 取消以下代码注释可加速
			-- self.battleLogic:update()			
			-- self.battleLogic:update()
			-- self.battleLogic:update()
			-- self.battleLogic:update()
			-- self.battleLogic:update()
		end
	end)
	self:scheduleUpdate()


	--音乐
	local musicRandom = math.random(0,1)
	uiData.battleMusic = SOUND_PATH.battle1
	if musicRandom > 0.5 then
		uiData.battleMusic = SOUND_PATH.battle2
	end
	playUiMusic(uiData.battleMusic, true)

end

function BattleScene:onExit()
	print("BattleScene:onExit")
	self:unscheduleUpdate()
end

return BattleScene