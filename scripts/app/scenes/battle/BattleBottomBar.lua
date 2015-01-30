-- BattleView 底部控制栏
local SoldierUnit = import(".SoldierUnit")
local scheduler = require("framework.scheduler")

local BattleBottomBar = class("BattleBottomBar", function()
	return display.newSprite(BattleUIRes .. "battle_cardsbottom.png")
end)

function BattleBottomBar:ctor(param)
	self.space = 60
	self.width = 134
	self.posX = 0
	self.offsetX = 0
	self.units = display.newSprite():addTo(self)
	-- 根据BattleType设置UI
    if param.battleType == "PVE" then
        self:initPVE(param)
    elseif param.battleType == "PVP" then
        self:initPVP(param)
    end
end

function BattleBottomBar:initPVE(param)
    self.autoBtn = cc.ui.UICheckBoxButton.new({on = BattleUIRes.."battle_AutoOn.png", off = BattleUIRes.."battle_AutoOff.png"})
        :setButtonSelected(game.autoBattle)
        :onButtonStateChanged(function(event)
            if event.target:isButtonSelected() then
                param.super.setAutoTalentSkill(true)
                self.units:setTouchEnabled(false)
            else
                param.super.setAutoTalentSkill(false)
                self.units:setTouchEnabled(true)
            end
        end)
        :align(display.CENTER,display.width-80,69)
        :addTo(self)
end

function BattleBottomBar:initPVP(param)
    display.newSprite(BattleUIRes.."battle_AutoLocked.png"):align(display.CENTER,display.width-80,69)
        :addTo(self)
    self.units:setTouchEnabled(false)
    scheduler.performWithDelayGlobal(function ()
        param.super.setAutoTalentSkill(true)
    end,0.1)    
end

function BattleBottomBar:addSoldier(soldierView)
	local soldierUnit = SoldierUnit.new(soldierView)
	soldierUnit:addTo(self.units):pos(self.posX,0)
	self.posX = self.posX - self.space - self.width

	self.units:pos(display.cx+self.offsetX,115)
	self.offsetX = self.offsetX + (self.width+self.space)/2
end


return BattleBottomBar