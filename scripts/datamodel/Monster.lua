local Monster = class("Monster")
local Unit = require("logical.Unit")
Unit.bind(Monster)

function Monster:ctor(properties)
    self.type = properties.type
    self.level = properties.level
    self.starLevel = properties.starLevel
    self.grade = properties.grade
    if properties.boss then
        self.strPercent = BOSS_ATTRIBUTE_BONUS
        self.agiPercent = BOSS_ATTRIBUTE_BONUS
        self.intlPercent = BOSS_ATTRIBUTE_BONUS
    end

    self.unitData = unitCsv:getUnitByType(self.type)

    --初始化grade，不同，可能激活不同的技能，
    for _, grade in pairs(ding_enum:values("skillActiveGrade")) do
        if self:getProperty("grade") >= grade then
            local skillId = self.unitData[ding_enum:label("skillActiveGrade", grade)]
            if skillId and skillId > 0 then
                --激活技能，如果有了就不再激活
                if not self.skillLevels[tostring(skillId)] then
                    local skillLevel = self:getProperty("level")
                    self.skillLevels[tostring(skillId)] = skillLevel
                end
            end
        end
    end
    self:updateAllFinalAttrValues()
end

function Monster:getProperty(property)
    return self[property]
end

function Monster:setProperty(property, value)
    self[property] = value
end


function Monster:pbData()
    return {
        type = self.type,
        level = self.v,
        starLevel = self.starLevel,
        grade = self.grade,
        skillLevelJson = json.encode(self.skillLevels),

        str = self.str,
        agi = self.agi,
        intl = self.intl,
        hp = self.hp,
        dc = self.dc,
        mc = self.mc,
        def = self.def,
        mdef = self.mdef,
        crit = self.crit,
        mcrit = self.mcrit,
        hprec = self.hprec,
        mprec = self.mprec,
        eva = self.eva,
        hit = self.hit,
        idef = self.idef,
        imdef = self.imdef,
        treatAddition = self.treatAddition,
        manaCostReduce = self.manaCostReduce,
        suck = self.suck,
        skillLevelInc = self.skillLevelInc,
    }
end

return Monster