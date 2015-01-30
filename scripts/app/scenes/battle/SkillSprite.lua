local SkillSprite = class("SkillSprite", function()  
    return display.newSprite()
end)
local scheduler = require("framework.scheduler")

local skillRes =  "resource/battle/skillEffect/"


function SkillSprite:ctor(res,target,pos,scale)
    -- res = "1=2=launch_100104=5=10"
    -- 目标类型=资源类型编号=资源名称[=相对坐标x=相对坐标y],...多个资源之间用，分隔 0对地，1对人，2全屏
    --  目标类型=资源类型编号=frameName=帧数=帧率[=相对坐标x=相对坐标y=zorder]
    -- 2=1=end_100202_bg=0.5=0.5=2900,2=2=end_100202=4=5=0.5=0.5=1
    --     end_100202_bg 2=1=end_100202_bg=0.5=0.5=1,2=2=end_100202=4=5=0.5=0.5=2900
    -- 2=1=end_100202_bg=0.5=0.5=1,2=2=end_100202=4=4=0.5=0.5=2900
    -- 2=3=end_100802_01=0=0.5=2900,2=3=end_100802_02=0=0.5=2850,2=3=end_100802_03=0=0.5=2900
    -- 2=1=end_100202_bg=0.5=0.5=1,2=2=end_100202=4=5=0.5=0.5=2900
    if res == "" then
        return
    end
    self.particles = {}

    pos = pos or {x =0,y =0}
    local resource = string.toTableArray(res,",")
    for k,v in pairs(resource) do
        local posType = tonumber(v[1])
        local typeId = tonumber(v[2])
        local zorder = tonumber(v[6])
        if typeId == 2 then
            zorder = tonumber(v[8])
        end

        if posType == 2 then
            local skillNode = self:initRes(v)
            local x,y = self:getPos(v)
            if target.camp == "right" then
                x = 1-x             
            end
            skillNode:addTo(target.battleView,zorder):pos({x = x*display.width,y =y*display.height}):setScale(scale)
        else
            local skillNode = self:createSkill(v) 
            skillNode:addTo(target):pos(pos)
        end
    end
end

function SkillSprite:getPos(res)
    local typeId = tonumber(res[2])
    if typeId == 2 then
        return tonumber(res[6]) or 0,tonumber(res[7]) or 0
    else
        return tonumber(res[4]) or 0,tonumber(res[5]) or 0
    end
end

function SkillSprite:createSkill(res)
    local typeId = tonumber(res[2])
    local x,y = self:getPos(res)
    local effect = display.newNode()
    self:initRes(res):addTo(effect):pos(x, y)
    return effect
end

function SkillSprite:initRes(res)
    local typeId = tonumber(res[2])
    local fileName = res[3]
    if fileName then
        if typeId == 1 then --图片
            local sprite = display.newSprite(skillRes..fileName..".png")
            scheduler.performWithDelayGlobal(function ()
                sprite:removeSelf()
            end,2)
            return sprite
        elseif typeId == 2 then --帧动画
            local length,fps = tonumber(res[4]),tonumber(res[5])
            display.addSpriteFramesWithFile(skillRes..fileName .. ".plist",skillRes..fileName .. ".png")
            local frames = display.newFrames(fileName.."_%02d.png", 1, length)
            local animation = display.newAnimation(frames, 1/fps)
            local farmeAnimation = display.newSprite()
            farmeAnimation:playAnimationOnce(animation,true)    
            return farmeAnimation
        elseif typeId == 3 then --粒子
            local particle = CCParticleSystemQuad:create(skillRes..fileName..".plist")
            scheduler.performWithDelayGlobal(function ()
                particle:removeSelf()
            end,1.5)
            return particle
        elseif typeId == 4 then --骨骼动画
            local spine = SkeletonAnimation:createWithFile(skillRes..fileName..".json",skillRes..fileName..".atlas",1)
            spine:setSpeedScale(0.5)
            spine:setAnimation(888,"animation",false)
            spine.endListener = function (trackIndex)                
                spine:removeSelf()
            end
            return spine
        end
    end
    return display.newNode()
end



return SkillSprite