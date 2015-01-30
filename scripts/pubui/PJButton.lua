local scheduler = require("framework.scheduler")
--
-- Author: 张伟超
-- Date: 2014-08-07 09:53:25
--

local PJButton = class("PJButton",function()
        return display.newNode()
    end)

--使用简例：
--[[

    --传入sprite 或者 传入图片路径均可；
    
    local nor = display.newSprite(PUBLIC_RES.."btn_red_n.png")
    local sel = display.newSprite(PUBLIC_RES.."btn_gold_n.png")
    local dis = display.newSprite(PUBLIC_RES.."btn_gray_star.png")

    local PJButton = require("uiutils/PJButton")
    local button = PJButton.new({
        normal = nor,
        selected = sel,
        disabled = dis,
        autoRepeat = autoRep,
        text = "确认",
        border = 2,
        callback = function() print(" == callback == ") end
        })
    :pos(display.cx,display.cy + 500)
    :addTo(self,999)

]]

function PJButton:ctor(params)
    --单张图片的sprite
    --多张图片的sprite
    self.params = params
    self.isSelected = false
    self.isDisabled = false 
    self.label = nil 
    self.isAction = self.params.isAction or nil  --是否启用动画 参数：{"shake",-- 抖动
                                                 --                 "scale",-- 缩放 }；

    self.normal = self.params.normal
    self.selected = self.params.selected or nil 
    self.disabled = self.params.disabled or nil
    self.autoRepeat = self.params.autoRepeat or nil
    local border =  self.params.border or nil

    if self.normal and type(self.normal) == "string" then
        self.normal = display.newSprite(self.normal)
    end
    if self.selected and type(self.selected) == "string" then
        self.selected = display.newSprite(self.selected)
    end
    if self.disabled and type(self.disabled) == "string" then
       self.disabled = display.newSprite(self.disabled)
    end

    if self.params.text then
        local params = {}

        --是否有描边，描边大小
        if self.params.border then
            params.outlineWidth = self.params.border
        end
        --描边颜色
        if self.params.borderColor then
            params.outlineColor = self.params.borderColor
        end
        --大小
        if self.params.size then
            params.size = self.params.size
        else
            params.size = 25
        end
        --指定颜色
        if self.params.color then
            params.color = self.params.color
        end
        --位置
        local xx = 0
        local yy = 0
        if self.params.fontPos then
            xx = self.params.fontPos.x
            yy = self.params.fontPos.y
        end
        --内容
        params.text = self.params.text
        --默认字体
        params.font = GAME_FONT
        params.align = ui.TEXT_ALIGN_CENTER
        if self.params.border then
            self.label = ui.newTTFLabelWithOutline(params)
        else
            self.label = ui.newTTFLabel(params)
        end
        self.label:pos(xx,yy)
        self.label:addTo(self,999)
    end
    self:addChild(self.normal)
    if self.selected then
        self:addChild(self.selected)
        self.selected:setVisible(false)
    end
    if self.disabled then
        self:addChild(self.disabled)
        self.disabled:setVisible(false)
    end
    self:setTouchEnabled(true)
    self:onTouch()
end

--调节文字位置：
function PJButton:reset(x,y)
    if self.label then
        self.label:setPosition(x,y)
    end
end 

function PJButton:setFontPosAddition(x,y)
    if self.label then
        self.label:setPosition(x,y)
    end
end 

function PJButton:onTouch()
    local scale = nil
    local moved = false
    local firstPos = nil
    self:addNodeEventListener(NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            if scale == nil then
                scale = self:getScaleX()
            end
            firstPos = event
            self:stopAllActions()
            if self.selected then
                self:setSelected(true)
            end
            if self.isAction == "scale" then
                transition.scaleTo(self, { scale = scale*0.98, time = 0.05 ,easing = "backou"})
            end
            if self.autoRepeat ~= nil then
                self.callbackTimes = 0
                self.firstHandle = scheduler.scheduleGlobal(function ()
                                                                if moved == true then
                                                                    return
                                                                end
                                                                self.params.callback()
                                                                self.callbackTimes = 1
                                                                if self.firstHandle ~=nil then
                                                                    scheduler.unscheduleGlobal(self.firstHandle)
                                                                    self.firstHandle = nil
                                                                end
                                                                self.handle = scheduler.scheduleGlobal(function()
                                                                    if moved == true then
                                                                        return
                                                                    end
                                                                    if self.callbackTimes < self.autoRepeat then
                                                                        self.params.callback()
                                                                        self.callbackTimes = self.callbackTimes + 1
                                                                    end
                                                                    if self.callbackTimes >= self.autoRepeat and self.handle ~= nil then
                                                                        scheduler.unscheduleGlobal(self.handle)
                                                                        self.handle = nil
                                                                    end
                                                                    end, 0.1)
                                                            end, 0.5)
            end
            return true 
        elseif event.name == "moved" then
            if firstPos == nil then
                firstPos = event
            end
            if math.abs(firstPos.x - event.x) >= 5 or math.abs(firstPos.y - event.y) >= 5  then
                moved = true
            end

        elseif event.name == "ended" then

            if self.firstHandle ~=nil then
                scheduler.unscheduleGlobal(self.firstHandle)
                self.firstHandle = nil
            end
            if self.handle ~= nil then
                scheduler.unscheduleGlobal(self.handle)
                self.handle = nil
            end
            self:setNormal()
            if self:getCascadeBoundingBox():containsPoint(CCPointMake(event.x, event.y)) and moved == false then
                playUiSound(SOUND_PATH.button)
                if self.isAction == "shake111" then
                    self:buttonShakeAction(function (  )
                        if not (self.autoRepeat ~= nil and self.callbackTimes ~= 0) then
                            self.params.callback()
                        end
                    end)
                elseif self.isAction == "scale" then
                    transition.scaleTo(self, { scale = scale, time = 0.05 ,easing = "backin",onComplete = function (  )
                        if not (self.autoRepeat ~= nil and self.callbackTimes ~= 0) then
                            self.params.callback()
                        end
                    end})
                else
                    if not (self.autoRepeat ~= nil and self.callbackTimes ~= 0) then
                        self.params.callback()
                    end
                end
            else
                if self.isAction then
                     transition.scaleTo(self, { scale = scale, time = 0.05 ,easing = "backin" })
                end
            end
            moved = false
            
        end
    end)
end

function PJButton:buttonShakeAction( confirm  )
    local function zoom1(offset, time, onComplete)
        local x, y = self.normal:getPosition()
        local size = self.normal:getContentSize()

        local scaleX = self.normal:getScaleX() * (size.width + offset) / size.width
        local scaleY = self.normal:getScaleY() * (size.height - offset) / size.height

        transition.moveTo(self.normal, {y = y - offset, time = time})
        if self.label then
            transition.moveTo(self.label, {y = self.label:getPositionY() - offset, time = time})
        end
        transition.scaleTo(self, {
            scaleX     = scaleX,
            scaleY     = scaleY,
            time       = time,
            onComplete = onComplete,
        })
    end
 
    local function zoom2(offset, time, onComplete)
        local x, y = self.normal:getPosition()
        local size = self.normal:getContentSize()

        transition.moveTo(self.normal, {y = y + offset, time = time / 2})
        if self.label then
            transition.moveTo(self.label, {y = self.label:getPositionY() + offset, time = time/2})
        end
        transition.scaleTo(self, {
            scaleX     = 1.0,
            scaleY     = 1.0,
            time       = time,
            onComplete = onComplete,
        })
    end
 
    self:setTouchEnabled(false)  

    zoom1(20, 0.08, function()
        zoom2(20, 0.09, function()
            zoom1(10, 0.10, function()
                zoom2(10, 0.11, function()
                    self:setTouchEnabled(true)
                    if confirm then
                        confirm()
                    end
                end)
            end)
        end)
    end)
end

function PJButton:setSelected(isSelect)
    self.isSelected = isSelect
    if self.selected then
        self.normal:setVisible(not isSelect)
        self.selected:setVisible(isSelect)
        if self.disabled then
            self.disabled:setVisible(false)
        end 
    else
        self.normal:setVisible(true)
        if isSelect then
            self.normal:setColor(ccc3(150, 150, 150))
        else
            self.normal:setColor(ccc3(255, 255, 255))
        end
        
    end
end


function PJButton:setDisabled(isdisbale)
    self.isDisabled = isdisbale
    self:setTouchEnabled(not isdisbale)
    if self.disabled then
        self.disabled:setVisible(isdisbale)
        self.normal:setVisible(not isdisbale)
        if self.selected then
            self.selected:setVisible(false)
        end
    else
        if isdisbale then
            self.normal:setColor(ccc3(150, 150, 150))
        else
            self.normal:setColor(ccc3(255, 255, 255))
        end
        
    end
end

function PJButton:setNormal()
    self.normal:setVisible(true)
    self.normal:setColor(ccc3(255, 255, 255))
    self.isSelected = false
    self.isDisabled = false 
    if self.isdisbale then
        self.isdisbale:setVisible(false)
    end
    if self.selected then
        self.selected:setVisible(false)
    end
end


function PJButton:setButtonLabel(string )
    self.label:setString(string)
end

return PJButton