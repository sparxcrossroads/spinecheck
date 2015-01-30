
local TalkCsvData = {
    m_data = {},
}

function TalkCsvData:load(fileName)
    self.m_data = {}

    local csvData = CsvLoader.load(fileName)

    for index = 1, #csvData do
        local typeId = tonumber(csvData[index]["副本ID"])
        if typeId and typeId > 0 then
        	local id = tonumber(csvData[index]["剧情ID"])
        	if  self.m_data[typeId] == nil then
        		 self.m_data[typeId] = {}
        	end
            self.m_data[typeId][id] = {
                	type = tonumber(csvData[index]["类型"]),
	                position = tonumber(csvData[index]["玩家对话"]),
	                roleIcon = tonumber(csvData[index]["NPC资源"]),
	                roleName = csvData[index]["NPC名称"],
	                expression = tonumber(csvData[index]["表情"]),
	                bg = tonumber(csvData[index]["场景"]),
	                block = tonumber(csvData[index]["对话框"]),
	                talk = csvData[index]["对白"],

        
            }

        end
    end
end

function TalkCsvData:getById( typeId )
    return self.m_data[typeId]
end


return TalkCsvData