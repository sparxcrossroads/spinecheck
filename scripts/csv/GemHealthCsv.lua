local GemHealthCsvData = {
	m_data = {},
}

function GemHealthCsvData:load(fileName)
	self.m_data = {}

	local csvData = CsvLoader.load(fileName)

	for index = 1, #csvData do
		local id = tonumber(csvData[index]["id"])	
		if id ~= nil and id > 0 then
			self.m_data[tonumber(csvData[index]["count"])]  =  tonumber(csvData[index]["price"])
		end
	end 
end

function GemHealthCsvData:getDataByCount(count)
	return self.m_data[count]
end

function GemHealthCsvData:Size()
	return #self.m_data
end

return GemHealthCsvData