local PvpTicketCsvData = {
    m_data = {},
}

function PvpTicketCsvData:load(fileName)
    self.m_data = {}

    local csvData = CsvLoader.load(fileName)

    for index = 1, #csvData do
        local count = tonumber(csvData[index]["购买次数"])  
        if count ~=nil and count > 0  then
            self.m_data[count] = {
            price = tonumber(csvData[index]["价格"]),
            getCount = tonumber(csvData[index]["获得挑战次数"]),
        }
        end   
    end
end

function PvpTicketCsvData:getDataByCount(count)
    return self.m_data[count]
end

function PvpTicketCsvData:Size()
    return #self.m_data
end

return PvpTicketCsvData