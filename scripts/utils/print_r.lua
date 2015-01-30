local print = print
local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next
 
function print_r(root, maxlevel)
	-- 关闭表打印时取消一下几行注释
	-- if true then
	-- 	return
	-- end
	---------------------------
	if maxlevel == nil then maxlevel = 1 end
	local cache = {  [root] = "." }
	local function _dump(t,space,name,level)
		if level <= 0 then return "停止遍历"..maxlevel.."层以下的表" end
		local temp = {}
		for k,v in pairs(t) do
			local key = tostring(k)
			if cache[v] then
				tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
			elseif type(v) == "table" then
				local new_key = name .. "." .. key
				cache[v] = new_key
				tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key, level - 1))
			else
				tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
			end
		end
		return tconcat(temp,"\n"..space)
	end
	print("$$$$$$$$$$$$$$$$$$$$$$$$$".."\n".._dump(root, "","", maxlevel))
end