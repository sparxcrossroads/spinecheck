local Hero = class("Hero")

Hero.pbField = { 
	"id", "type", "level", "exp", "starLevel", "grade", "skillLevelJson",
	"equipmentJson", 
	"str1","str2","agi1","agi2", "intl1","intl2", "hp1","hp2", "dc1","dc2", "mc1", "mc2",  
	"def1","def2", "mdef1","mdef2", "crit1","crit2","mcrit1","mcrit2", "hprec1","hprec2","mprec1","mprec2","eva1", "eva2","hit1","hit2", 
	"idef1","idef2", "imdef1","imdef2", "treatAddition1","treatAddition2", "manaCostReduce1","manaCostReduce2", "suck1","suck2",   
	"skillLevelInc","score"	
}

function Hero:ctor(pbSource)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self:loadFromPbData(pbSource)

	if self.equipmentJson then
		self.equipmentJson = json.decode(self.equipmentJson)
	end
	if self.skillLevelJson then
		self.skillLevelJson = json.decode(self.skillLevelJson)
	end
end

function Hero:loadFromPbData(pbData)
	for _,property in pairs(self.class.pbField) do
		-- printf("%s ==== %s",property,pbData[property])
		self[property] = pbData[property]
	end
end

-- 得到武将的总属性
function Hero:getTotalAttrValues(baseValues)
	
end

-- 等级升级所需总经验
function Hero:getLevelExp(level)
	
end

-- 得到升级所需剩余经验
function Hero:getLevelUpExp()
	
end


function Hero:set_choose(newChoose)
	self.choose = tonumber(newChoose)
	self:dispatchEvent({ name = "updateChoose", choose = self.choose })
end

function Hero:set_level(newLevel)
	self.level = tonumber(newLevel)
	self:dispatchEvent({name = "updateLevel", level = self.level})
end

function Hero:set_exp(newExp)
	self.exp = tonumber(newExp)
	self:dispatchEvent({name = "updateExp", exp = self.exp})
end

return Hero