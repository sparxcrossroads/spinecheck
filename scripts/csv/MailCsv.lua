local MailCsv = {
    m_data = {},
}

function MailCsv:load(fileName)
    self.m_data = {}

    local csvData = CsvLoader.load(fileName)
-- print("ayyaadd===",#csvData)
    for index = 1, #csvData do
    local mailid = tonumber(csvData[index]["邮件id"])

    -- print("ayyaadd222===",mailid)
        if mailid and mailid > 0 then
            self.m_data[index] = {
                sender = csvData[index]["发件人"],
                attachments = string.toNumMap(csvData[index]["附件"]),  --？？改
                tittle = csvData[index]["邮件标题"],
                mailcontent = csvData[index]["邮件内容"],         
            }

            -- print("ayyaaddsender===",csvData[index]["发件人"])
        end
    end
end

function MailCsv:getDataByMailid(mailid)
    return self.m_data[mailid]
end


return MailCsv