local StoreCsvData = {
	m_data = {},	
}

function StoreCsvData:load(fileName)
	self.m_data = {}

	local csvData = CsvLoader.load(fileName)	

	for index = 1, #csvData do
		local id = tonumber(csvData[index]["id"])			
		if id ~= nil and id > 0 then	
			self.m_data[id] = {	
				id = id,
				level = tonumber(csvData[index]["商店投放"]),
				dorp = tonumber(csvData[index]["掉落库"]),
				itemId = tonumber(csvData[index]["道具id"]),
				count = tonumber(csvData[index]["道具数量"]),
				coinType = tonumber(csvData[index]["货币类型"]),
				price = tonumber(csvData[index]["价格"]),
				weight = tonumber(csvData[index]["权重"]),
				weight = tonumber(csvData[index]["触发等级"]),
				flag = tonumber(csvData[index]["标记"]),
			}
		end
	end 
end

function StoreCsvData:getDataById(Id)
	return self.m_data[Id]
end

return StoreCsvData