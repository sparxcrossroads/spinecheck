local BuffSprite = class("BuffSprite", function()  
    return display.newSprite()
end)

local buffRes  = "resource/battle/buff/"

function BuffSprite:ctor(res)
    if res then
        local resource = string.toTableArray(res,",")
        for k,v in pairs(resource) do
            local typeId = tonumber(v[1])
            local fileName = v[2]
            if fileName then
                local x,y = tonumber(v[3]) or 0,tonumber(v[4]) or 0 
                if typeId == 1 then --图片
                    display.newSprite(buffRes..fileName..".png"):pos(x,y):addTo(self)
                elseif typeId == 2 then --帧动画
                    local length,fps = tonumber(v[3]),tonumber(v[4])
                    local x,y = tonumber(v[5]) or 0,tonumber(v[6]) or 0     
                    display.addSpriteFramesWithFile(buffRes..fileName .. ".plist",buffRes..fileName .. ".png")
                    local frames = display.newFrames(fileName.."_%02d.png", 1, length)
                    local animation = display.newAnimation(frames, 1/fps)
                    display.newSprite():pos(x,y):addTo(self):playAnimationForever(animation)
                elseif typeId == 3 then --粒子
                    local particle = CCParticleSystemQuad:create(buffRes..fileName..".plist")
                    particle:addTo(self):pos(x,y)
                elseif typeId == 4 then --骨骼动画
                    local spine = SkeletonAnimation:createWithFile(buffRes..fileName..".json",buffRes..fileName..".atlas",1)
                    spine:setSpeedScale(0.5)
                    spine:pos(x, y):addTo(self)
                    spine:setAnimation(888,"animation",true)        
                end
            end            
        end
    end
end


return BuffSprite