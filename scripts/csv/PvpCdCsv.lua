local PvpCdCsvData = {
    m_data = {},
}

function PvpCdCsvData:load(fileName)
    self.m_data = {}

    local csvData = CsvLoader.load(fileName)

    for index = 1, #csvData do
        local count = tonumber(csvData[index]["次数"])  
        if count ~=nil and count > 0 then
            self.m_data[count] = {
            price = tonumber(csvData[index]["价格"]),
        }
        end
    end 
end

function PvpCdCsvData:getDataByCount(count)
    return self.m_data[count]
end

function PvpCdCsvData:Size()
    return #self.m_data
end

return PvpCdCsvData
