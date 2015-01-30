local BattleTopBar = class("BattleTopBar", function()
	return display.newSprite()
end)

local BattlePauseLayer = require("app.scenes.battle.BattlePauseLayer")


function BattleTopBar:ctor(params)
    if params.battleType == "PVE" then
        self:initPVE(params)
    elseif params.battleType == "PVP" then
        self:initPVP(params)
    end
    self.itemCount = 0
    self.coinCount = 0
end

function BattleTopBar:initPVE(params)
    
    local sceneId = params.params.pbData.sceneId
    local fightNo = params.params.pbData.fightNo

    self.topBar = display.newSprite(BattleUIRes .. "battle_barbottom.png")
    self.topBar:pos(0,0):addTo(self)
    local topBarSize = self.topBar:getContentSize()

    local exitBtn = cc.ui.UIPushButton.new(BattleUIRes .. "battle_suspended.png")
    :addTo(self):pos(-topBarSize.width/2-20,-3)
    :onButtonClicked(function()
        params:addChild(BattlePauseLayer.new({sceneId = sceneId}),ZOrder.battleUI+10)
        CCDirector:sharedDirector():pause()
    end)

    -- 倒计时
    local countDownBg = display.newSprite(BattleUIRes .. "battle_coinsbottom.png")
    countDownBg:pos(220,self.topBar:getContentSize().height/2):addTo(self.topBar)
    local bgSize = countDownBg:getContentSize()
    self.leftTimeLabel = ui.newTTFLabelWithShadow({text = "00:00", font = HuaKangFont, size = 26 , shadowColor = ccc3(91, 90, 90)})
    self.leftTimeLabel:pos(20, bgSize.height/2):addTo(countDownBg)
    self.leftTime = 90
    display.newSprite(BattleUIRes .. "battle_hourglass.png")
        :align(display.CENTER_RIGHT,bgSize.width-12, bgSize.height / 2):addTo(countDownBg)
    self:updateTime()


    -- 副本类型
    self.curStageType = ui.newTTFLabelWithShadow({ text = "普通", font = JING_FONT, size = 30 , shadowColor = ccc3(91, 90, 90) })
    self.curStageType:pos(38, topBarSize.height/2)
        :addTo(self.topBar)

    -- 当前阶段
    local sceneCsvData = sceneCsv:getDataById(sceneId)
    if sceneCsvData then
        self.curStageTips = ui.newTTFLabelWithShadow({ text = fightNo .. "/" .. sceneCsvData.count,font = JING_FONT, size = 30 , shadowColor = ccc3(91, 90, 90)})
        self.curStageTips:pos(topBarSize.width/2-90, topBarSize.height/2)
            :addTo(self.topBar)
    end    

    --掉落宝箱
    local dropItemBg = display.newSprite(BattleUIRes .. "battle_coinsbottom.png")
    dropItemBg:align(display.CENTER_RIGHT,topBarSize.width-40,topBarSize.height/2):addTo(self.topBar)
    local bgSize = dropItemBg:getContentSize()
    
    self.dropItemCount = ui.newTTFLabelWithShadow({text = "0", font = JING_FONT, size = 26 , shadowColor = ccc3(91, 90, 90)})
    self.dropItemCount:pos(50, bgSize.height / 2):addTo(dropItemBg)

    display.newSprite(BattleUIRes .. "battle_baoxiang.png")
        :align(display.CENTER_RIGHT,bgSize.width-12, bgSize.height / 2):addTo(dropItemBg)

    --掉落金币
    local dropCoinBg = display.newSprite(BattleUIRes .. "battle_coinsbottom.png")
    dropCoinBg:align(display.CENTER_RIGHT,topBarSize.width-200,topBarSize.height/2):addTo(self.topBar)

    self.dropCoinCount = ui.newTTFLabelWithShadow({text = "0", font = JING_FONT, size = 26 , shadowColor = ccc3(91, 90, 90)})
    self.dropCoinCount:pos(50, bgSize.height / 2):addTo(dropCoinBg)

    display.newSprite(BattleUIRes .. "battle_coins.png")
        :align(display.CENTER_RIGHT,bgSize.width-12, bgSize.height / 2):addTo(dropCoinBg)
end

function BattleTopBar:initPVP(params)
    -- 倒计时
    local countDownBg = display.newSprite(BattleUIRes .. "battle_coinsbottom.png")
    countDownBg:pos(-display.cx+100,0):addTo(self)
    local bgSize = countDownBg:getContentSize()
    self.leftTimeLabel = ui.newTTFLabelWithShadow({text = "00:00", font = HuaKangFont, size = 26 , shadowColor = ccc3(91, 90, 90)})
    self.leftTimeLabel:pos(20, bgSize.height/2):addTo(countDownBg)
    self.leftTime = 90
    display.newSprite(BattleUIRes .. "battle_hourglass.png")
        :align(display.CENTER_RIGHT,bgSize.width-12, bgSize.height / 2):addTo(countDownBg)
    self:updateTime()
end


function BattleTopBar:updateTime()
    if  self.leftTime > 0 then
        self.leftTime = self.leftTime - 1
        local min = math.floor(self.leftTime/ 60)
        local sec = self.leftTime - min * 60
        self.leftTimeLabel:setString(string.format("%02d:%02d",min,sec))
        self.leftTimeLabel:runAction(transition.sequence({
                    CCDelayTime:create(1),
                    CCCallFunc:create(function ()
                        self:updateTime()
                    end)
                }))
    end
end

function BattleTopBar:pauseTime()
    self.leftTimeLabel:pauseSchedulerAndActions()
end

function BattleTopBar:resumeTime()
    self.leftTimeLabel:resumeSchedulerAndActions()
end

function BattleTopBar:addItem(count)
    self.itemCount = self.itemCount + count
	self.dropItemCount:setString(tostring(self.itemCount))
end

function BattleTopBar:addCoin(count)
    self.coinCount = self.coinCount + count
    self.dropCoinCount:setString(tostring(self.coinCount))
end


return BattleTopBar