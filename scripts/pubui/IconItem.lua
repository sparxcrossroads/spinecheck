--
-- Author: 张伟超
-- Date: 2014-08-07 09:53:25
--

local borderPath = RES.."icon_border/"
local itemPath = RES.."icon_item/"

local IconItem = class("IconItem",function(params)
        return display.newNode()
    end)

function IconItem:ctor(params)
    self.params = params or {}
    self.id = self.params.itemid
    self.quility = self.params.quility or 0
    self.quilityTable = { 
        [1] = 1, 
        [2] = 2,
        [3] = 4,
        [4] = 7,
        [5] = 12,
    }
    self.count = self.params.count or 0
    self.isBook = self.params.isBook
    self.data = self.params.data

    if self.isBook == true then
        if self.data then
           self:BookIcon(params)
        end
    else
        self:refreshIcon(params)
    end

end

--刷新方法：
function IconItem:refreshIcon(params)

    local function getClipNode(iconRes,isSuiPian)
        local data = {}
        local str = isSuiPian and "bag_lingzhoumoban.png" or "bag_suipianmoban.png"
        data.steRes = RES.."bag/"..str
        data.clipRes = iconRes
        return getShaderNode(data)
    end

    local function getFile(path)
        if not isFileExistByPath(path) then
            return itemPath.."item.png"
        else
            return path
        end
    end


    local itemData = nil
    local iconNode = nil 
    local iconRes = nil
    local borderRes = nil 
    local borderNode = nil 
    local iconBack = display.newSprite(itemPath.."item_0.png")

    -- print("itemid ======== ",params.itemid)

    if MIN_FRAGMENT_NO <= params.itemid and MAX_FRAGMENT_NO >= params.itemid then --碎片

        print("itemid ======== ",params.itemid)



        itemData = equipmentCsv:getDataById(params.itemid)
        local duiyingId = itemData.duiyingId
        getShaderNode({steRes = RES.."bag/bag_lingzhoumoban.png",node = iconBack}):addTo(self)

        print("itemData.type ========= ",itemData.type)

        if itemData.type == 2 then --卷轴碎片

            print("== 卷轴碎片 ==")

            local juanzhouData = equipmentCsv:getDataById(duiyingId)

            display.newSprite(itemPath.."item_1.png"):addTo(self)
            display.newSprite(itemPath.."item_"..juanzhouData.duiyingId..".png"):scale(0.5):addTo(self)
            iconNode = display.newSprite(itemPath.."item_3.png"):addTo(self)
            display.newSprite(RES.."bag/bag_fragment.png"):pos(16,iconNode:getContentSize().height - 20):addTo(iconNode)

        else --其他装备碎片；

            print("== 装备碎片 ==")

            iconRes = getFile(itemPath.."item_"..duiyingId..".png")
            iconNode = getClipNode(iconRes,true):addTo(self)
        end

         borderRes = RES.."bag/bag_lingzhou.png"
        borderNode = display.newSprite(borderRes):scale(1):addTo(self)
        display.newSprite(RES.."bag/bag_fragment.png"):scale(1)
        :pos(24,borderNode:getContentSize().height - 24):addTo(borderNode)

    elseif MIN_SPELL_NO <= params.itemid and MAX_SPELL_NO >= params.itemid then --令咒
        -- print("== 令咒 ==")

        display.newSprite(RES.."bag/bag_suipianmoban.png"):addTo(self)
        iconRes = getFile(RES.."icon_hero/hero_"..params.itemid..".png")
        iconNode = getClipNode(iconRes):addTo(self)
        itemData = itemCsv:getDataById(params.itemid)
        borderRes = borderPath.."border_2_"..itemData.quality..".png"
        borderNode = display.newSprite(borderRes):addTo(self)
        display.newSprite(RES.."hero/hero_lingzhou.png"):scale(0.8):rotation(-45)
        :pos(24,borderNode:getContentSize().height - 24):addTo(borderNode)

    elseif MIN_EQUIPMENT_NO <= params.itemid and MAX_EQUIPMENT_NO >= params.itemid then --装备；

        itemData = equipmentCsv:getDataById(params.itemid)
        iconBack:addTo(self, -1)
        
        if itemData.type == 2 then --卷轴
            -- print("params.itemid ======== ",params.itemid)
            -- print("itemData.duiyingId ======= ",itemData.duiyingId)
            display.newSprite(itemPath.."item_1.png"):addTo(self)
            local resid = equipmentCsv:getDataById(itemData.duiyingId).id  
            display.newSprite(itemPath.."item_"..resid..".png"):scale(0.5):addTo(self)
            iconNode = display.newSprite(itemPath.."item_3.png"):addTo(self)
        else
            iconRes = getFile(itemPath.."item_"..params.itemid..".png")
            iconNode = display.newSprite(iconRes):addTo(self)
        end
        
        borderRes = borderPath.."border_"..self.quilityTable[itemData.quality]..".png"
        borderNode = display.newSprite(borderRes)
        :pos(iconNode:getContentSize().width/2,iconNode:getContentSize().height/2 - 4):addTo(iconNode)

    else --其他
        -- print("== 其他 ==")

        if params.itemid ~= 102 then
            iconBack:addTo(self, -1)
            itemData = itemCsv:getDataById(params.itemid)
            iconRes = getFile(itemPath.."item_"..params.itemid..".png")
            borderRes = borderPath.."border_"..self.quilityTable[itemData.quality]..".png"
            iconNode = display.newSprite(iconRes):addTo(self)
            borderNode = display.newSprite(borderRes)
            :pos(iconNode:getContentSize().width/2,iconNode:getContentSize().height/2 - 4):addTo(iconNode)
        else
            iconRes = itemPath.."item_102.png"
            borderRes = RES.."icon_border/border_4.png"

            iconNode = display.newSprite(iconRes):addTo(self)
            itemData = itemCsv:getDataById(params.itemid)
            borderNode = display.newSprite(borderRes)--:scale(0.86)
            :pos(iconNode:getContentSize().width/2,iconNode:getContentSize().height/2 - 4):addTo(iconNode)
        end

    end

    --数量
    if self.count > 1 then
        self.countLabel = ui.newTTFLabelWithOutline({
            text = params.count,
            size = 24,
            align = ui.TEXT_ALIGN_RIGHT
        }):align(display.RIGHT_CENTER, 60 + string.utf8len(params.count) * 4, -40):addTo(self,4)
    end
end

--图鉴icon：
function IconItem:BookIcon(params)

    local background = display.newSprite(RES.."armory/armory_itembg.png"):addTo(self,0)
    local width = background:getContentSize().width
    local height = background:getContentSize().height

    if self.data.minLevel > game.master.level then
    -- if self.data.minLevel > 99 then
        --bg
        display.newScale9Sprite(RES.."armory/armory_greyitem.png",0,0,CCSizeMake(108, 108))
            :pos(width/2,height*0.6)
            :addTo(background,1)
        ui.newTTFLabel({text = "lv."..self.data.minLevel.."开启" ,size =28,color = ccc3(141, 64, 25)})
                :pos(width/2,height*0.16):addTo(background,1)
    else

        local itemData = nil
        local iconNode = nil 
        local iconRes = nil
        local borderRes = nil 
        local borderNode = nil 
        local iconBack = display.newSprite(itemPath.."item_0.png")

        if params.itemid then
            itemData = equipmentCsv:getDataById(params.itemid)

            local iconRes = itemPath.."item_"..params.itemid..".png"
            if not isFileExistByPath(iconRes) then
                iconRes =  itemPath.."item.png"
            end

            iconNode = display.newSprite(iconRes):pos(width/2,height*0.6)
            :addTo(background,2)

            borderRes = borderPath.."border_"..self.quilityTable[itemData.quality]..".png"
            borderNode = display.newSprite(borderRes)
            :pos(iconNode:getContentSize().width/2,iconNode:getContentSize().height/2 - 4):addTo(iconNode)

            iconBack:pos(iconNode:getContentSize().width/2,iconNode:getContentSize().height/2 )
            :addTo(iconNode,-1)

            iconNode:setScale(0.92)


        
        end
        
        -- --名称
        if self.data then
            ui.newTTFLabel({text = self.data.name ,size =28,color = ccc3(141, 64, 25)})
                :pos(width/2,height*0.16):addTo(background,1)
        end
    end
   

    
end
--选中效果；


--长按点击事件：

--点击事件：
function IconItem:setTouchEvent(confirm)
    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(false)
    local moved , speed
    local scale = self:getScaleX()
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function ( event )
        if event.name == "began" then
            self:setTouchEnabled(false)
            moved = event
            transition.scaleTo(self, {time = 0.1 ,scale = scale*0.96})
        elseif event.name == "moved" then
            if math.abs(event.x - event.prevX) > 5 or math.abs(event.y - event.prevY) > 5 then
                speed = true
            end
        elseif event.name == "ended" then
            playUiSound(SOUND_PATH.sound)
            transition.scaleTo(self, {time = 0.1 ,scale = scale})
            if moved == nil then
                moved = event 
            end
            local dec = CCPoint(event.x,event.y):getDistance(CCPoint(moved.x,moved.y))
            if speed ~= true and dec <= 5 then
                -- 点击出现信息框
                if confirm then
                    confirm()
                    self:setTouchEnabled(true)
                end
            end
            speed = false
            self:setTouchEnabled(true)
        end
        return true
    end)
end 

-- 返回ID
function IconItem:getId()
    return self.id
end 


--数量更新；

function IconItem:updateCount(count)
    self.countLabel:setString(count)
end



return IconItem