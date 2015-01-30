local BuffSprite = import(".BuffSprite")
local SkillSprite = import(".SkillSprite")
local scheduler = require("framework.scheduler")

local SoldierTip = class("SoldierTip", function()
    return display.newSprite()
end)

function SoldierTip:ctor(soldierView)
    self.buffs = {}
    self.anchPoint = soldierView.anchPoint
    self.battleView = soldierView.battleView
    self.csvData = soldierView.battleView
    self.camp = soldierView.camp
    self:addHP()

end

-- 血条
function SoldierTip:addHP()
    self.hpProgress = display.newProgressTimer(BattleUIRes .. "battle_heroHP.png", display.PROGRESS_TIMER_BAR)
    self.hpProgress:setMidpoint(ccp(0, 0))
    self.hpProgress:setBarChangeRate(ccp(1,0))
    self.hpProgress:setPercentage(100)
    self.hpSlot = display.newSprite(BattleUIRes .. "battle_xueliangdi.png")
    self.hpProgress:pos(self.hpSlot:getContentSize().width / 2, self.hpSlot:getContentSize().height / 2):addTo(self.hpSlot)
    self.hpSlot:pos(0,200):addTo(self)
    self.hpSlot:setVisible(false)
end


function SoldierTip:addBuff(params)
    if params.csvData.buffRes then
        local buff = BuffSprite.new(params.csvData.buffRes)
        buff:addTo(self):pos(0, 0)
        buff.objectId = params.objectId
        table.insert(self.buffs, buff)
    end
    if params.csvData.buffTip then
        local hurtNode = display.newNode()
        local coord = BattleConstants:anchToPosition(self.anchPoint)
        hurtNode:align(display.CENTER,coord.x,coord.y+150):addTo(self.battleView,ZOrder:anchZorder(self.anchPoint))
        local file = "resource/battle/battle_ui/"
        local name = params.csvData.buffTip
        if string.len(name) > 0 then
            local color = "_b"
            if self.camp == "left" then
                if params.csvData.debuff then
                    color = "_r"
                end
            else                
                if not params.csvData.debuff then
                    color = "_r"
                end
            end
            file = file..name..color
            display.newSprite(file..".png"):addTo(hurtNode)
            hurtNode:runAction(transition.sequence({
                CCSpawn:createWithTwoActions(CCMoveBy:create(0.1, ccp(0, 30)), CCScaleTo:create(0.1, 0.8)),
                CCDelayTime:create(0.2),
                CCSpawn:createWithTwoActions(CCMoveBy:create(0.1, ccp(0, 10)), CCScaleTo:create(0.1, 0.6)),
                CCSpawn:createWithTwoActions(CCMoveBy:create(0.5, ccp(0, 30)), CCFadeOut:create(0.5)),
                CCRemoveSelf:create()
            }))
        end
        
    end
end

function SoldierTip:removeBuff(params)
    if params.csvData.buffRes then
        print("removeBuff"..params.csvData.name)
        for k,v in pairs(self.buffs) do
            if v.objectId == params.objectId then
                v:removeSelf()
                v=nil
                table.remove(self.buffs, k)
            end
        end
    end
end

function SoldierTip:killReward(params)
    local hurtNode = display.newNode()
    local coord = BattleConstants:anchToPosition(self.anchPoint)
    hurtNode:align(display.CENTER,coord.x,coord.y+150):addTo(self.battleView,ZOrder:anchZorder(self.anchPoint))
    local file = "resource/battle/battle_ui/award_"
    file = self.camp == "left" and file.."b.png" or file.."r.png"
    display.newSprite(file):addTo(hurtNode):setScale(0.5)
    hurtNode:runAction(transition.sequence({
        CCEaseBackOut:create(CCMoveBy:create(0.5, ccp(0, 70))),
        CCEaseBackOut:create(CCScaleTo:create(0.5, 1.5)),
        CCDelayTime:create(0.5),
        CCRemoveSelf:create()})
    )
end

--冒血数字
function SoldierTip:onHurt(params)
    if params.bulletCsvData then
        -- print("SoldierTip:onHurt")
        -- print_r(params.bulletCsvData, 2)
        self:addSkillEffect(params.bulletCsvData)
    end

    local hurtValue = params.hurtValue
    local effect = params.hurtEffect
    local oldHp = params.oldhp
    local newHp = params.newhp
    local maxHp = params.maxhp  

    local hurtValue = params.hurtValue or 0
    if math.abs(hurtValue)>0 and self.hpSlot then
        self.hpSlot:setVisible(true)
        self.hpProgress:setPercentage(newHp*100/maxHp)      
        scheduler.performWithDelayGlobal(function ()
            if self.hpSlot then
                self.hpSlot:setVisible(false)
            end
        end,2)
    end     

    local hurtNode = display.newNode()
    local coord = BattleConstants:anchToPosition(self.anchPoint)
    hurtNode:align(display.CENTER,coord.x,coord.y+100):addTo(self.battleView,ZOrder:anchZorder(self.anchPoint)+1)

    if effect == "miss" then
        local label = ui.newTTFLabel({
            text = "miss",
            font = "Arial",
            size = 30,
            color = ccc3(255, 255, 255),
            align = ui.TEXT_ALIGN_CENTER,
        })
        label:pos(0, 0):addTo(hurtNode)
    elseif effect == "treat" or effect == "suck" then
        if hurtValue < 0 then
            local label = ui.newTTFLabel({
                    text = "+" .. math.abs(hurtValue),
                    font = "Arial",
                    size = 30,
                    color = ccc3(0, 255, 0),
                    align = ui.TEXT_ALIGN_CENTER,
                })
            label:pos(0, 0):addTo(hurtNode)
        end     
    elseif effect == "crit" then
        local font = FontRes.."num_y.fnt"
        local critTips = ui.newBMFontLabel({
            text = hurtValue > 0 and "-" ..tostring(hurtValue) or "+" .. math.abs(hurtValue),
            font = font })      
        critTips:pos(0, 0):addTo(hurtNode)
    elseif effect == "normal" then
        --todo
        local font = FontRes.."num_r.fnt"
        local critTips = ui.newBMFontLabel({
            text = hurtValue > 0 and "-" ..tostring(hurtValue) or "+" .. math.abs(hurtValue),
            font = font })      
        critTips:pos(0, 0):addTo(hurtNode)
    else
        print("未知类型。。。。"..effect)
    end

    hurtNode:scale(0.6)
    hurtNode:runAction(transition.sequence({
        CCSpawn:createWithTwoActions(CCMoveBy:create(0.1, ccp(0, 30)), CCScaleTo:create(0.1, 0.8)),
        CCDelayTime:create(0.2),
        CCSpawn:createWithTwoActions(CCMoveBy:create(0.1, ccp(0, 10)), CCScaleTo:create(0.1, 0.6)),
        CCSpawn:createWithTwoActions(CCMoveBy:create(0.5, ccp(0, 30)), CCFadeOut:create(0.5)),
        CCRemoveSelf:create()
    }))
end

function SoldierTip:addSkillEffect(params)
    -- local skillSprite = SkillSprite.new(params.endRes,self)
    local skillSprite = SkillSprite.new(params.impactRes,self,{x=0,y=100})
end

function SoldierTip:actionTip(action)
    if DEBUG_RELEASE then
        --调试冒字
        local text = {
            attack = "普通攻击",
            attack2 = skillCsv:getSkillById(self.csvData.skillA).name,
            attack3 = skillCsv:getSkillById(self.csvData.skillB).name,
            attack4 = skillCsv:getSkillById(self.csvData.skillC).name
        }

        if text[action] then
            local label = ui.newTTFLabel({text = text[action], size = 40})

            label:align(display.CENTER,0,100):addTo(self.sprite, 100)
            label:setRotationY(self.direction == -1 and 180 or 0)
            label:runAction(transition.sequence({
                CCSpawn:createWithTwoActions(CCMoveBy:create(0.1, ccp(0, 30)), CCScaleTo:create(0.1, 0.8)),
                CCDelayTime:create(0.2),
                CCSpawn:createWithTwoActions(CCMoveBy:create(0.1, ccp(0, 10)), CCScaleTo:create(0.1, 0.6)),
                CCSpawn:createWithTwoActions(CCMoveBy:create(0.5, ccp(0, 30)), CCFadeOut:create(0.5)),
                CCRemoveSelf:create()
            }))
        end
    end
end

return SoldierTip