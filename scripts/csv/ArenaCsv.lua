local ArenaCsvData = {
    m_data = {},
}
function ArenaCsvData:load(fileName)
    self.m_data = {}
    local id

    local csvData = CsvLoader.load(fileName)
    for index = 1, #csvData do
        id = tonumber(csvData[index]["id"])
        if id and id > 0 then
            self.m_data[id] ={
                max = tonumber(csvData[index]["排名上限"]),
                min = tonumber(csvData[index]["排名下限"]),
                reward = string.toNumMap(csvData[index]["每日结算奖励"]),
                rewardMax = string.toNumMap(csvData[index]["最高排名奖励"]),
            }
        end
    end
end

function ArenaCsvData:getDataByCapsuleType(id)
    return self.m_data[id]
end

return ArenaCsvData