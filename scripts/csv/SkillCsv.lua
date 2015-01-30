local SkillCsvData = {
	m_data = {},
}

function SkillCsvData:load(fileName)
	local csvData = CsvLoader.load(fileName)

	self.m_data = {}

	for index = 1, #csvData do
		local skillId = tonumber(csvData[index]["技能ID"])
		local hurtCount = tonumber(csvData[index]["伤害次数"])
		
		if skillId and skillId > 0 then

			local data = {}
			data.skillId = skillId
			data.releaseType = tonumber(csvData[index]["技能类型"])								--1为物理技能 2为魔法技能  魔法技能可被沉默
			data.effectType = tonumber(csvData[index]["技能效果"])
			data.hurtType = tonumber(csvData[index]["伤害类型"])
			data.name = csvData[index]["技能名称"]
			data.desc = csvData[index]["技能描述"]
			data.secondDesc = csvData[index]["辅助描述"]
			data.initLevel = tonumber(csvData[index]["初始等级"])
			data.maxLevel = tonumber(csvData[index]["可升等级"])
			data.star = csvData[index]["技能星级"]
			data.angryUnitNum = tonumber(csvData[index]["消耗"])
			data.passiveSkillTrigger = string.toNumMap(csvData[index]["被动技能触发条件"]) or {}
			data.passiveSkillGrowth = string.toNumMap(csvData[index]["被动技能效果成长"]) or {}
			data.effectObject = tonumber(csvData[index]["作用对象"])
			data.effectXPos = tonumber(csvData[index]["作用中心横坐标"])
			data.effectObjProfession = tonumber(csvData[index]["作用对象职业"])
			data.effectObjCamp = tonumber(csvData[index]["作用对象阵营"])
			data.effectObjAttr = tonumber(csvData[index]["作用对象属性"]) or 1
			data.secondAttrGrowth = tonumber(csvData[index]["临时变更成长"])
			data.atkCoefficient = tonumber(csvData[index]["攻击系数"]) or 0
			data.atkConstant = tonumber(csvData[index]["技能常数"])   or 0
			data.atkConstantGrowth = tonumber(csvData[index]["技能常数成长"]) or  0
			data.keepTime = tonumber(csvData[index]["持续时间"])
			data.hurtCount = hurtCount == 0 and 1 or hurtCount
			data.ignoreDef = tonumber(csvData[index]["无视防御"]) == 1
			data.hypnosisPercent = tonumber(csvData[index]["催眠"])
			data.hypnosisGrowth = tonumber(csvData[index]["催眠成长"])
			data.suckHpPercent = tonumber(csvData[index]["吸血百分比"])
			data.suckHpGrowth = tonumber(csvData[index]["吸血成长"])
			data.angryCostPercent = tonumber(csvData[index]["增加怒气消耗"])
			data.angryCostGrowth = tonumber(csvData[index]["增加怒气消耗成长"])
			data.showPic = csvData[index]["技能展示图片"]
			data.audio = csvData[index]["技能音效"]
			data.icon = csvData[index]["技能icon"]
			data.cardResource = csvData[index]["技能卡牌资源"]
			data.jump = tonumber(csvData[index]["浮空"]) == 1
			data.castRange = tonumber(csvData[index]["施法距离"])
			data.beginWaitFrameCnt = tonumber(csvData[index]["吟唱时间"]) or 0	
			data.enemyBulletIds = string.toArray(csvData[index]["技能子弹ID"], "=", "number")
			data.friendBulletIds = string.toArray(csvData[index]["己方技能子弹ID"], "=", "number")
			data.lastIntervals = string.toArray(csvData[index]["每次攻击攻击间隔"], "=", "number")
			data.moveDistances = string.toArray(csvData[index]["施法时位移"], "=", "number")
			data.beginMoveDistance = tonumber(csvData[index]["施法前位移"]) or 0
			data.beginMoveType = tonumber(csvData[index]["位移坐标人物属性"])
			data.effectRangeType = tonumber(csvData[index]["作用范围类型"])
			data.effectRangeParams = string.split(string.trim(csvData[index]["作用范围参数"]), "=")
			data.lastTimes = tonumber(csvData[index]["作用次数"]) 				--超过一次表示持续施法
			data.targetCntPerTimes = tonumber(csvData[index]["每次目标个数"]) or 0
			data.beginBuffIds = string.toArray(csvData[index]["前置BUIF ID"], "=", "number")
			data.beginMoveDistance = tonumber(csvData[index]["施法前位移"]) or 0
			data.launchRes = csvData[index]["launch资源"]
			data.launchDelay =  tonumber(csvData[index]["特效播放延时"]) or 0
			data.endRes = csvData[index]["end资源"]
			data.shakeTime =  tonumber(csvData[index]["震屏时间"]) or 0 
			data.resScale =  tonumber(csvData[index]["放大倍数"]) or 1 


			
			--region 配置错误检测
			if data.releaseType ~=1 and data.releaseType~= 2 then
				if data.effectType == 1 or data.effectType == 2 or data.effectType == 3 then
					print("配置错误，技能ID:"..skillId.."没有配置技能的施放类型")
				end
			end
			--skill配表错误检测
			if data.effectType == 1 then
				if data.hurtType < 1 or data.hurtType > 8 or
					math.ceil(data.hurtType) ~= data.hurtType then	--不是整数
					print("配置错误,技能ID:"..skillId.."伤害类技能伤害类型配置错误")
				end
			elseif data.effectType == 2 then
				
			elseif data.effectType == 3 then
--				if #data.beginBuffIds == 0 and #data.buffIds == 0 then
--					print("配置错误,技能ID:"..skillId.."没有配置buff或者前置buff")
--				end
			end
			--位移配置
			if data.beginMoveType and data.beginWaitFrameCnt == 0 then
				print("配置错误,技能ID:"..skillId.."有施法前位移，技能前摇时间必须大于0")
				data.beginWaitFrameCnt = 1
			end
			--bulletIfs和lastIntervals配置个数一定一致
			if #data.enemyBulletIds ~= #data.lastIntervals and #data.friendBulletIds ~= #data.lastIntervals then
				print(string.format("配置错误,技能ID:%d,[技能子弹ID]个数:%d,[己方技能子弹ID]个数:%d,[每次攻击攻击间隔]个数:%d",
													skillId, #data.enemyBulletIds, #data.friendBulletIds, #data.lastIntervals))
				data.enemybulletIds = {}
				data.friendBulletIds = {}
				data.lastIntervals = {}
			end
			--endregion
			self.m_data[skillId] = data
		end
	end
end

function SkillCsvData:getSkillById(skillId)
	if not self.m_data[skillId] then
		print("不存在的技能:"..skillId)
		print(debug.traceback())
	end
	return self.m_data[skillId]
end

function SkillCsvData:getDescByLevel(skillId, level)
	if not self.m_data[skillId] then return "" end

	local formatArgs = {}
	for _, array in ipairs(self.m_data[skillId].secondDesc) do
		formatArgs[tonumber(array[1])] = tonumber(array[2]) + level * tonumber(array[3])
	end

	return string.format(self.m_data[skillId].desc, unpack(formatArgs))
end

return SkillCsvData