--
-- Author: 张伟超
-- Date: 2014-10-28 09:53:25
-- 简单的progress：
--

local PJProgress = class("PJProgress", function(file)
	return display.newNode()
end)
--竖版和圆形有需求时扩展；
function PJProgress:ctor(file)

	self.progress = display.newSprite(file):align(display.CENTER_LEFT, 0, 0):addTo(self)
	self.scale = self.progress:getScaleX()
end 

function PJProgress:setPercent(percent)
	local p = percent > 100 and 100 or percent
	self.progress:setScaleX(self.scale * percent/100)
end

--添加个计时器弄下冬天增减；

return PJProgress