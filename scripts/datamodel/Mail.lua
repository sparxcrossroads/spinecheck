
local Mail = class("Mail")

Mail.pbField = {
	"id","addresser","attachments","subject","body","createTime","readTime"
}

function Mail:ctor(pbSource)
	for _, field in pairs(self.class.pbField) do
		-- print("self[field] ===== ",pbSource[field])
		self[field] = pbSource[field]
	end	
end



return Mail