local SoldierLogic = class("SoldierLogic")

local SkillLogic = import(".SkillLogic")
local BulletLogic = import(".BulletLogic")
local BuffLogic =  import(".BuffLogic")


--技能循环进入下一步
local function stepNextTurn(turnInfo)
	turnInfo.totalIndex = turnInfo.totalIndex + 1
	if turnInfo.totalIndex <= turnInfo.beginLength then
		turnInfo.actionIndex = turnInfo.totalIndex
	else
		turnInfo.actionIndex = (turnInfo.totalIndex - turnInfo.beginLength - 1) %  (#turnInfo.actionInfoByActionIndex - turnInfo.beginLength) + turnInfo.beginLength + 1
	end
end

function SoldierLogic:ctor(params)
	--存在此结构说明自身是一个被召唤出来的对象
	self.summonInfo = params.summonInfo
	--此结构内部有数据时说明召唤了一些对象,(key为技能id，value为对应的召唤物SoldierLogic对象)
	self.mySummons = {}

	self.index = params.index
	self.camp = params.camp
	self.battleLogic = params.battleLogic
	self.csvData = params.csvData

	self.anchPoint = params.anchPoint
	self.skillLevel = params.skillLevel

	--region 初始化技能循环信息
	local function initCurTurnInfoBySkillLevel()
		--region 函数功能:过滤未开启的技能，然后转换为{actionId=XX,skillId=XX,actionName=XX}的结构数组
		local function fliterActionTurn(csvTurnConfig)
			local skillIdByActionId = {
				[0] = self.csvData.normalSkillId,			--普通攻击
				[1] = self.csvData.skillA, 					--技能A
				[2] = self.csvData.skillB,					--技能B
				[3] = self.csvData.skillC, 					--技能C
			}

			local actionNameByActionId = {
				[0] = "attack",
				[1] = "attack2",
				[2] = "attack3",
				[3] = "attack4",
			}

			local ret = {}
			for k, v in pairs(csvTurnConfig) do
				local actionId = tonumber(v)
				local skillId = skillIdByActionId[actionId]
				local actionName = actionNameByActionId[actionId]
				if self.skillLevel[skillId] then
					table.insert(ret, {actionId = actionId, skillId = skillId, actionName = actionName})
				end
			end
			return ret
		end
		--endregion
		local actionInfoByActionIndex = {}
		local firstTurn = fliterActionTurn(self.csvData.firstTurn)
		local cycleTurn = fliterActionTurn(self.csvData.cycleTurn)
		--region 将firstTurn和cycleTurn拼接成一整个table
		for i=1, #firstTurn do
			table.insert(actionInfoByActionIndex, firstTurn[i])
		end
		for i=1, #cycleTurn do
			table.insert(actionInfoByActionIndex, cycleTurn[i])
		end
		--endregion
		--region 错误检测
		if #actionInfoByActionIndex - #firstTurn <= 0 then
			self:debugPrint(2, string.format("技能循环配置错误,首轮长度:%d,循环长度:%d", #firstTurn, #cycleTurn))
			print(debug.traceback())
		end
		--endregion
		return {actionIndex = 1, totalIndex = 1, actionInfoByActionIndex = actionInfoByActionIndex, beginLength = #firstTurn}
	end
	self.turnInfo = initCurTurnInfoBySkillLevel()
	--endregion

	--魅惑会改变curcamp
	self.curcamp = self.camp
    --region 战斗相关数值
	--力量
	self.str = params.str
	self.curstr = self.str
	--敏捷
	self.agi = params.agi
	self.curagi = self.agi
	--智力
	self.intl = params.intl
	self.curintl = self.intl
	--生命回复
	self.hprec = params.hprec
	self.curhprec = self.hprec
	--能量回复	
	self.mprec = params.mprec
	self.curmprec = self.mprec
	
	--生命值
	self.maxhp = params.maxhp
	self.curhp = params.curhp
	--物理攻击
	self.dc = params.dc
	self.curdc = self.dc
	--魔法攻击
	self.mc = params.mc
	self.curmc = self.mc
	--物理防御
	self.def = params.def
	self.curdef = self.def
	--魔法防御
	self.mdef = params.mdef
	self.curmdef = self.mdef
	--物理暴击
	self.crit = params.crit
	self.curcrit = self.crit
	--魔法暴击
	self.mcrit = params.mcrit
	self.curmcrit = self.mcrit
	--无视物防
	self.idef = params.idef
	self.curidef = self.idef
	--无视法防
	self.imdef = params.imdef
	self.curimdef = self.imdef
	--命中
	self.hit = params.hit
	self.curhit = self.hit
	--闪避
	self.eva = params.eva
	self.cureva = self.eva
	--吸血
	self.suck = params.suck
	self.cursuck = self.suck
	--治疗加成
	self.treatAddition = params.treatAddition
	self.curtreatAddition = self.treatAddition
	--英雄级别
	self.level = params.level



	self.moveSpeed = params.moveSpeed			--单位: 小格/逻辑帧
	self.curmoveSpeed = self.moveSpeed
	self.attackSpeed = params.attackSpeed		--单位: 次数/逻辑帧
	self.curattackSpeed = self.attackSpeed
    --endregion



	self.direction = self.camp == "left" and 1 or -1


	--禁止直接修改此变量，请通过武将状态机相关函数来 设置or 读取
	self.state = "standby"

	--region 逻辑帧延迟控制
	self.leaveStateWaitFrameCnt = 0 				--状态进入时候的等待延迟
	self.beginStateWaitFrameCnt = 0 				--状态离开时候的等待延迟

	--endregion

	--技能释放后会有此结构
	self.curSkillStatus = nil
	--被子弹击退时候会有此结构
	self.knockMoveInfo = nil
	--每秒的生命值变化(中毒，治疗等buff总叠加后的值)
	self.curhealthChange = 0

	--伤害触发队列 禁止直接操作。
	self.hurtInfoQueue = {}
	--子弹队列
	self.bulletQueue = {}
	--位移子弹队列
	self.bulletMovingQueue = {}
	--buff到期队列
	self.buffEndQueue = {}
	--能量值	禁止直接操作
	self.curenergy = params.curenergy
	--当前是否释放大招 (根据，能量，施法距离，沉默buff计算得出)
	self.canRelease = false
	--大招释放控制 and 纪录
	self.talentQueue = {}


	--region buff控制
	self.cantPysicalAttackCnt = 0		--限制物理攻击buff计数
	self.cantMagicAttackCnt = 0			--限制法术攻击buff计数
	self.cantWalkBuffCnt = 0			--限制移动buff计数
	self.cantHurtByMagicAttackCnt = 0	--物理免疫buff计数
	self.cantHurtByPysicalAttackCnt = 0	--法术免疫buff计数
	self.cantBeTargetCnt = 0 			--不能被其他人选为攻击目标
	self.cantInDebuffCnt = 0			--不能被debuff影响
	self.buffShield = nil				--护盾类buff
	--endregion

	self:addAttrFromPassiveSkill()
end

--追加被动技能增加的属性
function SoldierLogic:addAttrFromPassiveSkill()
	
end

--region 调试条件函数
function SoldierLogic:debugCondition()
	if self.camp == "left" and self.index == 1 then
		return true
	end
	return true
end

function SoldierLogic:debugPrint(level, str)
	local printLevel = DEBUG_LEVEL or 3
	if level > printLevel then
		return
	end

	local HeadLabelConfig = {
		[1] = "[FATEL]",
		[2] = "[ERROR]",
		[3] = "[WARN ]",
		[4] = "[INFO ]",
		[5] = "[DEBUG]",
	}

	if self:debugCondition() then
		local camp = self.camp == "left" and "L" or "R"
		print(string.format("%s[第%04d帧][%s][%d][%s]%s", HeadLabelConfig[level], self.battleLogic.frameIndex, camp, self.index, self.state, str))
	end
end

--用于测试现有的buff配置是否都正常，不再在buffCsv.lua中检测错误
function SoldierLogic:testBuffConfig()
	for k,v in pairs(buffCsv.m_data) do
		xpcall(function ()
				local buffId = v.buffId
				local buffInfo = {}
				buffInfo.csvData = buffCsv:getBuffById(buffId)
				buffInfo.buffLevel = 90
				self:debugPrint(4, ",buffId="..buffId..",级别为:"..buffInfo.buffLevel)
				self:addBuff(buffInfo, 1000)
				end,
				function ()
				print("buffID:"..v.buffId.."配置有误")
				end)
		--self:sendNotify("buffAdd", buffInfo)
	end
end
--endregion


--region 能量变更操作接口
function SoldierLogic:changeEnerge(action, params)
	--对于没有配置大招的unit,无需计算能量值
	if not self.csvData.talentSkillId then return end
	
	local energeInfo ={}

	if action == "skill" then
		local skillId = params
		if skillId == self.csvData.normalSkillId then	--普通攻击加90
			energeInfo.addValue = 90
			energeInfo.effect = "normal"
		elseif											--其他小技能加100
			skillId == self.csvData.skillA or
			skillId == self.csvData.skillB or
			skillId == self.csvData.skillC then
			energeInfo.addValue = 100
			energeInfo.effect = "normal"
		elseif skillId == self.csvData.talentSkillId then--大招不加能量
			energeInfo.addValue = -1000		--此处待加入[能量消耗减少属性逻辑]
			energeInfo.effect = "releaseSkill"
		end
	elseif action == "hurt" then						--受到一次伤害
		local hurtInfo = params
		energeInfo.addValue = math.floor(hurtInfo.hurtValue / self.maxhp * 1000)
		energeInfo.effect = "normal"
	elseif action == "killSomeOne" then					--击杀
		energeInfo.addValue = 300
		energeInfo.effect = "killSomeOne"
	end

	self.curenergy = self.curenergy + energeInfo.addValue	--能量增加

	--能量满通知
	if self.curenergy > 1000 then
		self.curenergy = 1000
	elseif self.curenergy < 0 then
		self.curenergy = 0
	end

	--通知表现层
	energeInfo.curValue = self.curenergy
	self:sendNotify("Energe", energeInfo)
end
--endregion


--region buff添加移除接口
function SoldierLogic:addBuff(buffInfo, buffProbability)
	if self.battleLogic.randGenerator() % 1000 < 1000 * buffProbability then
		buffInfo.objectId = self.battleLogic.generelId()
		buffInfo.lastFrameCnt = BuffLogic.getBuffLastFrameCnt(buffInfo)
		self:debugPrint(4, "buff持续时间为:"..tostring(buffInfo.lastFrameCnt))
		BuffLogic.doBuffEffect(self, buffInfo)
		self:addBuffTimer(buffInfo)
		--buffInfo此时包含的成员
		--objectId
		--lastFrameCnt
		--csvData
		--buffLevel
		self:sendNotify("buffadd", buffInfo)
	else	--通知界面显示未命中等
		self:sendNotify("buffmiss", buffInfo)
	end
end

function SoldierLogic:removeBuff(buffInfo)
	BuffLogic.undoBuffEffect(self, buffInfo)
	self:sendNotify("buffdel", buffInfo)
end
--endregion


--region 伤害触发延迟接口
function SoldierLogic:hurtAfterFrameCnt(delayFrameCnt, hurtInfo)
	local effectFrameIndex = self.battleLogic.frameIndex + delayFrameCnt
	if not self.hurtInfoQueue[effectFrameIndex] then
		self.hurtInfoQueue[effectFrameIndex] = {}
	end 
	table.insert(self.hurtInfoQueue[effectFrameIndex], hurtInfo)
end

--检查当前帧是否有伤害
function SoldierLogic:checkHurtInfos()
	if self.hurtInfoQueue[self.battleLogic.frameIndex] then
		for _, hurtInfo in pairs(self.hurtInfoQueue[self.battleLogic.frameIndex]) do
			self:onHurt(hurtInfo)
		end
		self.hurtInfoQueue[self.battleLogic.frameIndex] = nil
	end	
end
--endregion


--bullet结构

--region 不带碰撞检测的子弹
function SoldierLogic:bulletCreate(bulletInfo)
	local hitFrameIndex = self.battleLogic.frameIndex + bulletInfo.flyFrameCnt
	if not self.bulletQueue[hitFrameIndex] then
		self.bulletQueue[hitFrameIndex] = {}
	end
	table.insert(self.bulletQueue[hitFrameIndex], bulletInfo)
end

function SoldierLogic:checkBulletHit()
	if self.bulletQueue[self.battleLogic.frameIndex] then
		for _, bulletInfo in pairs(self.bulletQueue[self.battleLogic.frameIndex]) do
			--region 子弹爆炸业务逻辑 在此处触发伤害
			local targets = BulletLogic.getBulletEffectTargets(bulletInfo)
			--region 子弹对每一个目标的影响
			self:debugPrint(4, "子弹爆炸了,炸到了"..#targets.."个目标")
			for _, target in pairs(targets) do
				BulletLogic.doBulletEffect(bulletInfo, target)
			end
			--endregion
			--region 子弹爆炸后产生召唤
			if bulletInfo.csvData.summonId then
				--第一次使用技能
				if not self.mySummons[bulletInfo.skillInfo.csvData.skillId] then
					self.mySummons[bulletInfo.skillInfo.csvData.skillId] = {}
				end
				--region 之前的同个技能召唤出来的怪物需要强制死亡
				local oldSummons = self.mySummons[bulletInfo.skillInfo.csvData.skillId]
				for _,v in pairs(oldSummons) do
					if v:getCurrentState() ~= "dead" then
						v:changeState(v:getCurrentState(), "dead", "召唤技能重新施放,旧的召唤物强制死亡")
					end
				end
				--endregion

				for i=1, bulletInfo.csvData.summonCnt do--召唤物个数
					local summonAnchPoint = {	x = bulletInfo.targetAnchPoint.x + bulletInfo.direction * bulletInfo.csvData.summonOffset,
						y = bulletInfo.targetAnchPoint.y + i * 0.1}--临时解决方案，轴加一点点偏移，因为完全一样的位置会导致挤压散卡算法无限往一个方向走，待解决 @wangyue 2015-01-28
					self.battleLogic:addSummon(	bulletInfo.skillInfo.csvData,
												self,
												unitCsv:getUnitByTypeId(bulletInfo.csvData.summonId),
												bulletInfo.skillInfo.skillLevel,
												summonAnchPoint )
					
				end
			end
			--endregion
			--endregion
		end
		self.bulletQueue[self.battleLogic.frameIndex] = nil
	end
end
--endregion

--region 带碰撞检测的子弹
function SoldierLogic:bulletMovingCreate(bulletMovingInfo)
	local nextFrameIndex = self.battleLogic.frameIndex + 1
	if not self.bulletMovingQueue[nextFrameIndex] then
		self.bulletMovingQueue[nextFrameIndex] = {}
	end
	table.insert(self.bulletMovingQueue[nextFrameIndex], bulletMovingInfo)
end

function SoldierLogic:checkBulletMovingHit()
	if self.bulletMovingQueue[self.battleLogic.frameIndex] then
		for _, bulletMovingInfo in pairs(self.bulletMovingQueue[self.battleLogic.frameIndex]) do
			--region 位移子弹的移动逻辑
			bulletMovingInfo.curAnchPoint.x, bulletMovingInfo.curAnchPoint.y = bulletMovingInfo.curAnchPoint.x + bulletMovingInfo.movingVec.x, bulletMovingInfo.curAnchPoint.y + bulletMovingInfo.movingVec.y
			self:sendNotify("shootMovingMove", {objectId = bulletMovingInfo.objectId,
												curAnchPoint = bulletMovingInfo.curAnchPoint,
												csvData = bulletMovingInfo.csvData})
			--是否撞到敌方对象
			local target = BulletLogic.getBulletMovingEffectTTarget(bulletMovingInfo)
			if target then
				BulletLogic.doBulletEffect(bulletMovingInfo, target)
				table.insert(bulletMovingInfo.effectedSet, target)
				bulletMovingInfo.currentHitCnt = bulletMovingInfo.currentHitCnt + 1
			end
			--子弹是否达到销毁条件
			if  --子弹伤害计数满
				bulletMovingInfo.currentHitCnt >= bulletMovingInfo.destroyAfterHitCnt then
				self:debugPrint(4, "子弹伤害计数满,子弹id:"..bulletMovingInfo.objectId.."当前位置:("..bulletMovingInfo.curAnchPoint.x..","..bulletMovingInfo.curAnchPoint.y..")")
				self:sendNotify("shootMovingDestroy", {	objectId = bulletMovingInfo.objectId,
														csvData = bulletMovingInfo.csvData})
			elseif --子弹飞出屏幕
				math.abs(bulletMovingInfo.curAnchPoint.x) > BattleConstants.ColMax or
				math.abs(bulletMovingInfo.curAnchPoint.y) > BattleConstants.RowMax then
				self:debugPrint(4, "子弹飞出屏幕,子弹id:"..bulletMovingInfo.objectId.."当前位置:("..bulletMovingInfo.curAnchPoint.x..","..bulletMovingInfo.curAnchPoint.y..")")
				self:sendNotify("shootMovingDestroy", bulletMovingInfo)
			--放入下一帧回调队列
			else
				self:debugPrint(5, "子弹id:"..bulletMovingInfo.objectId.."当前位置:("..bulletMovingInfo.curAnchPoint.x..","..bulletMovingInfo.curAnchPoint.y..")")
				self:bulletMovingCreate(bulletMovingInfo)
			end
			--endregion
		end
		self.bulletMovingQueue[self.battleLogic.frameIndex] = nil
	end
end
--endregion

--region buff结束检测
function SoldierLogic:addBuffTimer(buffInfo)
	local endFrameIndex = self.battleLogic.frameIndex + buffInfo.lastFrameCnt
	if not self.buffEndQueue[endFrameIndex] then
		self.buffEndQueue[endFrameIndex] = {}
	end
	table.insert(self.buffEndQueue[endFrameIndex], buffInfo)
end

function SoldierLogic:checkBuffTimer()
	if self.buffEndQueue[self.battleLogic.frameIndex] then
		for _, buffInfo in pairs(self.buffEndQueue[self.battleLogic.frameIndex]) do
			self:removeBuff(buffInfo)
		end
		self.buffEndQueue[self.battleLogic.frameIndex] = nil
	end
end
--endregion


--region 武将状态机相关
function SoldierLogic:changeState(from, to, printInfo)
	if self.state ~= from then
		print("当前状态为:"..self.state.."调用参数为"..from)
		print(debug.traceback())
		return
	end
	self:debugPrint(4, string.format("状态切换:[%s]--->[%s],切换原因:[%s]", from, to, tostring(printInfo)))
	self:leaveState(from)
	self.state = to
	self:beginState(to)
end




--进入state状态的回调函数
function SoldierLogic:beginState(state)
	if state == "move" then
		self.beginStateWaitFrameCnt = 1

	elseif state == "dead" then
		self.canRelease = false--待通知
		self:doAction("dead")
		--此处待添加主人死亡召唤物也死亡的逻辑

	elseif state == "attack" then
		self.beginStateWaitFrameCnt = 1

	elseif state == "standby" then
		self.beginStateWaitFrameCnt = 1

	elseif state == "damaged" then
		self.beginStateWaitFrameCnt = 1			

	elseif state == "knockMove" then--击退状态时不能攻击和移动
		self.cantPysicalAttackCnt = self.cantPysicalAttackCnt + 1
		self.cantMagicAttackCnt = self.cantMagicAttackCnt + 1
		self.cantWalkBuffCnt = self.cantWalkBuffCnt + 1
	end

	self:debugPrint(4, "进入["..state.."]状态,开始延迟帧数为:"..self.beginStateWaitFrameCnt)
end

--离开state状态的回调函数 
function SoldierLogic:leaveState(state)
	if state == "attack" then
		self:beBreak()

	elseif state == "damaged" then
		self.leaveStateWaitFrameCnt = 20		--最好等于后仰动作的帧数，暂时写20，待调整
	elseif state == "knockMove" then
		self.cantPysicalAttackCnt = self.cantPysicalAttackCnt - 1
		self.cantMagicAttackCnt = self.cantMagicAttackCnt - 1
		self.cantWalkBuffCnt = self.cantWalkBuffCnt - 1
	end

	self:debugPrint(4, "离开["..state.."]状态,离开延迟帧数为:"..self.leaveStateWaitFrameCnt)
end


function SoldierLogic:getCurrentState()
	return self.state
end
--endregion



--region 技能距离、 目标选取等相关函数
--获取最近的敌方目标
function SoldierLogic:getNearestTarget()
	return self.battleLogic:nearestEnemy(self)
end

--目标是否在当前技能的施法距离之内
--参数target为目标soldier对象
function SoldierLogic:isTargetInCurSkillRange(target)
	local skillId = self.turnInfo.actionInfoByActionIndex[self.turnInfo.actionIndex].skillId
	local csvData = skillCsv:getSkillById(skillId)
	local anchX1, anchX2 = self.anchPoint.x, target.anchPoint.x
	return math.abs(anchX1 - anchX2) <= SkillLogic.getSkillCastRange(csvData)
end

--目标是否在大招的施法距离之内
function SoldierLogic:isTargetInBigSkillRange(target)
	local skillId = self.csvData.talentSkillId
	if skillId == nil then
		print("unit表配置有误:")
		print("英灵ID="..self.csvData.typeId..", 大招ID为="..skillId)
		print(debug.traceback())
	end
	local csvData = skillCsv:getSkillById(skillId)
	local anchX1, anchX2 = self.anchPoint.x, target.anchPoint.x
	return math.abs(anchX1 - anchX2) <= SkillLogic.getSkillCastRange(csvData)
end


--endregion

--attack状态内部由 技能前摇(开始播放技能动画)----技能释放(技能生成子弹并发射)----技能后摇(结束等待，cd控制) 3个子状态组成
function SoldierLogic:curSkillUpdate()
	if not self.curSkillStatus then return end
	--region 技能前摇阶段
	if self.curSkillStatus.status == "skillBegin" then
		--region 前摇等待
		if self.curSkillStatus.skillBeginInfo.curFrameCnt < self.curSkillStatus.skillBeginInfo.totalFrameCnt then
			self.curSkillStatus.skillBeginInfo.curFrameCnt = self.curSkillStatus.skillBeginInfo.curFrameCnt + 1
			--region 前摇过程中的位移
			if self.curSkillStatus.skillBeginInfo.beginMoveSpeed then
				self.anchPoint.x = self.anchPoint.x + self.curSkillStatus.skillBeginInfo.beginMoveSpeed
				self:sendNotify("move", {moveType = "skill", anchPoint = self.anchPoint})
				self:debugPrint(5, "技能前摇中位移:"..self.curSkillStatus.skillBeginInfo.beginMoveSpeed)
			end
			--endregion
			return
		end
		--endregion
		--region 前摇完毕,技能真正被释放
		--region curSkillStatus结构
		self.curSkillStatus = {
			status = "skillRelease",
			skillReleaseInfo = {
				csvData = self.curSkillStatus.skillBeginInfo.csvData,
				skillLevel = self.curSkillStatus.skillBeginInfo.skillLevel,
				skillOwner = self,
				totalTimes = #self.curSkillStatus.skillBeginInfo.csvData.lastIntervals,				--需要产生的子弹次数
				curTimes = 1,
				curFrameIndex = 1,
				nextShootFrame = 1,
			}
		}
		--endregion
		self:debugPrint(4, "技能吟唱完毕,真正被释放:id="..self.curSkillStatus.skillReleaseInfo.csvData.skillId)
		--能量改变
		self:changeEnerge("skill", self.curSkillStatus.skillReleaseInfo.csvData.skillId)
		--region 技能前置buff
		local buffIds  = self.curSkillStatus.skillReleaseInfo.csvData.beginBuffIds
		for i = 1, #buffIds do
			local buffId = buffIds[i]
			local buffInfo = {}
			buffInfo.csvData = buffCsv:getBuffById(buffId)
			buffInfo.buffLevel = skillInfo.skillLevel
			self:debugPrint(4, "给自己增加了技能的前置buff,buffId="..buffId..",级别为:"..buffInfo.buffLevel)
			self:addBuff(buffInfo)
			self:sendNotify("buffadd", buffInfo)
		end
		--endregion
		--endregion
	end
	--endregion

	--region 技能施法阶段
	if self.curSkillStatus.status == "skillRelease" then
		--region 施法阶段空闲帧等待
		if self.curSkillStatus.skillReleaseInfo.curFrameIndex < self.curSkillStatus.skillReleaseInfo.nextShootFrame then
			self.curSkillStatus.skillReleaseInfo.curFrameIndex = self.curSkillStatus.skillReleaseInfo.curFrameIndex + 1
			--region 技能释放过程中的位移加在这里
			if self.curSkillStatus.skillReleaseInfo.curMoveSpeed ~= 0 then
				self.anchPoint.x = self.anchPoint.x + self.curSkillStatus.skillReleaseInfo.curMoveSpeed
				self:sendNotify("move", {moveType = "skill", anchPoint= self.anchPoint})
				self:debugPrint(5, "技能释放中位移:"..self.curSkillStatus.skillReleaseInfo.curMoveSpeed)
			end
			--endregion
			return
		end
		--endregion
		--region 技能生效一次
		if self.curSkillStatus.skillReleaseInfo.curTimes <= self.curSkillStatus.skillReleaseInfo.totalTimes then
			self:debugPrint(4, "技能生效进度:"..self.curSkillStatus.skillReleaseInfo.curTimes.."/"..self.curSkillStatus.skillReleaseInfo.totalTimes)
			--region 技能作用范围内的每个敌人(不超过子弹每次上限个数)发射一枚子弹
			local targetInfos = SkillLogic.getBulletTargetInfos(self, self.curSkillStatus.skillReleaseInfo.csvData)
			self:debugPrint(4, "范围内目标个数为:"..#targetInfos..",技能每次产生子弹上限个数为:"..tostring(self.curSkillStatus.skillReleaseInfo.csvData.targetCntPerTimes))
			local enemyBulletId = self.curSkillStatus.skillReleaseInfo.csvData.enemyBulletIds[self.curSkillStatus.skillReleaseInfo.curTimes]
			local friendBulletId = self.curSkillStatus.skillReleaseInfo.csvData.friendBulletIds[self.curSkillStatus.skillReleaseInfo.curTimes]
			local cnt = 1
			for _, targetInfo in pairs(targetInfos) do
				if cnt <=  self.curSkillStatus.skillReleaseInfo.csvData.targetCntPerTimes then					
					--region 对于每一个targetInfo,根据其阵营决定到底是产生友方子弹还是敌方子弹(如果配置了的话)
					local bulletCsvData
					if targetInfo.targetCamp == self.curcamp and friendBulletId then--友方
						bulletCsvData = bulletCsv:getBulletById(friendBulletId)
					elseif targetInfo.targetCamp ~= self.curcamp and enemyBulletId then--敌方
						bulletCsvData = bulletCsv:getBulletById(enemyBulletId)
					else
						self:debugPrint(3, string.format("无匹配的子弹,技能id:%d，跳过,[%s]---attack--->[%s]", 
											self.curSkillStatus.skillReleaseInfo.csvData.skillId, self.curcamp, targetInfo.targetCamp))
					end
					--endregion
					if bulletCsvData then 
						cnt = cnt + 1
						--region begin 生成碰撞检测子弹
						if bulletCsvData.bulletType ==  1 then
							local bulletMovingInfo = {}
							bulletMovingInfo.objectId = self.battleLogic.generelId()
							bulletMovingInfo.skillInfo = self.curSkillStatus.skillReleaseInfo
							bulletMovingInfo.curAnchPoint = {x = self.anchPoint.x + bulletCsvData.oppositeX1 * self.direction, y = self.anchPoint.y}
							bulletMovingInfo.csvData = bulletCsvData
							bulletMovingInfo.movingVec = BulletLogic.getBulletMovingVec(	bulletMovingInfo.curAnchPoint,
																							{x = targetInfo.anchPoint.x - bulletCsvData.oppositeX2 * self.direction, y = targetInfo.anchPoint.y},
																							bulletMovingInfo.csvData)
							bulletMovingInfo.direction = bulletMovingInfo.movingVec.x > 0 and 1 or -1
							bulletMovingInfo.destroyAfterHitCnt = 1 			--命中几个目标后摧毁该子弹
							bulletMovingInfo.currentHitCnt = 0 					--命中目标计数
							bulletMovingInfo.effectedSet = {}					--已经作用过的目标集合
							bulletMovingInfo.targetCamp = targetInfo.targetCamp
							self:debugPrint(4, "生成了一枚带碰撞检测的子弹,子弹id:"..tostring(bulletMovingInfo.csvData.id)..",位移向量:("..tostring(bulletMovingInfo.movingVec.x)..","..tostring(bulletMovingInfo.movingVec.y)..")")
							self:bulletMovingCreate(bulletMovingInfo)
							self:sendNotify("shootMovingCreate", {	objectId = bulletMovingInfo.objectId,
																	curAnchPoint = bulletMovingInfo.curAnchPoint,
																	csvData = bulletMovingInfo.csvData,
																	movingVec = bulletMovingInfo.movingVec})
						--endregion
						--region 生成不带碰撞检测的子弹
						else 									--抛物线、垂直落体、隐形子弹不需要碰撞检测
							local bulletInfo = {}
							bulletInfo.skillInfo = self.curSkillStatus.skillReleaseInfo
							bulletInfo.targetAnchPoint = { x = targetInfo.anchPoint.x, y = targetInfo.anchPoint.y}           --子弹发射时候的目标位置
							bulletInfo.direction = targetInfo.anchPoint.x > self.anchPoint.x and 1 or -1
							bulletInfo.targetCamp = targetInfo.targetCamp
							bulletInfo.targetIndex = targetInfo.targetIndex 												--用Camp和index确定目标   命中目标后根据targetAnch与实际位置的偏离决定是否需要触发伤害
							bulletInfo.csvData = bulletCsvData
							bulletInfo.flyFrameCnt = BulletLogic.getBulletFlyFrameCnt(self.curSkillStatus.skillReleaseInfo.skillOwner.anchPoint, targetInfo.anchPoint, bulletInfo.csvData)
							self:debugPrint(4, "生产了一枚不带碰撞检测的子弹,子弹id:"..tostring(bulletInfo.csvData.id)..",飞行时间"..bulletInfo.flyFrameCnt)
							self:bulletCreate(bulletInfo)
							self:sendNotify("shoot", {	targetAnchPoint = bulletInfo.targetAnchPoint,
														targetCamp = bulletInfo.targetCamp,
														targetIndex = bulletInfo.targetIndex,
														csvData = bulletInfo.csvData,
														flyFrameCnt = bulletInfo.flyFrameCnt})
						end
						--endregion
					end
				end
			end
			--endregion
			--region 计算下一次生效帧index
			local curInterval = tonumber(self.curSkillStatus.skillReleaseInfo.csvData.lastIntervals[self.curSkillStatus.skillReleaseInfo.curTimes])
			if not curInterval then
				print("技能id:"..self.curSkillStatus.skillReleaseInfo.csvData.skillId.."[每次攻击攻击间隔]配置有误")
				curInterval = 0
				print(debug.traceback())
			end

			self.curSkillStatus.skillReleaseInfo.nextShootFrame = self.curSkillStatus.skillReleaseInfo.nextShootFrame + curInterval
			self.curSkillStatus.skillReleaseInfo.curMoveSpeed = SkillLogic.getSkillMoveSpeed(self.curSkillStatus.skillReleaseInfo.csvData,
											self.curSkillStatus.skillReleaseInfo.curTimes,self)
			--endregion
			self.curSkillStatus.skillReleaseInfo.curTimes = self.curSkillStatus.skillReleaseInfo.curTimes + 1
			return
		end
		--endregion
		--region 技能释放完毕
		self.curSkillStatus = {
			status = "skillEnd",
			skillEndInfo = {
				csvData = self.curSkillStatus.skillReleaseInfo.csvData,
				curFrameCnt = 0,
				totalFrameCnt = math.ceil(1 / self.curattackSpeed),
			}
		}
		self.waitAttackFrameCnt = math.ceil(1 / self.curattackSpeed)
		self:debugPrint(4, "技能释放完毕,攻击CD重置为:"..self.waitAttackFrameCnt)
		--endregion
	end
	--endregion

	--region 技能结束等待
	if self.curSkillStatus.status == "skillEnd" then
		self.curSkillStatus.skillEndInfo.curFrameCnt = self.curSkillStatus.skillEndInfo.curFrameCnt + 1
		self:debugPrint(5, "技能释放完毕,CD等待:"..self.curSkillStatus.skillEndInfo.curFrameCnt.."/"..self.curSkillStatus.skillEndInfo.totalFrameCnt)
		--region 在此处添加挤压检测
		local fixPositionInfo = self.battleLogic:needFixPosition(self)
		if fixPositionInfo then
			self:debugPrint(4, "发生挤压,需要位置修正,方向为:"..fixPositionInfo.directionY)
			self.anchPoint.y = self.anchPoint.y + fixPositionInfo.directionY / math.ceil(1 / self.curmoveSpeed)
			self:sendNotify("move", {moveType="spread", anchPoint = self.anchPoint})
		end
		--endregion
		if self.curSkillStatus.skillEndInfo.curFrameCnt >= self.curSkillStatus.skillEndInfo.totalFrameCnt then
			self.curSkillStatus = nil
			return
		end
	end
	--endregion
end



--如果有必要，通知逻辑层改变方向
function SoldierLogic:doFlipIfNeed(target)
	if (target.anchPoint.x - self.anchPoint.x) * self.direction < 0 then
		self.direction = self.direction * (-1)
		self:debugPrint(4, "发生了一次转向")
		self:sendNotify("needFlip")
	end 
end


--region 小技能循环和大招
function SoldierLogic:attackByTurns(target)
	if self.curSkillStatus then return end
	local skillId = self.turnInfo.actionInfoByActionIndex[self.turnInfo.actionIndex].skillId
	local csvData = skillCsv:getSkillById(skillId)


	--region 被物理沉默物理技能无法使用
	if self.cantPysicalAttackCnt > 0 and csvData.releaseType == 1 then
		stepNextTurn(self.turnInfo)
		self:debugPrint(4, "技能:"..skillId.."物理沉默中,直接进入下轮循环")
		return
	end
	--endregion

	--region 被法术沉默法术技能无法使用
	if self.cantMagicAttackCnt > 0 and csvData.releaseType == 2 then
		stepNextTurn(self.turnInfo)
		self:debugPrint(4, "技能:"..skillId.."法术沉默中,直接进入下轮循环")
		return
	end
	--endregion

	--region 真正释放一次技能
	self:doFlipIfNeed(target)
	self:doAction(self.turnInfo.actionInfoByActionIndex[self.turnInfo.actionIndex].actionName, 
					csvData)							--通知播放对应骨骼动画

	--进入skillBeginInfo状态
	self.curSkillStatus = {
		status = "skillBegin",
		skillBeginInfo = {
			csvData = csvData,
			skillLevel = self.skillLevel[skillId],
			skillOwner = self,
			totalFrameCnt = SkillLogic.getSkillBeginFrameCnt(csvData),					--前摇总帧数
			curFrameCnt = 0,															--当前前摇帧数
			beginMoveSpeed = SkillLogic.getSkillBeginMoveSpeed(csvData,self)			--前摇过程中的位移速度
		}
	}
	self:debugPrint(4, "技能开始吟唱:skillId=.."..skillId..",预计吟唱时间为:"..self.curSkillStatus.skillBeginInfo.totalFrameCnt)
	--必须放在流程最末尾
	stepNextTurn(self.turnInfo)
	--endregion
end


function SoldierLogic:skillAttack(target)
	local skillId = self.csvData.talentSkillId
	local csvData = skillCsv:getSkillById(skillId)
	self:doFlipIfNeed(target)
	self:doAction("skill", csvData)
	self.curSkillStatus = {
		status = "skillBegin",
		skillBeginInfo = {
			csvData = csvData,
			skillLevel = self.skillLevel[skillId],
			skillOwner = self,
			totalFrameCnt = SkillLogic.getSkillBeginFrameCnt(csvData),					--前摇总帧数
			curFrameCnt = 0,															--当前前摇帧数
			beginMoveSpeed = SkillLogic.getSkillBeginMoveSpeed(csvData,self)			--前摇过程中的位移速度
		}
	}
	self:debugPrint(4, "大招开始吟唱:skillId=.."..skillId..",预计吟唱时间为:"..SkillLogic.getSkillBeginFrameCnt(csvData))
end
--endregion

--region 武将实际状态逻辑函数
function SoldierLogic:beingMove(target)
	self:doFlipIfNeed(target)
	self.anchPoint.x = self.anchPoint.x + self.direction / math.ceil(1 / self.curmoveSpeed)
	self:sendNotify("move", {moveType= "walk", anchPoint = self.anchPoint})
end


--计算吸血比例
function SoldierLogic:CalcSuckRate(target)
	return self.cursuck / (self.cursuck + target.level + 100)		--100为吸血的数值计算常数,以后从策划配表中读取
end


--受伤回调
function SoldierLogic:onHurt(hurtInfo)
	local realHurtValue = math.min(self.curhp, hurtInfo.hurtValue)
	hurtInfo.oldhp = self.curhp

	--region 物理或者法术免疫
	if hurtInfo.hurtType == 1 and self.cantHurtByPysicalAttackCnt > 0 or
		hurtInfo.hurtType == 2 and self.cantHurtByMagicAttackCnt > 0 then
		hurtInfo.hurtValue = 0
		hurtInfo.hurtEffect = "Immune"
		self:debugPrint(4, "伤害被免疫,类型"..hurtInfo.hurtType)
	end
	--endregion

	--region 身上有护盾buff,需要先做抵消/吸收伤害逻辑
	if hurtInfo.hurtValue > 0 and self.buffShield then
		if hurtInfo.hurtType == 1 and self.buffShield.PysicalType or
			hurtInfo.hurtType == 2 and self.buffShield.MagicType then
			local buffValue = self.buffShield.curValue												--护盾剩余点数
			local useValue = buffValue - hurtInfo.hurtValue < 0 and buffValue or hurtInfo.hurtValue	--本次消耗的护盾点数
			hurtInfo.hurtValue = hurtInfo.hurtValue - useValue										--护盾效果作用之后实际应该造成的伤害点数
			self.buffShield.curValue = self.buffShield.curValue - useValue							--护盾剩余点数

			self:debugPrint(4, "使用了护盾点数:"..useValue..",伤害调整为:"..hurtInfo.hurtValue)

			--region 通知界面更新buff进度条
			local buffChangeInfo = {}
			buffChangeInfo.maxValue = self.buffShield.totalValue
			buffChangeInfo.oldValue = self.buffShield.curValue + useValue
			buffChangeInfo.newValue = self.buffShield.curValue
			self:sendNotify("buffChange", buffChangeInfo)
			self:debugPrint(4,"maxvalue="..buffChangeInfo.maxValue..",oldValue="..buffChangeInfo.oldValue
								..",newValue"..buffChangeInfo.newValue)
			--endregion

			--region 吸收类护盾消耗的同时还需要增加生命值
			if self.buffShield.effectType == "suckShield" then
				local suckShieldHurtInfo = {}
				suckShieldHurtInfo.fromCamp = self.camp
				suckShieldHurtInfo.fromIndex = self.index
				suckShieldHurtInfo.hurtEffect = "suckShield"
				suckShieldHurtInfo.hurtValue = -useValue
				self:hurtAfterFrameCnt(1, suckShieldHurtInfo)
			end
			--endregion

			--region buff用完了
			if self.buffShield.curValue == 0 then
				self:debugPrint(4, "护盾被消耗完毕")
				self:removeBuff(self.buffShield.buffInfo)
			end

			--endregion
		end
	end
	--endregion

	--真实伤害 用作最后伤害统计 以及物理攻击的吸血
	if hurtInfo.hurtValue > 0 then
		local attacker = self.battleLogic[hurtInfo.fromCamp.."Soldiers"][hurtInfo.fromIndex]		--获取hurtInfo中的伤害来源
		local realHurtValue = math.min(self.curhp, hurtInfo.hurtValue)
		--region 伤害统计逻辑
		if attacker.summonInfo then--召唤物的伤害属于主人
			self.battleLogic:hurtStatisticsAdd(attacker.camp, attacker.summonInfo.owner.index, realHurtValue)
		else
			self.battleLogic:hurtStatisticsAdd(attacker.camp, attacker.index, realHurtValue)
		end
		--endregion
		--region 能量改变
		self:changeEnerge("hurt", hurtInfo)
		--endregion
		if hurtInfo.hurtType == 1 then	--吸血逻辑
			--region 生成吸血的hurtInfo
			local suckHurtInfo = {}
			suckHurtInfo.fromCamp = self.camp
			suckHurtInfo.fromIndex = self.index
			suckHurtInfo.hurtEffect = "suck"
			suckHurtInfo.hurtValue = -math.ceil(hurtInfo.hurtValue * attacker:CalcSuckRate(self))
			attacker:debugPrint(4, "物理攻击吸血:"..tostring(-suckHurtInfo.hurtValue))
			attacker:hurtAfterFrameCnt(3, suckHurtInfo)
			--endregion
		end
	end

	self.curhp = self.curhp - hurtInfo.hurtValue

	if self.curhp < 0 then
		self.curhp = 0
	elseif self.curhp > self.maxhp then
		self.curhp = self.maxhp
	end

	hurtInfo.newhp = self.curhp
	hurtInfo.maxhp = self.maxhp
	self:sendNotify("Health", hurtInfo)

	if hurtInfo.hurtValue > self.maxhp / 10 then
		if self:getCurrentState() == "move" or self:getCurrentState() == "attack" then--只打断移动和攻击状态
			self:debugPrint(4, "被打断,伤害来源:"..hurtInfo.fromCamp.."|"..hurtInfo.fromIndex)
			self:changeState(self:getCurrentState(), "damaged", "被打断")
		end
	end

	if self.curhp == 0 then
		self:changeState(self:getCurrentState(), "dead", "生命值降为0")
		--region 能量改变
		local attacker = self.battleLogic[hurtInfo.fromCamp.."Soldiers"][hurtInfo.fromIndex]
		attacker:changeEnerge("killSomeOne")
		--endregion
	end
end
--endregion

--被打断 (沉默开始瞬间， 自己放大招， 单次受击超过10% HP都会触发打断效果)
--沉默可能需要表现层停止技能动画
function SoldierLogic:beBreak()
	self.beginStateWaitFrameCnt = 0
	self.leaveStateWaitFrameCnt = 0
	self.curSkillStatus = nil
end

function SoldierLogic:releaseTalentSkill(frameIndex)
	self:debugPrint(4, "即将在第"..frameIndex.."帧释放大招")
	self.talentQueue[frameIndex] = true
end


--region soldier--->battle 通知接口
function SoldierLogic:doAction(action, params)
	self.battleLogic:doAction(self.camp, self.index, action, params)
end

function SoldierLogic:sendNotify(notify, params)
	self.battleLogic:sendNotify(self.camp, self.index, notify, params)
end
--endregion


--武将的状态机业务逻辑
function SoldierLogic:checkState()
	--大招是否因为限制类buff导致无法释放，返回true表示可释放
	local function canReleaseBigSkill(Soldier)
		local skillId = Soldier.csvData.talentSkillId
		local csvData = skillCsv:getSkillById(skillId)
		if csvData.releaseType == 1 and Soldier.cantPysicalAttackCnt > 0
			or csvData.releaseType == 2 and Soldier.cantMagicAttackCnt > 0 
		then 
			return false 
		end
		return true
	end

	--大招触发
	if self.talentQueue[self.battleLogic.frameIndex] then
		self:debugPrint(4, string.format("大招触发"))
		self:changeEnerge("skill", self.csvData.talentSkillId)
		--region 通知界面层大招是否可释放
		self.canRelease = false
		self:sendNotify("canReleaseBigSkill", self.canRelease)
		self:debugPrint(4, "大招释放后大招是否可点击"..tostring(self.canRelease))
		--endregion
		--region 用户大招释放纪录
		if self.camp == "left" then
			if not self.battleLogic.endInfo.userOp[self.battleLogic.frameIndex] then
				self.battleLogic.endInfo.userOp[self.battleLogic.frameIndex] = {}
			end
			self.battleLogic.endInfo.userOp[self.battleLogic.frameIndex][self.index] = true
		end
		--endregion
		if self:getCurrentState() ~= "attack" then
			self:changeState(self:getCurrentState(), "attack", "大招强制状态切换")
		end
		self:beBreak()
		local target = self:getNearestTarget()
		self:skillAttack(target)
	end



	--region 状态切换延迟
	if self.leaveStateWaitFrameCnt > 0 then
		self:debugPrint(5, "leveStateWaitFrameCnt等待延迟剩余:"..self.leaveStateWaitFrameCnt)
		self.leaveStateWaitFrameCnt = self.leaveStateWaitFrameCnt - 1
		return
	end

	if self.beginStateWaitFrameCnt > 0 then
		self:debugPrint(5, "beginStateWaitFrameCnt等待延迟剩余:"..self.beginStateWaitFrameCnt)
		self.beginStateWaitFrameCnt = self.beginStateWaitFrameCnt - 1
		return
	end
	--endregion

	--获取最近的敌军
	local target = self:getNearestTarget()
	if not target then
		self:debugPrint(4, "已经没有施法目标了")
		return
	end

	--region 通知界面层大招是否可释放
	if self.curenergy >= 1000 and self.csvData.talentSkillId then
		local newFlag = self:isTargetInBigSkillRange(target) and canReleaseBigSkill(self)
		if newFlag ~= self.canRelease then
			self.canRelease = newFlag
			self:sendNotify("canReleaseBigSkill", newFlag)
			self:debugPrint(4, "能量满后大招是否可点击:"..tostring(newFlag))
		end
	end
	--endregion

	--standby: 根据施法距离决定移动还是施法(暂时未加沉默判断)
	if self:getCurrentState() == "standby" then
		if not self:isTargetInCurSkillRange(target) then
			self:changeState("standby", "move", "目标不在施法距离")
			return
		end
		self:changeState("standby", "attack", "目标已经在施法距离")
		return
	end	
	--move状态: 根据施法距离决定继续移动还是施法
	if self:getCurrentState() == "move" then
		if not self:isTargetInCurSkillRange(target) then
			if self.cantWalkBuffCnt == 0 then
				self:beingMove(target)
			else
				self:debugPrint(5, "自身buff限制所以无法移动,个数为"..self.cantWalkBuffCnt)
			end
			self:debugPrint(5, "目标不在施法距离,状态持续[move]")
			return	--继续移动
		end
		self:changeState("move", "attack", "目标已在施法距离")
		return
	end
	--attack状态(小技能循环)
	if self:getCurrentState() == "attack" then
		if not self:isTargetInCurSkillRange(target) and not self.curSkillStatus then
			self:changeState("attack", "move", "目标不在施法距离")
			return
		end
		self:debugPrint(5, "目在施法距离,状态持续[attack]")
		self:attackByTurns(target)
		self:curSkillUpdate()
		return
	end
	--被打断
	if self:getCurrentState() == "damaged" then
		--打断技能吟唱和持续施法
		self:doAction("damaged")
		self:changeState("damaged", "standby", "被打断完毕")
		return
	end
	--被击退
	if self:getCurrentState() == "knockMove" then
		if self.knockMoveInfo and self.knockMoveInfo.curFrameCnt <= self.knockMoveInfo.totalFrameCnt then
			self:debugPrint(5, "击退状态进度:"..self.knockMoveInfo.curFrameCnt.."/"..self.knockMoveInfo.totalFrameCnt..",位移:"..self.knockMoveInfo.speed)
			if self.knockMoveInfo.speed ~= 0 then
				self.anchPoint.x = self.anchPoint.x + self.knockMoveInfo.speed
				self:sendNotify("move", {moveType = "knock", anchPoint = self.anchPoint })
			end
			self.knockMoveInfo.curFrameCnt = self.knockMoveInfo.curFrameCnt + 1
			return
		end
		self.knockMoveInfo = nil
		self:changeState("knockMove", "standby", "击退状态完毕")
		return
	end
	--已经死亡
	if self:getCurrentState() == "dead" then
		return
	end
	print("never come to here:"..self:getCurrentState())
	print(debug.traceback())
end




function SoldierLogic:update()
	if self:getCurrentState() == "dead" then
		return
	end
	--中毒或者治疗buff导致的生命值变化
	if self.curhealthChange ~= 0 then
		local hurtInfo = {}
		hurtInfo.oldhp = self.curhp
		self.curhp = self.curhp + self.curhealthChange
		if self.curhp > self.maxhp then self.curhp = self.maxhp end		--不超过最大生命值
		if self.curhp < 0 then self.curhp = 1 end						--中毒buff不致死
		hurtInfo.newhp = self.curhp
		hurtInfo.maxhp = self.maxhp
		hurtInfo.hurtValue = hurtInfo.newhp - hurtInfo.oldhp
		--生命值有变化才通知表现层
		if hurtInfo.hurtValue ~= 0 then
			hurtInfo.hurtEffect = "buffChange"
			self:sendNotify("Health", hurtInfo)
			self:debugPrint(4, "中毒导致生命值改变:"..hurtInfo.hurtValue.."当前生命值:"..self.curhp)
		end
	end

--武将执行新的动作
	self:checkState()

--子弹命中(不带碰撞检测的子弹)
	self:checkBulletHit()

--位移子弹命中(带碰撞检测的子弹)
	self:checkBulletMovingHit()

--检查是否有伤害触发
	self:checkHurtInfos()

--buff结束检测
	self:checkBuffTimer()
end

return SoldierLogic
