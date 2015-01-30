local CapsuleMainCsvData = {
    m_data = {},
}
function CapsuleMainCsvData:load(fileName)
    self.m_data = {}
    local id

    local csvData = CsvLoader.load(fileName)
    for index = 1, #csvData do
        id = tonumber(csvData[index]["id"])
        if id and id > 0 then
            self.m_data[id] ={
                name = csvData[index]["法阵名称"],
                currency = tonumber(csvData[index]["货币类型"]),
                price = tonumber(csvData[index]["价格"]),
                discount = tonumber(csvData[index]["10连抽优惠"]),
                defaultItemId = tonumber(csvData[index]["保底道具id"]),
                freeCount = tonumber(csvData[index]["免费次数"]),
                cooldown = tonumber(csvData[index]["冷却时间"]),--配置表中数据单位分钟
                queueLength = tonumber(csvData[index]["序列长度"]),
                keyLootLibraries = string.toNumMap(csvData[index]["关键类型"]),
                tips = csvData[index]["法阵tips"],

            }
        end
    end
end

function CapsuleMainCsvData:getDataByCapsuleType(id)
    return self.m_data[id]
end

return CapsuleMainCsvData