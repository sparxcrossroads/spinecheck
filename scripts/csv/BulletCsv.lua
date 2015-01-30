local BulletCsvData = {
	m_data = {}
}

function BulletCsvData:load(fileName)
	self.m_data = {}
	
	local csvData = CsvLoader.load(fileName)

	for index = 1, #csvData do
		local id = tonumber(csvData[index]["子弹ID"])
		if id and id > 0 then
			local data = {}
			data.id = id
			data.bulletType = tonumber(csvData[index]["类型"]) or 0
			data.speed = tonumber(csvData[index]["速度"]) or 1.5
			data.flyFrameCnt = tonumber(csvData[index]["飞行时间"])
			data.hasHurt = tonumber(csvData[index]["子弹有无伤害"]) or 0
			data.summonId = tonumber(csvData[index]["召唤物ID"])
			data.summonOffset = tonumber(csvData[index]["召唤物位置坐标"]) or 0
			data.summonCnt = tonumber(csvData[index]["召唤个数"]) or 0
			data.res = csvData[index]["子弹资源"]
			data.actCsv = csvData[index]["子弹动作配表"]
			data.tipsIcon = csvData[index]["头顶icon"]
			data.referenceAngle = tonumber(csvData[index]["基准角"]) 
			data.effectRange = tonumber(csvData[index]["作用半径"]) or 0
			data.stageCnt = tonumber(csvData[index]["子弹段数"]) or 1
			data.stageTargetType = tonumber(csvData[index]["多段式子弹后续目标类型"]) or 0
			data.stageWaitFrameCnt = tonumber(csvData[index]["多段式子弹段延迟"]) or 1
			data.playCount = tonumber(csvData[index]["发射数量"]) 
			data.playInterval = tonumber(csvData[index]["播放间隔"]) 
			data.screenShake = tonumber(csvData[index]["震屏"]) 
			data.shakeDelay = tonumber(csvData[index]["震屏延迟"]) 
			data.jump = tonumber(csvData[index]["浮空"]) 
			data.beginXOffset = tonumber(csvData[index]["开始特效x"])
			data.beginYOffset = tonumber(csvData[index]["开始特效y"])
			data.oppositeX1 = tonumber(csvData[index]["相对x1"]) or 0
			data.oppositeY1 = tonumber(csvData[index]["相对y1"]) or 0
			data.oppositeX2 = tonumber(csvData[index]["相对x2"]) or 0
			data.oppositeY2 = tonumber(csvData[index]["相对y2"]) or 0
			data.oppositeX3 = tonumber(csvData[index]["相对x3"])
			data.oppositeY3 = tonumber(csvData[index]["相对y3"])
			data.oppositeX4 = tonumber(csvData[index]["相对x4"])
			data.oppositeY4 = tonumber(csvData[index]["相对y4"])
			data.oppositeX5 = tonumber(csvData[index]["相对x5"])
			data.oppositeY5 = tonumber(csvData[index]["相对y5"])
			data.buffIds = string.toArray(csvData[index]["关联buff"], "=", "number")
			data.knockMoveSpeed = tonumber(csvData[index]["x轴位移速度"]) or 0      --子弹击退x轴速度
			data.knockHeight = tonumber(csvData[index]["击飞高度"]) or 0            --子弹击飞高度
			data.knockFrameCnt = tonumber(csvData[index]["位移时间"]) or 0          --子弹击飞总帧数
			data.endRes = string.trim(csvData[index]["子弹爆炸特效资源"]) 
			data.impactRes = string.trim(csvData[index]["impact特效资源"])
			data.launchRes = string.trim(csvData[index]["子弹起始特效"])




			--region 多段式子弹相关的错误检测
			if data.stageCnt > 1 then
				if data.stageTargetType == 2 or data.stageTargetType == 3 then
					if data.bulletType ~= 1 then
						print(string.format("配置错误，多段式子弹[多段式子弹后续目标类型]为%d时,子弹[类型]必须为1", data.stageTargetType))
					end
				elseif data.stageTargetType == 1 then
					if data.bulletType == 1 then
						print(string.format("配置错误，多段式子弹[多段式子弹后续目标类型]为%d时,子弹[类型]必须不为1", data.stageTargetType))
					end
				end
			end
			--endregion
			--region 召唤相关的配表检测
			if data.summonId and data.bulletType ==  1 then
				print("召唤子弹必须是非碰撞检测的:"..data.id)
			end
			--endregion
			self.m_data[id] = data
		end
	end
end

function BulletCsvData:getBulletById(id)
	if not self.m_data[id] then
		print("不存在对应的子弹id:"..id)
		print(debug..traceback())
		return
	end
	return self.m_data[id]
end

return BulletCsvData