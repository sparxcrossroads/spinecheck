local SceneCsvData = {
    m_data = {},    
}

function SceneCsvData:load(fileName)
    self.m_data = {}
    self.dropPath = {}
    local csvData = CsvLoader.load(fileName)    

    for index = 1, #csvData do
        local id = tonumber(csvData[index]["副本ID"])            
        if id ~=nil and id > 0 then    
            self.m_data[id] = { 
                chapterId = tonumber(csvData[index]["章节id"]), 
                type = tonumber(csvData[index]["副本类型"]),
                name = csvData[index]["副本名"], 
                desc = csvData[index]["副本描述"], 
                icon = tonumber(csvData[index]["关卡图标"]), 
                pos = string.toArray(csvData[index]["关卡坐标"]), 
                prevId = tonumber(csvData[index]["前置副本"]),
                starLevel = tonumber(csvData[index]["开启等级"]),
                grade = tonumber(csvData[index]["品阶"]),
                star = tonumber(csvData[index]["怪物星级"]),
                level = tonumber(csvData[index]["战斗等级"]),
                enemyMap = string.toNestedNumMap(csvData[index]["怪物配表"]),    
                count = tonumber(csvData[index]["战斗阶段"]),
                boss = string.toNumMap(csvData[index]["BOSS配表"]),     
                sceneBack = string.tomap(csvData[index]["场景背景"]),  
                dialog = tonumber(csvData[index]["剧情"]),  
                health = tonumber(csvData[index]["消耗体力"]),
                wheater = csvData[index]["天气"],  
                times = tonumber(csvData[index]["进入次数"]) or -1, 
                masterExp = tonumber(csvData[index]["御主经验"]), 
                heroExp = tonumber(csvData[index]["英灵经验"]), 
                gold = tonumber(csvData[index]["过关金钱"]),                
                gainMap = string.toTableArray(csvData[index]["掉落"], " ", 3),  
                commonScene = tonumber(csvData[index]["对应副本"]),  
                sweepItems = string.toNumMap(csvData[index]["扫荡奖励"]),                         
            }
            if CHECK_CSV_DEBUG then
                local enemyCount
                if self.m_data[id].enemyMap == nil or self.m_data[id].boss == nil then
                    print("SceneCsvData"..id.."enemyMap or boss error")
                else
                    for i=1,self.m_data[id].count do
                        enemyCount = 0
                        if self.m_data[id].enemyMap[i] ~= nil then
                            for k,v in pairs(self.m_data[id].enemyMap[i]) do
                                enemyCount = enemyCount + v
                            end
                            if self.m_data[id].boss[i] ~= nil then
                                enemyCount = enemyCount + 1
                            end
                            if enemyCount > 5 or enemyCount == 0 then
                                print("SceneCsvData"..id.."enemyMap or boss error")
                            end
                        else
                            print("SceneCsvData"..id.."enemyMap or boss error")
                        end
                    end
                end
            end 
          
            --by tanweijiang 2015-01-29   从这里获取精英副本的id  赋值给itemCsv.m_data[value].source
            --下面的筛选条件用不了，但怕改乱，所以新加这个
            --希望能合并在一起
            if self.m_data[id].times ~= 0 and math.floor(id/SCENE_TYPE_RATE) == SCENE_TYPE_ELITE then
                for k,v in pairs(self.m_data[id]["gainMap"]) do
                    local value = tonumber(v[1])
                    if value <= MAX_SPELL_NO and value >= MIN_SPELL_NO and itemCsv.m_data[value] ~= nil then
                        itemCsv.m_data[value].source[#itemCsv.m_data[value].source+1] = id
                        -- print("id=======",id)
                    end
                end
            end
            --by tanwijiang end

            if self.m_data[id].times ~= 0 and math.floor(id/SCENE_TYPE_RATE) == SCENE_TYPE_COMMON then
                for k,v in pairs(self.m_data[id]["gainMap"]) do
                    local value = tonumber(v[1])
                    if value <= MAX_SPELL_NO and value >= MIN_SPELL_NO and itemCsv.m_data[value] ~= nil then
                        itemCsv.m_data[value].source[#itemCsv.m_data[value].source] = id
                    elseif equipmentCsv.m_data[value] ~= nil then
                        equipmentCsv.m_data[value].source[#equipmentCsv.m_data[value].source+1] = id
                    end
                end
            end
        end
    end 
end

function SceneCsvData:getDataById(Id)
    return self.m_data[Id]
end

return SceneCsvData