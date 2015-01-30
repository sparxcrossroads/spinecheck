local ItemCsvData = {
	m_data = {},	
}

function ItemCsvData:load(fileName)
	self.m_data = {}

	local csvData = CsvLoader.load(fileName)	

	for index = 1, #csvData do
		local id = tonumber(csvData[index]["道具id"])			
		if id ~= nil and id> 0 then	
			self.m_data[id] = {	
				type = tonumber(csvData[index]["道具类别"]),
				name = csvData[index]["道具名称"],
				desc = csvData[index]["道具描述"],
				quality = tonumber(csvData[index]["道具品质"]),
				getsource = tonumber(csvData[index]["获取途径"]),
				effect = tonumber(csvData[index]["数值效果"]),
				price = tonumber(csvData[index]["售出价格"]),
				limit = tonumber(csvData[index]["堆叠数量"]),
				source = {},
			}
		end
	end 
end

function ItemCsvData:getDataById(Id)
	return self.m_data[Id]
end

return ItemCsvData