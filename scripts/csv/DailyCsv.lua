local DailyCsvData = {
    m_data = {},    
}

function DailyCsvData:load(fileName)
    self.m_data = {}

    local csvData = CsvLoader.load(fileName)    

    for index = 1, #csvData do
        local id = tonumber(csvData[index]["活动id"])            
        if id~=nil and id > 0 then  
            self.m_data[id] = { 
                name = csvData[index]["活动名称"],
                dailyType = csvData[index]["活动类别"], 
                startLevel = tonumber(csvData[index]["开放等级"]), 
                time = tonumber(csvData[index]["显示时间"]),
                keepTime = string.toNumMap(csvData[index]["持续时间"]),
                desc = csvData[index]["活动描述"],  
                icon = tonumber(csvData[index]["活动图标"]),       
                count = tonumber(csvData[index]["活动次数"]),  
                reward = string.toNumMap(csvData[index]["奖励"]),  
                finish = tonumber(csvData[index]["一键完成"]),        
            }
        end
    end 
end

function DailyCsvData:getDataById(Id)
    return self.m_data[Id]
end

return DailyCsvData