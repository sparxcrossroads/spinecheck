-- 战斗测试
require "logic.battle.BattleConstants"
local BulletSprite = import(".BulletSprite")
local ShaderProgram = import(".ShaderProgram")

local tempFrameActRes = "resource/tempSkill_pic/"
local spinePath = "resource/spineBones/"
local resDir = spinePath.."1015"
local TransitionMoveSpeed = 180
local GlobalRes = "resource/ui_rc/global/"
local battleRes = "resource/ui_rc/battle/"
local skillEffectRes = "resource/skillEffect/"

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

function spineTest:createBT(text,pos,callBack)
    cc.ui.UIPushButton.new(BattleUIRes.."battle_coinsbottom.png", {scale9 = true})
    :setButtonLabel(cc.ui.UILabel.new({text = text, size = 22, color = display.COLOR_WHITE}))
    :setButtonSize(100, 40)
    :onButtonClicked(callBack)
    :pos(pos.x,pos.y)
    :addTo(self,10)
end

function spineTest:ctor(params)
	local bg = display.newSprite("resource/bg/8007.png")
	bg:addTo(self,-1):align(display.CENTER, display.cx, display.cy)

	self.spine = self:createSpine()
	self:createAnimatonsBt(self.spine)	
	-- self:createEffectTest(self.spine)
	-- self:createBT("fjdjf",{x=500,y=200},function ()	
	-- self:mapTest()
	-- self:particleTest()
	-- self:skillTest()
	-- self:fontTest()
	-- self:shaderTest()
end

function spineTest:shaderTest()
	-- FrozenShader 冰冻
	-- Blur 模糊
	-- InvisibleShader 隐形
	-- BanishShader 放逐
	-- PoisonShader 中毒
	-- StoneShader 石化
	-- IceShader 冰雪
	-- GrayScalingShader 灰阶
	local sharders ={
		"Blur",
		"BanishShader",
		"FireShader",
		"FrozenShader",
		"GrayScalingShader",
		"IceShader",
		"InvisibleShader",
		"MirrorShader",
		"PoisonShader",
		"StoneShader",
		"VanishShader",
	}
	local x = 30
	for k,v in pairs(sharders) do		
		local spine = SkeletonAnimation:createWithFile(resDir..".json",resDir..".atlas",0.5)
		spine:addTo(self):pos(x, 250)
		ui.newTTFLabel({text = v,size = 15 ,shadowColor = ccc3(91, 90, 90)}):addTo(self):align(display.CENTER, x, 200)
		local sharder = ShaderProgram.init(v)
		spine:setShaderProgram(sharder)
		x = x+120
	end

	local bg = display.newSprite("resource/bg/8007.png"):addTo(self):pos(display.cx, display.cy+200):scale(0.2)
	bg:setShaderProgram(ShaderProgram.init("IceShader"))
	self:createBT("clear", {x=400,y=100}, function ()
        bg:setShaderProgram(ShaderProgram.clear())
	end)

end

function spineTest:clipnodeTest()
	display.newRect(100, 100):addTo(self):pos(display.cx-300,display.cy,{color = ccc3(255,0,0)})
	display.newRect(200, 200):addTo(self):pos(display.cx-300,display.cy,{color = ccc3(255,0,0)})

	display.newRect(100, 100):addTo(self):pos(display.cx,display.cy,{color = ccc3(255,0,0)})
	display.newRect(200, 200):addTo(self):pos(display.cx,display.cy,{color = ccc3(255,0,0)})
	display.newRect(400, 400):addTo(self):pos(display.cx,display.cy,{color = ccc3(255,0,0)})


	display.newRect(100, 100):addTo(self):pos(display.cx+300,display.cy,{color = ccc3(255,0,0)})
	display.newRect(200, 200):addTo(self):pos(display.cx+300,display.cy,{color = ccc3(255,0,0)})

	local start  = {x=display.cx,y=display.cy}
	local destination = {x=display.cx+100,y=display.cy+300}

	local angle =  ccp(start.x - destination.x , start.y - destination.y):getAngle()
	angle = 180-angle * 180 / math.pi
	local distance = ccp(start.x,start.y):getDistance(ccp(destination.x,destination.y))	
	print("display"..distance.."angle "..angle.."height"..destination.y-start.y)										
	local clipnode = display.newClippingRegionNode(cc.rect(0,0,distance,math.abs(destination.y-start.y)))
	clipnode:addTo(self):pos(start.x,start.y)
	clipnode:setRotation(angle)

	self.camp = "right"
	self.direction = -1
	local time =0.5

	local sx,sy,dx,dy = display.cx+200,display.cy+100,display.cx,display.cy+100
	local angle =  ccp(sx - dx , sy - dy):getAngle()
	angle = 180-angle * 180 / math.pi
	local distance = ccp(sx,sy):getDistance(ccp(dx,dy))	
	local x1 = sx-dx>=0 and -1 or 0
	local clipnode = display.newClippingRegionNode(cc.rect(distance*x1,-240,distance,480))

	clipnode:addTo(self):pos(sx+200,sy)
	display.newSprite("123.jpg"):addTo(clipnode,-1):setScale(3)
	display.newSprite(BattleUIRes.."battle_coins.png"):addTo(clipnode,2):pos(0,0)

	self:createBT("fjdjf",{x=200,y=300},function ()
		local bulletSprite =  BulletSprite.new() 
		bulletSprite:setRotation(angle)
		bulletSprite:addTo(clipnode,10):pos(0,0)
		transition.moveTo(bulletSprite,{x = dx -sx,y=dy-sy,time =time,onComplete = function()
			transition.moveTo(bulletSprite,{x = 0,y=0,time =time,onComplete = function()
					bulletSprite:removeSelf()
				end})
		end})
	end)
end


function spineTest:fontTest()
	local font = "resource/ui_rc/battle/font/fontY.fnt"
	local critTips = ui.newBMFontLabel({
		text = "+111222333444555666-77890000555888999",
		font = font })		
	critTips:pos(display.cx,display.cy):addTo(self)
	local spine = self:createSpine()
	self:createAnimatonsBt(spine)	
	self:createEffectTest(spine)
	-- self:mapTest()
end

function spineTest:skillTest()
	-- /Users/feng/Documents/newbattle/res/resource/Weigong/skeleton.json
	-- local testDir = "resource/Weigong/skeleton"
	-- self.displayNode = display.newNode()
	-- local spine = SkeletonAnimation:createWithFile(testDir..".json",testDir..".atlas",1)
	-- spine:setSpeedScale(0.5)
	-- spine:setAnimation(1,"animation", true)
	-- spine:pos(0, 0):addTo(self.displayNode)	
	-- self.displayNode:addTo(self):pos(display.cx,display.cy)

	-- self.particle = CCParticleSystemQuad:create("resource/particle/particle001.plist");
	-- local node = CCParticleBatchNode:createWithTexture(self.particle:getTexture())
	-- node:addTo(self):pos(-400,display.cy)
	-- self.particle:addTo(node,1)


	-- self.particle2 = CCParticleSystemQuad:create("resource/particle/Untitled 2.plist");
	-- local node2 = CCParticleBatchNode:createWithTexture(self.particle2:getTexture())
	-- node2:addTo(self):pos(-300,display.cy)
	-- self.particle2:addTo(node2,1)


	-- self.particle3 = CCParticleSystemQuad:create("resource/particle/Untitled 2.plist");
	-- local node3 = CCParticleBatchNode:createWithTexture(self.particle3:getTexture())
	-- node3:addTo(self):pos(-300,display.cy)
	-- self.particle3:addTo(node3,1)

	-- self.particle2 = CCParticleSystemQuad:create("resource/particle/Untitled 2.plist");
	-- self.particle2:addTo(self,20):pos(-50,display.cy):scale(1.0)

	-- local particle3 = CCParticleSystemQuad:create("resource/particle/Untitled 3.plist");
	-- particle3:addTo(self,30):pos(0,display.cy)

	-- m_pParticleSystem = new CCParticleSystemQuad();
	-- CCParticleBatchNode* pBatchNode = CCParticleBatchNode::create((CCTexture2D*)NULL, 16000);
	-- addChild(m_pBatchNode);
	-- m_pParticleSystem->initWithFile("Particles/LavaFlow.plist");
	-- m_pBatchNode->setTexture(m_pParticleSystem->getTexture());
	-- m_pBatchNode->addChild(m_pParticleSystem);
	-- m_pParticleSystem->setPosition(500, 300);

	local fileName = "end_100502"
	self:createBT("png2", {x=400,y=100}, function ()
		local spine = SkeletonAnimation:createWithFile(skillEffectRes..fileName..".json",skillEffectRes..fileName..".atlas",1)
		spine:setSpeedScale(0.5)
		spine:pos(display.cx, display.cy):addTo(self)
		spine:setAnimation(888,"animation",true)
		spine.endListener = function (trackIndex)
			spine:removeSelf()
		end

	end)
end

function spineTest:particleTest()
	-- auto plistData = FileUtils::getInstance()->getValueMapFromFile("Particles/emissionPart.plist");  
	-- auto emission_frame = SpriteFrame::create("Images/engine.jpg", Rect(0,0,25,32));   
	-- auto emitter = ParticleSystemQuad::create(plistData, emission_frame);  
	-- _background->addChild(_emitter, 10); /Users/feng/Documents/newbattle/res/resource/particle/a.plist
	local particle = CCParticleSystemQuad:create("resource/particle/a.plist");
	particle:addTo(self.spine:findBone("bone34")):pos(0,100)
end

function spineTest:nodeTest()

	local space = 20
	local width = 100
	local offsetX = 0
	local heros = display.newSprite()
	for i=0,1 do
		cc.ui.UIPushButton.new(battleRes.."battle_coinsbottom.png", {scale9 = true})
    :setButtonLabel(cc.ui.UILabel.new({text = tostring(i), size = 22, color = display.COLOR_WHITE}))
    :setButtonSize(100, 40)
    :pos(120*i,0)
    :addTo(heros,10)
    offsetX = i*(width/2 + space/2)
	end
	local bW,bH = heros:getContentSize().width,heros:getContentSize().height
	print(bW.."..."..bH)
	heros:setColor(display.COLOR_RED)
	heros:addTo(self):pos(display.cx-offsetX, display.cy)
    
	local placeHolder = display.newSprite(BattleUIRes.."battle_coins.png")
		:addTo(self):pos(display.cx,display.cy)
end



function spineTest:mapTest()

	self.rowCount = BattleConstants.RowMax
	self.colCount = BattleConstants.ColMax
	self.FormationPositions = BattleConstants:generateMap()

	for col = -self.colCount,self.colCount  do
		for row = -self.rowCount, self.rowCount do	
			local placeHolder = display.newSprite(battleRes .. "battle_coins.png")
			placeHolder:addTo(self,-1)
			placeHolder:align(display.CENTER, self.FormationPositions[col][row].x, self.FormationPositions[col][row].y)
			placeHolder:scale(0.4)
			ui.newTTFLabel({text = string.format("(%d,%d)",col,row), size = 40})
						:addTo(placeHolder)		
			self.FormationPositions[col][row].placeHolder = placeHolder
		end
	end

	local testPos = {{400,400},{450,400},{500,400},{550,400},{600,400},{700,400},{800,400},{500,350},{500,400},{500,250},{600,250}}
	for k,v in pairs(testPos) do
		local placeHolder = display.newSprite(battleRes .. "battle_coins.png")
		placeHolder:addTo(self)
		placeHolder:pos(v[1], v[2])
		placeHolder:scale(0.4)
		ui.newTTFLabel({text = string.format("(%d,%d)",BattleConstants:positionToAnch(v[1],v[2])), size = 40,color = display.COLOR_RED})
			:addTo(placeHolder)
	end	
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

-- 自动创建各个动画播放按钮
-- 移动 move
-- 普通攻击 attack 
-- 死亡 dead
-- 待机  standby
-- 受击 damaged
-- 胜利 victory 
-- 大招 手动释放耗蓝 skill 
-- 自动释放不耗蓝
-- 技能1 attack2
-- 技能2 attack3
-- 技能3 attack4
function spineTest:createAnimatonsBt(spine)
	self.animations = {}
	local data = readResFile()
   	self.animations = table.keys(json.decode(data).animations)

	local i = 1
	for k,v in pairs(self.animations) do
		self:createBT(v, {x=110 * i,y=150}, function ()
			spine:clearTracks()
			spine:setToSetupPose()
			spine:setAnimation(k,v,false)
		end)		
		i= i+1
	end

	print("--feng-- createAnimatonsBt")
	print_r(self.animations)
end

-- 创建底座光圈特效
function spineTest:createBaseEffect(spine)
	local totem = "totem" 
	display.addSpriteFramesWithFile(tempFrameActRes .. totem .. ".plist", tempFrameActRes .. totem .. ".png")	
	local totemFrames = display.newFrames("totem%04d.png", 1, 17)
	self.totemAnimation = display.newAnimation(totemFrames, 1/15)	
	local totemPlaceHolder = display.newSprite(totemFrames[1])
	totemPlaceHolder:addTo(spine,-1):align(display.CENTER, 0, 0)
	totemPlaceHolder:playAnimationOnce(self.totemAnimation,true)	
end

-- 创建其他测试按钮
function spineTest:createEffectTest(spine)	
	-- 遍历切换
	self:createBT("遍历", {x=220,y=100}, function ()
			spine:clearTracks()
			local index = math.random(1,#self.animations)
			spine:setAnimation(index,self.animations[index],false)
			self.loop = true
		end)

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

return spineTest