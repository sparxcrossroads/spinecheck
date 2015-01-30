import(".BattleConstants")
local BattleLogic = class("BattleLogic")

local SoldierLogic = import(".SoldierLogic")

--深拷贝一个table,
--注意t必须是无环类结构，否则会无限递归
local function cloneTable(t)
	local function doCopy(t)
		local ret = {}
		for k, v in pairs(t) do
			if type(v) == "table" then
				ret[k] = doCopy(v)
			else
				ret[k] = v
			end
		end
		return ret
	end
	
	local ret = type(t) == "table" and doCopy(t) or t
	return ret
end

--在BattleLogic生命周期内，生成一个唯一的id标识符
local function generelId()
    local id = 0
    function retFun()
        id = id + 1
        return id
    end
    return retFun
end

function BattleLogic:ctor(params)
	self.frameIndex = 0						--逻辑帧序号
	self.viewFrameIndex = 0                 --显示帧序号
	self.battleView = params.battleView     --logic与view通信就全靠它了＝ ＝。
	--self.battleView = nil
	self.runFreq = 30						--游戏逻辑刷新频率 一秒刷新10次

	self.leftSoldiers = {}
	self.rightSoldiers = {}

	self.leftAuto = false					--左阵营是否自动放大招
	self.rightAuto = true					--右阵营是否自动放大招,默认true

	self.randSeed = params.randSeed --初始种子，由server端下发
	--随机数生成器
	self.randGenerator = require("myrand").generator(self.randSeed) --随机数生产器，生成0~32767之间的一个数字
	--id生成器
	self.generelId = generelId()
	self.battleState = 0	--0，初始化	1,战斗中	2,战斗结算, 3结算以后


--region 临时数据填充
--endregion




--战斗结果验证结构
	self.endInfo = {
		randSeed = params.randSeed,		--战斗初始种子
		userOp = {						--用户有效操作记录,本例表示第369帧，1号队员放了一次大, 第374帧,1号和3号队员放了一次大
			--[369] = {
			--	[1] = true
			--},
			--[374] = {
			--	[3] = true,
			--	[4] = true
			--}
		},
		--战斗伤害统计
		battleStatistics = {
			left = {
			--	[1] =1000,
			--	[2] = 2000,
			},
			right = {},
		},
		--结构同上
		endHp = {left = {}, right = {}},
		endEnergy = {left = {}, right = {}},
		star = -1,					-- <0表示战斗失败,=0表示战斗超时 >0表示战斗胜利后的星星数
		magicNumber = nil
	}
end

--服务端运行接口
function BattleLogic:mainLoop()
	while self.battleState ~= 3 do
		xpcall(function() self:update() end,
			function () print("mainLoop捕捉异常:"..debug.traceback()) end)
	end
	for _, camp in pairs({"left", "right"}) do
		for _, v in pairs (self[camp.."Soldiers"]) do
			self.endInfo.endHp[camp][v.index] = v.curhp
			self.endInfo.endEnergy[camp][v.index] = v.curenergy
		end
	end
	return self.endInfo
end
--服务端验证客户端战斗结果和本地计算结果
function BattleLogic:isEndInfoValid(clientEndInfo)
	--验证战斗帧数
	if self.frameIndex ~= clientEndInfo.endFrameIndex then
		print("战斗帧数不一致.."..self.frameIndex.."/"..clientEndInfo.endFrameIndex)
		return false
	end
	--验证magicNumber
	if self.endInfo.magicNumber ~= clientEndInfo.magicNumber then
		print("两端随机过程不一致")
		return false
	end
	--验证左军信息
    for i=1, #clientEndInfo.herosStatistics do
        local soldierIndex = clientEndInfo.herosStatistics[i].soldierIndex
        local soldierHurt = clientEndInfo.herosStatistics[i].soldierHurt
        local soldierCurhp = clientEndInfo.herosStatistics[i].soldierCurhp
        local soldierCurEnergy = clientEndInfo.herosStatistics[i].soldierCurEnergy
        print(self.endInfo.battleStatistics.left[soldierIndex].."/"..soldierHurt)
       	print(self.leftSoldiers[soldierIndex].curhp.."/"..soldierCurhp)
        print(self.leftSoldiers[soldierIndex].curenergy.."/"..soldierCurEnergy)
        if self.endInfo.battleStatistics.left[soldierIndex] ~= soldierHurt or
        	self.leftSoldiers[soldierIndex].curhp ~= soldierCurhp or
        	self.leftSoldiers[soldierIndex].curenergy ~= soldierCurEnergy then
        	print("左军数据不一致")
        	return false
        end
    end
    --验证右军信息
    for i=1, #clientEndInfo.enemiesStatistics do
        local soldierIndex = clientEndInfo.enemiesStatistics[i].soldierIndex
        local soldierHurt = clientEndInfo.enemiesStatistics[i].soldierHurt
        local soldierCurhp = clientEndInfo.enemiesStatistics[i].soldierCurhp
        local soldierCurEnergy = clientEndInfo.enemiesStatistics[i].soldierCurEnergy
    	print(self.endInfo.battleStatistics.right[soldierIndex].."/"..soldierHurt)
    	print(self.rightSoldiers[soldierIndex].curhp.."/"..soldierCurhp)
    	print(self.rightSoldiers[soldierIndex].curenergy.."/"..soldierCurEnergy)
        if self.endInfo.battleStatistics.right[soldierIndex] ~= soldierHurt or
        	self.rightSoldiers[soldierIndex].curhp ~= soldierCurhp or
        	self.rightSoldiers[soldierIndex].curenergy ~= soldierCurEnergy then
        	print("右军数据不一致")
        	return false
        end 
    end
    return true
end

function BattleLogic:update()
	if self.battleState == 0 then		--战斗前
		--初始化伤害统计为0
		for _, camp in pairs({"left", "right"}) do
			for index = 1, #self[camp.."Soldiers"] do
				self.endInfo.battleStatistics[camp][index] = 0
			end
		end
		self.beginTime = os.clock()
		self.battleState = 1
		print("战斗开始..初始种子为"..self.randSeed)
	elseif self.battleState == 1 then --战斗中
		self.viewFrameIndex = self.viewFrameIndex + 1
		if self.viewFrameIndex % 2 == 0 then		--速度控制,战斗逻辑不需要跟显示帧率一致，保持倍数关系即可
													--目前假定逻辑帧率30，显示帧率60，后期应根据机器性能自动降帧并保证战斗总时间不变
			self.frameIndex = self.frameIndex + 1

			for _, camp in pairs({"left", "right"}) do
				for index, soldier in pairs (self[camp.."Soldiers"]) do
					if self[camp.."Auto"] and soldier.canRelease then
						soldier:debugPrint(4, "即将自动释放大招")
						self[camp.."Soldiers"][index]:releaseTalentSkill(self.frameIndex)
					end
					soldier:update()
				end
			end

			if self:checkEnd() or self.frameIndex > 90 * 30	 then--战斗结束或者战斗超时
				self.battleState = 2
				self.endTime = os.clock()
			end
		end
	elseif self.battleState == 2 then --战斗结算
		print("战斗结束")
		print("战斗耗时:"..tostring(self.endTime - self.beginTime))

		print("======左边阵营伤害统计=======")
		for i, v in ipairs(self.leftSoldiers) do
			if not v.summonInfo then
				print(string.format("累计伤害:%d,剩余生命值:%d,剩余能量值:%d", self.endInfo.battleStatistics.left[i], v.curhp, v.curenergy))
			end
		end
		print("============END===========")

		print("======右边边阵营伤害统计=======")
		for i, v in ipairs(self.rightSoldiers) do
			if not v.summonInfo then
				print(string.format("累计伤害:%d,剩余生命值:%d,剩余能量值:%d", self.endInfo.battleStatistics.right[i], v.curhp, v.curenergy))
			end
		end
		print("============END===========")

		local endInfo = {}
		--战斗结束帧序号
		endInfo.endFrameIndex = self.frameIndex
		--填充操作记录
		endInfo.userops = {}
		for frameIndex, soldierSet in pairs(self.endInfo.userOp) do
			local frameOp = {frameIndex = frameIndex, soldiersIndex = {}}
			for soldierIndex, _ in pairs(soldierSet) do
				table.insert(frameOp.soldiersIndex, soldierIndex)
			end
			table.insert(endInfo.userops, frameOp)
		end
		--填充左右军伤害统计	
		local function getStatisticsElement(soldier)
			local ret = {}
			ret.soldierIndex = soldier.index
			ret.soldierHurt = self.endInfo.battleStatistics[soldier.camp][soldier.index]
			ret.soldierCurhp = soldier.curhp
			ret.soldierCurEnergy = soldier.curenergy
			return ret
		end
		endInfo.herosStatistics = {}
		endInfo.enemiesStatistics = {}
		for _, camp in pairs({{"left", "heros"}, {"right", "enemies"}}) do
			for _, v in pairs(self[camp[1].."Soldiers"]) do
				if not v.summonInfo then
					table.insert(endInfo[camp[2].."Statistics"], getStatisticsElement(v))
				end
			end
		end
		--magicNumber
		endInfo.magicNumber = self.randGenerator()						--客户端发送
		self.endInfo.magicNumber = endInfo.magicNumber					--服务端验证


		self:sendNotify("all",0,"battleEnd", endInfo)
		self.battleState = 3


	elseif self.battleState == 3 then --结算以后  do nothing
	end
	return self.battleState == 3
end

--检测战斗是否结束
function BattleLogic:checkEnd()
	local retInfo = { leftEnd = true, rightEnd = true}

	for _, camp in pairs({"left", "right"}) do 
		for _, soldier in pairs(self[camp.."Soldiers"]) do
			if soldier:getCurrentState() ~= "dead" then
				retInfo[camp.."End"] = false
			end
		end
	end

	local timeOut = self.frameIndex >= 90 * 30

	--调试打印
	if retInfo.leftEnd then print("左边阵营已死光") end
	if retInfo.rightEnd then print("右边阵营已死光") end
	if timeOut then print("战斗超时") end

	return retInfo.leftEnd or retInfo.rightEnd or timeOut
end


--region 通知View的接口函数，服务端跑此逻辑时可在此处切断
function BattleLogic:doAction(camp, index, action, params)
	if self.battleView then
		--params = cloneTable(params)	--如有必要,对table 做一次深拷贝保证逻辑层的结构不会被表现层修改
		xpcall(	function() self.battleView:doAction(camp, index, action, params) end,
				function() print("doAction捕捉异常:"..debug.traceback()) end)
	end
end

function BattleLogic:sendNotify(camp, index, notify, params)
	if self.battleView then
		--params = cloneTable(params)	--如有必要,对table 做一次深拷贝保证逻辑层的结构不会被表现层修改
		xpcall(	function() self.battleView:onNotify(camp, index, notify, params) end,
				function() print("sendNotify捕捉异常:"..debug.traceback()) end)
	end
end
--endregion

--params 构造soldier的参数
--index 队员编号
--camp 所属阵营
--battleLogic 战场逻辑对象
--csvData 	  英雄的csvData
function BattleLogic:addSoldier(params)
	--region 在此处展开一些自相关的参数
	params.battleLogic = self
	params.anchPoint = {}
	params.anchPoint.x, params.anchPoint.y = BattleConstants:indexToAnch(params.index, params.camp)
	--end
	local soldier = SoldierLogic.new(params)
	self[params.camp.."Soldiers"][params.index] = soldier

	if self.battleView then
		self.battleView:addSoldier({index = params.index,
									camp = params.camp,
									csvData = params.csvData,
									maxhp = params.maxhp,
									curhp = params.curhp,
									curenergy = params.curenergy,
									anchPoint = params.anchPoint,
									id = params.id})
	end
end



--level，召唤物级别
function BattleLogic:addSummon(skillCsvData, owner, csvData, level, anchPoint)
	--region 召唤物属性计算
	--临时填充数据，待策划给出计算方法
	local function CalcSummonAttr(csvData, level)
		local ret = {}
		ret.str = 0  
		ret.agi = 0
		ret.intl = 0
		ret.hprec = 0
		ret.mprec = 0
		ret.maxhp = csvData.hp * csvData.str * level--召唤物特有的配表逻辑:[初始生命] + [初始筋力] * 等级
		ret.curhp = ret.maxhp
		ret.curenergy = 0
		ret.dc = csvData.dc + csvData.mc * level	--召唤物特有的配表逻辑:[初始攻击] + [初始法强] * 等级 
		ret.mc = 0
		ret.def = csvData.def + csvData.agi * level	--召唤物特有的配表逻辑:[初始护甲] + [初始敏捷] * 等级
		ret.mdef = csvData.mdef + csvData.intl		--召唤物特有的配表逻辑:[初始魔抗] + [初始魔力] * 等级
		ret.crit = csvData.crit
		ret.mcrit = 0
		ret.idef = 0
		ret.imdef = 0
		ret.hit = 0
		ret.eva = 0
		ret.suck = 0
		ret.treatAddition = 0
		ret.level = level
		ret.moveSpeed = 1 / 6
		ret.attackSpeed = 1 / 60
		return ret
	end
	--endregion
	params = CalcSummonAttr(csvData, level)
	--region 召唤物技能信息初始化
	local function getSummonSkillLevel()
		local allSkill = { "normalSkillId", "talentSkillId", "skillA", "skillB", "skillC" }
		local ret = {}
		for _, v in pairs(allSkill) do
			if csvData[v] and owner.skillLevel[owner.csvData[v]] then
				ret[csvData[v]] = owner.skillLevel[owner.csvData[v]]
			end
		end
		return ret
	end
	--endregion
	params.skillLevel = getSummonSkillLevel()

	for k,v in pairs(params.skillLevel) do
		print(tostring(k).."="..tostring(v))
	end

	repeat 
		params.index = self.generelId()
	until params.index > #self[owner.camp.."Soldiers"]
	params.camp = owner.camp

	params.battleLogic = self
	params.anchPoint = anchPoint

	params.summonInfo = {owner = owner}
	params.csvData = csvData

	local summon = SoldierLogic.new(params)
	self[owner.camp.."Soldiers"][params.index] = summon

	if not owner.mySummons[skillCsvData.skillId] then
		owner.mySummons[skillCsvData.skillId] = {}
	end

--	--region 之前的同个技能召唤出来的怪物需要强制死亡
--	local oldSummons = owner.mySummons[skillCsvData.skillId]
--	for _,v in pairs(oldSummons) do
--		if v:getCurrentState() ~= "dead" then
--			v:changeState(v:getCurrentState(), "dead", "召唤技能重新施放,旧的召唤物强制死亡")
--		end
--	end
--	--endregion



--	--region 召唤技能重新释放，之前同id技能的召唤物强制死亡
--	local oldSummon = owner.mySummons[skillCsvData.skillId]
--	if oldSummon then
--		oldSummon:changeState(oldSummon:getCurrentState(), "dead", "召唤技能重新施放,旧的召唤物强制死亡")
--	end
--	--endregion
	table.insert(owner.mySummons[skillCsvData.skillId], summon)

	if self.battleView then
		self.battleView:addSoldier({index = params.index,
									camp = params.camp,
									csvData = params.csvData,
									maxhp = params.maxhp,
									curhp = params.curhp,
									curenergy = params.curenergy,
									anchPoint = params.anchPoint,
									isSummon = true})
	end 
end


--伤害统计
function BattleLogic:hurtStatisticsAdd(camp, index, addValue)
	self.endInfo.battleStatistics[camp][index] = self.endInfo.battleStatistics[camp][index] + addValue
end

--region 开放给外部调用的接口
--客户端手动释放大招
function BattleLogic:releaseTalentSkill(camp, index)
	self[camp.."Soldiers"][index]:debugPrint(4, "收到了点击回调")
	if self[camp.."Soldiers"][index].canRelease then--暂时加上true方便调试
		self[camp.."Soldiers"][index]:releaseTalentSkill(self.frameIndex + 1)	--大招必须延迟一帧以上
	end
end

--服务端验算需要调用此函数
function BattleLogic:setTalentSkillRecord(userOp)
	for frameIndex, v in pairs(userOp) do
		for soldierIndex, _ in pairs(v) do
			self["leftSoldiers"][soldierIndex]:debugPrint(4, "收到了操作记录回调")
			self["leftSoldiers"][soldierIndex]:releaseTalentSkill(frameIndex)
		end
	end
end

--设置左军自动释放大招
function BattleLogic:setAutoTalentSkill(leftAuto)
	self.leftAuto = leftAuto
end
--endregion

--region 战场坐标判断相关函数
--计算soldier1, soldier2的直线距离
function BattleLogic.getDisTance(soldier1, soldier2)
	local disX = math.abs(soldier1.anchPoint.x - soldier2.anchPoint.x)
	local disY = math.abs(soldier1.anchPoint.y - soldier2.anchPoint.y)
	local dis = math.sqrt(disX * disX + disY * disY)
	return dis
end

--获取战场的[全局存活,且可被攻击]对象
function BattleLogic:getAllAliveSoldiers()
	local ret = {}
	for _, camp in pairs({"left", "right"}) do
		for _, v in pairs(self[camp.."Soldiers"]) do
			if v:getCurrentState() ~= "dead" and v.cantBeTargetCnt == 0 then
				table.insert(ret, v)
			end
		end
	end
	return ret
end



--返回anchPoint.x ∈[x1,x2]区间的所有soldier集合
function BattleLogic:getRegionSoldiers(x1, x2)
	if x1 > x2 then return self:getRegionSoldiers(x2, x1) end	--交换参数

	local ret = {}
	for _, v in pairs(self:getAllAliveSoldiers()) do
		if v.anchPoint.x >= x1 and v.anchPoint.x <= x2 then
			table.insert(ret, v)
		end
	end
	return ret
end

--返回anchPoint为圆心，R为半径, 属于camp阵营的所有对象
function BattleLogic:getCircularRangeSoldiers(anchPoint, R, camp)
	local ret = {}
	for _, v in pairs(self:fliterCampSoldiers(camp, self:getAllAliveSoldiers())) do
		local dx = math.abs(v.anchPoint.x - anchPoint.x)
		local dy = math.abs(v.anchPoint.y - anchPoint.y)
		if dx * dx + dy * dy <= R * R then
			table.insert(ret, v)
		end
	end
	return ret
end


--如果soldier与其他队友挤在一起，则需要做Y轴的位置
function BattleLogic:needFixPosition(soldier)
	local set = self:fliterCampSoldiers(soldier.camp, self:getAllAliveSoldiers())
	--set中滤掉自己和其他已经在move状态的对象
	set = self:fliterCondSoldier(function (a) return a:getCurrentState() == "move" or a == soldier end, set)
	--set中滤掉与自身距离大于1.5的对象
	set = self:fliterCondSoldier(function(a) return BattleLogic.getDisTance(a, soldier) >= 1.5 end, set)
	--没有与任何单位发生挤压
	if #set == 0 then return nil end
	--如果距离小于1的单位分布在soldier上下两侧,则先保持不动，等待最边上的人先移动
	if #self:fliterCampSoldiers(function(a) return a.anchPoint.y > soldier.anchPoint.y end, set) > 0 and
		#self:fliterCampSoldiers(function(a) return a.anchPoint.y <= soldier.anchPoint.y end, set) > 0 then
		return nil
	end
	--剩下的set全部位于soldier的上方或者下方,即soldier位于最边上,根据相对关系返回位置修正应该移动的方向
	if soldier.anchPoint.y  > set[1].anchPoint.y then
		return{directionY = 1}
	else
		return {directionY = -1}
	end
end



--得到全局最近的敌人
function BattleLogic:nearestEnemy(soldier)

	local opponent = soldier.curcamp == "left" and "right" or "left"	--敌军阵营
	local set = self:fliterCampSoldiers(opponent, self:getAllAliveSoldiers())	--滤出敌方活着的阵营
	set = self:fliterCondSoldier(function (a) return  a == soldier end, set)	--滤掉魅惑状态的自己
	local dis = {}
	for i=1, #set do
		local disx = math.abs(set[i].anchPoint.x - soldier.anchPoint.x)
		local disy = math.abs(set[i].anchPoint.y - soldier.anchPoint.y)
		dis[i] = math.sqrt(disx * disx + disy * disy)
	end

	local minIndex = 1
	for i =1, #set do
		if dis[i] < dis[minIndex] then
			minIndex = i
		end
	end
	return set[minIndex]
end


--返回set中阵营为camp的所有soldier集合
function BattleLogic:fliterCampSoldiers(camp,set)
	local ret = {}
	for _, v in pairs(set) do
		if v.camp == camp then
			table.insert(ret, v)
		end
	end
	return ret
end

function BattleLogic:fliterRegionSoldiers(x1, x2, set)
	if x1 > x2 then return self:fliterRegionSoldiers(x2, x1, set) end	--交换参数

	local ret = {}
	for _, v in pairs(set) do
		if v.anchPoint.x >= x1 and v.anchPoint.x <= x2 then
			table.insert(ret, v)
		end
	end

	return ret
end

--从set集中滤除fliterCb(soldier)返回true的soldier
function BattleLogic:fliterCondSoldier(fliterCb, set)
	local ret ={}
	for _,v in pairs(set) do
		if not fliterCb(v) then
			table.insert(ret, v)
		end
	end
	return ret
end

--endregion


return BattleLogic
