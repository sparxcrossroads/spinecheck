local SoldierView = class("SoldierView", function()  
	return display.newNode()
end)
local scheduler = require("framework.scheduler")
local IconItem = require("pubui.IconItem")

local BulletSprite = import(".BulletSprite")
local SkillSprite = import(".SkillSprite")
local SoldierTip = import(".SoldierTip")
local ShaderProgram = import(".ShaderProgram")


SoldierView.HP_EVENT     	= "SoldierView_HP_EVENT"
SoldierView.ENERGE_EVENT 	= "SoldierView_ENERGE_EVENT"
SoldierView.DEATH_EVENT 	= "SoldierView_DEATH_EVENT"
SoldierView.SKILL_EVENT 	= "SoldierView_SKILL_EVENT"
SoldierView.DANGER_EVENT 	= "SoldierView_DANGER_EVENT"

local indexToName = {
	[1] =	"attack",				--普攻技能
	[2] =	"dead",					--死亡
	[3] =	"standby",				--闲置
	[4] =	"damaged",				--受伤
	[5] =	"victory",				--胜利
	[6] =	"skill",				--大招
	[7] =	"attack2",				--被动技能a
	[8] =	"attack3",				--被动技能b
	[9] =	"attack4",				--被动技能c
	[10] = 	"move"					--移动
}

function SoldierView:ctor(params)
    cc.GameObject.extend(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.params = params
	self.camp = params.camp       --所属阵营
	self.index = params.index     --在队伍中的编号
	self.direction = self.camp == "left" and 1 or -1    --朝向 1朝右, -1朝左
	self.battleView = params.battleView
	self.csvData = params.csvData
	self.maxhp = params.maxhp
	self.curhp = params.curhp
	self.curenergy = params.curenergy
	self.anchPoint = params.anchPoint
	self.currentAction = 3
	self.typeId = params.typeId
	self.isSummon = params.isSummon

	self:createSpine()
	--根据朝向决定是否翻转
	self:actionFlip()

	self.tip = SoldierTip.new(self):addTo(self)

	--带碰撞检测的子弹, key为子弹id, value位子弹对应Sprite
	self.bulletMovingMap = {}
end

function SoldierView:createSpine()
	local resDir = "resource/spineBones/"..tostring(self.csvData.typeId)
	if not isFileExistByPath(resDir..".json") then
		print(resDir.."资源不存在，用1001代替")
		resDir = "resource/spineBones/1001"
	end
	self.scale = 0.5
	self.sprite = SkeletonAnimation:createWithFile(resDir..".json",resDir..".atlas",self.scale)
	self.sprite:setSpeedScale(0.5)
	self.sprite:addTo(self)
	self.sprite.loop = false
	if self.params.isSummon and string.len(params.csvData.shader) >0  then
		local sharder = ShaderProgram.init(params.csvData.shader)
		self.sprite:setShaderProgram(sharder)
	end

	self.sprite.completeListener = function (trackIndex)
		if trackIndex == 2 then -- 死亡回调
			transition.fadeOut(self.sprite,{time = 1,onComplete = function ()
				self.sprite:setVisible(false)
			end})
		else
			if self.sprite.loop then
				self:playAnimation(indexToName[trackIndex],true)
			else
				self:playAnimation("standby",true)
			end
		end		
	end	
end

function SoldierView:playAnimation(name,loop)
	self.sprite:clearTracks()
	if self.currentAction ~= 3 and self.currentAction ~= 10 then
		self.sprite:setToSetupPose()
	end

	local loop = loop or false
	self.sprite.loop = loop
	self.currentAction = table.indexof(indexToName,name)
	self.sprite:setAnimation(self.currentAction,name,false)
end

--武将翻转
function SoldierView:actionFlip()
	local fRotationY = self.direction == -1 and 180 or 0
	self:setRotationY(fRotationY)
end

function SoldierView:releaseTalentSkill()
	self.battleView.super.releaseTalentSkill(self.camp,self.index) --通知逻辑层
end

--主要用于播放人物的骨骼动画
function SoldierView:doAction(action, params)
	if action == "attack" or action == "attack2" or action == "attack3"or action == "skill"then
		if params.launchRes then
			scheduler.performWithDelayGlobal(function ()
				local skillSprite = SkillSprite.new(params.launchRes,self)
		    end,params.launchDelay/1000)
		end
	end

	if action == "attack" then
		self:playAnimation("attack")
	elseif action == "attack2" then
		self:playAnimation("attack2")
	elseif action == "attack3" then
		self:playAnimation("attack3")
	elseif action == "attack4" then
		self:playAnimation("attack4")
	elseif action == "move" then
		self:playAnimation("move", true)
	elseif action == "damaged" then	--被打断
		self.sprite:clearTracks()
		self:playAnimation("damaged")
	elseif action == "dead" then
		self:onDrop()
		self.sprite:setSpeedScale(0.5)
		self.sprite:resumeSchedulerAndActions()
		for k,bullet in pairs(self.bulletMovingMap) do
			if bullet then
				bullet:removeSelf()
                table.remove(self.bulletMovingMap, k)
			end
		end
		if self.tip then
			self.tip:removeSelf()
			self.tip = nil
		end		
		self:dispatchEvent({name = self.DEATH_EVENT,params = params})
		self:playAnimation("dead")
	elseif action == "victory" then
		if self.tip then
			self.tip:removeSelf()
			self.tip = nil
		end	
	elseif action == "skill" then
		self:playAnimation("skill")
		self.battleView:releaseSkill(self.camp,self.index) --通知视图层
		local skillSprite = SkillSprite.new(params.endRes,self,nil,params.resScale)
		local count = params.shakeTime/100
		if count > 0 then
			shakeScene({count = count})
		end
	elseif action == "standby" then
		self:playAnimation("standby",true)
	end
end

function SoldierView:onDrop()
	local items = self.battleView.params.pbData.fightItems
	if items and #items >0 then
		print("onDrop")
		for k,v in pairs(items) do
			print("diaoluo"..v.heroId)
			if v.heroId == self.csvData.typeId then
				local count = 0
				for k,v in pairs(v.items) do
			        print("onDrop  id"..v.id.."count"..v.count)
			        if v.id == 101 then
			        	self.battleView.topBar:addCoin(v.count)
			        else
			        	for i=1,v.count do
			        		count = count + 1
				        	local pos = BattleConstants:anchToPosition(self.anchPoint)
							local itemBtn  = cc.ui.UIPushButton.new(BattleUIRes .. "baoxiangdiaoluo.png")
								:addTo(self.battleView,ZOrder.battleUI):pos(pos)
								:onButtonClicked(function(params)
									table.removebyvalue(self.battleView.dropItems, params.target)
									params.target:removeSelf()
									local item = IconItem.new({itemid = v.id})
									item:pos(pos):addTo(self.battleView,ZOrder.battleUI):setScale(0.5)
									item:runAction(transition.sequence({
									    CCEaseBackIn:create(CCMoveTo:create(0.5, ccp(1150,display.cy+320))),
									    CCRemoveSelf:create(),
									    CCCallFunc:create(function ()
									    	self.battleView.topBar:addItem(1)
									    end)
									}))
								end)
							local x = 100*math.floor(count/2)*(count%2 == 1 and -1 or 1)
							itemBtn:runAction(transition.sequence({
							    CCEaseBackIn:create(CCMoveBy:create(0.5, ccp(x, -60))),
							}))
							table.insert(self.battleView.dropItems, self.btIndex)
				        end
			        end
			    end
			end
		end
	end
end
--notify定义 : 
--		move 更新soldier位置
--		hurt 播放冒血/吸血/治疗/闪避 数字 or 文字
--		shoot 新建子弹(不带碰撞检测)
--		shootMovingCreate 创建一枚带碰撞检测的子弹
--		shootMovingMove   更新子弹位置
--		shootMovingDestroy 销毁子弹
--		needFlip	武将转身

function SoldierView:onNotify(notify, params)
	if notify == "move" then
		local moveInfo = params
		if moveInfo.moveType == "walk" then
			if self.currentAction ~= 10 then
				self:playAnimation("move", true)
			end
		end

		if moveInfo.moveType == "spread" and self.currentAction == 3 then
			self:playAnimation("move", true)
		end
		self:pos(BattleConstants:anchToPosition(moveInfo.anchPoint))
			:zorder(ZOrder:anchZorder(moveInfo.anchPoint))
	elseif notify == "Health" then
		if self.tip then
			self.tip:onHurt(params)
			self:dispatchEvent({name = self.HP_EVENT,params = params})
		end		
	elseif notify == "shoot" then
		self:onBulletCreate(params)
	elseif notify == "Energe" then
		self:dispatchEvent({name = self.ENERGE_EVENT,params = params})
		if params.effect == "killSomeOne" and self.tip then
			self.tip:killReward(params)
		end
	elseif notify == "canReleaseBigSkill" then
		self:dispatchEvent({name = self.SKILL_EVENT,params = params})
	elseif 
		notify == "shootMovingCreate" or
		notify == "shootMovingMove" or
		notify == "shootMovingDestroy" then
		local notifyAction = string.sub(notify, 12, #notify)
		local bulletMovingInfo = params
		self:onShootMoving(notifyAction, bulletMovingInfo)
	elseif notify == "needFlip" then
		self.direction = self.direction * -1
		self:actionFlip()
	elseif notify == "knockHeight" then	--击飞
		local knockHeightInfo = params
		--print("击飞逻辑帧数:"..knockHeightInfo.totalFrameCnt)
		--print("飞起高度:"..knockHeightInfo.height)
		--ToDo:需要根据以上两个值在表现层播放击飞效果
		print("击飞效果待实现")
	elseif notify == "buffadd" and self.tip then
		self.tip:addBuff(params)
		if string.len(params.csvData.shader) >0 then			
			local sharder = ShaderProgram.init(params.csvData.shader)
			self.sprite:setShaderProgram(sharder)
			self.sprite:setSpeedScale(params.csvData.speed)
			if params.csvData.speed == 0 then
				self.sprite:pauseSchedulerAndActions()
			end
		end
	elseif notify == "buffdel" and self.tip then
		self.tip:removeBuff(params)
		if string.len(params.csvData.shader) >0 then
			local sharder = ShaderProgram.clear()
			self.sprite:setShaderProgram(sharder)
			self.sprite:setSpeedScale(0.5)
			self.sprite:resumeSchedulerAndActions()
		end
	elseif notify == "buffmiss" and self.tip then
		-- self.tip:showWordTip(params)
		print("buffmiss 待实现。。。。")
	else
		print("SoldierView收到了未处理的消息:"..tostring(notify))
		print_r(params, 2)
	end
end

function SoldierView:setSkillEnable(enable)
	self:dispatchEvent({name = self.SKILL_EVENT,params = enable})
end


--region begin 操作带碰撞检测的子弹接口
function SoldierView:onShootMoving(notify, bulletMovingInfo)
	if notify == "Create" then
		local angle =  ccp(bulletMovingInfo.movingVec.x, bulletMovingInfo.movingVec.y):getAngle()			--向量角度(弧度)
		angle = 360 - angle * 180 / math.pi																	--数字角度
		local bulletSprite = BulletSprite.new(bulletMovingInfo.csvData.res)
		local fixedYAnchPoint = {x = bulletMovingInfo.curAnchPoint.x,y=bulletMovingInfo.curAnchPoint.y+bulletMovingInfo.csvData.oppositeY1}
		local curPosition = BattleConstants:anchToPosition(fixedYAnchPoint)
		bulletSprite:pos(curPosition.x, curPosition.y):addTo(self.battleView,ZOrder:anchZorder(self.anchPoint)):setRotation(angle)
		self.bulletMovingMap[bulletMovingInfo.objectId] = bulletSprite
		return
	end

	local bulletSprite = self.bulletMovingMap[bulletMovingInfo.objectId]

	if not bulletSprite then
		print("不存在对应的子弹id:"..bulletMovingInfo.objectId)
		print(debug.traceback())
		return
	end

	if notify == "Move" then
		local fixedYAnchPoint = {x = bulletMovingInfo.curAnchPoint.x,y=bulletMovingInfo.curAnchPoint.y+bulletMovingInfo.csvData.oppositeY1}
		local curPosition = BattleConstants:anchToPosition(fixedYAnchPoint)
		bulletSprite:pos(curPosition.x, curPosition.y)
		return
	end

	if notify == "Destroy" then
		bulletSprite:removeSelf()
		self.bulletMovingMap[bulletMovingInfo.objectId]= nil
		return
	end

	print("never come to here!!!")
	print(debug.traceback())
end
--region end

function SoldierView:onBulletCreate(bulletInfo)
	local bullet = bulletInfo.csvData

	local target = self.battleView[bulletInfo.targetCamp.."Soldiers"][bulletInfo.targetIndex]
	if bullet.launchRes then
		local skillSprite = SkillSprite.new(bullet.launchRes,target)
	end

	if bullet.bulletType == 0 then				--隐形子弹
		local target = self.battleView[bulletInfo.targetCamp.."Soldiers"][bulletInfo.targetIndex]
	    local skillSprite = SkillSprite.new(bullet.endRes,target)
		return
	end

	local targetPosition = BattleConstants:anchToPosition({x=bulletInfo.targetAnchPoint.x - bullet.oppositeX2 * self.direction ,y=bulletInfo.targetAnchPoint.y+bullet.oppositeY2})
	local sx, sy = self:getPosition() --子弹初始坐标
	sx=sx+BattleConstants.cellSize*bullet.oppositeX1 * self.direction
	sy=sy+BattleConstants.cellSize*bullet.oppositeY1
	local dx, dy = targetPosition.x, targetPosition.y       --子弹终点坐标
	local time = bulletInfo.flyFrameCnt * 2 / 60			--飞行时间

	if bullet.bulletType == 1 then		--直线
		print("类型为1的子弹已改为碰撞检测类子弹!!!")
		print(debug.traceback())
		return
	end

	--抛物线
	if bullet.bulletType == 2 then 
		local gridCnt = bulletInfo.flyFrameCnt * bulletInfo.flyFrameCnt * BattleConstants.ConstantG / 8	--抛物线的格子高度
		local h = gridCnt * BattleConstants.cellSize													--抛物线的像素高度

		local bulletSprite = BulletSprite.new(bullet.res)
		bulletSprite:pos(sx, sy):addTo(self.battleView,ZOrder:anchZorder(self.anchPoint))
		
		local array = CCArray:create()
		array:addObject(MyParabola:create(time, ccp(sx,sy), ccp(dx, dy), h))
		bulletSprite:runAction(transition.sequence({
			CCSpawn:create(array),
			CCRemoveSelf:create(),
			CCCallFunc:create(function ()
				if bullet.endRes then
					local skillSprite = SkillSprite.new(bullet.endRes,self.battleView,targetPosition)
				end
			end)
			}))

		return
	end

	-- 落体
	if bullet.bulletType == 3 then
		local target = self.battleView[bulletInfo.targetCamp.."Soldiers"][bulletInfo.targetIndex]
		local bulletSprite = BulletSprite.new(bullet.res)
		bulletSprite:addTo(target,ZOrder:anchZorder(self.anchPoint)):align(display.BOTTOM_CENTER, 0, 300)
		bulletSprite:runAction(transition.sequence({
			CCMoveTo:create(0.5, CCPoint(0, 0)),
			CCRemoveSelf:create(),
			CCCallFunc:create(function ()
				if bullet.endRes then
					local skillSprite = SkillSprite.new(bullet.endRes,target)
				end
			end)
			}))
		return
	end

	if bullet.bulletType == 4 then --链状
		local angle =  ccp(sx - dx , sy - dy):getAngle()
		angle = 180-angle * 180 / math.pi
		local distance = ccp(sx,sy):getDistance(ccp(dx,dy))	
		local x1 = sx-dx>=0 and -1 or 0
		local clipnode = display.newClippingRegionNode(cc.rect(distance*x1,-240,distance,480)):addTo(self.battleView,ZOrder:anchZorder(self.anchPoint)+10):pos(sx,sy)
		local bulletSprite =  BulletSprite.new(bullet.res) 
		bulletSprite:setRotation(angle)
		bulletSprite:addTo(clipnode):pos(0,0)
		transition.moveTo(bulletSprite,{x = dx -sx,y=dy-sy,time =time,onComplete = function()
			transition.moveTo(bulletSprite,{x = 0,y=0,time =time,onComplete = function()
					bulletSprite:removeSelf()
				end})
		end})

		return
	end
end

return SoldierView