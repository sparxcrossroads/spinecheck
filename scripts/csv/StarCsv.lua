local StarCsv = {
    m_data = {},
}

function StarCsv:load(fileName)
    self.m_data = {}

    local csvData = CsvLoader.load(fileName)

    for index = 1, #csvData do
        local starid = tonumber(csvData[index]["星级id"])
        if starid and starid > 0 then
            self.m_data[starid] = {
                degree = csvData[index]["完美度"],
                num = tonumber(csvData[index]["令咒数"]),
                money = tonumber(csvData[index]["消耗金币"]),
            }
        end
    end
end

function StarCsv:getDataBystarid( starid )
    return self.m_data[starid]
end


return StarCsv