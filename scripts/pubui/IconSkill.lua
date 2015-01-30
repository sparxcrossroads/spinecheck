--
-- Author: 张伟超
-- Date: 2014-08-07 09:53:25
--

local IconItem = class("IconItem",function(params)
        return display.newNode()
    end)

function IconItem:ctor(params)
    --bg
    if not self.bg then
        self.bg = display.newSprite(RES.."icon_border/border_grey.png"):scale(0.9):addTo(self,1)
    end
    --icon
    if params.skillid and not self.icon then
        local path = RES.."icon_skill/skill_"..params.skillid..".png"
        if not isFileExistByPath(path) then
            path = RES.."icon_skill/skill.png"
        end
        self.icon = display.newSprite(path):addTo(self,2)
    end
    --quility
    if not self.border then
        self.border = display.newSprite(RES.."icon_border/border_"..params.quility..".png"):scale(1.0):addTo(self,3)
    elseif self.quility ~= params.quility then
        
    end
end

function IconItem:setGray()
    self.icon:setColor(ccc3(100, 100, 100))
end 


return IconItem