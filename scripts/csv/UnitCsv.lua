local UnitCsvData = {
    m_data = {},
}

function UnitCsvData:load(fileName)
    self.m_data = {}

    local csvData = CsvLoader.load(fileName)

    for index = 1, #csvData do
        local typeId = tonumber(csvData[index]["武将ID"])
        if typeId and typeId > 0 then
            print("读取unit数据:"..typeId)
            self.m_data[typeId] = {
                typeId = tonumber(csvData[index]["武将ID"]),
                name = csvData[index]["武将名称"],
                profession = tonumber(csvData[index]["职业ID"]),
                professionName = csvData[index]["职业名称"],
                primeAttribute = tonumber(csvData[index]["主属性"]),
                starLevel = tonumber(csvData[index]["星级"]),
                hp = tonumber(csvData[index]["初始生命"]),
                str = tonumber(csvData[index]["初始筋力"]),--力量
                agi = tonumber(csvData[index]["初始敏捷"]),
                intl = tonumber(csvData[index]["初始魔力"]),--智力
                dc = tonumber(csvData[index]["初始攻击"]),--物攻
                mc = tonumber(csvData[index]["初始法强"]),--法攻
                def = tonumber(csvData[index]["初始防御"]),--物防
                mdef = tonumber(csvData[index]["初始对魔力"]),--法防
                strGrowth = string.toNumMap(csvData[index]["筋力成长"]),
                agiGrowth = string.toNumMap(csvData[index]["敏捷成长"]),
                intlGrowth = string.toNumMap(csvData[index]["魔力成长"]),
                crit = tonumber(csvData[index]["初始暴击"]),--物理暴击
                moveSpeed = tonumber(csvData[index]["移动速度"]),
                attackSpeed = tonumber(csvData[index]["攻击速度"]),
                atcRange = tonumber(csvData[index]["攻击距离"]),
                position = tonumber(csvData[index]["站位顺序"]),
                normalSkillId = tonumber(csvData[index]["普攻技能id"]),
                talentSkillId = tonumber(csvData[index]["必杀技ID"]),
                skillA = tonumber(csvData[index]["技能Aid"]),
                skillB = tonumber(csvData[index]["技能Bid"]),
                skillC = tonumber(csvData[index]["技能Cid"]),
                passiveSkill1 = tonumber(csvData[index]["被动技能1"]),
                passiveSkill2 = tonumber(csvData[index]["被动技能2"]),
                passiveSkill3 = tonumber(csvData[index]["被动技能3"]),
                firstTurn = string.split(string.trim(csvData[index]["首轮顺序"]), "="),
                cycleTurn = string.split(string.trim(csvData[index]["循环顺序"]), "="),
                heroOpen = tonumber(csvData[index]["图鉴开关"]),
                spellid = tonumber(csvData[index]["令咒id"]),

                heroStory =  csvData[index]["英灵故事"],                 
                herodiscrib =  csvData[index]["英灵描述"], --fixed
                herofixed = string.tomap(csvData[index]["定位"]),
                shader = csvData[index]["shader"],

            }
        end
    end
end

function UnitCsvData:getUnitByTypeId( typeId )
    return self.m_data[typeId]
end


return UnitCsvData