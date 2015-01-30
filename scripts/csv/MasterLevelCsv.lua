local MasterLevelCsvData = {
	m_data = {},
	m_size = 0,
}

function MasterLevelCsvData:load(fileName)
	self.m_data = {}

	local csvData = CsvLoader.load(fileName)	

	for index = 1, #csvData do
		local id = tonumber(csvData[index]["id"])			
		if id ~= nil and id> 0 then	
			self.m_data[tonumber(csvData[index]["御主等级"])] = {	
				upLevelExp =  tonumber(csvData[index]["需要经验"]),
				heath = tonumber(csvData[index]["获取体力"]),
				healthLimit = tonumber(csvData[index]["体力上限"]),
			}
		end
	end 
end

function MasterLevelCsvData:getDataByLevel(level)
	return self.m_data[level]
end

return MasterLevelCsvData