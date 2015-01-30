UIPub = {}

--[[
	****************** 一些常用的，全局的 ，方便UI的一些方法定义   *************************
]]


-- 切换场景
-- @param name 场景名字
-- @param params    传递给下一个场景的参数
-- @param callback  回调函数
-- @param transitionParams  切换效果参数
function switchScene(name, params,transitionParams,callback)
	
	CCDirector:sharedDirector():getActionManager():removeAllActions()
	local scene = require(string.format("app.scenes.%s.scene", name))
	if transitionParams then
		display.replaceScene(scene.new(params), transitionParams.style, transitionParams.time, transitionParams.more)
	else
		display.replaceScene(scene.new(params))
	end

	if type(callback) == "function" then
		-- 必须延迟，不然会在替换场景之前执行
		local handle
		handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
			handle = nil
			callback()
		end, 0.5 , false)
	end

	if audio.isMusicPlaying() then
		audio.stopMusic(false)
	end
	audio.stopAllSounds()
end

function pushScene(name, params)
	local scene = require(string.format("scenes.%s.scene", name))
	CCDirector:sharedDirector():pushScene(scene.new(params))
end

function popScene()
	CCDirector:sharedDirector():popScene()
end


--弹出动画：
--参数类型1：params = someLayer
--参数类型2：params = {node = someLayer ...}
function showAction(params)
	local function doAction(node)
		playUiSound(SOUND_PATH.pop)
		local scale = node:getScale()
		-- node:runAction(transition.sequence({
		-- 	CCScaleTo:create(0.1, scale + 0.2),
		-- 	CCScaleTo:create(0.2, scale - 0.1),
		-- 	CCScaleTo:create(0.1, scale),
		-- }))
		node:setScale(scale * 0.1)
		transition.scaleTo(node, {scale = scale,time = 0.3,easing = "backout"})
	end 
	if type(params) == "table" and params.node then
		doAction(params.node)
	else
		doAction(params)
	end
end

--缩小退出
function removeOutAction(params,confirm)
	local scale = params:getScale()
	-- transition.fadeOut(params, {time = 0.6})
	transition.scaleTo(params,{scale = scale * 0.4,time = 0.3,easing = "backin",onComplete = function ()
		if confirm then
			confirm()
		end
	end})
end

--移动进入
--params.node 移动物体
--params.pos 最终坐标
--params.direction 移动方向 1：从左往右，-1：从右往左
function goInAction(params,confirm)
	local pos = params.pos or ccp(0, 0)
	local direction = params.direction or 1
	local distance = 50 * direction
	params.node:setPosition(ccp(pos.x - distance, pos.y))
	
	transition.moveTo(params.node, {time = 0.5, x = pos.x, y = pos.y, easing = "exponentialout",onComplete = function (  )
		if confirm then
			confirm()
		end
	end})
end



--显示弹出框信息；
--[[
	showMessage({
		text = "XXXXX",
		sure = function()end,
		cancel = function()end
	})
]]
function showMessage(params)
	local message = require("pubui.PJMessage")
	local m = message.new(params)
	CCDirector:sharedDirector():getRunningScene():addChild(m,99999)
end 


--Tip提示；
-- text, func
function showTip(params)
	local message = require("pubui.PJTips")
	local m = message.new(params)
	return m 
end 


function switchSceneByIndex(index)
	if index == 1 then
		switchScene("home")--home 主页
	elseif index == 2 then
		switchScene("summon")--summon 召唤
	elseif index == 3 then
		switchScene("shop")--shop 商店
	elseif index == 4 then
		switchScene("pvp")--pvp 竞技场
	elseif index == 5 then
		switchScene("carbon")--carbon 副本
	elseif index == 6 then
		switchScene("armory")--armory 兵工厂
	elseif index == 7 then
		switchScene("battle")--battle 边境
	elseif index == 8 then
		switchScene("partner")--partner 家族
	elseif index == 9 then
		switchScene("recharge")--recharge 充值
	else
		print("=== wrong ===")
	end
end

--获取英灵头像：（heroid,quality,star）
function getHeroIcon(data)
	return require("pubui.IconHero").new(data)
end
--获取装备头像：
function getEquipIcon(data)
	return require("pubui.IconEquip").new(data)
end 
--获取道具头像
function getItemIcon(data)
	return require("pubui.IconItem").new(data)
end 

--获取道具头像
function getPicesesIcon(data)
	return require("pubui.IconPieces").new(data)
end 

--技能头像；
function getSkillIcon(data)
	return require("pubui.IconSkill").new(data)
end 


--体力刷新：
function updateHealthLabel( )
	-- 更新金币钻石等数值 self.coinLabel,self.diamondLabel,self.phyLabel
	uiData.phyLabel:setString(game.master.health)
end

--金币刷新
function updateGoldLabel( )
	-- 更新金币钻石等数值 self.coinLabel,self.diamondLabel,self.phyLabel
  uiData.coinLabel:setString(game.master.gold)
end
--钻石刷新
function updateDiamondLabel( )
	-- 更新金币钻石等数值 self.coinLabel,self.diamondLabel,self.phyLabel
	uiData.diamondLabel:setString(game.master.gem)
end

--通过gridid获取对应的颜色：
function getColorByGrid(gridid)
	if gridid == 1 then
		return GRID_COLOR_WHITE
	elseif gridid < 4 then
		return GRID_COLOR_GREEN
	elseif gridid == 1 then
		return GRID_COLOR_BLUE
	elseif gridid < 12 then
		return GRID_COLOR_PUIPLE
	else
		return GRID_COLOR_ORANGE
	end
end

--返回当前品质下+n
function getAddtionByGridid(gridid)
	local addition = 0
	if gridid > 11 then
		addition = gridid%12
	elseif gridid > 6 then
		addition =  gridid%7
	elseif gridid > 3 then
		addition =  gridid%4
	elseif gridid > 1 then
		addition =  gridid%2
	end
	return addition > 0 and "+"..addition or ""
end

--当前色系：
function getColorIndexByGridid(gridid)
	if gridid > 11 then
		return 5
	elseif gridid > 6 then
		return  4
	elseif gridid > 3 then
		return  3
	elseif gridid > 1 then
		return  2
	else
		return  1
	end
end

--普通按钮：
--[[
	{ 	nor 必须
		sel 可选
		dis 可选
	}
]]
function getMenu(params)
	local item = ui.newImageMenuItem({
          image = params.nor,
          imageSelected = params.sel or params.nor,
          imageDisabled = params.dis or params.nor,
          listener = function()
          		playUiSound(SOUND_PATH.button)
            	params.listener()
           end
      	})
	item:setTag(NORMAL_MENU_TAG)
  return ui.newMenu({item})
end



--取得骨骼动画
function getHeroBones(index)
	local node = display.newNode()

	local actionType = {"attack","victory","attack2","attack3","damaged"}

	local jsonRes = "resource/spineBones/"..tostring(index)..".json"
	local atlaRes = "resource/spineBones/"..tostring(index)..".atlas"

	--暂时添加：
	if (not isFileExistByPath(jsonRes)) or (not isFileExistByPath(atlaRes))  then
		display.newSprite(RES.."icon_item/item.png"):pos(0,100):addTo(node)
	else

		local sprite = SkeletonAnimation:createWithFile(jsonRes,atlaRes,0.8):addTo(node)
	  	sprite:setSpeedScale(0.5)
	  	sprite:setAnimation(1,"standby",true)

	  	local rect = display.newNode():pos(-50,0):addTo(node,1)
	  	rect:setContentSize(CCSizeMake(100, 200))
	  	rect:setTouchEnabled(true)
	  	rect:addNodeEventListener(cc.NODE_TOUCH_EVENT, function ( event )
	    	if event.name == "began" then
	      		--英灵点击事件
	      		local count = math.random(1,#actionType)
	      		sprite:setToSetupPose()
	    		sprite:setAnimation(2,actionType[count],false)
	    	end
	  	end)

	  	node.rect = rect
    
  	end

 
  return node
end

--选装图片
-- node : 旋转物体  rDirection : 旋转方向 1 or -1 rTime : 旋转半圈时间，秒为单位，默认18
function setForRotate(node, rDirection , rTime)
	local time = rTime or 18
	local direction = rDirection or 1

	local action = transition.sequence({
		CCRotateTo:create(time,180 * direction),
		CCRotateTo:create(time,360 * direction),})
	local forever = CCRepeatForever:create(action)
	node:runAction(forever)
end

-- args { x = 0, y = 3, count = 200 }
function shakeScene(args, target)
	local target = target or display.getRunningScene()
	args = args or {}
	local time = args.time or 0.01
	local x = args.x or 5
	local y = args.y or 5
	local shakeCount = args.count or 5
	local onComplete = args.onComplete or nil

	local actions = {}
	actions[#actions + 1] = CCMoveBy:create(time, ccp(x, y))
	for count = 1, shakeCount do
		actions[#actions + 1] = CCMoveBy:create(time * 2, ccp(0 - x * 2, 0 - y * 2))
		actions[#actions + 1] = CCMoveBy:create(time * 2, ccp(x * 2, y * 2))
	end
	actions[#actions + 1] = CCMoveBy:create(time, ccp(-x, -y))
	
	target:runAction(transition.sequence(actions))
end

-- 播放音乐
function playUiMusic(path,isLoop)
	local loop = isLoop or true
	if game.musicOn then
		audio.playMusic(path,loop)
	end
end


-- 播放音效

function playUiSound(path)
	if game.musicOn then
		audio.playSound(path)
	end
end

