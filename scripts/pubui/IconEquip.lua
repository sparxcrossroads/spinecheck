--
-- Author: 张伟超
-- Date: 2014-08-07 09:53:25
--

local IconEquip = class("IconEquip",function(params)
        return display.newNode()
    end)

function IconEquip:ctor(params)
    self.params = params or {}
    self.quality = self.params.quality or 0
    self.star = self.params.star or 0
    self:refreshIcon(params)
end

--刷新方法：
function IconEquip:refreshIcon(params)
    --bg
    if not self.bg then
        self.bg = display.newSprite(RES.."icon_border/border_grey.png"):addTo(self,1)
    end
    --icon
    print("图像icon ====== ",RES.."icon_hero/hero_"..params.id..".png")
    if params.id and not self.icon then
        self.icon = display.newSprite(RES.."icon_hero/hero_"..params.id..".png"):addTo(self,2)
    end
    --quality
    if not self.border then
        self.border = display.newSprite(RES.."icon_border/border_"..params.quality..".png"):addTo(self,3)
    elseif self.quality ~= params.quality then
        
    end
    -- star 调试阶段，如果英雄列表中没有该对应id
    self:refreshStarNum(params.star)
end
--选中效果；
function IconEquip:refreshStarNum(starNum)
    if self.stars and #self.stars > 0 then
        for _,v in pairs(self.stars) do
            v:removeFromParent()
        end
    end
    self.stars = {}
    local starSize = 22
    local w = self.border:getContentSize().width/2
    local px = w - (starNum-1) * (starSize/2)
    for i=1,starNum do
        local star = display.newSprite(RES.."public/battle_star.png")
        :pos(px + (i - 1) * starSize, starSize/2):addTo(self.border,4)
        self.stars[#self.stars + 1] = star
    end
end 
--长按点击事件：



return IconEquip