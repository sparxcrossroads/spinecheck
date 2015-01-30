local HeroEquipCsv = {
	m_data = {},
}

function HeroEquipCsv:load(fileName)
	local csvData = CsvLoader.load(fileName)

	self.m_data = {}

	for index = 1, #csvData do
		-- print("xxxxx ======= ",json.encode(csvData[index]))
		local heroid = tonumber(csvData[index]["英灵ID"])
		if heroid and heroid > 0 then
			if not self.m_data[heroid] then
				self.m_data[heroid] = {}
			end
			local grid = tonumber(csvData[index]["品质"])
			self.m_data[heroid][grid] = {}
			self.m_data[heroid][grid].hole1 = tonumber(csvData[index]["装备栏1"])
			self.m_data[heroid][grid].hole2 = tonumber(csvData[index]["装备栏2"])
			self.m_data[heroid][grid].hole3 = tonumber(csvData[index]["装备栏3"])
			self.m_data[heroid][grid].hole4 = tonumber(csvData[index]["装备栏4"])
			self.m_data[heroid][grid].hole5 = tonumber(csvData[index]["装备栏5"])
			self.m_data[heroid][grid].hole6 = tonumber(csvData[index]["装备栏6"])
			
		end
	end
end

function HeroEquipCsv:getDataByHeroId(heroid,gridLevel)
	return self.m_data[heroid][gridLevel]
end


return HeroEquipCsv