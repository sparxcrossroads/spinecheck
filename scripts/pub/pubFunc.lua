FuncsPub = {}

--[[
	****************** 常用的公共方法定义   *************************
]]


--随机种子
function initSeed(seed)
	if device.platform ~= "android" then
		seed = seed or os.time()
		math.randomseed(tonumber(tostring(seed):reverse():sub(1,#tostring(seed))))
	end
end

function contentByErrorCode(errorCode)
	if errorCodes[tostring(errorCode)] then
		return errorCodes[tostring(errorCode)]
	else
		return errorCodes["999"]
	end
end

--时间格式
function getTimeString(seconds,isTwo)
	--"aa:bb:cc"
	local hour = math.floor(seconds / 3600)
	local min = math.floor((seconds - hour * 3600 ) / 60)
	local sec = seconds - hour * 3600 - min * 60

	local string = string.format("%02d:%02d:%02d",hour,min,sec)

	if isTwo then
		if hour == 0 then
			string = string.format("%02d:%02d",min,sec)
		else
			string = string.format("%02d:%02d",hour,min)
		end
	end
	return string
end

--时间格式2
function getTimeWeekString(seconds)
	--xx周，xx天，xx小时，xx分钟

	local hour = math.floor(seconds / 3600)
	local min = math.floor((seconds - hour * 3600 ) / 60)
	local sec = seconds - hour * 3600 - min * 60
	local day = math.floor(hour / 24)
	local week = math.floor(day / 7)


	local string = ""

	if week ~= 0  then
		string = week.."周"
	else
		if day ~= 0 then
			string = day.."天"
		else
			if hour ~= 0 then
				string = hour.."小时"
			else
				if min ~= 0 then
					string = min.."分钟"
				else
					string = sec.."秒"
				end
			end
		end
	end
	return string
end

--中文数字(100以内
function getChinaNumber(num)
	local table = {"","一","二","三","四","五","六","七","八","九","十"}
	local a = math.floor( num / 10)
	local b = num % 10
	local string = table[a+1]..table[11]..table[b+1]
	if a == 0 then
		string = table[b+1]
	elseif a == 1 then
		string = table[11]..table[b+1]
	end
	return string
end

function isFileExistByPath(path)
	local fullname = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
    return CCFileUtils:sharedFileUtils():isFileExist(fullname)
end

--@ steRes:模板; @[color4:纯色 / clipRes:被剪切资源 / node:被剪切node] @isInverted:是否取反
function getShaderNode(params)
	local clip = nil
	local params = params or {}
	local steRes = params.steRes
	local color4 = params.color4
	local clipRes= params.clipRes
	local isInverted = params.isInverted or false
	local node = params.node
	local isFlip = params.isFlip or false

	if params and steRes and (steRes or color4) then

		local sten = CCSprite:create(steRes)
		sten:setFlipX(isFlip)
	    clip = CCClippingNode:create()
	    clip:setStencil(sten)
	    clip:setInverted(isInverted)
	    clip:setAlphaThreshold(0)

	    if color4 then
	    	local flayer = CCLayerColor:create(color4)
		    flayer:setPosition(ccp(-display.cx, -display.cy))
		    clip:addChild(flayer)
	    elseif clipRes then
	    	local sten = CCSprite:create(clipRes)
	    	sten:setPosition(ccp(clip:getContentSize().width/2, clip:getContentSize().height/2))
	    	clip:addChild(sten)

	    elseif node then 
	    	node:setFlipX(isFlip)
	    	node:setPosition(ccp(clip:getContentSize().width/2, clip:getContentSize().height/2))
	    	clip:addChild(node)
	    end
	end
	return clip 
end
