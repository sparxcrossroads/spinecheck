
local PJButton = require("pubui/PJButton")

local ItemInfoLayer = class("ItemInfoLayer",function(params)
        return display.newColorLayer(ccc4(0, 0, 0, 150))
    end)

--参数有更改：params = {data =  ,...}
function ItemInfoLayer:ctor(params)
    self.data = params and params.data or {}
    self.layer = display.newLayer():addTo(self)
    self.itemIndex = {}
    self.state = params and params.state or 0
    self.dressCallBack = params and params.dressCallBack or nil
    self:createItemBack()
    self:exitFun()

end

function ItemInfoLayer:createItemBack( )

	local background = display.newScale9Sprite(RES.."public/bg_white.png",display.cx,display.cy,
		CCSizeMake(460, 614)):addTo(self.layer,1)
	background:setTouchEnabled(true)
	showAction(background)
	local width = background:getContentSize().width
	local height = background:getContentSize().height
	local count
	if game.master.items[self.data.id] then
		count = game.master.items[self.data.id].count
	else
		count = 0
	end

	-- 图标，名称，拥有数量
	require("pubui.IconItem").new({quility = self.data.quality,itemid = self.data.id}):pos(80,536):addTo(background)
	ui.newTTFLabel({text = self.data.name, size = 28,color = ccc3(52, 44, 41) })
	:align(display.LEFT_CENTER,155,560)
	:addTo(background)
	ui.newTTFLabel({text = "拥有" , size = 28,color = ccc3(89, 89, 89) })
	:align(display.LEFT_CENTER,155,512)
	:addTo(background)

	self.mainItemCount = ui.newTTFLabel({text = count , size = 28,color = ccc3(17, 131, 249) })
	:align(display.CENTER,228,512)
	:addTo(background)

	ui.newTTFLabel({text = "件" , size = 28,color = ccc3(89, 89, 89) })
	:align(display.LEFT_CENTER,245,512)
	:addTo(background)
	--350x160
 	local natureTabel = {}
    for v, k in pairs(self.data) do
    	if self.data[v]~=0 then
    		if EQUIP_TYPE_NAME[v] then
    			natureTabel[#natureTabel + 1] = v
    		end
    	end
    end
    local decBack = display.newScale9Sprite(RES.."public/bg_grey.png",0,0,CCSizeMake(410, (#natureTabel) * 30 + 50 ) ):addTo(background)
	decBack:align(display.CENTER_TOP,width/2,450)
	for i=1,#natureTabel do
		ui.newTTFLabel({text = EQUIP_TYPE_NAME[natureTabel[i]].."：",color = ccc3(60, 51, 45),size = 28 })
		:align(display.LEFT_TOP,55,435 - (i-1)*30)
		:addTo(background, 1)
		if self.data[natureTabel[i]] > 0 then
			ui.newTTFLabel({text = "+"..self.data[natureTabel[i]],color = ccc3(141, 64, 25),size = 28 })
			:align(display.LEFT_TOP,80 + 28/3*string.len(EQUIP_TYPE_NAME[natureTabel[i]]),435 - (i-1)*30)
			:addTo(background, 1)
		else
			ui.newTTFLabel({text = self.data[natureTabel[i]],color = ccc3(141, 64, 25),size = 28 })
			:align(display.LEFT_TOP,80 + 28/3*string.len(EQUIP_TYPE_NAME[natureTabel[i]]),435 - (i-1)*30)
			:addTo(background, 1)
		end
		
	end

	--简介
	ui.newTTFLabel({text = self.data.desc ,size = 26,align = ui.TEXT_ALIGN_LEFT,color = ccc3(89, 89, 89),
    valign = ui.TEXT_VALIGN_TOP,
    dimensions = CCSize(decBack:getContentSize().width-20, decBack:getContentSize().height*0.8)})
    :align(display.CENTER_TOP,width/2,440 - decBack:getContentSize().height )
    :addTo(background,1)


    --穿戴等级
    local color = self.state == 2 and ccc3(255, 0, 0) or ccc3(40, 109, 8)
    ui.newTTFLabel({text = "需要英灵等级："..self.data.minLevel ,size = 26,color = color,})
    :pos(width/2,120)
    :addTo(background,1)

    --按钮
    -- self.data.composeLine
    local isMulti = false
    for v, k in pairs(self.data.composeLine) do
    	isMulti = true
    	print("hecheng",v,self.data.composeLine[v])
    end
    local string = ""
    if isMulti then
    	string = "合 成 公 式"
    else
    	string = "获 得 途 径"
    end
    if self.state == 2 or self.state == 3 then
    	string = "装 备"
    elseif self.state == 4 or self.state == 5 then
    	string = "确 定"
    end

    local button = PJButton.new({
        normal = display.newScale9Sprite(RES.."public/button_orange.png", 0,0,CCSizeMake(415, 66)),
        text = string,
        color = ccc3(248, 246, 214),
        isAction = "scale",
        callback = function() 

        	local function DelMyself()
        		removeOutAction(self.layer,function (  )
		        	self:removeSelf()
		        end)
        	end 
        	if self.state == 2 then
        		showTip({text  = "等级不足!"}):pos(display.cx,display.cy):addTo(display.getRunningScene(),9999)
        	elseif self.state == 3 then
        		self.dressCallBack()
        		DelMyself()
        	elseif self.state == 4 then
        		DelMyself()
        	else
        		if self.sonBack then
		        	DelMyself()
		        else
		        	self.itemIndex[#self.itemIndex + 1] = self.data.id
		        	self:createSonLayer()
		        	self.mainButton:setButtonLabel("确 定")
		        end
        	end
        end
        })
    :pos(width/2,height*0.1)
    :addTo(background,1)
    self.mainButton = button

    self.mainBack = background
end

function ItemInfoLayer:createSonLayer(  )
	local background = display.newScale9Sprite(RES.."public/bg_white.png",display.cx,display.cy,
		CCSizeMake(460, 614)):addTo(self.layer)
	background:setTouchEnabled(true)
	self.sonBack = background
	transition.moveTo(self.mainBack, {time = 0.1, x = 434})
	transition.moveTo(background, {time = 0.1, x = 908})

	local line = display.newSprite(RES.."hero/hero_zhuangshi.png", 230,520):addTo(background)
	line:setScaleX(420/line:getContentSize().width)

	self:sonItem():pos(0,0):addTo(background,1)

end


function ItemInfoLayer:sonItem()
	if self.sonNode then
		self.sonNode:removeSelf()
		self.sonNode = nil
	end
	local itemSizex = 100
	local background = display.newNode()
	background:setTouchEnabled(true)
	self.sonNode = background
	local initPos = 1
	if #self.itemIndex >= 4 then
		initPos = #self.itemIndex - 3
	end
	for i= initPos,#self.itemIndex do
		print(self.itemIndex[i])
		local data = _G["equipmentCsv"]:getDataById(self.itemIndex[i])
		local item = require("pubui.IconItem").new({quility = data.quality,itemid = self.itemIndex[i]})
		:pos(70 + (i - initPos ) * itemSizex ,555)
		:addTo(background)
		item:setScale(0.55)

		if i == #self.itemIndex then
			local selected = display.newSprite(RES.."public/ui_selected.png")
			:pos(70 + (i - initPos ) * itemSizex ,552)
			:addTo(background,1)
			selected:setScale(70/selected:getContentSize().height)
			selected:setRotation(-90)
		end
		item:setTouchEvent(function (  )
			local isNew = false
			for k = i , #self.itemIndex - 1 do
				table.remove(self.itemIndex)
				isNew = true
			end
			if isNew then
				self:sonItem():pos(0,0):addTo(self.sonBack,1)
			end
		end)

		--箭头
		if i ~= initPos then
			display.newSprite(RES.."armory/armory_arrow.png")
			:pos(25 + (i - initPos ) * itemSizex ,555)
			:addTo(background)
		end
	end
	local nowIndex = self.itemIndex[#self.itemIndex]
	local data =_G["equipmentCsv"]:getDataById(nowIndex)
	local isMulti = false
	local addItem = {}
    for v, k in pairs(data.composeLine) do
    	isMulti = true
    	addItem[#addItem + 1] = v
    end

    if isMulti == true then
    	--合成
    	local isEnough = true
    	ui.newTTFLabel({text = data.name, size = 28,color = ccc3(52, 44, 41) })
		:align(display.CENTER,230,470)
		:addTo(background)
    	local item = require("pubui.IconItem").new({quility = data.quality,itemid = nowIndex})
    	:pos(230,380):addTo(background)


    	--子项目
    	local Lpos = 0
    	if #addItem % 2 == 0  then
    		Lpos = #addItem/2 + 0.5
    	else
    		Lpos = math.ceil(#addItem/2)
    	end

    	--中间的条
    	local line = display.newSprite(RES.."public/ui_line.png")
    	:align(display.RIGHT_CENTER,230,300)
    	:rotation(90)
    	:addTo(background)
    	line:setScaleX(20/line:getContentSize().width)
    	if #addItem > 1 then
    		display.newScale9Sprite(RES.."public/ui_line.png",230,300,CCSizeMake(100 * (#addItem - 1), 3))
    		:addTo(background)
    	end
    	for i=1,#addItem do
    		--线
	    	display.newSprite(RES.."public/ui_linepoint.png",230 + (i-Lpos) * 100 ,295)
	    	:addTo(background)

    		--item
			local itemdata = _G["equipmentCsv"]:getDataById(addItem[i])
			
			local item = require("pubui.IconItem").new({quility = itemdata.quality,itemid = addItem[i]})
			:pos(230 + (i-Lpos) * 100 ,235)
			:addTo(background)
			item:setScale(0.7)
			item:setTouchEvent(function (  )
				print("hahahahah")
				self.itemIndex[#self.itemIndex + 1] = addItem[i]
				self:sonItem():pos(0,0):addTo(self.sonBack,1)
			end)
			
			--数量
			local count 
			if game.master.items[addItem[i]] then
				count = game.master.items[addItem[i]].count
			else
				count = 0
			end
			local richText = RichText:create()
			richText:setSize(CCSizeMake(100, 50))
       		local re1 
			if count < data.composeLine[addItem[i]] then
				isEnough = false
				re1 = RichElementText:create(1,ccc3(250, 0, 0),255,count,"Helvetica",20)
			else
				re1 = RichElementText:create(1,ccc3(52, 44, 41),255,count,"Helvetica",20)
			end
			local re2 = RichElementText:create(1,ccc3(52, 44, 41),255,"/"..data.composeLine[addItem[i]],"Helvetica",20)
			richText:pushBackElement(re1)
			richText:pushBackElement(re2)
       		richText:setPosition(ccp(230 + (i-Lpos) * 100 ,180))
       		richText:addTo(background)
		end

    	--费用
    	ui.newTTFLabel({text = "合成花费："..data.composeCost,color = ccc3(141, 64, 25),size = 28 })
		:pos(230,120)
		:addTo(background, 1)

    	--按钮

    	local button = PJButton.new({
        normal = display.newScale9Sprite(RES.."public/button_orange.png", 0,0,CCSizeMake(415, 66)),
        text = "合 成",
        color = ccc3(248, 246, 214),
        isAction = "scale",
        callback = function() 
        	if isEnough and game.master.gold >= data.composeCost then
        		print("可以合成")
        		self:composeResponse(nowIndex)

        	else
        		if isEnough == true then
        			showTip({text  = "金币不足!"}):pos(display.cx,display.cy):addTo(self,20)
        		else
        			showTip({text  = "合成材料不足!"}):pos(display.cx,display.cy):addTo(self,20)
        		end
        	end
    

        end
        })
	    :pos(230,614*0.1)
	    :addTo(background,1)

        
    else
    	--获取途径
    	ui.newTTFLabel({text = data.name, size = 28,color = ccc3(52, 44, 41) })
		:align(display.CENTER,230,485)
		:addTo(background)

		ui.newTTFLabel({text = "获得途径：", size = 22,color = ccc3(141, 64, 25) })
		:align(display.LEFT_CENTER,35,448)
		:addTo(background)


    	local movedLayer = display.newColorLayer(ccc4(0, 0, 0, 0))
		local itemnum = #data.source
		print(itemnum,"副本数量")
		local size = 100
		movedLayer:setContentSize(CCSizeMake(400,100*itemnum))

		for i=1, itemnum do
			local itemBack = display.newScale9Sprite(RES.."public/bg_whitelight.png", 0,0,CCSizeMake(386, 99) )
			display.newScale9Sprite(RES.."hero/hero_rbutton.png", 0,0,CCSizeMake( 46, 96) )
			:align(display.CENTER_RIGHT,385,52)
			:addTo(itemBack)
			display.newSprite(RES.."hero/hero_rrow.png")
			:align(display.CENTER,365,100/2)
			:addTo(itemBack)

			--副本icon

			--副本章节
			--TODO:精英的区别
			local number = tonumber(string.sub(data.source[i],2,3))
			ui.newTTFLabel({text = "第".. getChinaNumber(number) .."章",size = 24,color = ccc3(141, 64, 25) })
			:align(display.LEFT_CENTER,135,60)
			:addTo(itemBack)
			--副本名称
			local sceneData = sceneCsv:getDataById(data.source[i]) 
			local name = "副本暂缺"
			if sceneData then
				name = sceneData.name
			end
			ui.newTTFLabel({text = name,size = 24,color = ccc3(141, 64, 25) })
			:align(display.LEFT_CENTER,135,30)
			:addTo(itemBack)

			local itemButton = PJButton.new({
	        normal = itemBack,
	        isAction = "scale",
	        callback = function() 
	        	print("去副本xxxx",data.source[i])
	        	-- require("app.scenes.carbon.SceneMapLayer").new({index = data.source[i] }):addTo(display.getRunningScene(),3)
	        	if game.master.lastScene[SCENE_TYPE_COMMON] == data.source[i] or
	        					game.master.sceneProgress[data.source[i]] ~= nil then
                    require("app.scenes.carbon.SceneMapLayer").new({index = data.source[i] }):addTo(display.getRunningScene(),3)
                else
                    showTip({text  = "副本未开启!"}):pos(display.cx,display.cy):addTo(display.getRunningScene(),999)
                end
	        end
	        })
		    :pos(movedLayer:getContentSize().width/2 ,movedLayer:getContentSize().height - size/2 - (i-1)*size)
		    :addTo(movedLayer)

		    itemButton:setTouchSwallowEnabled(false)

		end


		local movebar = CCScrollView:create(CCSizeMake(400,320))
		movebar:setContentSize(CCSizeMake(400, movedLayer:getContentSize().height ))
		movebar:addChild(movedLayer)
		movebar:setPosition(ccp(30, 105))
		movebar:setContentOffset(ccp(0, -movedLayer:getContentSize().height + 320 ))
		movebar:setClippingToBounds(true)
		movebar:setDirection(1)
		movebar:addTo(background,1)

		if itemnum <= 3 then
			movebar:setTouchEnabled(false)
		end


		local button = PJButton.new({
        normal = display.newScale9Sprite(RES.."public/button_orange.png", 0,0,CCSizeMake(415, 66)),
        text = "返 回",
        color = ccc3(248, 246, 214),
        isAction = "scale",
        callback = function() 
        	if #self.itemIndex > 1 then
        		table.remove(self.itemIndex)
        		self:sonItem():pos(0,0):addTo(self.sonBack,1)
        	elseif #self.itemIndex == 1 then
        		table.remove(self.itemIndex)
				transition.moveTo(self.mainBack, {time = 0.1, x = display.cx})
				transition.moveTo(self.sonBack, {time = 0.1, x = display.cx,onComplete = function (  )
					self.sonBack:removeSelf()
					self.sonBack = nil
					self.sonNode = nil
					self.mainButton:setButtonLabel("获 得 途 径")
				end})
        	end

        end
        })
	    :pos(230,614*0.1)
	    :addTo(background,1)
    end


	return background
end

function ItemInfoLayer:composeResponse( index )
	local itemIndex = index
	print(index)
	local bin = pb.encode("HeroComposeRequest", { equipmentId = itemIndex })
   	game:sendData(actionCodes.HeroComposeRequest, bin)
   	game:addEventListener(actionModules[actionCodes.HeroComposeResponse], function(event)
   
      local data = pb.decode("HeroComposeResponse", event.data)
      if data.status == 1000 then
        --刷新数量和金钱
        playUiSound(SOUND_PATH.compose)
        game.master:set_gold(data.gold)
        for i=1,#data.items do
        	game.master:refreshItemInfoByData(data.items[i])
        end
       
		--ui刷新--sonlayer
		self:sonItem():pos(0,0):addTo(self.sonBack,1)
		--mainlayer
		print(game.master.items[self.data.id].count)
		if self.data.id == index then
			self.mainItemCount:setString(game.master.items[self.data.id].count)
		end

		CCNotificationCenter:sharedNotificationCenter():postNotification("REFRESH_HERO_CONTENT")

      elseif data.status == 51 then
      	--todo金币不足
      	showTip({text  = "金币不足!"}):pos(display.cx,display.cy):addTo(self,20)
      elseif data.status == 66 then
      	--todo合成材料不足
      	showTip({text  = "合成材料不足!"}):pos(display.cx,display.cy):addTo(self,20)
      else
      	showTip({text  = "合成 error"..data.status}):pos(display.cx,display.cy):addTo(self,20)
      end
      game:removeEventListenersByTag(EVENT_LISTENER_TAG_HERO_COMPOSE)
   end,EVENT_LISTENER_TAG_HERO_COMPOSE)
end

function ItemInfoLayer:exitFun( )
	self:setTouchEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function ( event )
		if event.name == "ended" then
			removeOutAction(self.layer,function (  )
        		self:removeSelf()
        	end)
		end
		return true
	end)
end


return ItemInfoLayer