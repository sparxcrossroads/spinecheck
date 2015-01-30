local SignCsv = {
    m_data = {},
}

function SignCsv:load(fileName)
    self.m_data = {}

    local csvData = CsvLoader.load(fileName)


print("666666===",#csvData)
    for index = 1, #csvData do
    local signid = tonumber(csvData[index]["签到id"])
        if signid and signid > 0 then
            self.m_data[index] = {
                signid = tonumber(csvData[index]["签到id"]),
                year = tonumber(csvData[index]["年份"]),
                month = tonumber(csvData[index]["月份"]),
                num = tonumber(csvData[index]["签到次数"]),
                encourage = csvData[index]["奖励"],
                vipNum = tonumber(csvData[index]["双倍VIP等级"]), 
            }
        end
    end
end

function SignCsv:getDataBysignid(signid)
    return self.m_data[signid]
end


return SignCsv