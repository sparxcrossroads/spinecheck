local SkillLogic = {}

--根据作用范围和作用范围参数筛选对象
local function fliterByEffectRangeType(skillOwner, skillCsvData, set)
	if skillCsvData.effectRangeType == 1 then --全屏
		return set
	end

	if skillCsvData.effectRangeParams[1] == nil or skillCsvData.effectRangeParams[2] == nil then
		print("技能[作用范围参数]配置有误,技能ID:"..skillCsvData.skillId)
		print(debug.traceback())
		return
	end

	if skillCsvData.effectRangeType == 2 then --射线
		local X1 = skillOwner.direction * skillCsvData.effectRangeParams[1] + skillOwner.anchPoint.x
		local X2 = skillOwner.direction * skillCsvData.effectRangeParams[2] + skillOwner.anchPoint.x
		set = 	skillOwner.battleLogic:fliterRegionSoldiers(X1, X2, set)
		return set, (X1 + X2) / 2
	end

	if skillCsvData.effectRangeType == 3 then --固定区域
		local X1 = skillCsvData.effectRangeParams[1] - skillCsvData.effectRangeParams[2]
		local X2 = skillCsvData.effectRangeParams[1] + skillCsvData.effectRangeParams[2]
		return skillOwner.battleLogic:fliterRegionSoldiers(X1, X2, set), (X1 + X2) / 2 
	end
	print("never come to here!!!")
	print(debug.traceback())
end

--将set中的对象随机乱序
local function randSort(set, randGen)
	local ret = {}
	local loopCnt = #set
	for i=1, loopCnt do
		local index = randGen() % #set + 1
		table.insert(ret, set[index])
		table.remove(set, index)
	end
	return ret
end

--根据sortType将set中元素排序并返回set
local function sortByConfig(skillOwner, sortType, set, centerX)
	if sortType < 1 or sortType > 7 then
		print("配置有误,不存在的排序类型:"..tostring(sortType))
		print(debug.traceback())
	end

	if sortType == 3 then	--随机
		return randSort(set, skillOwner.battleLogic.randGenerator)
	end

	local sortFun = {
		[1] = function (a, b) return a.anchPoint.x * skillOwner.direction < b.anchPoint.x * skillOwner.direction end,--最近
		[2] = function (a, b) return a.anchPoint.x * skillOwner.direction > b.anchPoint.x * skillOwner.direction end,--最远
		--3为随机
		[4] = function (a, b) return a.curhp > b.curhp end,		--生命值最高
		[5] = function (a, b) return a.curhp < b.curhp end,		--生命值最低
		[6] = function (a, b) return a.curintl > b.curintl end,	--智力最高
		[7] = function (a, b) return a.anchPoint.x - centerX < b.anchPoint.x - centerX end	--最接近x=centerX的目标
	}
	table.sort(set, sortFun[sortType])
	return set
end








--根据作用对象类型筛选对象
--1 敌军
--2 自己
--3 己方包括自己
--4 全体
--5 自己以及自己的召唤物
--6 自己的召唤物
--100 战场上随机位置

--根据技能配置生成子弹的targetInfos,每一个元素是如下结构{anchPoint = { x = XXX, y = XXX}, targetCamp = XXX, targetIndex = XXX}
function SkillLogic.getBulletTargetInfos(skillOwner, skillCsvData)
	local set = {}
	if skillCsvData.effectObject == 1 then	--敌军(不包括魅惑状态的自己)
		set = skillOwner.battleLogic:getAllAliveSoldiers()
		local enemy = skillOwner.curcamp == "left" and "right" or "left"
		set = skillOwner.battleLogic:fliterCampSoldiers(enemy, set)
		set = skillOwner.battleLogic:fliterCondSoldier( function (a) return a == skillOwner end, set)--滤掉魅惑状态的自己
		set, midAnchX = fliterByEffectRangeType(skillOwner, skillCsvData, set)
		set = sortByConfig(skillOwner, skillCsvData.effectObjAttr, set, midAnchX)

	elseif skillCsvData.effectObject == 2 then
		table.insert(set, skillOwner)

	elseif skillCsvData.effectObject == 3 then	--己方包括自己
		set = skillOwner.battleLogic:getAllAliveSoldiers()
		local friend = skillOwner.curcamp
		set = skillOwner.battleLogic:fliterCampSoldiers(friend, set)
		set, midAnchX = fliterByEffectRangeType(skillOwner, skillCsvData, set)
		set = sortByConfig(skillOwner, skillCsvData.effectObjAttr, set, midAnchX)

	elseif skillCsvData.effectObject ==  4 then	--全体不分敌我
		set = skillOwner.battleLogic:getAllAliveSoldiers()
		set, midAnchX = fliterByEffectRangeType(skillOwner, skillCsvData, set)
		set = sortByConfig(skillOwner, skillCsvData.effectObjAttr, set, midAnchX)

	elseif skillCsvData.effectObject == 5 then --自己以及自己的召唤物
		table.insert(set, skillOwner)
		skillOwner:debugPrint(3, "目标对象类型5待完善,还需要添加自己的幻象")

	elseif skillCsvData.effectObject == 6 then	--自己的召唤物		
		skillOwner:debugPrint(3, "目标对象类型6待完善,还需要添加自己的幻象")

	elseif skillCsvData.effectObject == 100 then --随机坐标点
		local randX = skillOwner.battleLogic.randGenerator() % (BattleConstants.RowMax * 2 + 1) - BattleConstants.RowMax
		local randY = skillOwner.battleLogic.randGenerator() % (BattleConstants.ColMax * 2 + 1) - BattleConstants.ColMax
		local fakeSoldier = {	anchPoint = { x = randX, y = randY }, 
								targetCamp = skillOwner.curcamp == "left" and "right" or "left" }
		table.insert(set, fakeSoldier)

	else
		print("未实现的目标范围:"..tostring(skillCsvData.effectObject).."技能id:"..skillCsvData.skillId)
	end

	local ret = {}
	for i = 1, #set do
		local targetInfo = {}
		targetInfo.anchPoint = set[i].anchPoint
		targetInfo.targetCamp = set[i].camp
		targetInfo.targetIndex = set[i].index
		table.insert(ret, targetInfo)
	end
	return ret
end




--获取技能的吟唱时间 (技能吟唱---->吟唱完毕)
function SkillLogic.getSkillBeginFrameCnt(csvData)
	return csvData.beginWaitFrameCnt
end

--获取技能的吟唱期间位移速度 格子数/逻辑帧
function SkillLogic.getSkillBeginMoveSpeed(csvData, skillOwner)
	if not csvData.beginMoveType then return 0 end
	if not csvData.beginWaitFrameCnt then
		print("技能吟唱时间有位移，必须设置beginWaitFrameCnt不为0")
		return
	end

	--region 根据配表筛选位移目标moveTarget
	local moveTarget
	if csvData.beginMoveType == 21 then 
		moveTarget = skillOwner
	else
		local targetCamp = skillOwner.curcamp == "left" and "right" or "left"
		local targetSet = skillOwner.battleLogic:fliterCampSoldiers(targetCamp, skillOwner.battleLogic:getAllAliveSoldiers())
		targetSet = sortByConfig(skillOwner, csvData.beginMoveType, targetSet)
		moveTarget = targetSet[1]
	end
	--endregion

	local anchX = moveTarget.anchPoint.x + moveTarget.direction * csvData.beginMoveDistance	--位移目的地
	return (anchX - skillOwner.anchPoint.x) / csvData.beginWaitFrameCnt						--配表解析时需要保证beginWaitFrameCnt不为0
end

--获取技能第n发子弹后的位移速度 格子数/逻辑帧
function SkillLogic.getSkillMoveSpeed(csvData, curtime, skillOwner)
	local ret
	xpcall(	function() ret = tonumber(csvData.moveDistances[curtime]) / tonumber(csvData.lastIntervals[curtime]) * skillOwner.direction end,
			function() 
--				print("计算技能位移速度失败:技能id:"..csvData.skillId..","..tostring(curtime)) 
--				print("位移距离:"..tostring(csvData.moveDistances[curtime]))
--				print("位移时间:"..tostring(csvData.lastIntervals[curtime]))
--				print(debug.traceback())
				ret = 0 end)
	return ret
end

--获取技能的持续施法时间 (前摇完毕开始施法---->施法结束)
function SkillLogic.getSkillLastFrameCnt(csvData)
	if not csvData.lastIntervals then return 0 end
	local ret = 0
	local times = 1
	for _, value in pairs(csvData.lastIntervals) do
		value = tonumber(value)
		if value then
			ret = ret + value
			times = times + 1
		end
	end
	if times ~= #csvData.bulletIds then
		print("技能ID:"..csvData.skillId..",[每次攻击攻击间隔]配置有误,与[技能子弹ID]不一致!!!")
		print(debug.traceback())
	end
	return ret
end

--获取技能的施法距离
function SkillLogic.getSkillCastRange(csvData)
	if not csvData.castRange then
		print("技能:"..csvData.skillId.."[施法距离]配置有误")
		print(debug.traceback())
	end
	return csvData.castRange
end


--传入参数 damagedPoind 初始伤害点数
--传入参数 defensePoint 防御点数(物防 or 法防)
--返回值   防御效果作用后的伤害点数  
local function CalcDamageAfterDefense(damagedPoint, defensePoint)
	if defensePoint < 0 then
		defensePoint = 0
	end
	if damagedPoint == 0 then
		return 0
	end
	return damagedPoint * damagedPoint/ (8 * defensePoint + damagedPoint)
end



--计算物理暴击几率
local function CalcPhysicalCritHitRate(atkCrit, defensePoint)
	if defensePoint < 0 then
		defensePoint = 0
	end
	if atkCrit == 0 then
		return 0
	end
	--print("atkCrit="..tostring(atkCrit))
	--print(debug.traceback())
	local PhysicalCritConstant = 1.5                      --物理暴击常数，以后考虑从csv读取
	return atkCrit / (atkCrit * PhysicalCritConstant + defensePoint)
end

--计算法术暴击几率
local function CalcMagicCritHitRate(atkCrit, defensePoint)
	if defensePoint < 0 then
		defensePoint = 0
	end
	if atkCrit == 0 then
		return 0
	end
	local  MagicCritConstant= 1.6                         --法术暴击常数，以后考虑从csv读取
	return atkCrit / (atkCrit * MagicCritConstant + defensePoint)
end

--计算物理闪避几率
local function  CalcPhysicalMissRate(atkHit, defMiss)
	if atkHit - defMiss <= 0 then
		return 0
	end
	local MissConstant = 150							  --闪避计算常数
	return  (atkHit - defMiss) / (atkHit - defMiss + MissConstant)
end



--计算技能的附加总点数
local function getSkillValue(skillInfo)
	return skillInfo.csvData.atkConstant + skillInfo.csvData.atkConstantGrowth * skillInfo.skillLevel
end


-- 计算技能的伤害/治疗总点数  攻击 or 法强 + 技能附加伤害点数 (伤害类型1,2,3,4)
local function getDamagePoint(skillInfo)
	local hurtType = skillInfo.csvData.hurtType
	local addValue = getSkillValue(skillInfo)
	local useatk = {skillInfo.skillOwner.curdc, skillInfo.skillOwner.curmc, 
					skillInfo.skillOwner.curdc, skillInfo.skillOwner.curmc}--根据技能类型决定用攻击还是法强计算

	local finalValue = useatk[skillInfo.csvData.releaseType] * skillInfo.csvData.atkCoefficient + getSkillValue(skillInfo)
	return finalValue
end


--计算二次效果
local function secondAttrEffect(skillOwner, hurtInfo, target)
	local randGenerator = skillOwner.battleLogic.randGenerator					--
	local hurtType = hurtInfo.hurtType
	--是否闪避
	if hurtType == 1 or hurtType == 3 then   --只有物理or物理神圣伤害会被闪避
		local miss = CalcPhysicalMissRate(skillOwner.curhit, target.cureva)
		skillOwner:debugPrint(4, "目标闪避概率为:"..tostring(miss * 100).."%")
		if (randGenerator() % 1000) < 1000 * miss then
			hurtInfo.hurtValue = 0
			hurtInfo.hurtEffect = "miss"
			return hurtInfo
		end
	end

	--是否暴击
	if hurtType == 1 or hurtType == 2 then	--神圣类伤害无暴击
		local useCrit = {skillOwner.curcrit, skillOwner.curmcrit}
		local useDef = {target.curdef, target.curmdef}
		local useCalcFun = {CalcPhysicalMissRate, CalcMagicCritHitRate}
		local crit = useCalcFun[hurtType](useCrit[hurtType], useDef[hurtType])
		skillOwner:debugPrint(4, "暴击概率为:"..tostring(crit * 100).."%")
		if (randGenerator() % 1000) < 1000 * crit then
			hurtInfo.hurtValue = hurtInfo.hurtValue * 2
			hurtInfo.hurtEffect = "crit"
		end
	end

	--region 护盾吸收,buff减免在此计算
	--endregion
	return hurtInfo
end


--根据skillInfo和target得到对应的hurtInfo
function SkillLogic.getHurtInfo(skillInfo, target)
	local hurtInfo = {}			--ret
	--先填充伤害来源
	hurtInfo.fromCamp = skillInfo.skillOwner.camp
	hurtInfo.fromIndex = skillInfo.skillOwner.index
	local hurtType = skillInfo.csvData.hurtType

	if hurtType == 1 or hurtType == 2 then--普通物理攻击和法术攻击(法术攻击包括治疗)
		if getDamagePoint(skillInfo) < 0 then--负值表示治疗，无需防御参与计算
			hurtInfo.hurtValue = getDamagePoint(skillInfo)
		else
			local usedef = {target.curdef - skillInfo.skillOwner.curidef, 
							target.curmdef - skillInfo.skillOwner.curimdef}
			usedef = usedef[hurtType] > 0 and usedef[hurtType] or 0
			hurtInfo.hurtValue = math.ceil(CalcDamageAfterDefense(getDamagePoint(skillInfo), usedef))
			hurtInfo.hurtType = hurtType
		end

	elseif hurtType == 3 or hurtType == 4 then--物理神圣和魔法神圣(不用防御参与计算(注意与防御=0的区别))
		hurtInfo.hurtValue = math.ceil(getDamagePoint(skillInfo))
		hurtInfo.hurtType = hurtType

	elseif hurtType == 5 then--敌方伤害，我方治疗(敌方伤害类型一定是魔法伤害)
		if target.camp == skillInfo.skillOwner.camp then
			hurtInfo.hurtValue = -getDamagePoint(skillInfo)
		else
			local usedef = target.curmdef - skillInfo.skillOwner.curimdef
			usedef = usedef > 0 and usedef or 0
			hurtInfo.hurtValue = math.ceil(CalcDamageAfterDefense(getDamagePoint(skillInfo), usedef))
			hurtInfo.hurtType = 2
		end

	elseif hurtType == 6 then--伤害or治疗值为当前生命值的百分比
		hurtInfo.hurtValue = target.curhp * getSkillValue(skillInfo) / 1000
		hurtInfo.hurtType = 4

	elseif hurtType == 7 then--伤害or治疗值为最大生命值的百分比
		hurtInfo.hurtValue = target.maxhp * getSkillValue(skillInfo) / 1000
		hurtInfo.hurtType = 4

	elseif hurtType == 8 then--成吉思汗特有的大招计算逻辑	
		local damagePoint = (target.maxhp - target.curhp) * getSkillValue(skillInfo) / 1000
		damagePoint = math.max(damagePoint, 197 * skillInfo.skillLevel)
		damagePoint = math.min(damagePoint, 39 * skillInfo.skillLevel)
		local usedef = target.curmdef - skillInfo.skillOwner.curimdef
		usedef = math.max(usedef, 0)
		hurtInfo.hurtValue = math.ceil(CalcDamageAfterDefense(damagePoint, usedef))
		hurtInfo.hurtType = 2

	else
		print("未知的伤害类型:"..tostring(hurtType))
		print(debug.traceback())
	end

	--技能总点数为负，说明是治疗效果,需要加上技能释放者的治疗效果加成
	if hurtInfo.hurtValue < 0 then
		hurtInfo.hurtValue = math.floor(hurtInfo.hurtValue * (1 + skillInfo.skillOwner.curtreatAddition))
		hurtInfo.hurtEffect = "treat"
		return hurtInfo
	end

	hurtInfo.hurtEffect = "normal"
	return secondAttrEffect(skillInfo.skillOwner, hurtInfo, target)
end

return SkillLogic