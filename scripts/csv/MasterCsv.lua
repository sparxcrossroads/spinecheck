local MasterCsv = {
    m_data = {},
}

function MasterCsv:load(fileName)
    self.m_data = {}

    local csvData = CsvLoader.load(fileName)

    for index = 1, #csvData do
        local masterid = tonumber(csvData[index]["御主id"])
        if masterid and masterid > 0 then
            self.m_data[masterid] = {

                name = csvData[index]["名称"],
                iconPath = csvData[index]["头像资源"],
            }
        end
    end
end

function MasterCsv:getDataBymasterid(masterid)
    return self.m_data[masterid]
end


return MasterCsv