
require("config")
require("framework.init")
require("framework.shortcodes")
require("pub.init")
require("utils.init")
require("ErrorCode")
require("protos.init")
require("ProtocolCode")

--socket
local TcpSockets = require("network.TcpSockets")
local SocketActions = require("network.SocketActions")
local scheduler = require("framework.scheduler")

pb = require("protobuf")			--
json = require("framework.json")
audio = require("framework.audio")

GameState = require(cc.PACKAGE_NAME .. ".api.GameState")
GameData = {}
uiData = {}

local gameApp = class("gameApp", cc.mvc.AppBase)

function gameApp:ctor()
    gameApp.super.ctor(self)
    self:initUserDefault()
    self:registerPbFile()

    self.serverList = {}
    self.serverInfo = {}
	self.tcpSocket = nil
	self.master = nil
	self.autoBattle = false

    --前后台检测：
	self:addEventListener(cc.mvc.AppBase.APP_ENTER_BACKGROUND_EVENT, handler(self, self.onEnterBackground))
	self:addEventListener(cc.mvc.AppBase.APP_ENTER_FOREGROUND_EVENT, handler(self, self.onEnterForeground))

	--错误提示：
	-- self:addEventListener(actionModules[actionCodes.SysErrorMsg], handler(self, self.processErrorCode))
end

-- function gameApp:processErrorCode(event)
-- 	local msg = pb.decode("SysErrMsg", event.data)
-- 	print("errCode === ",msg.errCode)
-- 	showMessage({
-- 	    text = tostring(errorCode[tostring(msg.errCode)]),
-- 	    sure = function()
-- 	    	print("erro_code", msg.errCode)
-- 	    end,
--     })
-- end

function gameApp:run()
	CCFileUtils:sharedFileUtils():addSearchPath(device.writablePath .. "res/")
    CCFileUtils:sharedFileUtils():addSearchPath("res/")
    require("csv.CsvLoader").loadCsv()
    --直接进入战斗的调试入口
    if BATTLE_LOCATION then
        switchScene("battle",{battleType = "PVE"})
    else
        switchScene("login")
    end

end

function gameApp:getVersion()
	local args ={}
	local sig = "()Ljava/lang/String;"
	local className = "com/threepj/games/ding/Ding"
	local ok, gameVersion = luaj.callStaticMethod(className, "getVersion", args, sig)
	return gameVersion
end

function gameApp:initUserDefault()
	GameState.init(function(param)
		local returnValue = nil
		if param.errorCode then
			CCLuaLog("error")
		else
			if param.name == "save" then
				local str = json.encode(param.values)
				str = crypto.encryptXXTEA(str, "abcd")
				returnValue = { data = str }
			elseif param.name == "load" then
				local str = crypto.decryptXXTEA(param.values.data, "abcd")
				returnValue = json.decode(str)
			end
		end
		return returnValue 
	end, "default.bin", "threepjgames")

	GameData = GameState.load()
	if not GameData then 
		GameData = {}
		GameData.controlInfo = { musicOn = true, soundOn = true, }
		GameData.masterInfo = {}
		GameState.save(GameData)
	end
	self.musicOn = GameData.controlInfo.musicOn
	self.soundOn = GameData.controlInfo.soundOn
end

function gameApp:newSocket(host, port)
	self.tcpSocket = TcpSockets.new(host, port)
	if not self.tcpSocket or not self.tcpSocket:isReady() then return false end
	self.tcpSocket:addEventListener(TcpSockets.OPEN_EVENT, handler(self, self.onNetOpen))
	self.tcpSocket:addEventListener(TcpSockets.MESSAGE_EVENT, handler(self, self.onNetMessage))
	self.tcpSocket:addEventListener(TcpSockets.CLOSE_EVENT, handler(self, self.onNetClose))
	self.tcpSocket:addEventListener(TcpSockets.ERROR_EVENT, handler(self, self.onNetError))
	return true
end

function gameApp:isConnect()
	if not self.tcpSocket or not self.tcpSocket:isReady() then return false end
	return true
end

function gameApp:closeSocket()
	if self.messageHandler then
		scheduler.unscheduleGlobal(self.messageHandler)
		self.messageHandler = nil
	end
	if self.tcpSocket and self.tcpSocket:isReady() then
		self.tcpSocket:close()
	end
end

function gameApp:onNetOpen(event)
	self.messageHandler = scheduler.scheduleGlobal(
		function () self:sendData(actionCodes.HeartBeat, "") end, 15.0)
end

function gameApp:onNetMessage(event)
	local actionName = actionModules[event.cmd]
	
	if not actionName or actionName == "" then
		print("ERROR_SERVER_INVALID_ACTION", ERROR_SERVER_INVALID_ACTION, actionModuleName, actionMethodName)
		return
	end
	self:dispatchEvent({ name = actionName, data = event.message })	--- 
end

function gameApp:onNetClose(event)
	self:closeSocket()
	CCLuaLog("network disconnect")
end

function gameApp:onNetError(event)
	if event.error == "connection" then
		DGMsg.getInstance():flashShow("网络有问题")
	end
	CCLuaLog("error %s", event.error)
end

--发送数据：
function gameApp:sendData(actionCode, binaray)
	if not self.tcpSocket:isReady() then
		if not self:newSocket(self.serverInfo.host, self.serverInfo.port) then
			self:closeSocket()

			device.showAlert("不妙哦", "网络不给力啊，请重新登录", { "确定", "取消" }, 
				function() switchScene("login", { layer = GameData.user and "login" or "register" }) end)

			return false
		end
		
		local masterId
		if GameData.masterInfo and GameData.masterInfo.masterId then
			masterId = GameData.masterInfo.masterId
		else
			masterId = 0
		end
		local bin = pb.encode("MasterQueryLoginRequest", { masterId = tonumber(masterId) })
		game:sendData(actionCodes.MasterQueryLoginRequest, bin)
		-- local bin = pb.encode("MasterQueryLoginRequest",masterId = tonumber(game.master.id))
		-- self.tcpSocket:send(actionCodes.MasterQueryLoginRequest, bin)
	end

	self.tcpSocket:send(actionCode, binaray)
	return true
end

function gameApp:onEnterForeground(event)
	print("======   1111   =====")
	if self.tcpSocket and self.tcpSocket:isReady() then
		self:sendData(actionCodes.HeartBeat, "")
	else
		self:closeSocket()
		if not self:newSocket(self.serverInfo.host, self.serverInfo.port) then
			self:closeSocket()

			device.showAlert("不妙哦", "网络不给力啊，请重新登录", { "确定", "取消" }, 
				function() switchScene("login", { layer = GameData.user and "login" or "register" }) end)
		end
	end
end


function gameApp:onEnterBackground(event)
	print("===== 22222 ====")
	if self.tcpSocket and self.tcpSocket:isReady() then
		self:sendData(actionCodes.HeartBeat, "")
	end
end


--主要是为了解析GameProtos中各字符串proto模型；
function gameApp:registerPbFile()
	local protoFiles = {"common", "master", "hero","capsule","scene","store","pvp","mail","dailyActivity"}
	local parser = require("pbParser")
	parser.register(protoFiles)
end

function gameApp:loginNow()

   local masterId = LOGIN_USER_ID or GameData.masterInfo.masterId
   print("用户名 ========== ",masterId)
   local bin = pb.encode("MasterLoginRequest", { masterId = masterId})
   game:sendData(actionCodes.MasterLoginRequest, bin)
   game:addEventListener(actionModules[actionCodes.MasterLoginResponse], function(event)

      local data = pb.decode("MasterLoginResponse", event.data)

      if data.status == 1000 then
         game.master = require("datamodel.Master").new(data)

         -- switchScene("home",nil,{style = "fade",time = 0.8, color = ccc3(0, 0, 0)})
      else
         showMessage({
            text = contentByErrorCode(data.status),
            sure = function()end
         })
      end
   game:removeEventListenersByTag(EVENT_LISTENER_TAG_MASTER_LOGIN)
   
   end,EVENT_LISTENER_TAG_MASTER_LOGIN)
end


function gameApp:exit()
	if self.messageHandler then scheduler.unscheduleGlobal(self.messageHandler) end

	self.tcpSocket:close()
	self.tcpSocket = nil

    CCDirector:sharedDirector():endToLua()
    os.exit()
end

function gameApp:exit()
    CCDirector:sharedDirector():endToLua()
    os.exit()
end

return gameApp
