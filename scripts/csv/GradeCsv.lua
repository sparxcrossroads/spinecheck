local GradeCsv = {
    m_data = {},
}

function GradeCsv:load(fileName)
    self.m_data = {}

    local csvData = CsvLoader.load(fileName)

    for index = 1, #csvData do
        local gradeId = tonumber(csvData[index]["品质id"])
        if gradeId and gradeId > 0 then
            self.m_data[gradeId] = {
                gridId = gradeId,
                str = csvData[index]["力量"],
                intl = tonumber(csvData[index]["智力"]),
                agi = tonumber(csvData[index]["敏捷"]),
            }
        end
    end
end

function GradeCsv:getDataById( gradeId )
    return self.m_data[gradeId]
end


return GradeCsv