local EquipmentCsvData = {
    m_data = {}
}

function EquipmentCsvData:load(fileName)
    equipBookData = {
    {},{},{},{},{},{},{},{},{},{},{},{},
    }
    self.m_data = {}

    local csvData = CsvLoader.load(fileName)

    for index = 1, #csvData do
        local id = tonumber(csvData[index]["装备ID"])
        if id and id > 0 then
            self.m_data[id]= {
                id = id,
                type = tonumber(csvData[index]["装备类别"]),
                name = csvData[index]["装备名称"],
                duiyingId = tonumber(csvData[index]["对应装备"]),
                desc = csvData[index]["装备描述"],
                quality = tonumber(csvData[index]["装备品质"]),
                strengthenMaxLevel = tonumber(csvData[index]["强化次数上限"]),
                strengthenPoints = string.toNumMap(csvData[index]["装备强化所需魔能"]) or {},
                strengthenCostPerPoint = tonumber(csvData[index]["附魔所需金钱"]),
                minLevel = tonumber(csvData[index]["穿戴等级"]),
                composeLine = string.toNumMap(csvData[index]["合成路线"]) or {},
                composeCost = tonumber(csvData[index]["合成费用"]),
                price = tonumber(csvData[index]["售出价格"]),-- 购买价格是售出价格*2
                str = tonumber(csvData[index]["筋力"]) or 0,
                agi = tonumber(csvData[index]["敏捷"]) or 0,
                intl = tonumber(csvData[index]["魔力"]) or 0,
                hp = tonumber(csvData[index]["生命"]) or 0,
                dc = tonumber(csvData[index]["物攻"]) or 0,
                mc = tonumber(csvData[index]["法强"]) or 0,
                def = tonumber(csvData[index]["护甲"]) or 0,
                mdef = tonumber(csvData[index]["对魔力"]) or 0,
                crit = tonumber(csvData[index]["物理暴击"]) or 0,
                mcrit = tonumber(csvData[index]["魔法暴击"]) or 0,
                hprec = tonumber(csvData[index]["回血"]) or 0,
                mprec = tonumber(csvData[index]["回魔"]) or 0,
                eva = tonumber(csvData[index]["闪避"]) or 0,
                hit = tonumber(csvData[index]["命中"]) or 0,
                idef = tonumber(csvData[index]["护甲穿透"]) or 0,
                imdef = tonumber(csvData[index]["法术忽视"]) or 0,
                treatAddition = tonumber(csvData[index]["治疗效果提升"]) or 0,
                manaCostReduce = tonumber(csvData[index]["能量消耗降低"]) or 0,
                suck = tonumber(csvData[index]["吸血"]) or 0,
                immunoSilent= tonumber(csvData[index]["免疫沉默"]) or 0,
                skillLevelInc = tonumber(csvData[index]["技能等级提升"]) or 0,
                strengthenPoint = tonumber(csvData[index]["蕴含强化点数"]) or 0,
                source = {},
            }



            if id >= MIN_EQUIPMENT_NO and id <= MAX_EQUIPMENT_NO and self.m_data[id]["type"] ~= EQUIPMENT_STYPE_FRAGMENT then
                equipBookData[EQUIP_ALL][#equipBookData[EQUIP_ALL] + 1] = id
                if self.m_data[id]["str"] ~= 0 then
                    equipBookData[EQUIP_STR][#equipBookData[EQUIP_STR] + 1] = id
                end
                if self.m_data[id]["agi"] ~= 0 then
                    equipBookData[EQUIP_AGI][#equipBookData[EQUIP_AGI] + 1] = id
                end
                if self.m_data[id]["intl"] ~= 0 then
                    equipBookData[EQUIP_INTL][#equipBookData[EQUIP_INTL] + 1] = id
                end
                if self.m_data[id]["hp"] ~= 0 then
                    equipBookData[EQUIP_HP][#equipBookData[EQUIP_HP] + 1] = id
                end
                if self.m_data[id]["dc"] ~= 0 then
                    equipBookData[EQUIP_DC][#equipBookData[EQUIP_DC] + 1] = id
                end
                if self.m_data[id]["mc"] ~= 0 then
                    equipBookData[EQUIP_MC][#equipBookData[EQUIP_MC] + 1] = id
                end
                if self.m_data[id]["def"] ~= 0 then
                    equipBookData[EQUIP_DEF][#equipBookData[EQUIP_DEF] + 1] = id
                end
                if self.m_data[id]["crit"] ~= 0 then
                    equipBookData[EQUIP_CRIT][#equipBookData[EQUIP_CRIT] + 1] = id
                end
                if self.m_data[id]["mcrit"] ~= 0 then
                    equipBookData[EQUIP_CRIT][#equipBookData[EQUIP_CRIT] + 1] = id
                end
                if self.m_data[id]["hprec"] ~= 0 then
                    equipBookData[EQUIP_HPREC][#equipBookData[EQUIP_HPREC] + 1] = id
                end
                if self.m_data[id]["mprec"] ~= 0 then
                    equipBookData[EQUIP_MPREC][#equipBookData[EQUIP_MPREC] + 1] = id
                end
                if self.m_data[id]["treatAddition"] ~= 0 then
                    equipBookData[EQUIP_TREAT][#equipBookData[EQUIP_TREAT] + 1] = id
                end
            end
        end
    end


    if CHECK_CSV_DEBUG then
        for id,_ in pairs(self.m_data) do
            if self.m_data[id]["type"] == EQUIPMENT_STYPE_FRAGMENT or  self.m_data[id]["type"] == EQUIPMENT_STYPE_SYNTHETIC  then
                if self.m_data[id]["duiyingId"] == nil or self.m_data[self.m_data[id]["duiyingId"]] == nil then
                    print("euipmentCsv duiyingId Error ", id)
                end

            end
        end
    end

    for k,v in pairs(self.m_data) do
        if table.nums(v.composeLine) == 1 then
            for key,value in pairs(v.composeLine) do
                if self.m_data[key]~= nil and self.m_data[key]["type"] == EQUIPMENT_STYPE_SYNTHETIC then
                    self.m_data[key]["zeilId"] = k
                end
            end
        end
    end

    for i,v in ipairs(equipBookData) do
        table.sort(equipBookData[i], function(a,b) return self.m_data[a].minLevel<self.m_data[b].minLevel end )
    end

end
function EquipmentCsvData:getDataById(id)
    return self.m_data[id]
end
return EquipmentCsvData