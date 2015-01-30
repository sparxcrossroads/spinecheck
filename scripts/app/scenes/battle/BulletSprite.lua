local BulletSprite = class("BulletSprite", function()  
	return display.newSprite()
end)

local bulletRes  = "resource/battle/bullet/"

function BulletSprite:ctor(res)
	-- "1=bullet001，3=particleName=10=12，2=frameName=4=1/8，4=spineName"
	-- res = "2=bullet007=2=20"
	-- 子弹资源为空的时候配888
	if res == nil then
		res = "1=bullet888"
	end
	local resource = string.toTableArray(res,",")
	for k,v in pairs(resource) do
		local typeId = tonumber(v[1])
		local fileName = v[2]
		if fileName then
			local x,y = tonumber(v[3]) or 0,tonumber(v[4]) or 0 
			if typeId == 1 then --图片
				display.newSprite(bulletRes..fileName..".png"):pos(x,y):addTo(self)
			elseif typeId == 2 then --帧动画
				local length,fps = tonumber(v[3]),tonumber(v[4])
				local x,y = tonumber(v[5]) or 0,tonumber(v[6]) or 0 	
				display.addSpriteFramesWithFile(bulletRes..fileName .. ".plist",bulletRes..fileName .. ".png")
				local frames = display.newFrames(fileName.."_%02d.png", 1, length)
			    local animation = display.newAnimation(frames, 1/fps)
				display.newSprite():pos(x,y):addTo(self):playAnimationForever(animation)
			elseif typeId == 3 then --粒子
				local particle = CCParticleSystemQuad:create(bulletRes..fileName..".plist")
				particle:addTo(self):pos(x,y)
			elseif typeId == 4 then --骨骼动画
				local spine = SkeletonAnimation:createWithFile(bulletRes..fileName..".json",bulletRes..fileName..".atlas",1)
				spine:setSpeedScale(0.5)
				spine:pos(x, y):addTo(self)
				spine:setAnimation(888,"animation",true)
	
			end

		end
		
	end

end


return BulletSprite