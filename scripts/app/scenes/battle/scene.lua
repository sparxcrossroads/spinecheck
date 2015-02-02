

local spinecheck = import(".spinecheck")
local check = 1

local scene = class("scene", function(params)
	return display.newScene("scene")
end)

function scene:ctor(params)
	
end


function scene:onEnter()
	if check then
		self.battleView =spinecheck.new()
		self.battleView:pos(0, 0):addTo(self)
		print("--feng-- onEnter()")
		return
	end
end

function scene:onExit()
	print("scene:onExit")
	self:unscheduleUpdate()
end

return scene