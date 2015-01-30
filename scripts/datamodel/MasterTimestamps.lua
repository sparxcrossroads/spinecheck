-- 时间管理

local MasterTimestamps = class("MasterTimestamps", require("shared.ModelBase"))

function MasterTimestamps:ctor(properties)
	MasterTimestamps.super.ctor(self, properties)
end

MasterTimestamps.schema = {
    key     		= {"string"},       -- redis key	
	lastHealthTime 	= {"number", skynet.time()},	-- 上次恢复体力的时间
    lastSkillPointTime 	= {"number", skynet.time()},	-- 上次恢复体力的时间
    bronzeCapsuleCooldownUntil = {"number", 0}, --青铜法阵下次免费抽取的时间
    silverCapsuleCooldownUntil = {"number", 0}, --白银法阵下次免费抽取的时间
}

MasterTimestamps.fields = {	
	lastHealthTime = true,
	lastSkillPointTime = true,
    bronzeCapsuleCooldownUntil = true,
    silverCapsuleCooldownUntil = true,
}

function MasterTimestamps:updateProperty(params)
	local newValue = params.newValue or 0

	self:setProperty(params.field, newValue)
	self.owner:notifyUpdateProperty(params.field, newValue)
end


function MasterTimestamps:pbData()
	return {}
end

return MasterTimestamps