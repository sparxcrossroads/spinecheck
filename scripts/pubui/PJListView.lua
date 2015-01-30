
local PJListView = class("PJListView",function()
        return display.newNode()
    end)


--[[--

PJListView构建函数

可用参数有：

itemnum  --总数
sizey  -- 垂直距离
sizex  -- 水平距离
countx  -- 水平数量
county  -- 垂直数量
direction  --目前只支持垂直滑动嘿嘿 --1：垂直，2：水平
width  -- 可视宽度
height  -- 可视高度
data   -- 加入item的table
barImage   -- 滑动条
barPointImage --滑动条按钮

@param table params 参数表

]]

function PJListView:ctor(params)

	self.deltaDistan = params.deltaDistan or 0

	local movedLayer = display.newColorLayer(ccc4(255, 0, 0, 0))
	self.movedLayer = movedLayer
	local itemnum = params.itemnum or 0
	local sizey = params.sizey or 0
	local sizex = params.sizex or 0
	local countx = params.countx or 1
	local county = params.county or 1
	local direction = params.direction or 1
    self.haveBar = params.haveBar 
	self.width = params.width or 1
	self.height = params.height or 1
	local data  = params.data or {}
	local barImage =  params.barImage or RES.."bag/bag_barback.png"
	local barPointImage =  params.barPointImage or RES.."bag/bag_barpoint.png"


	local line 
	if direction == 1 then
		line = math.ceil(itemnum/countx)
		movedLayer:setContentSize(CCSizeMake(self.width,sizey * line + 10 ))
		
	elseif direction == 0 then
		line = math.ceil(itemnum/county)
		movedLayer:setContentSize(CCSizeMake(sizex * line + 10, self.height ))
	end


	for i=1,itemnum do
		if data[i] then
			local col = i % countx 
			if col == 0 then
			   col = countx
			end
			local lin = (i - col) / countx + 1
			data[i]
			:pos(sizex * (col - 0.5 ), movedLayer:getContentSize().height - sizey * 0.54 -(sizey *(lin - 1)) )
			:addTo(movedLayer)
		end
	end




	local movebar = CCScrollView:create(CCSizeMake(self.width,self.height))
	movebar:setContentSize(CCSizeMake(movedLayer:getContentSize().width, movedLayer:getContentSize().height ))
	movebar:addChild(movedLayer)
	movebar:setPosition(ccp(0,0))
	movebar:setContentOffset(ccp(-movedLayer:getContentSize().width + self.width,
							 -movedLayer:getContentSize().height + self.height ))
	movebar:setClippingToBounds(true)
	movebar:setDirection(direction)
	movebar:addTo(self)
	self.movebar = movebar


	if self.haveBar==nil then
		self.haveBar=true
	else 
		self.haveBar=false
	end

	if true==self.haveBar then
		self.bar = cc.ui.UISlider.new(display.TOP_TO_BOTTOM, { 
		bar = RES.."bag/bag_barback.png",
		button = RES.."bag/bag_barpoint.png"}, {scale9 = true})
		:setSliderSize(4,self.height)
		:setSliderValue(0)
		:align(display.CENTER_BOTTOM, self.movebar:getPositionX()- 5,  self.movebar:getPositionY() )
		:addTo(self)
		self.bar:setOpacity(0)
	end

    self:touchListener()
end

function PJListView:setBarPos(x, y)
	if true==self.haveBar then
	self.bar:align(display.CENTER_BOTTOM, 
	self.movebar:getPositionX() + x, self.movebar:getPositionY() + y)
	self.bar:setOpacity(0)
	end	
end


function PJListView:setMovePosition(x,y )
	self.movebar:setPosition(ccp(x , y))
	self:setBarPos(-5,0)
end

function PJListView:setMoveScollEnable(bloon)
	self.movebar:setTouchEnabled(bloon)
	self.node:setTouchEnabled(bloon)
end

function PJListView:setContenPosition( x,y )
	self.movebar:setContentOffset(ccp(x , y))
end
function PJListView:getContenPosition( )
	return self.movebar:getContentOffset()
end

function PJListView:setInitContenPosition( )
	self.movebar:setContentOffset(ccp(-self.movedLayer:getContentSize().width + self.width,
							 -self.movedLayer:getContentSize().height + self.height ))
end



function PJListView:touchListener()
	local alldelta = math.abs(-self.movedLayer:getContentSize().height + self.height)
	
	local node = display.newNode():pos(0,0):addTo(self.movebar)
	node:setContentSize(CCSizeMake(self.movedLayer:getContentSize().width,
		self.movedLayer:getContentSize().height))
	self.isBarShow = false
	self.isTouch = false
	local noTouchTime = 0 
    node:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function ( dt )
    	local pos = self.movebar:getContentOffset()
		local delta = pos.y - (-self.movedLayer:getContentSize().height + self.height)
		local value = 0
		if delta >= alldelta then
			value = 100
		elseif delta <= 0 then
			value = 0
		else
			value = delta / alldelta * 100
		end
		if true==self.haveBar then
			self.bar:setSliderValue(value)
		end
		

		if self.isTouch == false then
			noTouchTime = noTouchTime + dt 
			if noTouchTime >= 1 then
               if true==self.haveBar then
               	    transition.fadeTo(self.bar, {time = 0.5, opacity = 0, onComplete = function (  )
				 	self.isBarShow = false
			    	node:unscheduleUpdate()
			      end})

					end
			    end
		else
			noTouchTime = 0
		end
    end)

    node:setTouchEnabled(true)
    node:setTouchSwallowEnabled(false)
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function ( event )
    	if event.name == "began" then
			self.isTouch = true
			if self.isBarShow == false then
				if true==self.haveBar then
					transition.fadeTo(self.bar, {time =0.6, opacity=255,onComplete = function (  )
				
			
				end})
				self.isBarShow = true
				node:scheduleUpdate()

				end
    			
			end
		elseif event.name == "moved" then
			self.isTouch = true
			
		elseif event.name == "ended" then
			self.isTouch = false
		end
		return true
    end)
    self.node = node
end








return PJListView
