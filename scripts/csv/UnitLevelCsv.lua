local UnitLevelCsv = {
	m_data = {},	
}

function UnitLevelCsv:load(fileName)
	self.m_data = {}

	local csvData = CsvLoader.load(fileName)	

	for index = 1, #csvData do
		local id = tonumber(csvData[index]["等级"])			
		if id ~= nil and id> 0 then	
			self.m_data[id] = {	
				exp = tonumber(csvData[index]["升至下一等级需要经验"]),
			}
		end
	end 
end

function UnitLevelCsv:getDataById(Id)
	return self.m_data[Id]
end

return UnitLevelCsv