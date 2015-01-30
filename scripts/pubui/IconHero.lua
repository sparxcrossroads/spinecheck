--
-- Author: 张伟超
-- Date: 2014-08-07 09:53:25
--

local IconHero = class("IconHero",function(params)
        return display.newNode()
    end)

function IconHero:ctor(params)

    self:createIcon(params)
end

--参数列表：
-- {
    --heroid  本地配表id
    --level
    --star
    --grade
-- }
function IconHero:createIcon(params)

    if not  params.heroid then
        return
    end

    local function getFile(path)
        if not isFileExistByPath(path) then
            return RES.."icon_item/item.png"
        else
            return path
        end
    end



    local node = display.newNode():addTo(self)
    display.newScale9Sprite(RES.."icon_border/border_grey.png",0,0,CCSizeMake(125, 125))
            :addTo(node,1)

    local iconRes = getFile(RES.."icon_hero/hero_"..params.heroid..".png")
    self.icon = display.newSprite(iconRes):addTo(node,2)


    local baorderRes = params.grade and RES.."icon_border/border_"..params.grade..".png" or RES.."icon_border/border_1.png"
    self.border = display.newSprite(baorderRes):scale(1.1):addTo(node,3)

    if params.level then
        self.levelbg = display.newSprite(RES.."public/icon_level_bg.png")
        :pos(self.border:getContentSize().width - 20 ,self.border:getContentSize().height -  20)
        :addTo(self.border)
        self.levelLb = ui.newTTFLabel({text = tostring(params.level),size = 20})
        :pos(self.levelbg:getContentSize().width/2,self.levelbg:getContentSize().height/2)
        :addTo(self.levelbg)
    end

    if params.star then
        self:refreshStarNum(params.star)
    end
end
--选中效果；
function IconHero:refreshStarNum(starNum)
    if self.stars and #self.stars > 0 then
        for _,v in pairs(self.stars) do
            v:removeFromParent()
        end
    end
    self.stars = {}
    local starSize = 22
    local w = self.border:getContentSize().width/2
    -- local px = w - (starNum-1) * (starSize/2)
    local px = starSize
    for i=1,starNum do
        local star = display.newSprite(RES.."public/battle_star.png")
        :pos(px + (i - 1) * starSize, starSize):addTo(self.border,4)
        self.stars[#self.stars + 1] = star
    end
end 

function IconHero:setGray()                 ----make  icon be gray
    self.icon:setColor(ccc3(100, 100, 100))
end 

return IconHero