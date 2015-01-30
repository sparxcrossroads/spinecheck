local DungeonCsvData = {
    m_data = {},    
}

function DungeonCsvData:load(fileName)
    self.m_data = {}

    local csvData = CsvLoader.load(fileName)    

    for index = 1, #csvData do
        local id = tonumber(csvData[index]["地图ID"])            
        if id~=nil and id > 0 then  
            self.m_data[id] = { 
                type = tonumber(csvData[index]["地图类型"]),
                name = csvData[index]["地图名"], 
                desc = csvData[index]["地图描述"], 
                count = tonumber(csvData[index]["副本个数"]),
                level = tonumber(csvData[index]["开启等级"]),
                times = tonumber(csvData[index]["进入次数"]),  
                days = string.toTableArray(csvData[index]["日期限制"]),  
                map = csvData[index]["地图"],        
            }
        end
    end 
end

function DungeonCsvData:getDataById(Id)
    return self.m_data[Id]
end

return DungeonCsvData