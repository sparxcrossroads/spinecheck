--
-- Author: 张伟超
-- Date: 2014-10-28 09:53:25
-- 简单的消息弹出框：
--

local PJMessage = class("PJMessage", function()
	return display.newColorLayer(ccc4(0, 0, 0, 200))
end)
-- {text = "",sure = function ,cancel = function}
function PJMessage:ctor(params)

	self:setTouchEnabled(true)
	self:addNodeEventListener(NODE_TOUCH_EVENT, function(event)end)

	self.params = params or {}
	
	local text = self.params.text or "error !" 
	local bg_dialog = display.newScale9Sprite(RES.."public/bg_white.png", display.cx, display.cy,CCSizeMake(555, 346))
	bg_dialog:setAnchorPoint(ccp(0.5, 0.5))
	self:addChild(bg_dialog)


	--line
    display.newScale9Sprite(RES.."public/battle_line.png",0,0,CCSizeMake(540, 2))
    :align(display.CENTER,555/2,bg_dialog:getContentSize().height * 0.18 + 45):addTo(bg_dialog)

    local whiteBack = display.newScale9Sprite(RES.."public/bg_white1.png",0,0,CCSizeMake(536, 210))
    :align(display.CENTER_TOP,555/2,bg_dialog:getContentSize().height - 10):addTo(bg_dialog)

	showAction(bg_dialog)
	local showTest = ui.newTTFLabel({
			text = text,
			size = 30,
			color = ccc3(60, 51, 45),
			align = ui.TEXT_ALIGN_CENTER,
		    valign = ui.TEXT_VALIGN_CENTER,
		    dimensions = CCSize(whiteBack:getContentSize().width*0.9, whiteBack:getContentSize().height*0.9)
		}):pos(bg_dialog:getContentSize().width/2,bg_dialog:getContentSize().height * 0.65)
		:addTo(bg_dialog)

	local posX = self.params.cancel and bg_dialog:getContentSize().width * 0.25 or bg_dialog:getContentSize().width/2
	local PJButton = require("pubui/PJButton")
	local nor = display.newSprite(RES.."public/button_orange.png")
	local sel = display.newSprite(RES.."public/button_orange_on.png")
    local button = PJButton.new({
        normal = nor,
        selected = sel,
        text = "确认",
        -- border = 2,
        callback = function() 
        	print(" == 确定：callback == ") 

        	self:runAction(transition.sequence({
				CCCallFunc:create(self.params.sure),
				CCRemoveSelf:create(),
			}))

        end
        })
    :pos(posX,bg_dialog:getContentSize().height * 0.18)
    :addTo(bg_dialog)

	if self.params.cancel then
		local nor = display.newSprite(RES.."public/button_orange.png")
		local sel = display.newSprite(RES.."public/button_orange_on.png")
	    local button = PJButton.new({
	        normal = nor,
	        selected = sel,
	        text = "取消",
	        -- border = 2,
	        callback = function() 
	        	print(" == 取消：callback == ") 
		        self:runAction(transition.sequence({
					CCCallFunc:create(self.params.cancel),
					CCRemoveSelf:create(),
				}))
	        end
	        })
	    :pos(bg_dialog:getContentSize().width * 0.75,bg_dialog:getContentSize().height * 0.18)
	    :addTo(bg_dialog)
	end
end 

function PJMessage:showPanel()

end 

return PJMessage