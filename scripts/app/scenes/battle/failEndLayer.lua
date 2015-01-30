--
-- content:结算：
--
local failEndLayer = class("failEndLayer", function()
    return display.newColorLayer(ccc4(0, 0, 0, 255*0.8))
end)
local PJButton = require("pubui/PJButton")


function failEndLayer:ctor(params)
	self:setNodeEventEnabled(true)
	self:setTouchEnabled(true)
   	print(" == 结算失败 == ")

   	self.sceneIndex = params.sceneId

   	self.BattleType = params.BattleType

   	

   	
end

function failEndLayer:onEnter()
	self:createUi()
	playUiSound(SOUND_PATH.lost)
end


function failEndLayer:createUi()
	display.newSprite(RES.."end/end_title_fail.png"):pos(665,590):addTo(self)
	display.newSprite(RES.."end/end_title.png"):pos(665,610):addTo(self)

	

	local back = display.newScale9Sprite(RES.."public/bg_grey2.png", 665,345, CCSizeMake(714, 265)):addTo(self)

	ui.newTTFLabel({text = "前往提升战力",size = 30 ,font = JING_FONT,}):align(display.LEFT_CENTER,30,217)
	:addTo(back)


	local Stable = {"英雄升级","装备强化","英雄进阶"}
	local Itable = {"lvup","equp","gradeup"}
	for i=1,3 do

		local button = PJButton.new({
	        normal = display.newSprite(RES.."end/end_"..Itable[i]..".png"),
	        isAction = "scale",
	        text = Stable[i],
	        outlineColor = ccc3(255, 255, 255),
	        color = ccc3(255, 0, 0),
	        size = 30,
	        font = JING_FONT,
	        border = 1,
	        borderColor = ccc3(255,255,255),
	        callback = function()
	        	print("")
	        	if i == 1 then
	        		uiData.bottomIndex = 1
	        		switchScene("home")
	        	elseif i == 2 then
	        		uiData.bottomIndex = 6
	        		switchScene("armory")
	        	elseif i == 3 then
	        		uiData.bottomIndex = 1
	        		switchScene("home")
	        	end
	    	
	    	end
	        })
		:pos(714/2 + (i-2)*170,100)
	    :addTo(back)

	    button:setFontPosAddition(0,-45)
	end



	

	-- ui_reset
	local resetButton = PJButton.new({
        normal = display.newSprite(RES.."public/ui_exit.png"),
        isAction = "scale",
        callback = function()
        	print("退出")
        	if self.BattleType == "pvp" then
        		switchScene("pvp" )
        	else
        		switchScene("carbon",{index = self.sceneIndex})
        	end
        	
    	end
        })
	:pos(1130,140)
    :addTo(self)



    --ren
    display.newSprite(RES.."scene/scene_role.png"):align(display.BOTTOM_CENTER,140,0):addTo(self)

    --xian,posx = 674,width = 650
   	-- display.newSprite(filename, x, y, params) 
end


function failEndLayer:onExit()
end

return failEndLayer
