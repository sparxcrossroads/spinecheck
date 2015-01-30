require("utils.StringUtil")

local BuffCsvData = {
	m_data = {},
}

function BuffCsvData:load(fileName)
	self.m_data = {}

	local csvData = CsvLoader.load(fileName)

	for index = 1, #csvData do
		local buffId = tonumber(csvData[index]["id"])

		if buffId and buffId > 0 then
			local data = {}
			data.buffId = buffId
			data.name = csvData[index]["名称"]
			data.desc = csvData[index]["描述"]
			data.effects = string.toArray(csvData[index]["类型"], "=", "number")
			data.debuff = (tonumber(csvData[index]["DEBUFF"]) or 0) == 1
			data.breakType = tonumber(csvData[index]["是否可以打断技能"])
			data.initValue = string.split(string.trim(csvData[index]["BUFF初始值"]), "=")
			data.valueGrowth = string.split(string.trim(csvData[index]["效果成长"]), "=")
			data.rate = tonumber(csvData[index]["BUFF机率"])
			data.rateGrowth = tonumber(csvData[index]["机率成长"])
			data.initKeepTime = tonumber(csvData[index]["初始持续时间"])
			data.keepTimeGrowth = tonumber(csvData[index]["持续时间成长"]) or 0
			data.campModifies = string.tomap(csvData[index]["阵营覆盖"])
			data.campGrowth = tonumber(csvData[index]["阵营覆盖成长"])
			data.professionModifies = string.tomap(csvData[index]["职业覆盖"])
			data.professionGrowth = tonumber(csvData[index]["职业覆盖成长"])
			data.bulletId = tonumber(csvData[index]["BUFF子弹"])
			data.audio = csvData[index]["BUFF音效"]
			data.buffRes = csvData[index]["buff特效资源"]
			data.buffTip = string.trim(csvData[index]["buff关联UI"])
			data.shader = string.trim(csvData[index]["shader"])
			data.speed = tonumber(csvData[index]["动画播放速度"])

			 
			self.m_data[buffId] = data
		end
	end
end

function BuffCsvData:getBuffById(id)
	return self.m_data[id]
end

return BuffCsvData