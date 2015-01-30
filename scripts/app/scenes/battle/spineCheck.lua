-- 战斗测试
require "logic.battle.BattleConstants"
local BulletSprite = import(".BulletSprite")
local ShaderProgram = import(".ShaderProgram")

local tempFrameActRes = "resource/tempSkill_pic/"
local spinePath = "resource/spineBones/"
local resDir = spinePath.."1004"
local TransitionMoveSpeed = 180

local BattleBottomBar = require("app.scenes.battle.BattleBottomBar")

local spineTest = class("spineTest", function() 
	return display.newLayer() 
end)

local function addSpriteFrame(fileName)		
	local fileName = fileName 
	if device.platform ~= "ios" then
		display.addSpriteFramesWithFile(tempFrameActRes .. fileName .. ".plist", tempFrameActRes .. fileName .. ".png")
	else
		display.TEXTURES_PIXEL_FORMAT[tempFrameActRes .. fileName .. ".pvr.ccz"] = kCCTexture2DPixelFormat_PVRTC4
		display.addSpriteFramesWithFile(tempFrameActRes .. fileName .. ".plist", tempFrameActRes .. fileName .. ".pvr.ccz")
	end
end

local function readResFile()
	print("--feng-- "..device.writablePath)
    local file = io.open(device.writablePath .. "res/"..resDir..".json", "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end


function spineTest:ctor()
	local bg = display.newSprite("resource/bg/8007.png")
	bg:addTo(self,-1):align(display.CENTER, display.cx, display.cy)

	 self.spine = self:createSpine()
	 self:createAnimatonsBt(self.spine)	
	 self:createEffectTest(self.spine)
	-- self:createBT("fjdjf",{x=500,y=200},function ()	
	-- self:mapTest()
	-- self:particleTest()
	-- self:skillTest()
	-- self:fontTest()
	-- self:shaderTest()
end



function spineTest:createSpine()
	self.displayNode = display.newNode()
	local spine = SkeletonAnimation:createWithFile(resDir..".json",resDir..".atlas",0.5)
	spine:setSpeedScale(0.5)
	-- local pos = BattleConstants:anchToPosition({x=2,y=2})
	-- spine:align(display.BOTTOM_CENTER, pos.x, pos.y)
	-- spine:pos(200, 200)
	spine:pos(0, 0):addTo(self.displayNode)	
	spine:setMix("attack","damaged",0.2)
	spine:setMix("damaged","attack",0.2)
	spine:setMix("move","standby",0.2)
	spine:setMix("standby","move",0.2)

	
	-- self.displayNode:addTo(self):pos(pos.x, pos.y)
	self.displayNode:addTo(self):pos(200, 350)


	spine.startListener = function (trackIndex)
		printf("触发lua中startListener回调trackIndex=%d,trackName=%s\n", trackIndex,self.animations[trackIndex])
		local attackAnimation = {attack = 1, skill = 1, attack2 = 1, attack3 = 1}
		if attackAnimation[self.animations[trackIndex]] then

			-- self:createBaseEffect(spine)
		end
		
	end

	spine.endListener = function (trackIndex)
		if self.loop then
			local index = math.random(1,#self.animations)
			spine:setAnimation(index,self.animations[index],false)
		end
		printf("触发lua中endListener回调trackIndex=%d ,trackName=%s\n", trackIndex,self.animations[trackIndex])
	end

	spine.completeListener = function (trackIndex, loopcount)
		printf("触发lua中completeListener回调trackIndex=%d,loopcount=%d,trackName=%s\n",trackIndex,loopcount,self.animations[trackIndex])
	end

	spine.eventListener = function (trackIndex, event)
		printf("触发lua中eventListener回调:trackIndex=%d,event.name=%s,trackName=%s\n",trackIndex, event.name,self.animations[trackIndex])
		print_r(event)
		-- if self.animations[trackIndex] == "attack3" then
		-- 	local fileName = "end_AR_attack3" 
		-- 	display.addSpriteFramesWithFile(tempFrameActRes .. fileName .. ".plist", tempFrameActRes .. fileName .. ".png")
		-- 	local leftGridFrames = display.newFrames("end_AR_attack3_%02d.png", 1, 5)
		-- 	self.leftGridAnimation = display.newAnimation(leftGridFrames, 1/15)
			
		-- 	local placeHolder = display.newSprite(leftGridFrames[1])
		-- 	placeHolder:addTo(spine)
		-- 	placeHolder:align(display.CENTER, 0, 0)
		-- 	placeHolder:playAnimationOnce(self.leftGridAnimation,true)
		-- end		

	end

	return spine
end

function spineTest:createAnimatonsBt(spine)
	self.animations = {}
	local data = readResFile()
   	self.animations = table.keys(json.decode(data).animations)

	local i = 1
	-- 要检查的spine 骨骼动画
	spine_all={
	"move",
	"attack",
	"dead",
	"standby",
	"damaged",
	"victory",
	"skill",
	"attack2",
	"attack3",
	-- "i_add",
	}

	for k,v in pairs(self.animations) do
		self:createBT(v, {x=110 * i,y=150}, function ()
			spine:clearTracks()
			spine:setToSetupPose()
			spine:setAnimation(k,v,false)
		end)

		self:check_spine_name(v)

		i= i+1
	end

	-- 输出缺少的动作
	if(table.getn(spine_all)>=1) then
		local msg ="缺少 :"..table.concat(spine_all," ,")
		ui.newTTFLabel({text = msg, size = 24, color = display.COLOR_RED, align = ui.TEXT_ALIGN_CENTER})  
        :pos(display.cx, display.cy*1.2)  
        :addTo(self)  
	end

	print("--feng-- createAnimatonsBt")
	print_r(self.animations)
end

function spineTest:createBT(text,pos,callBack)
    cc.ui.UIPushButton.new(BattleUIRes.."battle_coinsbottom.png", {scale9 = true})
    :setButtonLabel(cc.ui.UILabel.new({text = text, size = 22, color = display.COLOR_WHITE}))
    :setButtonSize(100, 40)
    :onButtonClicked(callBack)
    :pos(pos.x,pos.y)
    :addTo(self,10)
end

function spineTest:createEffectTest(spine)	
	-- -- 遍历切换
	-- self:createBT("遍历", {x=220,y=100}, function ()
	-- 		spine:clearTracks()
	-- 		local index = math.random(1,#self.animations)
	-- 		spine:setAnimation(index,self.animations[index],false)
	-- 		self.loop = true
	-- 	end)

	-- 暂停
	self:createBT("暂停", {x=330,y=100}, function ()
			spine:pauseSchedulerAndActions()
			display.pause()	
		end)

	-- 继续
	self:createBT("继续", {x=440,y=100}, function ()
			spine:resumeSchedulerAndActions()
			display.resume()
		end)

	-- 重置
	self:createBT("重置", {x=550,y=100}, function ()
			spine:clearTracks()
			spine:setToSetupPose()
			spine:resumeSchedulerAndActions()
			self.displayNode:stopAllActions()
			self.displayNode:setPosition(200,350)
			self.loop = false
		end)

	-- 移动
	self:createBT("移动", {x=660,y=100}, function ()
		local actions = {
				CCCallFunc:create(function() spine:setAnimation(0,"move",true) end),
				CCMoveTo:create(1000 / TransitionMoveSpeed, ccp(1200, 350)),
			}
		self.displayNode:runAction(transition.sequence(actions))	
		end)


end

function spineTest:check_spine_name (v)
	local len=table.getn(spine_all)
	for i=1,len do
		if(v==spine_all[i]) then
			table.remove(spine_all,i)
		end
	end
end

return spineTest