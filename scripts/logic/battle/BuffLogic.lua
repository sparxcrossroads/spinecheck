local BuffLogic = {}

--region 获取buff的持续时间
function BuffLogic.getBuffLastFrameCnt(buffInfo)
	if not buffInfo.csvData.initKeepTime then return 99999 end	--无时限buff
	return math.ceil((buffInfo.csvData.initKeepTime + buffInfo.csvData.keepTimeGrowth * buffInfo.buffLevel) * 0.03)
end
--endregion

--获取buff的数值配置
local function getBuffValue(buffInfo, effectIndex)
	return buffInfo.csvData.initValue[effectIndex] + buffInfo.csvData.valueGrowth[effectIndex] * buffInfo.buffLevel
end

--region 类型分类
local effectGroup1 = {--纯数值百分比变化
	[1] = "def",
	[2] = "mdef",
	[3] = "treatAddition",
	[4] = "moveSpeed",
	[5] = "attackSpeed"
}

local effectGroup2 = {--纯数值数字变化
	[6] = "dc",
	[7] = "mc",
	[8] = "def",
	[11] = "mdef",
	[28] = "hit",
	[29] = "eva"
}

local effectGroup3 = {--限制类buff
	[16] = "cantMagicAttack",			--不能使用物理攻击
	[19] = "cantPysicalAttack",			--不能使用魔法攻击
	[20] = "cantBeTarget",				--不能被作为攻击目标
	[21] = "cantHurtByMagicAttack",		--不能受到魔法伤害
	[22] = "cantHurtByPysicalAttack",	--不能受到物理伤害
	[23] = "cantInDebuff",				--不能受到Debuff影响
	[26] = "cantWalkBuff"				--不能移动
}

local effectGroup4 = {--护盾类
	[15] = "_",							--吸收护盾
	[24] = "_",							--物理+魔法伤害免疫护盾
	[25] = "_",							--物理伤害免疫护盾
	[27] = "_"							--魔法伤害免疫护盾
}
--endregion

--region buff导致的数值变化(瞬间)
function BuffLogic.doBuffEffect(Soldier,buffInfo)
	for effectIndex = 1,#buffInfo.csvData.effects do
		--region begin 每一个buff效果
		local effectType = buffInfo.csvData.effects[effectIndex]
		if effectGroup1[effectType] then
			local key = effectGroup1[effectType]
			--Soldier:debugPrint(5, "buff增加导致"..key.."增加"..tostring(getBuffValue(buffInfo, effectIndex) / 10).."%")
			--Soldier:debugPrint(5, "增加前"..Soldier["cur"..key])
			Soldier["cur"..key] = Soldier["cur"..key] + Soldier[key] * (getBuffValue(buffInfo, effectIndex) / 1000)
			--Soldier:debugPrint(5, "增加后"..Soldier["cur"..key])
		elseif effectGroup2[effectType] then
			local key = effectGroup2[effectType]
			Soldier["cur"..key] = Soldier["cur"..key] + getBuffValue(buffInfo, effectIndex)
		elseif effectGroup3[effectType] then
			local key = effectGroup3[effectType].."Cnt"
			Soldier[key] = Soldier[key] + 1
		elseif effectGroup4[effectType] then
			--取消上一个护盾(身上同时只能有一种护盾)
			if Soldier.buffShield then
				Soldier:removeBuff(buffInfo)
			end

			--region 组Shield
			local Shield = {}
			Shield.buffInfo = buffInfo
			Shield.totalValue = getBuffValue(buffInfo, effectIndex)		--护盾总点数
			Shield.curValue = Shield.totalValue								--护盾当前剩余总点数

			--根据buff类型将护盾拆分为:   [物理 / 魔法]  + [免疫 / 吸收] 两组基础属性
			--region 配表--->护盾属性
			if effectType == 15 then
				Shield.MagicType = true
				Shield.PysicalType = true
				Shield.effectType = "suckShield"
			elseif effectType == 24 then
				Shield.MagicType = true
				Shield.PysicalType = true
				Shield.effectType = "immuneShield"
			elseif effectType == 25 then
				Shield.MagicType = false
				Shield.PysicalType = true
				Shield.effectType = "immuneShield"
			elseif effectType == 27 then
				Shield.MagicType = true
				Shield.PysicalType = false
				Shield.effectType = "immuneShield"
			end
			Soldier:debugPrint(4, "护盾点数为:"..Shield.totalValue..",护盾效果"..tostring(Shield.effectType)
								..",物理:"..tostring(Shield.PysicalType)..",魔法"..tostring(Shield.MagicType)
								..",buff对象id为:"..buffInfo.objectId)
			Soldier.buffShield = Shield
			--endregion
			--endregion

			--region 通知界面层显示buff进度条
			local buffChangeInfo = {}
			buffChangeInfo.maxValue = Soldier.buffShield.totalValue
			buffChangeInfo.oldValue = Soldier.buffShield.curValue
			buffChangeInfo.newValue = Soldier.buffShield.curValue
			Soldier:sendNotify("buffChange", buffChangeInfo)
			Soldier:debugPrint(4,"maxvalue="..buffChangeInfo.maxValue..",oldValue="..buffChangeInfo.oldValue
								..",newValue"..buffChangeInfo.newValue)
			--endregion

		elseif effectType == 17 then
			Soldier.curcamp = Soldier.camp == "left" and "right" or "left"
			--魅惑会打断当前法术类技能的释放
			if Soldier.curSkillStatus and Soldier.curSkillStatus[Soldier.curSkillStatus.status.."Info"].csvData.releaseType == 2 then
				Soldier:beBreak()
			end
			Soldier:debugPrint(4, "中了魅惑buff")
		elseif effectType == 9 then
			local buffValue = getBuffValue(buffInfo, effectIndex)
			local buffFrameCnt = BuffLogic.getBuffLastFrameCnt(buffInfo)
			local valuePerFrame = math.floor(buffValue / buffFrameCnt * 100) / 100 --精确到小数点后两位
			Soldier:debugPrint(4, "中毒或者治疗增加:"..buffValue.."|"..buffFrameCnt.."|"..valuePerFrame)
			Soldier.curhealthChange = Soldier.curhealthChange + valuePerFrame
		else
			Soldier:debugPrint(3, "buff增加:未实现的buff效果:"..effectType)
		end
		--endregion
	end

	--region buff配表的打断逻辑
	if buffInfo.csvData.breakType ~= 0 then				
		if  Soldier.curSkillStatus then
			local releaseType = Soldier.curSkillStatus[Soldier.curSkillStatus.status.."Info"].csvData.releaseType
			local skillId = Soldier.curSkillStatus[Soldier.curSkillStatus.status.."Info"].csvData.skillId
			--breakType配表逻辑: 1打断物理技能, 2打断法术技能, 3全部打断
			if	releaseType == 1 and buffInfo.csvData.breakType == 1					 
					or releaseType == 2 and buffInfo.csvData.breakType == 2 
					or buffInfo.csvData.breakType == 3 then
				Soldier:beBreak()
				Soldier:debugPrint(4, "技能被buff打断:"..buffInfo.csvData.buffId..",技能id为"..skillId)
			end
		else
			Soldier:debugPrint(4, "不在技能状态无需打断")
		end
	end
	--endregion	
end

function BuffLogic.undoBuffEffect(Soldier,buffInfo)
	for effectIndex = 1,#buffInfo.csvData.effects do
		local effectType = buffInfo.csvData.effects[effectIndex]
		if effectGroup1[effectType] then
			local key = effectGroup1[effectType]
			--Soldier:debugPrint(5, "buff移除导致"..key.."减少"..tostring(getBuffValue(buffInfo, effectIndex) / 10).."%")
			--Soldier:debugPrint(5, "移除前"..Soldier["cur"..key])
			Soldier["cur"..key] = Soldier["cur"..key] - Soldier[key] * (getBuffValue(buffInfo, effectIndex) / 1000)
			--Soldier:debugPrint(5, "移除后"..Soldier["cur"..key])
		elseif effectGroup2[effectType] then
			local key = effectGroup2[effectType]
			Soldier["cur"..key] = Soldier["cur"..key] - getBuffValue(buffInfo, effectIndex)
		elseif effectGroup3[effectType] then
			local key = effectGroup3[effectType].."Cnt"
			Soldier[key] = Soldier[key] - 1
		elseif effectGroup4[effectType] then
			--没有跳进此分支说明在buff超时之前已经消耗完毕
			if Soldier.buffShield then
				--region 通知界面层移除buff进度条
				local buffChangeInfo = {}
				buffChangeInfo.maxValue = Soldier.buffShield.totalValue
				buffChangeInfo.oldValue = Soldier.buffShield.curValue
				buffChangeInfo.newValue = 0
				Soldier:sendNotify("buffChange", buffChangeInfo)
				Soldier:debugPrint(4,"maxvalue="..buffChangeInfo.maxValue..",oldValue="..buffChangeInfo.oldValue
									..",newValue"..buffChangeInfo.newValue)
				--endregion
				Soldier:debugPrint(4, "护盾buff被清除")
				Soldier.buffShield = nil
			end
		elseif effectType == 17 then
			Soldier.curcamp = Soldier.camp
			Soldier:debugPrint(4, "结束了魅惑buff")
		elseif effectType == 9 then
			local buffValue = getBuffValue(buffInfo, effectIndex)
			local buffFrameCnt = BuffLogic.getBuffLastFrameCnt(buffInfo)
			local valuePerFrame = math.floor(buffValue / buffFrameCnt * 100) / 100 --精确到小数点后两位
			Soldier:debugPrint(4, "中毒或者治疗移除:"..buffValue.."|"..buffFrameCnt.."|"..valuePerFrame)
			Soldier.curhealthChange = Soldier.curhealthChange - valuePerFrame
		else
			Soldier:debugPrint(3, "buff移除:未实现的buff效果:"..effectType)
		end
	end
end
--endregion

return BuffLogic