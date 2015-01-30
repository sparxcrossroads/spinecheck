--PJTips.lua
--消息提示


local PJTips = class("PJTips", function()
	return display.newNode()
end)
-- {text = "",func = function }
function PJTips:ctor(params)

	self.params = params or {}
	
	local text = self.params.text or "error !" 


	local textLabel = ui.newTTFLabel({text = text ,size = 26,font = JING_FONT})
	local width = textLabel:getContentSize().width + 80
	local height = textLabel:getContentSize().height + 40
	--等待UI更替
	local bg_dialog = display.newScale9Sprite(RES.."public/tip_bg.png",0,0,CCSizeMake(width, height))
	:addTo(self)
	textLabel:addTo(bg_dialog)
	textLabel:setPosition(ccp(width/2,height/2))
	bg_dialog:setTouchEnabled(true)
	bg_dialog:setOpacity(0)


	
	local timeCount = 0
	bg_dialog:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function ( dt )
		timeCount = timeCount + dt 
		if timeCount > 1 then
			bg_dialog:unscheduleUpdate()
			transition.fadeOut(bg_dialog, {time = 0.5,onComplete = function (  )
				if self.params.func then
					self.params.func()
				end
				self:removeSelf()
			end})
		end
	end)
	transition.fadeIn(bg_dialog, {time = 0.5,onComplete = function (  )
		bg_dialog:scheduleUpdate()
	end})

end 


return PJTips