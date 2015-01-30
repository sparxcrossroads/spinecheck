local NameCsv = {
    m_data = {},
}

function NameCsv:load(fileName)
    self.m_data = {}

    local csvData = CsvLoader.load(fileName)

    for index = 1, #csvData do
        local nameid = tonumber(csvData[index]["ID"])
        if nameid and nameid > 0 then
            self.m_data[nameid] = {

                adjective = csvData[index]["形容词adj."],
                nouns = csvData[index]["名词n."],
   
             
            }
        end
    end
end

function NameCsv:getDataBysignid(nameid)
    return self.m_data[nameid]
end


return NameCsv