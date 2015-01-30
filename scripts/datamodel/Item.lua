
local Item = class("Item")

Item.pbField = {
	"id", "count"
}

function Item:ctor(pbSource)
	for _, field in pairs(self.class.pbField) do
		-- print("Item赋值字段 ==== ",field)
		self[field] = pbSource[field]
	end	
end

-- @param attr:string 
function Item:getAttr(attr)
	local csvData
	local type = self:getTypeValue()
	if type == ITEM_TYPE_SPELL or type == ITEM_TYPE_COMMODITY then
		--[[type, quality, effect, price, limit --]]
	    csvData = itemCsv:getDataById(self.id)	
	    return csvData[attr]
	else -- equipment or fragment
		csvData = equipmentCsv:getDataById(self.id)	
	    return csvData[attr]
	end    
end
 
function Item:getTypeValue()	
	local id = self.id
	if id >= MIN_EQUIPMENT_NO and id <= MAX_EQUIPMENT_NO then
		return ITEM_TYPE_EQUIPMENT
	elseif id >= MIN_FRAGMENT_NO and id <= MAX_FRAGMENT_NO then
	    return ITEM_TYPE_FRAGMENT		
	elseif id >= MIN_SPELL_NO and id <= MAX_SPELL_NO then
		return ITEM_TYPE_SPELL
	elseif id >= MIN_COMMODITY_NO and id <= MAX_COMMODITY_NO  then
		return ITEM_TYPE_COMMODITY
	end
end



return Item