local SkillLevelCsv = {
	m_data = {},
}

function SkillLevelCsv:load(fileName)
	self.m_data = {}

	local csvData = CsvLoader.load(fileName)	

	for index = 1, #csvData do
		local level = tonumber(csvData[index]["技能等级"])			
		if level ~= nil and level> 0 then	
			self.m_data[level] = {	
				level = level,
				gold = tonumber(csvData[index]["消耗金币"]),
			}
		end
	end 
end

function SkillLevelCsv:getDataByLevel(level)
	return self.m_data[level]
end

return SkillLevelCsv