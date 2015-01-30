local BattleView = class("BattleView", function ()
	return display.newLayer()
end)

local ZOrder = import(".ZOrder")

FontRes = "resource/font/"

local SoldierView = require("app.scenes.battle.SoldierView")
local BattleBottomBar = import(".BattleBottomBar")
local BattleTopBar = import(".BattleTopBar")

function BattleView:ctor(params)
	self.params = params
	self.battleType = params.battleType
    self.dropItems = {}
    local bgRes
    if params.sceneBg then
        if self.battleType == "PVE" then
            bgRes = params.sceneBg[tostring(params.pbData.fightNo)] 
        else
            bgRes = params.sceneBg
        end
    end
    
	-- 背景图片
	self.bg = display.newSprite("resource/bg/"..bgRes..".png")
				:pos(display.cx, display.cy)
				:addTo(self)	

	--左右阵营的map, key为index(英雄在小队中的编号)  v为soldierView
	self.leftSoldiers = {}
	self.rightSoldiers = {}

	self:initCommonUI()
	self.autoBattle = false
	self.battleHadEnd = false

end

--加载通用界面
function BattleView:initCommonUI()
	-- 顶部信息栏
	self.topBar = BattleTopBar.new(self):addTo(self,ZOrder.battleUI):align(display.CENTER_TOP,display.cx,display.cy+320)
	-- 底部控制栏
	self.bottomBar = BattleBottomBar.new(self):addTo(self,ZOrder.battleUI):align(display.CENTER_BOTTOM,display.cx,display.cy-360)

	if DEBUG_RELEASE then
		-- anchXY -> positionXY转换表
		self.positionByAnchXY = BattleConstants:generateMap()
		--加载BattleConstants常量
		self.colCount = BattleConstants.ColMax
		self.rowCount = BattleConstants.RowMax
		
		--占位符,用作肉眼调试
		for col = -self.colCount,self.colCount  do
			for row = -self.rowCount, self.rowCount do
				local placeHolder = display.newSprite(BattleUIRes.."battle_coins.png")
				placeHolder:addTo(self)
				placeHolder:pos(self.positionByAnchXY[col][row].x, self.positionByAnchXY[col][row].y)
				placeHolder:scale(0.2)

				ui.newTTFLabel({text = string.format("(%d,%d)",col,row), size = 60})
							:addTo(placeHolder)		
			end
		end
	end
end

--只允许被BattleLogic对象调用
function BattleView:addSoldier(params)
	--创建SoldierView对象
	params.battleView = self
	local soldier = SoldierView.new(params)
	self[params.camp.."Soldiers"][params.index] = soldier
	--将soldier放置到对应位置
	soldier:pos(BattleConstants:anchToPosition(params.anchPoint)):addTo(self,ZOrder:anchZorder(params.anchPoint))
	--bottomBar添加soldier
	if params.camp == "left" and 
		not params.isSummon then --不是召唤物
		self.bottomBar:addSoldier(soldier)
	end

end

function BattleView:doAction(camp, index, action, params)
	self[camp.."Soldiers"][index]:doAction(action, params)
end

function BattleView:onNotify(camp, index, notify, params)
	if notify == "battleEnd" then
		self:onBattleEndNotify(camp, index, notify, params)
	else
		self[camp.."Soldiers"][index]:onNotify(notify, params)
	end		
end


function BattleView:onBattleEndNotify(camp, index, notify, params)
    print("attleView:onBattleEndNotify--子类覆盖")
end

function BattleView:releaseSkill(camp, index)
    self.super.skillPause()
    self.topBar:pauseTime()
    self.bg:setColor(ccc3(100,100,100))
    for k,soldiers in pairs({self.leftSoldiers,self.rightSoldiers}) do
        for k,soldier in pairs(soldiers) do
            if soldier.tip then
                soldier.sprite:setColor(ccc3(100,100,100))
                soldier.sprite:pauseSchedulerAndActions()   
                for k,bullet in pairs(soldier.bulletMovingMap) do
                    bullet:pauseSchedulerAndActions()
                    bullet:setColor(ccc3(100,100,100))
                end
            end
        end
    end 
    
    local soldier = self[camp.."Soldiers"][index]
    soldier.sprite:resumeSchedulerAndActions()
    soldier.sprite:setColor(ccc3(255,255,255))
    local sequence = transition.sequence({
        CCScaleTo:create(0.2,1.2),
        CCDelayTime:create(0.5),
        CCScaleTo:create(0.2,1),
        CCCallFunc:create(function()
            self.bg:setColor(ccc3(255,255,255))
            for k,soldiers in pairs({self.leftSoldiers,self.rightSoldiers}) do
                for k,soldier in pairs(soldiers) do
                    if soldier.tip then
                        soldier.sprite:setColor(ccc3(255,255,255))
                        soldier.sprite:resumeSchedulerAndActions()      
                        for k,bullet in pairs(soldier.bulletMovingMap) do
                            bullet:resumeSchedulerAndActions()
                            bullet:setColor(ccc3(255,255,255))
                        end
                    end
                end
            end
            self.super.skillResume()
            self.topBar:resumeTime()
        end)
    })
    soldier:runAction(sequence)
end

return BattleView