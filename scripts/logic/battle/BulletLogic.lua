local SkillLogic = import(".SkillLogic")
local BulletLogic = {}


local function hasValue(t, v)
	if not t or type(t) ~= "table"  then
		print("table.hasValue:参数t错误")
		print(debug.traceback())
	end

	for _,value in pairs(t) do
		if value == v then
			return true
		end
	end
	return false
end


--region 带碰撞检测的子弹接口

--返回子弹在当前位置的作用目标
function BulletLogic.getBulletMovingEffectTTarget(bulletMovingInfo)
	local battleLogic = bulletMovingInfo.skillInfo.skillOwner.battleLogic
	local bulletCsvData = bulletMovingInfo.csvData
	--此处逻辑待优化
	local set = battleLogic:getRegionSoldiers(bulletMovingInfo.curAnchPoint.x - bulletMovingInfo.csvData.oppositeX2 - bulletMovingInfo.movingVec.x, 
											 	bulletMovingInfo.curAnchPoint.x +bulletMovingInfo.csvData.oppositeX2)
	local set = battleLogic:fliterCampSoldiers(bulletMovingInfo.targetCamp ,set)
	
	for i=1, #set do
		if not hasValue(bulletMovingInfo.effectedSet, set[i]) then
			return set[i]
		end
	end
	return nil
end

--计算子弹的每帧(逻辑帧)位移向量
function BulletLogic.getBulletMovingVec(startAnch, endAnch, bulletCsvData)
	local vec = {}
	local mx, my = endAnch.x - startAnch.x, endAnch.y - startAnch.y
	local d = math.sqrt(mx * mx + my * my)
	if d == 0 or bulletCsvData.speed == 0 then --避免除0异常
		vec.x, vec.y = 0, 0
		--print(debug.traceback())
	else
		vec.x, vec.y = mx / (d * bulletCsvData.speed), my / (d * bulletCsvData.speed)
	end
	return vec
end
--endregion


--region 不带碰撞检测的子弹接口
function BulletLogic.getBulletFlyFrameCnt(startAnch, endAnch, bulletCsvData)
	if bulletCsvData.flyFrameCnt then	--如果配置了飞行时间，则直接使用配表给出的固定飞行时间，否则用子弹速度去计算
		return bulletCsvData.flyFrameCnt
	end

	local distanceX = math.abs(startAnch.x - endAnch.x)
	local frameCntPerGrid = bulletCsvData.speed
	if bulletCsvData.bulletType == 2 then	--抛物线子弹根据重力常数G 和子弹配表中的子弹速度决定子弹的初始角度然后计算得出t
		local item1 = bulletCsvData.speed * bulletCsvData.speed
		local item2 = distanceX * BattleConstants.ConstantG
		if item1 - item2 < 0 then
			print("抛物线子弹的[速度]配置值过小,无法抛至目标处,子弹ID:"..bulletCsvData.id)
			print(string.format("子弹速度需要满足v^2 > dg,其中g为%.2f,v为%.2f,d为%.2f", 
									BattleConstants.ConstantG, bulletCsvData.speed, distanceX))
			return 0
		end
		local ret = math.floor((math.sqrt(item1 + item2) + math.sqrt(item1 - item2)) / (2 * BattleConstants.ConstantG))
		return ret
	end
	return math.floor(distanceX * frameCntPerGrid)
end

--获取子弹在目标点爆炸的作用目标
function BulletLogic.getBulletEffectTargets(bulletInfo)
	local battleLogic = bulletInfo.skillInfo.skillOwner.battleLogic
	local bulletCsvData = bulletInfo.csvData
	local ret = {}

	local bombPosition = bulletInfo.targetAnchPoint --爆炸位置

	if bulletCsvData.effectRange == 0 then	--单体子弹
		local bulletTarget = battleLogic[bulletInfo.targetCamp.."Soldiers"][bulletInfo.targetIndex]		--原始目标
		local distanceX = math.abs(bombPosition.x - bulletTarget.anchPoint.x) 							--偏差
		if distanceX <= 2 or bulletInfo.csvData.flyFrameCnt then
			table.insert(ret, bulletTarget)
		end
		return ret
	end

	if bulletCsvData.effectRange > 0 then								--范围子弹
		local targetCamp = bulletInfo.targetCamp						--子弹的作用阵营
		ret = battleLogic:getCircularRangeSoldiers(bombPosition, bulletCsvData.effectRange, targetCamp)
		return ret
	end

	print("子弹配置有误:[作用半径]"..bulletCsvData.effectRange..",ID:"..bulletCsvData.id)
	print(debug.traceback())
end
--endregion



function BulletLogic.doBulletEffect(bulletInfo, target)
	local skillOwner = bulletInfo.skillInfo.skillOwner
	--region 子弹附带的伤害
	if bulletInfo.skillInfo.csvData.effectType == 1 and bulletInfo.csvData.hasHurt == 1 then --只有伤害类技能才会产生伤害
		hurtInfo = SkillLogic.getHurtInfo(bulletInfo.skillInfo, target)
		hurtInfo.bulletCsvData = bulletInfo.csvData
		skillOwner:debugPrint(4, "伤害触发了"..tostring(hurtInfo.hurtValue)..",目标是:"..target.camp.."|"..target.index)
		target:hurtAfterFrameCnt(1, hurtInfo)
	end
	--endregion

	--region 子弹附带的buff
	local buffIds  = bulletInfo.csvData.buffIds
	for i = 1, #buffIds do
		local buffCsvData = buffCsv:getBuffById(buffIds[i])
		if not buffCsvData.debuff or								--不是debuff
			buffCsvData.debuff and target.cantInDebuffCnt == 0 then	--是debuff并且身上没有免疫debuff的其他buff
			local buffInfo = {}
			buffInfo.csvData = buffCsvData
			buffInfo.buffLevel = bulletInfo.skillInfo.skillLevel
			target:debugPrint(4, "需要增加的buff为:buffId="..buffCsvData.buffId..",级别为:"..buffInfo.buffLevel)
			--region 计算等级压制(如果需要)后的概率buffProbability
			local buffProbability = 1
			if buffInfo.csvData.debuff then
				buffProbability = buffProbability + (buffInfo.buffLevel - target.level) * 0.1
				target:debugPrint(4, "buff等级压制后的概率为:"..buffProbability)
			end
			--endregion
			target:addBuff(buffInfo, buffProbability)
		else
			target:debugPrint(3, "免疫debuff:"..target.cantInDebuffCnt..",")
		end
	end
	--endregion

	--region 子弹附带的击退or击飞
	if bulletInfo.csvData.knockFrameCnt >0 then
		--逻辑层只维护x轴坐标
		target:beBreak()
		target.knockMoveInfo = {
			totalFrameCnt = bulletInfo.csvData.knockFrameCnt,
			curFrameCnt = 1,
			speed = bulletInfo.direction * bulletInfo.csvData.knockMoveSpeed
		}
		target:debugPrint(4, "击退状态持续时间为:"..bulletInfo.csvData.knockFrameCnt)
		target:changeState(target:getCurrentState(), "knockMove", "被子弹击退or击飞")--击退or击飞，逻辑层都需要切至knockMove状态
		--击飞效果是纯表现层的东西，通知表现层对应参数即可
		if bulletInfo.csvData.knockHeight > 0 then
			local knockHeightInfo = {
				totalFrameCnt = bulletInfo.csvData.knockFrameCnt,
				height = bulletInfo.csvData.knockHeight
			}
			print("发送了击飞信息")
			target:sendNotify("knockHeight", knockHeightInfo)
		end
	end
	--endregion
end


return BulletLogic