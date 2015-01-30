local BattleView = import(".BattleView")
local scheduler = require("framework.scheduler")

local PVEBattleView = class("PVEBattleView", BattleView)

local SoldierView = require("app.scenes.battle.SoldierView")
local BattleBottomBar = import(".BattleBottomBar")
local BattleTopBar = import(".BattleTopBar")

local BattleEndLayer = require("app.scenes.battle.BattleEndLayer")

function PVEBattleView:ctor(params)
    self.params = params or {}    
    PVEBattleView.super.ctor(self, params)
    self.sceneId = params.pbData.sceneId
    self.fightNo = params.pbData.fightNo
    self.heroIds = params.heroIds
end

function PVEBattleView:onBattleEndNotify(camp, index, notify, params)
    print("PVEBattleView:onBattleEndNotify")
    self.topBar:pauseTime()
    self.battleHadEnd = true
    -- 清理战场
    for k,soldier in pairs(self.leftSoldiers) do
        soldier:setSkillEnable(false)
        for k,bullet in pairs(soldier.bulletMovingMap) do
            if bullet then
                bullet:removeSelf()
                table.remove(soldier.bulletMovingMap, k)
            end
        end
    end
    
    local FightEndRequest = {}
    FightEndRequest.sceneId = self.sceneId
    FightEndRequest.fightNo = self.fightNo
    FightEndRequest.endInfo = params

    local bin = pb.encode("SceneFightEndRequest", FightEndRequest)
    game:sendData(actionCodes.SceneFightEndRequest, bin)
    game:addEventListener(actionModules[actionCodes.SceneFightEndResponse], function(event)
        local msg = pb.decode("SceneFightEndResponse", event.data)
        if msg.status == 1000 then
            print("计算正常。。。")
            -- 敌方有人活着则为战斗失败或超时，battleEnd
            for k,soldier in pairs(self.rightSoldiers) do
                if soldier.tip then
                    self:battleEnd()
                    return
                end
            end

            local sceneCsvData = sceneCsv:getDataById(self.sceneId)
            if self.fightNo < tonumber(sceneCsvData.count) then
                self.fightNo = self.fightNo + 1
                self:nextBattle(params)
            else
                for k,v in pairs(self.leftSoldiers) do
                    if v.tip then
                        v:playAnimation("victory",true)
                    end
                end
                self:battleEnd()
            end
        elseif msg.status == 92 then
            print("计算结果不一致")
            showMessage({
              text = contentByErrorCode(msg.status),
              sure = function()end
            })
        else
            print("其他错误")
            showMessage({
              text = contentByErrorCode(msg.status),
              sure = function()end
            })
        end
        game:removeEventListenersByTag(EVENT_LISTENER_TAG_SCENE_FIGHT_END)
    end,EVENT_LISTENER_TAG_SCENE_FIGHT_END) 
end

function PVEBattleView:nextBattle(params)
    -- 自动战斗状态，直接进入下一场
    if self.battleHadEnd then
        if game.autoBattle then
            if self.nextBtn then
                self.nextBtn:removeSelf()
                self.nextBtn = nil
            end
            self:nextView()
        else
            -- 切换到待机状态
            for k,v in pairs(self.leftSoldiers) do
                v:playAnimation("standby",true)
            end
            -- 下一场战斗按钮
            self.nextBtn = cc.ui.UIPushButton.new(BattleUIRes .. "battle_Continue.png")
            :addTo(self,ZOrder.battleUI):pos(display.width-120,display.cy)
            :onButtonClicked(function()
                self.nextBtn:removeSelf()
                self.nextBtn = nil
                self:nextView()
            end)
        end
    end
end

function PVEBattleView:nextView()
    -- 下一场战斗请求
    self.walkout = false
    self.nextBattleData = nil
    local battleRequest = {}
    battleRequest.sceneId = self.sceneId
    battleRequest.fightNo = self.fightNo
    battleRequest.heroIds = self.heroIds
    if #battleRequest.heroIds > 0 then
        local bin = pb.encode("SceneFightPrepareRequest", battleRequest)
        game:sendData(actionCodes.SceneFightPrepareRequest, bin)
        game:addEventListener(actionModules[actionCodes.SceneFightPrepareResponse], function(event)
            self.nextBattleData  = pb.decode("SceneFightPrepareResponse", event.data)
            print("@@@@@@@@@@SceneFightPrepareResponse"..#self.nextBattleData.fightItems)
            local fightItems = self.nextBattleData.fightItems
            -- print_r(self.nextBattleData.fightItems, 2)
            for k,v in pairs(fightItems) do
                print("diaoluo"..v.heroId)
                for k,v in pairs(v.items) do
                    print("diaoluo  id"..v.id.."count"..v.count)
                end
            end
            if self.walkout then
                switchScene("battle", {battleType = "PVE",pbData=self.nextBattleData,heroIds = battleRequest.heroIds,sceneBg = self.params.sceneBg})
            end         
            game:removeEventListenersByTag(EVENT_LISTENER_TAG_SCENE_FIGHT_PREPARE)
        end,EVENT_LISTENER_TAG_SCENE_FIGHT_PREPARE)
    end

    -- 走出屏幕
    local farthest = nil
    local min = 18
    for k,v in pairs(self.leftSoldiers) do
        if min > v.anchPoint.x and not v.params.isSummon then
            farthest = v.index
        end
    end




    for k,v in pairs(self.leftSoldiers) do
        if v.params.isSummon then
            v:removeSelf()
            table.remove(self.leftSoldiers,k)
        else
            v:playAnimation("move",true)
            if v.index == farthest then
                local time = (1000-v:getPositionX())/200
                transition.moveTo(v,{x=1000,time= time,onComplete = function()
                    self.walkout = true
                    if self.nextBattleData then
                        switchScene("battle", {battleType = "PVE",pbData=self.nextBattleData,heroIds = battleRequest.heroIds,sceneBg = self.params.sceneBg})
                    end
                end})
            else
                local time = (1500-v:getPositionX())/200
                transition.moveTo(v,{x=1500,time= time})
            end
        end
    end

    for k,v in pairs(self.dropItems) do
        v:runAction(transition.sequence({
            CCEaseBackIn:create(CCMoveTo:create(0.5, ccp(1150,display.cy+320))),
            CCRemoveSelf:create(),
            CCCallFunc:create(function ()
                self.topBar:addItem(1)
            end)
        }))
    end 
end

function PVEBattleView:finished(sceneId)
    local bin = pb.encode("SceneEndRequest", { sceneId = sceneId })
    game:sendData(actionCodes.SceneEndRequest, bin)
    game:addEventListener(actionModules[actionCodes.SceneEndResponse], function(event)
        self.sceneEndResponse = pb.decode("SceneEndResponse", event.data)
        if self.sceneEndResponse.status == 1000 then
            if self.delayEnd then
                self:showEndView()
            end        
        else
            showTip({text  = "网络延迟，请刷新!"}):pos(display.cx,display.cy):addTo(self,20)
            -- TODO 重连，再次请求
        end
        game:removeEventListenersByTag(EVENT_LISTENER_TAG_SCENE_END)
   end,EVENT_LISTENER_TAG_SCENE_END)
end

function PVEBattleView:battleEnd(params)
    self.sceneEndResponse = nil
    self.delayEnd = false  
    self.bottomBar.autoBtn:removeSelf()
    self:finished(self.sceneId)
    scheduler.performWithDelayGlobal(function ()
        self.delayEnd = true
        if self.sceneEndResponse then
            self:showEndView()
        end
    end,2)
end

function PVEBattleView:showEndView()

    for k,v in pairs(self.dropItems) do
        v:runAction(transition.sequence({
            CCEaseBackIn:create(CCMoveTo:create(0.5, ccp(1150,display.cy+320))),
            CCRemoveSelf:create(),
            CCCallFunc:create(function ()
                self.topBar:addItem(1)
            end)
        }))
    end

    scheduler.performWithDelayGlobal(function ()
        game.master.sceneProgress[self.sceneEndResponse.sceneId] = require("datamodel.SceneProgress").new()
        game.master.sceneProgress[self.sceneEndResponse.sceneId].id = self.sceneEndResponse.sceneId
        game.master.sceneProgress[self.sceneEndResponse.sceneId].star = self.sceneEndResponse.star
        --TODO 数据不对
        game.master.sceneProgress[self.sceneEndResponse.sceneId].count = self.sceneEndResponse.count
        game.master.sceneProgress[self.sceneEndResponse.sceneId].resetCount = 0
        game.master:updateLastScene(self.sceneEndResponse.sceneId)

        if self.sceneEndResponse.star == -1 then
            -- TODO 失败
            require("app.scenes.battle.failEndLayer").new({sceneIndex = self.sceneId ,BattleType = "pve"}):addTo(display.getRunningScene(),ZOrder.battleUI+10)
        elseif self.sceneEndResponse.star == 0 then
            -- TODO 超时
            require("app.scenes.battle.failEndLayer").new({sceneIndex = self.sceneId ,BattleType = "pve"}):addTo(display.getRunningScene(),ZOrder.battleUI+10)
        else
            -- TODO 胜利 star为战斗结果星级
            require("app.scenes.carbon.BattleEndLayer").new(self.sceneEndResponse,self.heroIds):addTo(display.getRunningScene(),ZOrder.battleUI+10)
        end
    end,1)

end

return PVEBattleView