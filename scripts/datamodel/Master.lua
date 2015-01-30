local json = require("framework.json")
local scheduler = require("framework.scheduler")

local Role = class("Role")

Role.pbField = {
	"id", "name", "level", "exp", "health", "gold", "gem", "family", 
	"daemoneStar", "magicRound", "magicCountermark", "element", "faction",
	"magicInherit", "skillPoint", "dailySignDone", "dailySignCounter","sceneLastLineupIds","pictureId",
}

function Role:ctor(pbSource)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	self.heros = {}
	self.items = {}
	self.sceneProgress = {}
	self.lastScene = {}
	self.shopItemJsons = {}
	self.mails = {}
	
	self.iconId = 1 --暂时先用；


	--self.iconId =self.pictureId

	self.serverTime = pbSource.serverTime

	for _, field in pairs(self.class.pbField) do
		-- print("MasterInfo赋值字段 ==== ",field)
		self[field] = pbSource.masterInfo[field]
	end
	
	if pbSource.dailyData then
		print("pbSource.dailyData ",pbSource.dailyData )
		self.dailyData = require("datamodel.MasterDaily").new(pbSource.dailyData)
	end

	for i=1,#pbSource.heros do
        self.heros[pbSource.heros[i].id] = require("datamodel.Hero").new(pbSource.heros[i])
    end

    for i=1,#pbSource.items do
    	-- printf("id == %d , count == %d ",pbSource.items[i].id,pbSource.items[i].count)
	    self.items[pbSource.items[i].id] = require("datamodel.Item").new(pbSource.items[i])
	end

	-- print("pbSource.mails ===== ",pbSource.mails)
	-- print("#pbSource.mails ===== ",#pbSource.mails)
	for i=1,#pbSource.mails do
	    self.mails[pbSource.mails[i].id] = require("datamodel.Mail").new(pbSource.mails[i])
	end

	--TODO 活动副本未处理
	local weekday = tonumber(os.date("%w"))
	local hours = tonumber(os.date("%H"))
	if hours < 5 then
		if weekday ~= 0 then
			weekday = weekday - 1
		elseif weekday == 0 then
			weekday = 6
		end
	end
	if weekday == 0 then weekday = 7 end
    for i=1,#pbSource.sceneProgress do
	    self.sceneProgress[pbSource.sceneProgress[i].id] = require("datamodel.SceneProgress").new(pbSource.sceneProgress[i])
	    local sceneType = self.sceneProgress[pbSource.sceneProgress[i].id]:getSceneType()
	    local chapter = self.sceneProgress[pbSource.sceneProgress[i].id]:getChapter()
	    if self.lastScene[sceneType] == nil then
	    	if sceneType == SCENE_TYPE_ACTIVITY then
	    		local days = dungeonCsv:getDataById(chapter).days[1]
	    		print(days)
	    		for v,k in pairs(days) do
	    			if tonumber(k) == weekday then
	    				self.lastScene[sceneType] = pbSource.sceneProgress[i].id
	    			end
	    		end
		    else
		    	self.lastScene[sceneType] = pbSource.sceneProgress[i].id
		    end
	    elseif self.lastScene[sceneType] < pbSource.sceneProgress[i].id then
	    	if sceneType == SCENE_TYPE_ACTIVITY then
	    		local days = dungeonCsv:getDataById(chapter).days[1]
	    		for v,k in pairs(days) do
	    			if tonumber(k) == weekday then
	    				self.lastScene[sceneType] = pbSource.sceneProgress[i].id
	    			end
	    		end
		    else
		    	self.lastScene[sceneType] = pbSource.sceneProgress[i].id
		    end
	    end
	end


	for i=1,SCENE_TYPE_ACTIVITY do
		if self.lastScene[i] == nil then
			local initScene = i * SCENE_TYPE_RATE/SCENE_CHAPTER_RATE + 1
			if i == SCENE_TYPE_ACTIVITY then
				local days = dungeonCsv:getDataById(initScene).days[1]
				local isTrue = false
	    		for v,k in pairs(days) do
	    			if tonumber(k) == weekday then
	    				isTrue = true
	    			end
	    		end
	    		if isTrue == false then
	    			initScene = i * SCENE_TYPE_RATE/SCENE_CHAPTER_RATE + 2
	    		end
			end
			if dungeonCsv:getDataById(initScene) ~= nil and self.level >= dungeonCsv:getDataById(initScene).level then
				if i == SCENE_TYPE_COMMON then
					self.lastScene[i] = initScene*SCENE_CHAPTER_RATE + 1
				elseif i == SCENE_TYPE_ELITE then
					local commonScene = sceneCsv:getDataById(initScene*SCENE_CHAPTER_RATE + 1).commonScene
					if self.sceneProgress[commonScene] ~= nil and self.sceneProgress[commonScene].star > 0 then
						self.lastScene[i] = initScene*SCENE_CHAPTER_RATE + 1
					end
				elseif i == SCENE_TYPE_ACTIVITY then
					self.lastScene[i] = initScene*SCENE_CHAPTER_RATE + 1
				end
			end
		elseif self.sceneProgress[self.lastScene[i]].star > 0 then
			local lastChapter = math.floor(self.lastScene[i]/SCENE_CHAPTER_RATE)
			if dungeonCsv:getDataById(lastChapter).count ==  self.lastScene[i]%SCENE_CHAPTER_RATE then
				if dungeonCsv:getDataById(lastChapter + 1) ~= nil and self.level >= dungeonCsv:getDataById(lastChapter + 1).level then
					if i == SCENE_TYPE_COMMON then
						self.lastScene[i] = (lastChapter + 1)*SCENE_CHAPTER_RATE + 1
					elseif i == SCENE_TYPE_ELITE then
						local commonScene = sceneCsv:getDataById((lastChapter + 1)*SCENE_CHAPTER_RATE + 1).commonScene
						if self.sceneProgress[commonScene] ~= nil and self.sceneProgress[commonScene].star > 0 then
							self.lastScene[i] = (lastChapter + 1)*SCENE_CHAPTER_RATE + 1
						end
					end
				end
			else
				if i == SCENE_TYPE_COMMON then
					self.lastScene[i] = self.lastScene[i] + 1
				elseif i == SCENE_TYPE_ELITE then
					local commonScene = sceneCsv:getDataById(self.lastScene[i] + 1).commonScene
					if self.sceneProgress[commonScene] ~= nil and self.sceneProgress[commonScene].star > 0 then
						self.lastScene[i] = self.lastScene[i] + 1
					end
				elseif i == SCENE_TYPE_ACTIVITY then
					if sceneCsv:getDataById(self.lastScene[i]+1) ~= nil and self.level >= sceneCsv:getDataById(self.lastScene[i]+1).starLevel then
						self.lastScene[i] = self.lastScene[i] + 1
					end
				end
			end
		end
	end


	if self.sceneLastLineupIds == nil  then
		self.sceneLastLineupIds = {}
	end

	self.activitySceneCount = {} -- 活动副本总打的次数
	for k,v in pairs(self.sceneProgress) do
		if math.floor(k/SCENE_TYPE_RATE) == SCENE_TYPE_ACTIVITY then
			local chapter = math.floor(k/SCENE_CHAPTER_RATE)
			if self.activitySceneCount[chapter] == nil then
				self.activitySceneCount[chapter] = v.count
			else
				self.activitySceneCount[chapter] = self.activitySceneCount[chapter] + v.count 
			end
		end
	end


	-- self.heros = {}          --英灵列表；
	-- self.chooseHeros = {}	 --上阵英灵；
	-- self.items = {}			 --背包；
	-- self.chats = {}			 --聊天内容；
	-- self.guideSubStep = 0    --引导步骤；

	-- -- 处理聊天消息
	-- game:addEventListener(actionModules[actionCodes.ChatReceiveResponse], function(event)
	-- 	local msg = pb.decode("ChatMsg",event.data)
	-- 	self:addChat(msg)
	-- end)

	-- -- 服务端新事件通知
	-- game:addEventListener(actionModules[actionCodes.RoleNotifyNewEvents], function(event)
	-- 	local msg = pb.decode("NewMessageNotify", event.data)

	-- 	for _, event in ipairs(msg.newEvents) do
	-- 		local actionResult
	-- 		if event.value > 0 then
	-- 			actionResult = "add"
	-- 		end

	-- 		self:dispatchEvent({ name = "notifyNewMessage", type = event.key, action = actionResult })
	-- 	end
	-- end)
	

	if display.getRunningScene().name == "LoginScene" then
		--TODO:放这里从loginScene再回来有问题
		game:addEventListener(actionModules[actionCodes.SystemNotify], function(event)
			local msg = pb.decode("SystemNotify", event.data)
			if msg.type=="dailyReset" then
				game:loginNow()
			elseif msg.type=="mail" then
				--TODO:新邮件
			elseif msg.type=="dailyActivity" then
				--TODO:活动推送
			end
		end)

		game:addEventListener(actionModules[actionCodes.MasterUpdatePropertyResponse], function(event)
			local msg = pb.decode("MasterUpdateProperty", event.data)
			self:updateProperty(msg.key, msg.newValue)
		end)
		switchScene("home",nil,{style = "fade",time = 0.8, color = ccc3(0, 0, 0)})
	end

end


-- 更新属性的接口
function Role:updateProperty(property, value)
	local method = self["set_" .. property]
	if type(method) ~= "function" then
        print("ERROR_PROPERTY_SETTING_METHOD", property)
    end

    method(self, value)
end

function Role:reset()
	self:removeAllEventListeners()
	game:removeAllEventListenersForEvent(actionModules[actionCodes.ChatReceiveResponse])
end

function Role:set_level(newLevel)
	if tonumber(newLevel) > self.level  then
		require("app.scenes.hero.heroUpgrade").new({lv1 = self.level ,lv2 = tonumber(newLevel),
			health = uiData.health }):addTo(display.getRunningScene(),40010)
	end
	self.level = tonumber(newLevel)
	-- self:dispatchEvent({name = "updateLevel", level = self.level})
	CCNotificationCenter:sharedNotificationCenter():postNotification("UPDATE_MASTER_LEVEL")

end

function Role:set_exp(newExp)
	self.exp = tonumber(newExp)
	CCNotificationCenter:sharedNotificationCenter():postNotification("UPDATE_MASTER_EXP")
	-- self:dispatchEvent({name = "updateExp", exp = self.exp})
end

function Role:set_health(newHealth)
	self.health = tonumber(newHealth)
	-- self:dispatchEvent({name = "updateHealth", health = self.health})
	CCNotificationCenter:sharedNotificationCenter():postNotification("UPDATE_HEALTH")
end

function Role:set_gold(newMoney)
	self.gold = tonumber(newMoney)
	CCNotificationCenter:sharedNotificationCenter():postNotification("UPDATE_GOLD")
	-- self:dispatchEvent({name = "updateMoney", money = self.gold})
end

function Role:set_gem(newYuanbao)
	self.gem = tonumber(newYuanbao)
	-- self:dispatchEvent({name = "updateYuanbao", yuanbao = self.yuanbao})
	CCNotificationCenter:sharedNotificationCenter():postNotification("UPDATE_DIAMOND")
end

function Role:set_name(newName)
	self.name = tostring(newName)
	self:dispatchEvent({name = "updateName", rolename = self.name})
end

--刷新单个的英灵：有则刷新，无则添加；
function Role:refreshHeroInfoByData(data)
	if type(data) == "table" then
		if self.heros[data.id] then
			self.heros[data.id] = nil
		end
		self.heros[data.id] = require("datamodel.Hero").new(data)
	end
end 

--刷新单个道具：有的刷新，没有添加；
function Role:refreshItemInfoByData(data,isAdd)

	if type(data) == "table" then
		if isAdd then
			if self.items[data.id] then
				self.items[data.id].count =   self.items[data.id].count + data.count

				if self.items[data.id].count == 0 then
					self.items[data.id] = nil
				end
				
			else
				self:addItems(data)
			end
		else

			if self.items[data.id] then
				self.items[data.id] = nil
			end
			if data.count and data.count > 0  then
				self.items[data.id] = require("datamodel.Item").new(data)
			end

		end
		
	end
end 


--刷新指定已存在的英雄的属性：  增加数据
function Role:addHeroInfoByData(data)
    self.heros[data.id] = require("datamodel.Hero").new(data)
end 

--添加英雄
function Role:addHero(data)
	if type(data) == "table" then
		self.heros[data.id] = require("datamodel.Hero").new(data)
	end
end

--更新英雄等级
function Role:updataHeroLevel(data)
	if type(data) == "table" then
		self.heros[data.id].level = data.level
	end
end
--更新英雄当前经验
function Role:updataHeroExp(data)
	if type(data) == "table" then
		self.heros[data.id].exp = data.exp
	end
end

--删除邮件
function Role:delete_mail(mailid)      
	for k, v  in pairs(self.mails) do
		if mailid==v.id then
			self.mails[k]=nil
		end
	end
end


--改变邮件读取状态
function Role:refreshMailState(mailid)      
	for k, v  in pairs(self.mails) do
		if mailid==v.id then
			self.mails[k].readTime=100     --该值大于0 则标志 邮件已读
		end
end
end


--添加道具：
function Role:addItems(data)
	if type(data) == "table" then
		self.items[data.id] = require("datamodel.Item").new(data)
	end
end 
-- 体力购买次数上限
function Role:getMaxHealthBuyCount()
    return #gemHealthCsv
end

-- 金币购买次数上限
function Role:getMaxGoldBuyCount()
	return #gemGoldCsv
end

--御主战力：最高前五个
function Role:getMasterAtk()
	local top5Atk = 0
	local masterAtks = {}
	local heros = {}
	for _, v in pairs(self.heros) do
		masterAtks[#masterAtks + 1] = v
	end
	table.sort(masterAtks,function(a,b) return a.score > b.score end)
	for i=1,#masterAtks do
		if i < 6 then
			top5Atk = top5Atk + masterAtks[i].score
			heros[#heros + 1] = masterAtks[i]
		else
			break
		end
	end
	return top5Atk , heros
end

function Role:updateLastScene(sceneId)
	if self.sceneProgress[sceneId].star > 0 then
		local sceneType = self.sceneProgress[sceneId]:getSceneType()
		if self.lastScene[sceneType] == sceneId then
			local lastChapter = math.floor(sceneId/SCENE_CHAPTER_RATE)
			if sceneType == SCENE_TYPE_COMMON then
				local nextLastScene 
				if self.lastScene[SCENE_TYPE_ELITE] == nil then
					nextLastScene = SCENE_TYPE_ELITE * SCENE_TYPE_RATE  + SCENE_CHAPTER_RATE + 1
				elseif self.sceneProgress[self.lastScene[SCENE_TYPE_ELITE]] ~= nil and self.sceneProgress[self.lastScene[SCENE_TYPE_ELITE]].star > 0  then
					local lastEliteChapter = math.floor(self.lastScene[SCENE_TYPE_ELITE]/SCENE_CHAPTER_RATE)
					if dungeonCsv:getDataById(lastEliteChapter).count ==  self.lastScene[SCENE_TYPE_ELITE]%SCENE_CHAPTER_RATE then
						if dungeonCsv:getDataById(lastEliteChapter + 1) ~= nil and self.level >= dungeonCsv:getDataById(lastEliteChapter + 1).level then
							nextLastScene = (lastEliteChapter + 1)*SCENE_CHAPTER_RATE + 1
						end
					else
						nextLastScene = self.lastScene[SCENE_TYPE_ELITE] + 1
					end
				end
				if nextLastScene ~= nil and sceneCsv:getDataById(nextLastScene).commonScene == sceneId 
					and self.level >= dungeonCsv:getDataById(math.floor(nextLastScene/SCENE_CHAPTER_RATE)).level then
					self.lastScene[SCENE_TYPE_ELITE] = nextLastScene
				end

			end
			
			if dungeonCsv:getDataById(lastChapter).count ==  sceneId%SCENE_CHAPTER_RATE then
				if dungeonCsv:getDataById(lastChapter + 1) ~= nil and self.level >= dungeonCsv:getDataById(lastChapter + 1).level then
					if sceneType == SCENE_TYPE_COMMON then
						self.lastScene[sceneType] = (lastChapter + 1)*SCENE_CHAPTER_RATE + 1
					elseif sceneType == SCENE_TYPE_ELITE then
						local commonScene = sceneCsv:getDataById((lastChapter + 1)*SCENE_CHAPTER_RATE + 1).commonScene
						if self.sceneProgress[commonScene] ~= nil and self.sceneProgress[commonScene].star > 0 then
							self.lastScene[sceneType] = (lastChapter + 1)*SCENE_CHAPTER_RATE + 1
						end
					end
				end
			else
				if sceneType == SCENE_TYPE_COMMON then
					self.lastScene[sceneType] = self.lastScene[sceneType] + 1
				elseif sceneType == SCENE_TYPE_ELITE then
					local commonScene = sceneCsv:getDataById(self.lastScene[sceneType] + 1).commonScene
					if self.sceneProgress[commonScene] ~= nil and self.sceneProgress[commonScene].star > 0 then
						self.lastScene[sceneType] = self.lastScene[sceneType] + 1
					end
				elseif sceneType == SCENE_TYPE_ACTIVITY then
					if sceneCsv:getDataById(self.lastScene[sceneType]+1) ~= nil and self.level >= sceneCsv:getDataById(self.lastScene[sceneType]+1).starLevel then
						self.lastScene[sceneType] = self.lastScene[sceneType] + 1
					end
				end
			end
		end
	end
	self:updateActivitySceneCount()
end

function Role:updateActivitySceneCount()
	for k,v in pairs(self.activitySceneCount) do
		self.activitySceneCount[k] = nil
	end
	for k,v in pairs(self.sceneProgress) do
		if math.floor(k/SCENE_TYPE_RATE) == SCENE_TYPE_ACTIVITY then
			local chapter = math.floor(k/SCENE_CHAPTER_RATE)
			if self.activitySceneCount[chapter] == nil then
				self.activitySceneCount[chapter] = v.count
			else
				self.activitySceneCount[chapter] = self.activitySceneCount[chapter] + v.count 
			end
		end
	end
end

function Role.buyHealth()
    if game.master.dailyData.healthBuytimes >= game.master:getMaxHealthBuyCount() then
        showMessage({
            text = "确定花费".. gemHealthCsv:getDataByCount(game.master.dailyData.healthBuytimes + 1).."钻石购买120体力吗？(今日已购买"..game.master.dailyData.healthBuytimes.."次)",
            sure = function()
                if gemHealthCsv:getDataByCount(game.master.dailyData.healthBuytimes + 1) <= game.master.gem then
                    local bin = pb.encode("SimpleEvent", { masterId = game.master.id, param1 = 1})
                    game:sendData(actionCodes.MasterBuyHealthRequest, bin)
                    game:addEventListener(actionModules[actionCodes.MasterBuyHealthResponse], function(event)

                        local data = pb.decode("BuyHealthResponse", event.data)
                        if data.status == 1000 then
                        	playUiSound(SOUND_PATH.add)
                            game.master.dailyData.healthBuytimes=data.healthBuytimes
                            game.master:set_gem(data.gem)
                            game.master:set_health(data.health)
                        elseif data.status == 49 then
                            showTip({text  = "购买次数上限"}):pos(display.cx,display.cy):addTo(self,20)
                        elseif data.status == 50 then
                            showTip({text  = "钻石不足"}):pos(display.cx,display.cy):addTo(self,20)
                        else
                            showTip({text  = "购买金币 error"..data.status}):pos(display.cx,display.cy):addTo(self,20)
                        end
                    game:removeEventListenersByTag(EVENT_LISTENER_TAG_BUY_HEALTH)
                    end,EVENT_LISTENER_TAG_BUY_HEALTH)
                else
                    showTip({text  = "钻石不足"}):pos(display.cx,display.cy):addTo(self,20)
                end
            end,
            cancel = function () end
        })
    else
        showTip({text  = "购买次数上限!"}):pos(display.cx,display.cy):addTo(self,20)
    end
end


function Role.buyGold()
    if game.master.dailyData.goldBuytimes >= game.master:getMaxGoldBuyCount() then
        showMessage({
            text = "确定花费".. gemGoldCsv:getDataByCount(game.master.dailyData.goldBuytimes + 1).."钻石购买50000金币吗？(今日已购买"..game.master.dailyData.goldBuytimes.."次)",
            sure = function()
                if gemGoldCsv:getDataByCount(game.master.dailyData.goldBuytimes + 1) <= game.master.gem then
                    local bin = pb.encode("SimpleEvent", { masterId = game.master.id, param1 = 1})
                    game:sendData(actionCodes.MasterBuyGoldRequest, bin)
                    game:addEventListener(actionModules[actionCodes.MasterBuyGoldResponse], function(event)
                        local data = pb.decode("BuyGoldResponse", event.data)
                        if data.status == 1000 then

                        	playUiSound(SOUND_PATH.buy)
                            game.master.dailyData.goldBuytimes=data.goldBuytimes
                            game.master:set_gem(data.gem)
                            game.master:set_gold(data.gold)
                        elseif data.status == 49 then
                            showTip({text  = "购买次数上限"}):pos(display.cx,display.cy):addTo(self,20)
                        elseif data.status == 50 then
                            showTip({text  = "钻石不足"}):pos(display.cx,display.cy):addTo(self,20)
                        else
                            showTip({text  = "购买金币 error"..data.status}):pos(display.cx,display.cy):addTo(self,20)
                        end
                   game:removeEventListenersByTag(EVENT_LISTENER_TAG_BUY_GOLD)
                   end,EVENT_LISTENER_TAG_BUY_GOLD)
                else
                    showTip({text  = "钻石不足"}):pos(display.cx,display.cy):addTo(self,20)
                end
            end,
            cancel = function () end
        })
    else
        showTip({text  = "购买次数上限!"}):pos(display.cx,display.cy):addTo(self,20)
    end

end

return Role