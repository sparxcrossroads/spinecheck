local BattleView = import(".BattleView")
local scheduler = require("framework.scheduler")

local PVPBattleView = class("PVPBattleView", BattleView)

local SoldierView = require("app.scenes.battle.SoldierView")
local BattleBottomBar = import(".BattleBottomBar")
local BattleTopBar = import(".BattleTopBar")

local BattleEndLayer = require("app.scenes.battle.BattleEndLayer")

function PVPBattleView:ctor(params)
    self.params = params or {}    
    PVPBattleView.super.ctor(self, params)
    self.heroIds = params.heroIds
end


function PVPBattleView:onBattleEndNotify(camp, index, notify, params)
    print("camp"..camp.."index"..index..notify)
    self.topBar:pauseTime()

    for k,soldier in pairs(self.leftSoldiers) do
        if soldier.tip then
            soldier.tip:removeSelf()
            soldier.tip = nil
        end
        soldier:setSkillEnable(false)
        for k,bullet in pairs(soldier.bulletMovingMap) do
            if bullet then
                bullet:removeSelf()
                table.remove(soldier.bulletMovingMap, k)
            end
        end
    end

    for k,soldier in pairs(self.rightSoldiers) do
        if soldier.tip then
            soldier.tip:removeSelf()
            soldier.tip = nil
        end
        soldier:setSkillEnable(false)
        for k,bullet in pairs(soldier.bulletMovingMap) do
            if bullet then
                bullet:removeSelf()
                table.remove(soldier.bulletMovingMap, k)
            end
        end
    end



    -- todo pvpBattleEnd
    if self.params.from == "Fight" then
        --todo
        print("fight")
        local star = self.params.pbData.star or 0
        if star > 0  then
            require("app.scenes.pvp.PvpBattleEndLayer").new(self.params):addTo(display.getRunningScene(),ZOrder.battleUI+10)
        elseif star < 0  then
            require("app.scenes.battle.failEndLayer").new({BattleType = "pvp"}):addTo(display.getRunningScene(),ZOrder.battleUI+10)
        elseif star == 0 then
            require("app.scenes.battle.failEndLayer").new({BattleType = "pvp"}):addTo(display.getRunningScene(),ZOrder.battleUI+10)
        end

    elseif self.params.from == "Replay" then
        print("replay")
        require("app.scenes.pvp.PvpRecordEndLayer").new(self.params.pbData):addTo(display.getRunningScene(),ZOrder.battleUI+10)
        
    end


end

return PVPBattleView