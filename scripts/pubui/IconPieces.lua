--
-- Author: 张伟超
-- Date: 2014-08-07 09:53:25
--

local IconPieces = class("IconPieces",function(params)
        return display.newNode()
    end)

function IconPieces:ctor(params)

    local iconRes = nil
    local borderRes = nil
    self.id = params.id 
    self.type = params and params.type or 1

    if self.type ==  1 then
        iconRes = RES.."icon_hero/hero_"..self.id..".png"
        borderRes = RES.."bag/bag_suipianlan.png"
    else
        --todo
    end

    --裁剪
    local data = {}
    data.steRes = RES.."bag/bag_suipianmoban.png"
    data.clipRes = iconRes
    local node = getShaderNode(data):addTo(self)
    --外框：
    display.newSprite(borderRes):addTo(self)

end




return IconPieces